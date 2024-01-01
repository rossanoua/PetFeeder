#ifndef PetFeeder_h
#define PetFeeder_h

#include <Arduino.h>

struct PetFeederConfig {
  int enablePin;
  int dirPin;
  int stepPin;
  int feedAmount;
  int buttonPin;
  int stepsFwr;
  int stepsBkw;
  int feedSpeed;
};

class PetFeeder {
public:
  PetFeeder(const PetFeederConfig& config);
  void initialize();
  void feed();
  void handleButtonPress();

private:
  PetFeederConfig config;
  bool buttonPressed;

  void disableMotor();
  void oneRev();
};

#endif
