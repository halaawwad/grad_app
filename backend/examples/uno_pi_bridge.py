import json
import os
import time

import requests
import serial

SERIAL_PORT = os.getenv("SERIAL_PORT", "/dev/ttyACM0")
BAUD_RATE = int(os.getenv("BAUD_RATE", "9600"))

API_BASE_URL = os.getenv("API_BASE_URL", "http://192.168.137.183:4000/api")
DEVICE_API_KEY = os.getenv("DEVICE_API_KEY", "rosecare-device-key")

ESP_IP = os.getenv("ESP_IP", "192.168.4.1")
PUMP_ON_SECONDS = int(os.getenv("PUMP_ON_SECONDS", "8"))
DRY_SOIL_THRESHOLD = int(os.getenv("DRY_SOIL_THRESHOLD", "10"))
DRY_COOLDOWN_SECONDS = int(os.getenv("DRY_COOLDOWN_SECONDS", "15"))
LOW_PESTICIDE_DISTANCE_CM = float(os.getenv("LOW_PESTICIDE_DISTANCE_CM", "13"))
REQUEST_TIMEOUT = int(os.getenv("REQUEST_TIMEOUT", "10"))


pump_running = False
last_irrigation_time = 0.0


def clamp(value, min_value, max_value):
    return max(min_value, min(max_value, value))


def post_telemetry(payload):
    response = requests.post(
        f"{API_BASE_URL}/telemetry",
        headers={
            "Content-Type": "application/json",
            "x-device-key": DEVICE_API_KEY,
        },
        json=payload,
        timeout=REQUEST_TIMEOUT,
    )
    response.raise_for_status()
    return response.json()


def forward_sensor_payload(payload):
    response_json = post_telemetry(payload)
    print(
        "Forwarded to backend:",
        response_json["moisture"]["currentPercentage"],
        "% | Pesticide distance:",
        response_json["robotStatus"]["sprayDistanceCm"],
        "| Irrigation:",
        "ON" if response_json["robotStatus"]["irrigationEnabled"] else "OFF",
    )


def send_irrigation_state(is_on):
    payload = {
        "deviceId": "raspberry-pi-irrigation",
        "source": "raspberry-pi-pump",
        "currentAction": "irrigating" if is_on else "idle",
        "irrigationEnabled": is_on,
        "connectionOnline": True,
    }
    post_telemetry(payload)
    print("Backend irrigation state:", "ON" if is_on else "OFF")


def pump_request(path):
    response = requests.get(f"http://{ESP_IP}/{path}", timeout=REQUEST_TIMEOUT)
    response.raise_for_status()
    print("ESP response:", response.text)


def start_pump():
    global pump_running
    pump_request("on")
    pump_running = True
    send_irrigation_state(True)


def stop_pump():
    global pump_running
    pump_request("off")
    pump_running = False
    send_irrigation_state(False)


def maybe_run_irrigation_cycle(soil_moisture):
    global last_irrigation_time

    now = time.time()
    if pump_running:
        print("Pump already running, skipping duplicate DRY trigger")
        return

    if soil_moisture > DRY_SOIL_THRESHOLD:
        return

    if now - last_irrigation_time < DRY_COOLDOWN_SECONDS:
        print("Cooldown active, skipping repeated dry trigger")
        return

    print(
        f"Soil is DRY at {soil_moisture}% -> starting irrigation pump for {PUMP_ON_SECONDS} seconds"
    )

    try:
        start_pump()
        time.sleep(PUMP_ON_SECONDS)
    except Exception as error:
        print("Failed during irrigation cycle:", error)
    finally:
        try:
            stop_pump()
        except Exception as error:
            print("Failed to stop irrigation pump:", error)

        last_irrigation_time = time.time()
        print("Irrigation cycle finished")


def describe_pesticide_tank(distance_cm):
    if distance_cm >= LOW_PESTICIDE_DISTANCE_CM:
        print(
            "Pesticide tank status: LOW | Distance:",
            distance_cm,
            "| Prepare refill",
        )
    else:
        print("Pesticide tank status: OK | Distance:", distance_cm)


def normalize_payload(raw_payload):
    return {
        "deviceId": str(raw_payload.get("deviceId", "arduino-uno-robot")),
        "source": str(raw_payload.get("source", "arduino-uno")),
        "soilMoisture": clamp(int(raw_payload.get("soilMoisture", 0)), 0, 100),
        "soilMoistureRaw": clamp(int(raw_payload.get("soilMoistureRaw", 0)), 0, 1023),
        "sprayDistanceCm": float(raw_payload.get("sprayDistanceCm", 999)),
        "connectionOnline": True,
    }


def build_moisture_payload(moisture_value):
    return {
        "deviceId": "arduino-uno-robot",
        "source": "arduino-uno",
        "soilMoisture": clamp(int(moisture_value), 0, 100),
        "connectionOnline": True,
    }


def main():
    print("Opening serial port:", SERIAL_PORT)

    with serial.Serial(SERIAL_PORT, BAUD_RATE, timeout=2) as ser:
        time.sleep(2)
        print("Unified bridge started. Waiting for Arduino moisture/JSON lines...")

        while True:
            line = ser.readline().decode("utf-8", errors="ignore").strip()
            if not line:
                continue

            print("UNO -> PI:", line)

            try:
                if line.startswith("Moisture:"):
                    moisture_value = int(line.split(":", 1)[1].strip())
                    payload = build_moisture_payload(moisture_value)
                    print(f"Soil Moisture = {payload['soilMoisture']}%")
                    forward_sensor_payload(payload)
                    maybe_run_irrigation_cycle(payload["soilMoisture"])
                    continue

                raw_payload = json.loads(line)
                payload = normalize_payload(raw_payload)
                describe_pesticide_tank(payload["sprayDistanceCm"])
                print(f"Soil Moisture = {payload['soilMoisture']}%")
                forward_sensor_payload(payload)
                maybe_run_irrigation_cycle(payload["soilMoisture"])
            except json.JSONDecodeError:
                print("Skipped invalid line")
            except Exception as error:
                print("Failed to process telemetry:", error)


if __name__ == "__main__":
    main()
