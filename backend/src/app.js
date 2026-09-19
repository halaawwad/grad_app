import cors from "cors";
import express from "express";

import { createApiRouter } from "./routes/api.js";
import { createRobotModeBridge } from "./services/robotModeBridge.js";
import { DataStore } from "./store/dataStore.js";

export function createApp() {
  const app = express();
  const store = new DataStore();
  const robotModeBridge = createRobotModeBridge();
  const simulationEnabled = process.env.ENABLE_SIMULATION === "true";

  app.use(cors());
  app.use(express.json());

  app.use("/api", createApiRouter(store, robotModeBridge));

  app.use((err, _req, res, _next) => {
    console.error(err);
    res.status(500).json({ message: "Internal server error" });
  });

  if (simulationEnabled) {
    setInterval(() => {
      store.simulateTick();
    }, 5000).unref();
  }

  return { app, store };
}
