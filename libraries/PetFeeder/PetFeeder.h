#ifndef PetFeeder_h
#define PetFeeder_h

#include <Servo.h>
#include <TM1637Display.h>
#include <HX711.h>
#include <SoftwareSerial.h>

class PetFeeder {
  public:
    PetFeeder(int stepPin, int dirPin, int enPin, int loadCellDT, int loadCellSCK, int servoPin, int vibroPin, int displayClk, int displayDIO, int buttonPin, int bluetoothRx, int bluetoothTx);
    void initialize();
    void dispenseFood();
    void displayWeight(float weight);
    void vibrate();
    void readBluetooth();

  private:
    int _stepPin;
    int _dirPin;
    int _enPin;
    int _loadCellDT;
    int _loadCellSCK;
    int _servoPin;
    int _vibroPin;
    int _displayClk;
    int _displayDIO;
    int _buttonPin;
    int _bluetoothRx;
    int _bluetoothTx;
    HX711 _loadCell;
    Servo _servo;
    TM1637Display _display;
    SoftwareSerial _bluetooth;
    float _portionSize;
};

#endif
