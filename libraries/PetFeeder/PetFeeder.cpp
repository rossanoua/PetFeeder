#include "PetFeeder.h"

PetFeeder::PetFeeder(const PetFeederConfig& config)
  : config(config), buttonPressed(false) {}

void PetFeeder::initialize() {
  pinMode(config.enablePin, OUTPUT);
  pinMode(config.dirPin, OUTPUT);
  pinMode(config.stepPin, OUTPUT);
  pinMode(config.buttonPin, INPUT_PULLUP);
}

void PetFeeder::feed() {
  disableMotor();
  for (int i = 0; i < config.feedAmount; i++) {
    oneRev();
  }
  disableMotor();
}

void PetFeeder::handleButtonPress() {
  if (digitalRead(config.buttonPin) == LOW) {
    buttonPressed = true;
  }
}

void PetFeeder::disableMotor() {
  digitalWrite(config.enablePin, HIGH);
}

void PetFeeder::oneRev() {
  digitalWrite(config.dirPin, HIGH);
  for (int i = 0; i < config.stepsFwr; i++) {
    digitalWrite(config.stepPin, HIGH);
    delayMicroseconds(config.feedSpeed);
    digitalWrite(config.stepPin, LOW);
    delayMicroseconds(config.feedSpeed);
  }
  digitalWrite(config.dirPin, LOW);
  for (int i = 0; i < config.stepsBkw; i++) {
    digitalWrite(config.stepPin, HIGH);
    delayMicroseconds(config.feedSpeed);
    digitalWrite(config.stepPin, LOW);
    delayMicroseconds(config.feedSpeed);
  }
}
