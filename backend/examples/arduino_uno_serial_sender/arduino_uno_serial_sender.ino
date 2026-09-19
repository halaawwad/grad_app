#define TANK_TRIG_PIN A1
#define TANK_ECHO_PIN 6
#define SOIL_MOISTURE_PIN A0

void setup() {
  Serial.begin(9600);

  pinMode(TANK_TRIG_PIN, OUTPUT);
  pinMode(TANK_ECHO_PIN, INPUT);
}

void loop() {
  long tankDistanceCm = readTankDistanceCm();
  int soilMoistureRaw = analogRead(SOIL_MOISTURE_PIN);

  int soilMoisturePercent = map(soilMoistureRaw, 850, 350, 0, 100);
  soilMoisturePercent = constrain(soilMoisturePercent, 0, 100);

  Serial.print("{");
  Serial.print("\"deviceId\":\"arduino-uno-robot\",");
  Serial.print("\"source\":\"arduino-uno\",");
  Serial.print("\"soilMoisture\":");
  Serial.print(soilMoisturePercent);
  Serial.print(",");
  Serial.print("\"soilMoistureRaw\":");
  Serial.print(soilMoistureRaw);
  Serial.print(",");
  Serial.print("\"sprayDistanceCm\":");
  Serial.print(tankDistanceCm);
  Serial.println("}");

  delay(3000);
}

long readTankDistanceCm() {
  digitalWrite(TANK_TRIG_PIN, LOW);
  delayMicroseconds(2);

  digitalWrite(TANK_TRIG_PIN, HIGH);
  delayMicroseconds(10);

  digitalWrite(TANK_TRIG_PIN, LOW);

  long duration = pulseIn(TANK_ECHO_PIN, HIGH, 30000);
  if (duration == 0) {
    return 999;
  }

  return duration * 0.0343 / 2.0;
}
