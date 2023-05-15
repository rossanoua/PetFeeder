#ifndef PetFeeder_h
#define PetFeeder_h

#include <Arduino.h>
#include <Servo.h>
#include <HX711.h>
#include <TM1637.h>

struct PetFeederConfig {
  int servoPin;
  int hx711DataPin;
  int hx711ClockPin;
  int clkPin;
  int dioPin;
};

class PetFeeder {
public:
  PetFeeder(const PetFeederConfig& config);

  void begin();
  void dispenseFood(int portion);
  void refillFood(int amount);
  float getCurrentFoodWeight();

private:
  Servo servo;
  HX711 hx711;
  TM1637Display display;

  PetFeederConfig config;
  float emptyWeight;
  float currentWeight;

  void moveServo(int angle);
};

#endif