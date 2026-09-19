import { WebSocketServer } from "ws";

export function attachTelemetrySocketServer({ server, store }) {
  const deviceApiKey = process.env.DEVICE_API_KEY ?? "rosecare-device-key";
  const wss = new WebSocketServer({ noServer: true });

  server.on("upgrade", (request, socket, head) => {
    const url = new URL(request.url, "http://localhost");

    if (url.pathname !== "/ws/telemetry") {
      socket.destroy();
      return;
    }

    const receivedKey = url.searchParams.get("deviceKey");
    if (receivedKey !== deviceApiKey) {
      socket.write("HTTP/1.1 401 Unauthorized\r\n\r\n");
      socket.destroy();
      return;
    }

    wss.handleUpgrade(request, socket, head, (ws) => {
      wss.emit("connection", ws, request);
    });
  });

  wss.on("connection", (ws) => {
    ws.send(
      JSON.stringify({
        type: "connected",
        channel: "telemetry",
        message: "Telemetry socket connected"
      })
    );

    ws.on("message", (message) => {
      try {
        const payload = JSON.parse(message.toString());
        const result = store.ingestTelemetry(payload);

        ws.send(
          JSON.stringify({
            type: "telemetry_ack",
            receivedAt: new Date().toISOString(),
            telemetry: result.telemetry,
            moisture: result.moisture,
            robotStatus: result.robotStatus
          })
        );
      } catch (error) {
        ws.send(
          JSON.stringify({
            type: "error",
            message: "Invalid telemetry JSON payload"
          })
        );
      }
    });
  });

  return wss;
}
