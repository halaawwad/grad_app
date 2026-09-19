import express from "express";
import { SerialPort } from "serialport";

const port = Number(process.env.ROBOT_MODE_BRIDGE_PORT ?? 5001);
const host = process.env.ROBOT_MODE_BRIDGE_HOST ?? "0.0.0.0";
const serialPortPath = process.env.SERIAL_PORT ?? process.env.ROBOT_MODE_SERIAL_PORT ?? "/dev/ttyACM0";
const baudRate = Number(process.env.BAUD_RATE ?? process.env.ROBOT_MODE_BAUD_RATE ?? 9600);

const app = express();

app.use(express.json());

app.get("/health", (_req, res) => {
  res.json({
    status: "ok",
    service: "robot-mode-bridge",
    serialPortPath,
    baudRate
  });
});

app.post("/robot/mode", async (req, res) => {
  const command = String(req.body?.command ?? "");

  if (!["1", "2"].includes(command)) {
    return res.status(400).json({ message: "Command must be 1 or 2" });
  }

  try {
    await sendSerialCommand(command);
    return res.json({
      status: "sent",
      command,
      serialPortPath
    });
  } catch (error) {
    console.error("Failed to forward robot mode command:", error);
    return res.status(500).json({
      message: "Failed to forward robot mode command",
      error: error instanceof Error ? error.message : String(error)
    });
  }
});

app.listen(port, host, () => {
  console.log(`Robot mode bridge listening at http://${host}:${port}`);
});

async function sendSerialCommand(command) {
  const port = new SerialPort({
    path: serialPortPath,
    baudRate,
    autoOpen: false
  });

  await new Promise((resolve, reject) => {
    port.open((error) => {
      if (error) {
        reject(error);
        return;
      }
      resolve();
    });
  });

  try {
    await new Promise((resolve, reject) => {
      port.write(command, (error) => {
        if (error) {
          reject(error);
          return;
        }
        port.drain((drainError) => {
          if (drainError) {
            reject(drainError);
            return;
          }
          resolve();
        });
      });
    });
  } finally {
    await new Promise((resolve) => {
      port.close(() => resolve());
    });
  }
}
