#include <PetFeeder.h>

// Create an instance of the PetFeeder class
PetFeeder feeder;

void setup() {
  // Initialize the feeder
  feeder.begin();
}

void loop() {
  // Check if the button is pressed
  if (digitalRead(BUTTON_PIN) == HIGH) {
    // Dispense one portion of food
    feeder.dispenseFood();
  }
}