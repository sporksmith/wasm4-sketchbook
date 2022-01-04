Just some noodling with [wasm4](https://wasm4.org/).

* [Particles](https://sporksmith.github.io/wasm4-sketchbook/particles/).
  Currently non-interactive. Just spawns some particles.

* [Twin-stick](https://sporksmith.github.io/wasm4-sketchbook/twin-stick/).
  Originally intended as a twin-stick shooter, but it looks like wasm4 multiple
  gamepads isn't actually implemented yet, at least on the web runtime. Experimenting with analagous control scheme. Currently:
  * direction: Accelerate.
  * button1 + direction: Fire some bullets, with recoil.
  * button2: Brake.
