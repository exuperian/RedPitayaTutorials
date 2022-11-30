# Generating a sine wave

We'll see how to generate a sine wave from the Red Pitaya. FPGAs are digital devices, working with ones and zeros. A sine wave however is an analog concept, which the FPGA tries to approximate. We will do this with a *Direct Digital Synthesiser (DDS)*.

The Red Pitaya has two high-speed Digital to Analog Converters (DACs). We can send digital signals to these to synthesise an arbitrary analog waveform, for example to drive a system or apply feedback. There is a bit of a quirk to using these however. Internally, the Red Pitaya only has a single output port for DAC signals. You must 

## Preliminaries

### Two's-complement binary

*Sign extension*.

### Direct Digital Synthesis (DDS)

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

## Block design

### DDS block



The block transfers data via *AXI*. We met *AXI* in the [GPIO tutorial](/Tutorials/PROJ_LEDAXI), where it was used to transfer signals between the Processing System and FPGA. *AXI* is a general-purpose connector, and many blocks use it for input and output.

#### Block output

We need to choose the precision with which our sine wave will be generated. This precision is expressed by the *Output Width*, which is the number of bits used to encode the sine wave. 

The way you choose the *Output Width* depends on how you've configured the *DDS Compiler*. If you *Right-click -> Customize Block*, by default *Configuration Options* is set to *Phase Generator and SIN COS LUT*, and the block has two outputs, *M_AXIS_DATA* and *M_AXIS_PHASE*:

![On the left is the block diagram, input aclk and outputs M_AXIS_DATA and M_AXIS_PHASE. On the right we have the Configuration tab. At the top of this tab are Configuration Options set to Phase Generator and SIN COS LUT. At the bottom under heading System Parameters the Spurious Free Dynamic Range is set to 45.](img_DDSConfigurationPhaseAndSine.png)

At the bottom under *System Parameters*, there is an option called *Spurious Free Dynamic Range (dB)*. This is the [ratio of the amplitudes of the frequency being generated, and that of the next harmonic](https://www.ni.com/ja-jp/support/documentation/supplemental/18/specifications-explained--spurious-free-dynamic-range--sfdr-.html). The larger this is, the 'purer' the signal being generated. As shown in Table 4-3 of the [DDS Manual](https://docs.xilinx.com/v/u/en-US/pg141-dds-compiler), the *Output Width* is equal to the *Spurious Free Dynamic Range* divided by six (rounded up to the nearest bit): 

$$\mathrm{Output\,Width}=\frac{\mathrm{SFDR}}{6}$$,

In *Phase Generator and SIN COS LUT* mode, the *DDS* takes a clock signal and generates both the phase and a sine/cosine wave. This is the setting we'll use for this example. 

If however you change *Configuration Options* to *SIN COS LUT only*, the block takes a phase signal as input, and gives the sine wave as output. In this configuration you specify both the *Output Width*, and *Phase Width* to expect on the input. Note that if you switch to this configuration, then switch back to *Phase Generator and SIN COS LUT*, the customisation options glitch and won't automatically change back. You'll have to close and re-open block customisation.

In the left of the *Customize block* dialog, you can see the *DDS* block has outputs *M_AXIS_DATA* and *M_AXIS_PHASE*. The *M_* refers to this being [a *master* port](https://en.wikipedia.org/wiki/Master/slave_(technology)), and *AXIS* is an abbreviation for *AXI Stream*, the protocol it uses to transfer the data. The *DATA* port contains the sine and cosine waveforms, while *PHASE* carries the phase of the generated wave.

If you click the '+' after *M_AXIS_DATA*, you can see this is made up of two signals:

![The DDS block with input on the left aclk, on the right output M_AXIS_DATA made up of m_axis_data_tdata and m_axis_data_tvalid, and M_AXIS_PHASE](img_DDSBlockMasterExpanded.png)

* A vector *m_axis_data_tdata* which carries the sine and cosine wave.
* A wire *m_axis_data_tvalid* which is part of the *AXI* protocol. Electrical signals take time to propagate through the FPGA, so the data coming out of the *tdata* port may not always be what it's meant to. The *tvalid* signal is 1 if the data is valid, and 0 otherwise.

The *tdata* vector is sixteen bits long. The *Spurious Free Dynamic Range* is 45, so the *Output Width* is 

$$\frac{45}{6}=7.5\rightarrow 8$$.

The data contains both a sine and cosine, and $2\times 8=16$, which matches. In *tdata*, the bits at the start (0:7) encode the cosine, and the latter bits (8:15) encode the sine.

Let's increase the precision by setting *SFDR* to 80. Then the *Output Width* should be

$$\frac{80}{6}=13.3\rightarrow 14$$.

However if we expand *M_AXIS_DATA*, we'll see that the *tdata* vector is 32 bits long. The reason for this is that the *Output Width* is automatically padded to the nearest byte. Thus the sine and cosine are each sign padded to 16 bits, making the total output size 32 bits.

### Clocking wizard

- See [here](https://electronics.stackexchange.com/questions/110134/how-to-double-my-clocks-frequency-using-digital-design) for some examples on how clock frequencies may be sped up.
- This has an output *locked*. Signals take time to change, and can fluctuate. *locked* tells the output whether or not the clock signal can be trusted.

## What's next?

If you want to learn more about Direct Digital Synthesis, see

* [AnalogDialogue - All About Direct Digital Synthesis](Ask The Application Engineer—33: All About Direct Digital Synthesis)
  * For a deeper look, they also have a [122 page tutorial](https://www.analog.com/media/en/training-seminars/tutorials/450968421DDS_Tutorial_rev12-2-99.pdf).
* [All About Circuits - Everything you need to know about Direct Digital Synthesis](https://www.allaboutcircuits.com/technical-articles/direct-digital-synthesis/)

* [ZipCPU article on ODDR](https://zipcpu.com/blog/2020/08/22/oddr.html)

