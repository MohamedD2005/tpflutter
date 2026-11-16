const http = require('node:http');
const path = require('node:path');
const dns = require('node:dns');
const { createReadStream, existsSync, readFileSync } = require('node:fs');
const { MongoClient, ObjectId } = require('mongodb');

const PORT = Number(process.env.PORT || 3000);
const DATABASE_NAME = process.env.MONGO_DATABASE || 'contacts_db';
const DNS_SERVERS = (process.env.DNS_SERVERS || '1.1.1.1')
  .split(',')
  .map((server) => server.trim())
  .filter(Boolean);
const MAX_BODY_BYTES = 8 * 1024 * 1024;
const WEB_ROOT = path.resolve(__dirname, '../build/web');

dns.setServers(DNS_SERVERS);

function getMongoUri() {
  if (process.env.MONGO_URI) return process.env.MONGO_URI;

  try {
    const configPath = path.resolve(__dirname, '../secrets.json');
    const config = JSON.parse(readFileSync(configPath, 'utf8'));
    if (typeof config.MONGO_URI === 'string' && config.MONGO_URI.length > 0) {
      return config.MONGO_URI;
    }
  } catch (_) {
    // The configuration error below is clearer than a file parsing error.
  }

  throw new Error('MONGO_URI is missing. Configure it in ../secrets.json.');
}

function setCorsHeaders(request, response) {
  const origin = request.headers.origin;
  if (origin) {
    let hostname;
    try {
      hostname = new URL(origin).hostname;
    } catch (_) {
      return false;
    }
    if (hostname !== 'localhost' && hostname !== '127.0.0.1') return false;
    response.setHeader('Access-Control-Allow-Origin', origin);
    response.setHeader('Vary', 'Origin');
  }
  response.setHeader('Access-Control-Allow-Methods', 'GET,POST,PUT,DELETE,OPTIONS');
  response.setHeader('Access-Control-Allow-Headers', 'Content-Type');
  response.setHeader('Content-Type', 'application/json; charset=utf-8');
  return true;
}

function sendJson(response, statusCode, value) {
  response.writeHead(statusCode);
  response.end(value === null ? '' : JSON.stringify(value));
}

function serveWeb(pathname, response) {
  let decodedPath;
  try {
    decodedPath = decodeURIComponent(pathname);
  } catch (_) {
    sendJson(response, 400, { error: 'Invalid path.' });
    return;
  }

  const requestedPath = decodedPath === '/' ? '/index.html' : decodedPath;
  const filePath = path.resolve(WEB_ROOT, `.${requestedPath}`);
  if (!filePath.startsWith(`${WEB_ROOT}${path.sep}`) || !existsSync(filePath)) {
    sendJson(response, 404, { error: 'File not found. Build Flutter Web first.' });
    return;
  }

  const contentTypes = {
    '.css': 'text/css; charset=utf-8',
    '.html': 'text/html; charset=utf-8',
    '.ico': 'image/x-icon',
    '.js': 'text/javascript; charset=utf-8',
    '.json': 'application/json; charset=utf-8',
    '.png': 'image/png',
    '.svg': 'image/svg+xml',
    '.wasm': 'application/wasm',
    '.woff': 'font/woff',
    '.woff2': 'font/woff2',
  };
  response.writeHead(200, {
    'Content-Type': contentTypes[path.extname(filePath)] || 'application/octet-stream',
    'Cache-Control': 'no-cache',
  });
  createReadStream(filePath).pipe(response);
}

async function readJson(request) {
  const chunks = [];
  let length = 0;
  for await (const chunk of request) {
    length += chunk.length;
    if (length > MAX_BODY_BYTES) throw new RangeError('Request body is too large.');
    chunks.push(chunk);
  }
  return JSON.parse(Buffer.concat(chunks).toString('utf8'));
}

function validateContact(value) {
  if (!value || typeof value !== 'object' || Array.isArray(value)) {
    return { error: 'Invalid contact.' };
  }
  const { nom, prenom, telephone, email, imageBase64 } = value;
  if (![nom, prenom, telephone].every((field) => typeof field === 'string' && field.trim())) {
    return { error: 'Name, first name, and phone are required.' };
  }
  if (email != null && typeof email !== 'string') return { error: 'Invalid email.' };
  if (imageBase64 != null && typeof imageBase64 !== 'string') {
    return { error: 'Invalid image.' };
  }
  return {
    contact: {
      nom: nom.trim(),
      prenom: prenom.trim(),
      telephone: telephone.trim(),
      email: email?.trim() || null,
      imageBase64: imageBase64 || null,
    },
  };
}

function toClient(document) {
  const { _id, ...contact } = document;
  return { ...contact, _id: _id.toHexString() };
}

async function start() {
  const client = new MongoClient(getMongoUri(), { serverSelectionTimeoutMS: 10000 });
  await client.connect();
  const contacts = client.db(DATABASE_NAME).collection('contacts');

  const server = http.createServer(async (request, response) => {
    if (!setCorsHeaders(request, response)) {
      sendJson(response, 403, { error: 'Origin not allowed.' });
      return;
    }
    if (request.method === 'OPTIONS') {
      sendJson(response, 204, null);
      return;
    }

    const pathname = new URL(request.url, 'http://127.0.0.1').pathname.replace(/\/$/, '');
    if (!pathname.startsWith('/api/')) {
      serveWeb(pathname || '/', response);
      return;
    }
    const match = pathname.match(/^\/api\/contacts(?:\/([a-f\d]{24}))?$/i);
    if (!match) {
      sendJson(response, 404, { error: 'Route not found.' });
      return;
    }

    const id = match[1];
    try {
      if (request.method === 'GET' && !id) {
        const documents = await contacts.find().sort({ prenom: 1, nom: 1 }).toArray();
        sendJson(response, 200, documents.map(toClient));
        return;
      }

      if (request.method === 'POST' && !id) {
        const validation = validateContact(await readJson(request));
        if (validation.error) {
          sendJson(response, 400, { error: validation.error });
          return;
        }
        const result = await contacts.insertOne(validation.contact);
        sendJson(response, 201, { ...validation.contact, _id: result.insertedId.toHexString() });
        return;
      }

      if (id && !ObjectId.isValid(id)) {
        sendJson(response, 400, { error: 'Invalid contact ID.' });
        return;
      }

      if (request.method === 'GET' && id) {
        const document = await contacts.findOne({ _id: new ObjectId(id) });
        sendJson(response, document ? 200 : 404, document ? toClient(document) : { error: 'Contact not found.' });
        return;
      }

      if (request.method === 'PUT' && id) {
        const validation = validateContact(await readJson(request));
        if (validation.error) {
          sendJson(response, 400, { error: validation.error });
          return;
        }
        const result = await contacts.updateOne({ _id: new ObjectId(id) }, { $set: validation.contact });
        sendJson(response, result.matchedCount ? 200 : 404, result.matchedCount ? { ok: true } : { error: 'Contact not found.' });
        return;
      }

      if (request.method === 'DELETE' && id) {
        const result = await contacts.deleteOne({ _id: new ObjectId(id) });
        sendJson(response, result.deletedCount ? 200 : 404, result.deletedCount ? { ok: true } : { error: 'Contact not found.' });
        return;
      }

      sendJson(response, 405, { error: 'Method not allowed.' });
    } catch (error) {
      const status = error instanceof SyntaxError || error instanceof RangeError ? 400 : 500;
      sendJson(response, status, { error: status === 400 ? 'Invalid request body.' : 'Contacts service failed.' });
      console.error(`Contacts API error (${status}):`, error.message);
    }
  });

  server.listen(PORT, '127.0.0.1', () => {
    console.log(`Contacts app and API listening on http://127.0.0.1:${PORT}`);
  });

  const shutdown = async () => {
    server.close();
    await client.close();
  };
  process.on('SIGINT', shutdown);
  process.on('SIGTERM', shutdown);
}

start().catch((error) => {
  console.error(error.message);
  process.exitCode = 1;
});
