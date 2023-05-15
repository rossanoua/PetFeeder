#include <ArduinoUnit.h>
#include <PetFeeder.h>

test(dispenseFoodTest) {
  // Create a PetFeeder object with the required configuration
  PetFeederConfig config = {
    .servoPin = 9,
    .hx711DataPin = A0,
    .hx711ClockPin = A1,
    .clkPin = 2,
    .dioPin = 3
  };
  PetFeeder feeder(config);

  // Simulate the current weight and target weight
  feeder.currentWeight = 100.0;
  float targetWeight = 80.0;

  // Create a variable to store the mocked servo angle
  int mockedServoAngle = 0;

  // Define the lambda function as the mock for moveServo
  feeder.moveServo = [&mockedServoAngle](int angle) {
    // Store the value of angle in the mockedServoAngle variable
    mockedServoAngle = angle;
  };
//  // Mock the necessary behavior
//  feeder.moveServo = [](int angle) {
//    // Mock moveServo function
//    // You can add your own assertions or checks here if needed
//  };

  // Call the dispenseFood method
  feeder.dispenseFood(20);

  // Check if the current weight has reached the target weight
  assertEqual(feeder.currentWeight, targetWeight);
}

unittest_main()
