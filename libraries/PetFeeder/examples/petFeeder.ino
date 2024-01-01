#include <PetFeeder.h>

// Create an instance of the PetFeeder class
PetFeeder feeder;

// #define STEPS_FRW 19        // кроки вперед
// #define STEPS_BKW 12        // кроки назад

void setup() {
  // Initialize the feeder
  feeder.initialize();
}

void loop() {
  // Check if the button is pressed
  if (digitalRead(BUTTON_PIN) == HIGH) {
    // Dispense one portion of food
    feeder.dispenseFood();
  }
}