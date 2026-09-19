import http from "node:http";

import { createApp } from "./app.js";
import { attachTelemetrySocketServer } from "./realtime/telemetrySocketServer.js";

const port = Number(process.env.PORT ?? 4000);
const host = process.env.HOST ?? "0.0.0.0";
const { app, store } = createApp();
const server = http.createServer(app);

attachTelemetrySocketServer({ server, store });

server.listen(port, host, () => {
  console.log(`RoseCare backend running on http://${host}:${port}`);
  console.log(`Telemetry WebSocket ready at ws://${host}:${port}/ws/telemetry`);
});
