# Generating a sine wave

We'll see how to generate a sine wave from the Red Pitaya. FPGAs are digital devices, working with ones and zeros. A sine wave however is an analog concept, which the FPGA tries to approximate. We will do this with a *Direct Digital Synthesiser (DDS)*.

## Direct Digital Synthesis (DDS)



- Generate a sine wave using an external clock
- Main components are a *phase accumulator* and *phase-to-amplitude conversion*.
  - *phase-to-amplitude conversion is typically a look-up table*
- Frequency of sine wave depends on reference clock frequency, and the *tuning word*.
- How phase accumulators work
  - Phase accumulator is modulo-M counter that increments its stored number each time it receives a clock pulse.
  - Magnitude of increment is determined by input word M, which gives the phase step size.
  - Number of discrete phase points is determined by resolution of phase accumulator $n$, which determines tuning resolution of the DDS.
    - For an N=28 bit phase accumulator, an M value of 1 would result in the accumulator overflowing after 2^28 reference-clock cycles.
    - $f_{out}=\frac{M\times f_C}{2^n}$
    - $f_C$ is clock frequency, $n$ length of the phase accumulator, $M$ the binary tuning word.
    - Output frequency limited by reference clock.
- **Changes in M result in immediate and phase-continuous changes in output frequency.**
  - **DDSs have very fast *hopping-frequency***
- As output frequency is increased, number of samples per cycle decreases.
- When generating a constant frequency, phase accumulator is a ramp (linear accumulation).
- A phase-to-amplitude lookup table is used to convert the phase-accumulator's instantaneous output value into an amplitude.
  - Amplitude information typically has less bits than phase, so unneeded bits are truncated.
  - DDS uses symmetrical nature of sine wave and mapping logic to synthesise a full sine wave from just a quarter.



### Clocking wizard

See [here](https://electronics.stackexchange.com/questions/110134/how-to-double-my-clocks-frequency-using-digital-design) for some examples on how clock frequencies may be sped up.

## What's next?

If you want to learn more about Direct Digital Synthesis, see

* [AnalogDialogue - All About Direct Digital Synthesis](Ask The Application Engineer—33: All About Direct Digital Synthesis)
  * For a deeper look, they also have a [122 page tutorial](https://www.analog.com/media/en/training-seminars/tutorials/450968421DDS_Tutorial_rev12-2-99.pdf).
* [All About Circuits - Everything you need to know about Direct Digital Synthesis](https://www.allaboutcircuits.com/technical-articles/direct-digital-synthesis/)

* [ZipCPU article on ODDR](https://zipcpu.com/blog/2020/08/22/oddr.html)

