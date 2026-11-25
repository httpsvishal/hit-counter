const http = require("http");
const os = require("os");
const { createClient } = require("redis");

const port = process.env.PORT || 3000;
const redis = createClient({
  url: process.env.REDIS_URL || "redis://localhost:6379",
  password: process.env.REDIS_PASSWORD || undefined,
  disableOfflineQueue: true, // fail fast instead of hanging
});
redis.on("error", (e) => console.error("redis:", e.message));
redis.connect().catch(() => {});

const server = http.createServer(async (req, res) => {
  if (req.url === "/healthz") return res.end("ok");
  if (req.url === "/readyz") {
    res.statusCode = redis.isReady ? 200 : 503;
    return res.end(redis.isReady ? "ready" : "redis not ready");
  }
  if (req.url === "/burn") {
    const end = Date.now() + 50; // 50 ms of CPU
    while (Date.now() < end) {}
    return res.end("burned");
  }
  if (req.url === "/") {
    try {
      const hits = await redis.incr("hits");
      res.setHeader("Content-Type", "application/json");
      return res.end(JSON.stringify({
        message: "hello from hitcounter",
        pod: os.hostname(),
        env: process.env.APP_ENV,
        hits,
      }));
    } catch (e) {
      res.statusCode = 503;
      return res.end("redis unavailable");
    }
  }
  res.statusCode = 404;
  res.end("not found");
});

server.listen(port, () => console.log("listening on", port));

process.on("SIGTERM", () => {
  console.log("SIGTERM: draining");
  server.close(async () => {
    await redis.quit().catch(() => {});
    process.exit(0);
  });
});
