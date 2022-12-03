
# Negative numbers in binary


So far we've seen how to represent positive integers in binary, for example `0110` is

$$0\times 2^3+1\times 2^2+1\times 2^1+0\times 2^2=6.$$

In many cases we care about *signed integers*, where by "signed" we mean these can have a positive or negative sign. How can we represent these in binary?

One idea might be to add a single bit to the left of the number, which is `0`if the number is positive and `1` if it is negative. In this scheme +6 would be `00110`, and -6 would be `10110`. However, this has some problems. For one thing zero has two representations: both `00000` and `10000` refer to the same number $0=(-0)$ , which would complicate binary circuits. Moreover, the FPGA has digital circuits which can perform arithmetic like addition and subtraction on. We would have to create a second set of circuits which understood the sign bit.

Because of this, we need to be a bit more inventive when representing negative numbers. Here we'll briefly discuss two method's that come up when working with the Red Pitaya. If you want to learn more, there are many good resources on the internet.

## Two's complement

It turns out there is a representation of negative numbers which uniquely represents zero, and lets you re-use all the circuits for arithmetic with positive numbers. This is called *two's-complement*.

Suppose you want to use 4 bits to represent a signed integer. As before we will use the leftmost bit to represent the sign, but in a cleverer way. If the integer is positive, we use the the traditional binary representation. Then 6 is `0110`. If you want to represent a negative number, you write down the binary representation for $2^4$ minus the number. Thus to represent -6, you write down the binary representation of $2^4-6=10$, which is `1010`.

It turns out that with two's complement encoding:

* Negative numbers will always end with a `1`, and positive numbers with a `0`.
* All the circuits for binary arithmetic work for two's complement encoding with no modifications.
* Zero is uniquely represented as `0000`.

There is also a quick formula to switch a number between positive and negative: invert the bits and add one. For example if you see `1010` and want to know what number it corresponds to:

1. It ends with `1` so you know it's a negative number.
2. Swap the zeros and ones to get `0101`.
3. Add 1 to this number, giving you `0101+0001=0110`, which is 6. Thus `1010`is -6.

Because of these advantages two's complement is the most common way to represent negative integers. It is used by many Vivado blocks, including the Direct Digital Synthesiser. See [this stackexchange answer](https://stackoverflow.com/a/1125317/966556) for more discussion on why two's complement is so useful. 

For unsigned integers, you can always pad a number with leading zeros on the left without changing the value. For example 6 is written as `0110`, which can be padded to eight bits as `00000110`. 

For two's complement signed integers, you pad the number with the sign bit. Thus since -6 is written as `1010`, this is padded to eight bits as `11111010`. You can check that if you convert this to a number by inverting the bits and adding one, you will still get minus six.

Padding a signed integer this way is called [*sign expanding*](https://en.wikipedia.org/wiki/Sign_extension).

## Offset binary

There is another way of representing negative numbers, which arises naturally when considering Analog to Digital (DAC) and Digital to Analog (DAC) converters. These are generally built in a way that only allows current to flow in one direction (due to one-directional components such as transistors). Because of this, they either respond to only positive voltages, or only negative voltages. Suppose you want a DAC to output voltages between -1 and 1. The simplest solution is to make the DAC output a voltage between 0 and 2, and then afterwards use a DC offset to subtract 1 volt from the output. This idea of using positive numbers with a predetermined offset is called *offset binary*.

Suppose you want to use offset binary for 4 bits.

* To represent a number, you write down the binary expansion for that number plus $2^{4-1}$.
* To read a string of binary, you convert this to a number then subtract $2^{4-1}$.

For example to represent -6, you write down the binary expansion for -6+8=2: `0010`. If you see the string `1110`, this corresponds to 16, which after subtracting 8 becomes +16.

The key ideas about about offset binary are:

* A binary sequence of all zeros is the lowest value.
* A sequence of all ones is the highest value.
* Zero is represented by the integer $2^{n-1}$, which has the first bit 1 and all others zero.
* Just like with two's complement, you can swap the sign of a number by flipping all the bits and then adding `0001`.

## Converting between two's complement and offset binary

Converting between two's complement and offset binary is actually really simple: just flip the leftmost bit! For example -6 in two's complement is`1010`. Flipping the first bit we get `0010`, which is -6 in offset binary.

Here's a table of *two's complement* and *offset binary* for four bits. Use this to check the properties about the binary encodings that we mentioned earlier

|      | Binary | Two's complement | Offset binary |
| ---- | ------ | ---------------- | ------------- |
| 7    | 0111   | 0111             | 1111          |
| 6    | 0110   | 0110             | 1110          |
| 5    | 0101   | 0101             | 1101          |
| 4    | 0100   | 0100             | 1100          |
| 3    | 0011   | 0011             | 1011          |
| 2    | 0010   | 0010             | 1010          |
| 1    | 0001   | 0001             | 1001          |
| 0    | 0000   | 0000             | 1000          |
| -1   |        | 1111             | 0111          |
| -2   |        | 1110             | 0110          |
| -3   |        | 1101             | 0101          |
| -4   |        | 1100             | 0100          |
| -5   |        | 1011             | 0011          |
| -6   |        | 1010             | 0010          |
| -7   |        | 1001             | 0001          |
| -8   |        | 1000             | 0000          |