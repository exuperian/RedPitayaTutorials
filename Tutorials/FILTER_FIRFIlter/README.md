# Simple FIR filter

In this tutorial we'll learn how to implement a simple digital filter on the Red Pitaya. We will work with *Finite Impulse Response (FIR)* filters, where the filtered output at time $t$ is a linear combination of values of the input signal at previous times. These are the simplest kind of digital filter, but they are versatile enough to do most of the kinds of signal processing that you may want to do in the laboratory.

FIR filters work by summing linear combinations of the current and previous values of the signal. For this to work, they need to hold in memory the past several periods. Since the Red Pitaya samples signals at 125 MHz, this means that a simple FIR filter will only be able to operate at megahertz frequencies, since anything slower would require storing and then performing mathematical operations on vast amounts of data. To operate at lower frequencies it is necessary to first downsample the data, which we cover in [ADD THIS]().

We'll give only a brief introduction to FIR filters. Before going through this tutorial, you should first go through [Feeding an input signal through to the output](/Tutorials/PROJ_IOFeedthrough). To test out your filter you'll need an oscilloscope and signal generator.

## Preliminaries

### Filtering

When we measure a signal in a laboratory, there will often be unwanted noise corrupting our signal. With filtering we aim to remove (or 'filter out') this noise, and recover the original signal. We are able to do this because most of the time our signal of interest will occur at a different frequency range to the noise. Thus a filter can be thought of as something that amplifies certain frequencies, and suppresses others.

One way to filter an electrical signal is to design an electrical circuit out of basic components such as resistors, capacitors, and inductors. This is an *analogue filter*. When a continuously-varying electrical signal passes through the circuit, the output will be a filtered version of the input. On the Red Pitaya however we have a digital representation of our signal, as a sequence of 1s and 0s that changes every clock cycle. A *digital filter* is a series of mathematical operations that we apply to the current and past values of the signal, whose output will be a filtered version of the original.

One of the great things about digital filtering is that it is programmable. If you want to change the frequency ranges of the filter, you don't need to go out and buy different capacitors, you can just change some code in Vivado.

### FIR filters



## Block design

## What's next?

- A good reference on digital filtering is [Understanding Digital Signal Processing by Richard Lyons](https://www.amazon.com/Understanding-Digital-Signal-Processing-3rd/dp/0137027419).