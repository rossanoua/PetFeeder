#include "PetFeeder.h"
#include <AccelStepper.h>

// Initialize the stepper motor
AccelStepper stepper(AccelStepper::DRIVER, 8, 9);

PetFeeder::PetFeeder(int stepPin, int dirPin, int enPin, int loadCellDT, int loadCellSCK, int servoPin, int vibroPin, int displayClk, int displayDIO, int buttonPin, int bluetoothRx, int bluetoothTx) {
  _stepPin = stepPin;
  _dirPin = dirPin;
  _enPin = enPin;
  _loadCellDT = loadCellDT;
  _loadCellSCK = loadCellSCK;
  _servoPin = servoPin;
  _vibroPin = vibroPin;
  _displayClk = displayClk;
  _displayDIO = displayDIO;
  _buttonPin = buttonPin;
  _bluetoothRx = bluetoothRx;
  _bluetoothTx = bluetoothTx;
}

void PetFeeder::initialize() {
  // Initialize the pins and libraries
  pinMode(_stepPin, OUTPUT);
  pinMode(_dirPin, OUTPUT);
  pinMode(_enPin, OUTPUT);
  digitalWrite(_enPin, HIGH); // Disable the motor driver by default
  pinMode(_buttonPin, INPUT_PULLUP);
  _loadCell.begin(_loadCellDT, _loadCellSCK);
  _loadCell.set_scale(2000.f); // Adjust this value to match your load cell calibration
  _loadCell.tare();
  _servo.attach(_servoPin);
  _display.setBrightness(0x0f);
  _display.setSegments(displayChars);
  _bluetooth.begin(9600);
  stepper.setMaxSpeed(200);
  stepper.setAcceleration(100);
  stepper.setPins(_stepPin, _dirPin);
}

void PetFeeder::dispenseFood() {
// Calculate the portion size based on the weight
float weight = _loadCell.get_units();
_portionSize = weight / 10.0; // Adjust this value to set the portion size
_display.setNumber(_portionSize);

// Move the stepper motor to dispense the food
digitalWrite(_enPin, LOW);
stepper.moveTo(400); // Adjust this value to set the amount of food dispensed
while (stepper.distanceToGo() != 0) {
stepper.run();
}
digitalWrite(_enPin, HIGH);
}

void PetFeeder::displayWeight(float weight) {
// Display the weight on the 7-segment display
_display.showNumberDecEx(weight * 10, 0b01000000, true);
}

void PetFeeder::vibrate() {
// Vibrate the motor to prevent food from getting stuck
digitalWrite(_vibroPin, HIGH);
delay(100);
digitalWrite(_vibroPin, LOW);
}

void PetFeeder::readBluetooth() {
// Read the command from the Bluetooth module
if (_bluetooth.available() > 0) {
char command = _bluetooth.read();
if (command == '1') {
dispenseFood();
}
}
}