#include "PetFeeder.h"

PetFeeder::PetFeeder(const PetFeederConfig& config)
    : config(config) {}

void PetFeeder::begin() {
  servo.attach(config.servoPin);
  hx711.begin(config.hx711DataPin, config.hx711ClockPin);
  display.setPin(config.clkPin, config.dioPin);
  display.setBrightness(7);

  emptyWeight = hx711.read();
  currentWeight = emptyWeight;
}

void PetFeeder::dispenseFood(int portion) {
  float targetWeight = emptyWeight - portion;
  while (currentWeight > targetWeight) {
    moveServo(180);
    moveServo(0);
    currentWeight = hx711.read();
    display.showNumberDec(currentWeight);
    delay(500);
  }
}

void PetFeeder::refillFood(int amount) {
  emptyWeight += amount;
}

float PetFeeder::getCurrentFoodWeight() {
  return currentWeight;
}

void PetFeeder::moveServo(int angle) {
  servo.write(angle);
  delay(15);
}
