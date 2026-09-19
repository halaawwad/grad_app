import { SerialPort } from "serialport";

const DEFAULT_HTTP_URL = "http://127.0.0.1:5001/robot/mode";

function normalizeMode(mode) {
  if (mode === "indoor" || mode === "1" || mode === 1) {
    return { mode: "indoor", command: "1" };
  }

  if (mode === "outdoor" || mode === "2" || mode === 2) {
    return { mode: "outdoor", command: "2" };
  }

  throw new Error("Unsupported robot mode");
}

export function createRobotModeBridge() {
  const transport = (process.env.ROBOT_MODE_TRANSPORT ?? "http").toLowerCase();
  const raspberryUrl = process.env.ROBOT_MODE_PI_URL ?? DEFAULT_HTTP_URL;
  const serialPortPath = process.env.ROBOT_MODE_SERIAL_PORT ?? process.env.SERIAL_PORT;
  const baudRate = Number(process.env.ROBOT_MODE_BAUD_RATE ?? process.env.BAUD_RATE ?? 9600);

  return {
    async sendMode(targetMode) {
      const normalized = normalizeMode(targetMode);

      if (transport === "serial") {
        if (!serialPortPath) {
          throw new Error("ROBOT_MODE_SERIAL_PORT is not configured");
        }

        await sendSerialCommand(serialPortPath, baudRate, normalized.command);
        return {
          ...normalized,
          transport: "serial",
          destination: serialPortPath
        };
      }

      await sendHttpCommand(raspberryUrl, normalized);
      return {
        ...normalized,
        transport: "http",
        destination: raspberryUrl
      };
    }
  };
}

async function sendHttpCommand(url, normalized) {
  const response = await fetch(url, {
    method: "POST",
    headers: {
      "Content-Type": "application/json"
    },
    body: JSON.stringify({
      mode: normalized.mode,
      command: normalized.command
    })
  });

  if (!response.ok) {
    const body = await response.text();
    throw new Error(`Raspberry bridge rejected mode command (${response.status}): ${body}`);
  }
}

async function sendSerialCommand(path, baudRate, command) {
  const port = new SerialPort({
    path,
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
