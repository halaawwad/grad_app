# RoseCare AI Backend

`Node.js + Express` backend for the Flutter app and the real robot telemetry flow.

## 1. Run The Backend

```powershell
cd D:\grad_app\backend
copy .env.example .env
npm install
```

Then open `.env` and set:

```env
PORT=4000
DEVICE_API_KEY=rosecare-device-key
ENABLE_SIMULATION=false
ADMIN_EMAIL=awwadh311@gmail.com
ADMIN_PASSWORD=hala1234
```

Now start the real backend:

```powershell
npm run dev
```

For demo-only simulated values:

```powershell
npm run start:demo
```

The API runs on:

`http://localhost:4000/api`

## 2. Admin Login

The admin login is now read from `.env`:

- `ADMIN_EMAIL`
- `ADMIN_PASSWORD`

Default values in `.env.example` are:

- Email: `awwadh311@gmail.com`
- Password: `hala1234`

## 3. Main App Endpoints

- `POST /api/auth/login`
- `GET /api/health`
- `GET /api/dashboard`
- `GET /api/robot-status`
- `GET /api/moisture`
- `GET /api/alerts`
- `PATCH /api/alerts/mark-all-read`
- `GET /api/history?filter=all|spray|irrigation|alerts|moisture`
- `GET /api/settings`
- `PATCH /api/settings`
- `POST /api/robot/start`
- `POST /api/robot/stop`
- `POST /api/robot/spray`
- `POST /api/robot/irrigate`

## 4. Real Robot Telemetry

You now have both:

- `POST /api/telemetry`
- `WS /ws/telemetry`

### HTTP option

- `POST /api/telemetry`

Required header:

```http
x-device-key: rosecare-device-key
Content-Type: application/json
```

Example payload:

```json
{
  "deviceId": "esp32-rosecare",
  "source": "esp32",
  "soilMoisture": 42,
  "soilMoistureRaw": 620,
  "temperature": 25,
  "humidity": 59,
  "batteryLevel": 87,
  "waterTankLevel": 64,
  "sprayTankLevel": 58,
  "connectionOnline": true
}
```

Current telemetry status can be checked from:

- `GET /api/telemetry/status`
- `GET /api/telemetry/socket-info`

### WebSocket option

WebSocket URL format:

```text
ws://YOUR_BACKEND_IP:4000/ws/telemetry?deviceKey=rosecare-device-key
```

Send JSON messages in the same shape as the HTTP payload.

The backend replies with a `telemetry_ack` message after each valid packet.

## 5. Arduino Uno -> Raspberry Pi -> Backend

This is the recommended path if your moisture sensor is connected to `Arduino Uno A0`.

The flow is:

`Arduino Uno -> Serial -> Raspberry Pi -> Backend -> Flutter app`

Ready files:

- [backend/examples/arduino_uno_serial_sender/arduino_uno_serial_sender.ino](D:\grad_app\backend\examples\arduino_uno_serial_sender\arduino_uno_serial_sender.ino)
- [backend/examples/uno_pi_bridge.py](D:\grad_app\backend\examples\uno_pi_bridge.py)

### Step A: Upload the Uno sketch

Your sensor stays on:

```cpp
const int moisturePin = A0;
```

If your moisture sensor is on another analog pin, change:

```cpp
const int moisturePin = A0;
```

If your calibration is different, change:

```cpp
int soilPercent = map(raw, 850, 350, 0, 100);
```

The values `850` and `350` are dry/wet bounds for your sensor.

### Step B: Run the serial bridge on Raspberry Pi or laptop

Install dependencies:

```bash
pip3 install requests pyserial
```

Use this file:

- [backend/examples/uno_pi_bridge.py](D:\grad_app\backend\examples\uno_pi_bridge.py)

Edit these values only:

```python
SERIAL_PORT = os.getenv("SERIAL_PORT", "/dev/ttyACM0")
BAUD_RATE = int(os.getenv("BAUD_RATE", "9600"))
API_BASE_URL = os.getenv("API_BASE_URL", "http://127.0.0.1:4000/api")
DEVICE_API_KEY = os.getenv("DEVICE_API_KEY", "rosecare-device-key")
```

Replace:

- `/dev/ttyACM0` -> your real Arduino port on the Raspberry Pi
- `rosecare-device-key` -> same key from backend `.env`
- `127.0.0.1` -> backend machine IP if needed

Then run:

```bash
python3 uno_pi_bridge.py
```

## 6. How The Full Flow Works

1. Robot device sends telemetry to `POST /api/telemetry`
2. Backend updates robot status, moisture, alerts, and history
3. Flutter app fetches the latest data from the backend
4. The dashboard updates with the real values

## 7. Moisture Sensor Test Only

If you only want to test soil moisture first, the important values are:

```json
{
  "deviceId": "arduino-uno-robot",
  "source": "arduino-uno",
  "soilMoisture": 36,
  "soilMoistureRaw": 690,
  "temperature": 25,
  "humidity": 60,
  "batteryLevel": 90,
  "waterTankLevel": 70,
  "sprayTankLevel": 65,
  "connectionOnline": true
}
```

As soon as this reaches the backend, the Flutter app will show the new moisture value because it already refreshes from the backend periodically.

## 8. Exact Next Step For You

If you want the fastest real setup:

1. Run backend with:
   `npm run dev`
2. Keep `ENABLE_SIMULATION=false`
3. Upload the Uno sketch
4. Connect Uno to the Raspberry Pi by USB
5. Edit only these values in `uno_pi_bridge.py`:
   - serial port
   - backend URL
   - device key
6. Run the bridge
7. Open:
   `http://localhost:4000/api/telemetry/status`

If the values there change, the app is already wired correctly.
