#include <ArduinoUnitTests.h>
#include <PetFeeder.h>

const int ENABLE_PIN = 2;
const int DIR_PIN = 3;
const int STEP_PIN = 4;
const int FEED_AMOUNT = 3;
const int BUTTON_PIN = 5;
const int STEPS_FRW = 19;        // кроки вперед
const int STEPS_BKW = 12;        // кроки назад

PetFeederConfig config = {
  .enablePin = ENABLE_PIN,
  .dirPin = DIR_PIN,
  .stepPin = STEP_PIN,
  .feedAmount = FEED_AMOUNT,
  .buttonPin = BUTTON_PIN,
  .stepsFwr = STEPS_FRW,
  .stepsBkw = STEPS_BKW,
  .feedSpeed = 3000
  };

PetFeeder petFeeder(config);

unittest_setup() {
  // Set up any necessary initialization for the tests
  petFeeder.initialize();
}

unittest_teardown() {
  // Clean up any resources after the tests
}

unittest(testInitialize) {
  assertEqual(OUTPUT, pinMode_called[ENABLE_PIN]);
  assertEqual(OUTPUT, pinMode_called[DIR_PIN]);
  assertEqual(OUTPUT, pinMode_called[STEP_PIN]);
  assertEqual(INPUT_PULLUP, pinMode_called[BUTTON_PIN]);
}

unittest(testFeed) {
  petFeeder.feed();

  assertEqual(HIGH, digitalWrite_called[ENABLE_PIN]);
  assertEqual(HIGH, digitalWrite_called[ENABLE_PIN]);
  assertEqual(STEPS_FRW * FEED_AMOUNT + STEPS_BKW * FEED_AMOUNT, digitalWrite_called[STEP_PIN]);
  assertEqual(STEPS_FRW * FEED_AMOUNT + STEPS_BKW * FEED_AMOUNT, delayMicroseconds_called);
  assertEqual(HIGH, digitalWrite_called[STEP_PIN]);
  assertEqual(STEPS_FRW * FEED_AMOUNT + STEPS_BKW * FEED_AMOUNT + 1, digitalWrite_called[STEP_PIN]);
}

unittest(testHandleButtonPress) {
  // Simulate button press
  simulateDigitalRead(BUTTON_PIN, LOW);
  petFeeder.handleButtonPress();
  assertEqual(true, petFeeder.buttonPressed);

  // Simulate button release
  simulateDigitalRead(BUTTON_PIN, HIGH);
  petFeeder.handleButtonPress();
  assertEqual(false, petFeeder.buttonPressed);
}

unittest_main()
