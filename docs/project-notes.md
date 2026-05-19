# PetFeeder / AiPetFeeder project notes

> Notes from discussion about restarting the PetFeeder idea and turning it into a more structured AiPetFeeder project.

## General idea

The project idea is an automatic pet feeder, mainly for cats. The intended new project name is **AiPetFeeder**.

The old GitHub repository is:

- `rossanoua/PetFeeder`

The current repo should be treated mostly as an early prototype / source of ideas. A new clean repository may make more sense for the next implementation.

## Existing repository findings

The old repository contains an Arduino library skeleton for a pet feeder.

The `README.md` describes the following hardware idea:

- Arduino Uno
- Stepper motor NEMA17 17HS4401
- Auger inside a plastic tube to push food
- Vibration motor to prevent food from getting stuck
- TM1637 4-digit 7-segment display
- Button to dispense one portion
- Load cell / tension sensor + HX711 to measure weight
- HC-06 Bluetooth module for configuration
- Inspiration from GyverFeed2

The `dev` branch contains GitHub Actions workflow for Arduino unit tests:

- `.github/workflows/petfeeder-tests.yml`
- Uses Ruby and `arduino_ci`
- Runs tests from `libraries/PetFeeder`

The library metadata contains:

- `name=PetFeeder`
- `architectures=avr,esp8266`
- `includes=PetFeeder.h`
- `depends=HX711,AccelStepper,TM1637`

## Initial technical conclusion

The old project is not a complete feeder implementation. It looks like:

- Arduino library skeleton
- early hardware concept
- first attempt to add CI tests

It may be faster and cleaner to start a new implementation rather than continue the old code directly.

## Recommended direction

For a new MVP, prefer:

- ESP32 instead of Arduino Uno
- Wi-Fi / local API / Home Assistant support
- Stepper motor for food dosing
- HX711 + load cell for portion control
- Anti-jam logic
- Optional display and button

Bluetooth HC-06 is probably not needed if ESP32 is used.

## Core MVP

Minimum useful prototype:

1. Dispense one portion by button.
2. Dispense one portion via API / Home Assistant.
3. Measure bowl or output weight using HX711 + load cell.
4. Stop dispensing when target weight is reached.
5. Detect possible jam by timeout / missing weight change / motor behavior.
6. Try anti-jam sequence: reverse stepper, vibrate, retry.

## Motor discussion

There was confusion between servo and stepper motor.

For this project, the important motor is the **stepper motor** driving the auger.

### NEMA17

NEMA17 is still the safest option for the first working prototype.

Reasons:

- Good torque reserve
- Common and easy to mount
- Works well with auger mechanics
- Easy to control dosing by steps
- Allows reverse motion for anti-jam

A full-size NEMA17 such as 17HS4401 may be slightly large, but it is a good first choice because food can jam or compact inside the tube.

### Smaller motor options

Possible alternatives:

- Shorter NEMA17, for example 34 mm or 40 mm body length
- NEMA14 if the auger is small and friction is low
- 28BYJ-48 only for very light tests, not recommended for final feeder mechanics

Recommended approach:

1. Start with NEMA17.
2. Test real food with the auger.
3. If torque is clearly excessive, move to shorter NEMA17 or NEMA14.

## Mechanical concept

Recommended first mechanical test module:

- Stepper mount
- Auger tube
- Auger
- Output nozzle
- Simple test hopper

Do not start with the full finished case. First validate the feeding mechanism.

Questions to validate with the first print:

- Does the food move reliably?
- Does it jam?
- Is the portion reasonably repeatable?
- Is vibration needed?
- What auger diameter and pitch work best?
- Is the selected stepper strong enough?

## 3D modeling discussion

Blender is not the best main tool for this project. It is better for visual/organic modeling and renders.

For mechanical parts, use CAD / parametric modeling.

Recommended tools:

### OpenSCAD

Good for simple parametric mechanical parts and GitHub workflow.

Pros:

- Text-based
- Easy to version in Git
- Good for reproducible STL generation
- Good fit for brackets, mounts, tubes, simple enclosures

### FreeCAD

Good free CAD option for more complex mechanical parts.

Pros:

- Parametric CAD
- Better for exact dimensions, sketches, constraints
- Can export STL / STEP
- Good for cases, covers, brackets, load cell mounts

### Blender

Useful later for:

- Visual design
- Renders
- Marketing images
- Cosmetic body shapes

But not recommended as the primary CAD tool for motor mounts, load cell brackets, screw holes, and auger mechanism.

## Suggested next steps

1. Keep this old repo as reference or archive.
2. Create a new clean repository named `aipetfeeder`.
3. Define MVP hardware list.
4. Create first OpenSCAD model for auger test module.
5. Print and test with real cat food.
6. Only after mechanical validation, design the full enclosure.

## Possible new project structure

```text
hardware/
  cad/
    openscad/
    freecad/
  stl/
  bom.md
firmware/
  platformio/
  esphome/
docs/
  project-notes.md
  architecture.md
  mechanical-tests.md
  wiring.md
```

## Important product direction

The competitive advantage should probably not be just "another automatic feeder".

The stronger direction is:

- open-source
- local-first
- Home Assistant friendly
- no mandatory cloud
- API controllable
- serviceable / printable parts

This can differentiate AiPetFeeder from many closed commercial smart feeders.
