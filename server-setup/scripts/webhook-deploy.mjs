import { execFile } from "node:child_process";
import { createHmac, timingSafeEqual } from "node:crypto";
import { readFileSync } from "node:fs";
import { createServer } from "node:http";

const PORT = 9000;
const DEPLOY_SCRIPT = "/opt/dryads-bot/deploy.sh";

// Load webhook secret from .env
let WEBHOOK_SECRET = process.env.GITHUB_WEBHOOK_SECRET || "";
if (!WEBHOOK_SECRET) {
  try {
    const env = readFileSync("/opt/dryads-bot/.env", "utf8");
    const match = env.match(/^GITHUB_WEBHOOK_SECRET=(.+)$/m);
    if (match) {
      WEBHOOK_SECRET = match[1].replace(/['"]/g, "");
    }
  } catch {}
}

let deploying = false;

function verifySignature(payload, signature) {
  if (!WEBHOOK_SECRET || !signature) {
    return false;
  }
  const expected = "sha256=" + createHmac("sha256", WEBHOOK_SECRET).update(payload).digest("hex");
  try {
    return timingSafeEqual(Buffer.from(expected), Buffer.from(signature));
  } catch {
    return false;
  }
}

const server = createServer((req, res) => {
  if (req.method !== "POST" || req.url !== "/webhook/deploy") {
    res.writeHead(404);
    res.end("Not Found");
    return;
  }

  const chunks = [];
  req.on("data", (chunk) => chunks.push(chunk));
  req.on("end", () => {
    const body = Buffer.concat(chunks);
    const signature = req.headers["x-hub-signature-256"] || "";

    if (WEBHOOK_SECRET && !verifySignature(body, signature)) {
      console.log(`[${new Date().toISOString()}] Webhook: invalid signature`);
      res.writeHead(401);
      res.end("Unauthorized");
      return;
    }

    let payload;
    try {
      payload = JSON.parse(body.toString());
    } catch {
      res.writeHead(400);
      res.end("Bad Request");
      return;
    }

    // Only deploy on push to main
    if (payload.ref !== "refs/heads/main") {
      res.writeHead(200);
      res.end(JSON.stringify({ ok: true, skipped: true, reason: "not main branch" }));
      return;
    }

    if (deploying) {
      res.writeHead(429);
      res.end(JSON.stringify({ ok: false, error: "deploy already in progress" }));
      return;
    }

    deploying = true;
    console.log(
      `[${new Date().toISOString()}] Webhook: deploying ${payload.after?.slice(0, 7)}...`,
    );

    res.writeHead(202);
    res.end(JSON.stringify({ ok: true, deploying: true }));

    execFile("bash", [DEPLOY_SCRIPT], { timeout: 300_000 }, (err, stdout, stderr) => {
      deploying = false;
      if (err) {
        console.error(`[${new Date().toISOString()}] Deploy failed:`, err.message);
        if (stderr) {
          console.error(stderr);
        }
      } else {
        console.log(`[${new Date().toISOString()}] Deploy completed`);
      }
    });
  });
});

server.listen(PORT, "127.0.0.1", () => {
  console.log(`Webhook listener on 127.0.0.1:${PORT}`);
});
