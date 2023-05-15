#include <ArduinoUnit.h>
#include "../PetFeeder.h"

PetFeeder feeder;

void setup() {
  // Set up any necessary test fixtures here.
}

void teardown() {
  // Clean up any resources used by the test cases here.
}

// Define test cases using the TEST_CASE macro.
TEST_CASE(PetFeederTest, testDispenseFood) {
  // Test the dispenseFood method.
  feeder.dispenseFood(10);
  ASSERT_EQUAL(feeder.getCurrentFoodWeight(), 90);
}

TEST_CASE(PetFeederTest, testRefillFood) {
  // Test the refillFood method.
  feeder.refillFood(100);
  ASSERT_EQUAL(feeder.getCurrentFoodWeight(), 100);
}
