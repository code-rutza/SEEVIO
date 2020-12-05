#define echoPin 4 // D2
#define trigPin 5 // D1
#define buzzerPin 15 // D8

const int lowerLimit = 30;
const int upperLimit = 200;
const int tooClose = 100;

volatile int failsafe = 0;

void setup() {
  pinMode(trigPin, OUTPUT);
  pinMode(echoPin, INPUT);
  pinMode(buzzerPin, OUTPUT);
  Serial.begin(9600);
}

int getDistance() {
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
  digitalWrite(buzzerPin, HIGH);
  delay(200);
  digitalWrite(buzzerPin, LOW);
}

void checkDistance(int distance) {
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
