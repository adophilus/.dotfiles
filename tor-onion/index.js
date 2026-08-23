// tor-onion/index.js — "hello world" for hosting on Tor.
//
// Serves one page: what this server can (and cannot) see about its visitor.
// Pure Node, zero dependencies — the nix config runs this file directly from
// the store, where there is no node_modules. Binds 127.0.0.1 only: the ONLY
// way in is through the onion service (tor forwards 127.0.0.1:3000 → the
// .onion address).
const http = require("http");

const PORT = 3000;

// The page echoes attacker-controllable input (headers). Escape it —
// same rule as any clearnet app; anonymity of transport doesn't make XSS
// okay.
const esc = (s) =>
  String(s)
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;");

const page = (method, url, headers) => {
  const rows = Object.entries(headers)
    .map(([k, v]) => [k.toLowerCase(), Array.isArray(v) ? v.join(", ") : v])
    .sort(([a], [b]) => a.localeCompare(b))
    .map(
      ([k, v]) =>
        `<tr><td class="k">${esc(k)}</td><td class="v">${esc(v)}</td></tr>`,
    )
    .join("\n");

  return `<!doctype html>
<html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>hello, onion</title>
<style>
  :root { color-scheme: dark; }
  body {
    background: #0e0e12; color: #d8d8e0;
    font: 15px/1.6 ui-monospace, "JetBrains Mono", monospace;
    max-width: 46rem; margin: 2.5rem auto; padding: 0 1rem;
  }
  h1 { font-size: 1.4rem; margin-bottom: 0.25rem; }
  .sub { color: #7a7a90; margin-bottom: 2rem; }
  h2 { font-size: 1rem; margin: 1.75rem 0 0.5rem; color: #9fe8c1; }
  table { border-collapse: collapse; width: 100%; }
  td { border: 1px solid #26262e; padding: 0.35rem 0.6rem; vertical-align: top; }
  td.k { color: #8ab4ff; white-space: nowrap; width: 11rem; }
  td.v { word-break: break-all; }
  .no { border: 1px dashed #44445a; padding: 0.9rem 1.1rem; margin-top: 0.5rem; }
  .no td { border: none; padding: 0.15rem 0.6rem 0.15rem 0; }
  .void { color: #ff9f68; }
  footer { margin-top: 2.5rem; color: #55556a; font-size: 0.8rem; }
</style>
</head>
<body>
<h1>hello, onion 👋</h1>
<p class="sub">You reached this page through a 56-character address that is a public key. Nothing here knows where you came from.</p>

<h2>▸ what your browser chose to tell me</h2>
<table>${rows}</table>
<p class="sub">${esc(method)} ${esc(url)}</p>

<h2>▸ what I cannot know</h2>
<table class="no">
<tr><td class="k">your IP address</td><td class="void">∅ — onion services receive no client IP. There is no socket peer to read.</td></tr>
<tr><td class="k">your country</td><td class="void">∅</td></tr>
<tr><td class="k">X-Forwarded-For</td><td class="void">∅ — note its absence above. On clearnet, every reverse proxy injects it. Tor's rendezvous never does.</td></tr>
<tr><td class="k">your DNS lookups</td><td class="void">∅ — you never resolved anything to get here; the .onion name IS the address.</td></tr>
</table>

<footer>
served from a laptop behind home NAT, location undisclosed.<br>
no port was opened, no registrar was paid, no certificate was issued —<br>
the address is the key, the key is the address.
</footer>
</body>
</html>`;
};

http
  .createServer((req, res) => {
    console.log(`${new Date().toISOString()} ${req.method} ${req.url}`);
    res.writeHead(200, { "Content-Type": "text/html; charset=utf-8" });
    res.end(page(req.method, req.url, req.headers));
  })
  .listen(PORT, "127.0.0.1", () => {
    console.log(`onion demo backend on 127.0.0.1:${PORT}`);
  });
