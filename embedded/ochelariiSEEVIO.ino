/**
 * @file ochelariiSEEVIO.ino
 * @author @davidp-ro | Team code_rutza @ PoliHack
 * @brief Code for ESP that's used for the glasses [MVP version :)]
 * @version 1.0
 * @date 2020-12-05
 * 
 * @copyright GNU GPL v3 License
 */

#define echoPin 4 // D2
#define trigPin 5 // D1
#define buzzerPin 15 // D8

// In cm:
const int lowerLimit = 30;
const int upperLimit = 200;
const int tooClose = 100;

// Prevent "mis-beeps"
volatile int failsafe = 0;

void setup() {
  pinMode(trigPin, OUTPUT);
  pinMode(echoPin, INPUT);
  pinMode(buzzerPin, OUTPUT);
  Serial.begin(9600);
}

int getDistance() {
  /**
   * @brief Get the distance from the HC-SR04
   * 
   * @returns the distance in cm
   */
  long duration;
  int distance;
  
  digitalWrite(trigPin, LOW);
  delayMicroseconds(2);
  digitalWrite(trigPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);
  duration = pulseIn(echoPin, HIGH);
  distance = duration * 0.034 / 2;

  return distance;
}

void beep() {
  /**
   * @brief Well... beep :) 
   */
  digitalWrite(buzzerPin, HIGH);
  delay(200);
  digitalWrite(buzzerPin, LOW);
}

void checkDistance(int distance) {
  /**
   * @brief Check if the social distance is respected and if it's not notify the user
   * 
   * @param distance Distance from the sensor
   */
  if (distance < tooClose) {
    if (failsafe > 5) {
      Serial.println("Distantareeeaaa");
      failsafe = 0;
      beep();
    } else {
      Serial.println("Dista... not yet");
      failsafe++;
    }
  } else {
    Serial.print("Ok d= ");
    Serial.print(distance);
    Serial.println(" cm");  
  }
}

void loop() {
  int d = getDistance();

  if (d < lowerLimit) {
    Serial.println("Too close, wait");
    delay(2000);
  } else if (d > upperLimit) {
    Serial.println("Too far or error, wait");
    delay(2000);
  } else {
    checkDistance(d);
  }
}
