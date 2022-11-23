# Understanding AXI

The resources for this are the [official AXI Documentation](https://docs.xilinx.com/v/u/en-US/pg144-axi-gpio), [The Zynq Book](http://www.zynqbook.com/), and [Anton's Stopwatch tutorial](http://antonpotocnik.com/?p=489265)

The *ZYNQ7 Processing System* has an output port *M_AXI_GP0*. 

## What is AXI?

AXI is what allows the processing system and programmable logic to communicate. The *Advanced eXtensible Interface (AXI)* is a general standard supported by many different systems. 

The protocol is *memory mapped*. This means an address is specified within the transaction, corresponding to an address in the system memory space. The master specifies the the address of the first word, and the slave calculates the addresses for the rest of the data words.

The connections between the PS and PL are very complicated. There are nine AXI interfaces, each composed of multiple channels. 

There are two types of connections:

* *Interconnects* operate within the PS. These manages and direct traffic between AXI interfaces.
* *Interfaces* allow for passing of data, addresses, and handshaking signals between master and slave clients within the system.

The structure is

![](img_AXIStructure.png)

* *Interconnects* act within the PS.

![](img_ZYNQ7_Structure.png)

* The naming convention M_ or S_ refers to whether the PS is the master or slave.
* *ACLK* stands for *AXI Clck*

![](img_AXIExample.png)

*c.f.* Anton's setup

![](img_AntonAXI.png)



* *M_AXI_GP0* is the *General Purpose AXI*.
  * 32 bit data bus, suitable for low and medium rate communication between PL and PS.
  * 12-bit master port ID width
  * 6-bit save port ID with
  * Master and slave port acceptance capability of 8 reads and writes.
  * Interface is direct, does not include buffering.
* *S_AXI_HP0*
  * High Performance Ports with read/write FIFOs.
  * 1kB data FIFO for buffering.

AXI write channel

1. Master sends address/control to slave.
2. Master sends data to slave.
3. Slave sends a write response back to the master.

AXI read channel

1. Master sends address/control to the slave.
2. Slave sends data back to the Master

* AXI allows out-of-order transactions.
  * Each transaction is given an identifying tag issued by the interconnect governing the order.

## AXI GPIO

* The *AXI GPIO* provides a general purpose input/output interface to an AXI4-Lite interface.
  * The Zynq's *M_AXI_GP0* plugs into an *AXI Interconnect*, which connects to an *AXI GPIO*.

### Data registers

* The *AXI GPIO* data register is used to read the general purpose input ports and write to the general purpose output ports.
  * When a port is configured as an input, writing to the data register has no effect.
* The GPIO data registers have predefined offsets
  * 0x0000 *GPIO_DATA* Channel 1 AXI GPIO Data register
  * 0x0008 *GPIO2_DATA* Channel 2 AXI GPIO Data Register

### Accessing GPIO core

- For input ports when interrupt is enabled
  1. Configure the port as input by writing the corresponding bit in the *GPIOx_TRI* register with 1.
  2. Enable the channel interrupt by setting the corresponding bit of the IP Interrupt Enable Register. Also enable the global interrupt, by setting bit 31 of the Global Interrupt Register to 1.
  3. When an interrupt is received, read the corresponding bit in the *GPIOx_DATA* register. Clear the status in the IP Interrupt Status Register by writing the corresponding bit with the value 1.
- For input ports where interrupt is not enabled.
  1. Configure the port as input by writing the corresponding bit in the *GPIOx_TRI* register with the value of 1.
  2. Read the corresponding bit in the *GPIOx_DATA* register.
- For output ports
  1. Configure the port as output by writing the corresponding bit in the *GPIOx_TRI* register with a value of 0.
  2. Write the corresponding bit in the *GPIOx_DATA* register.

### Vivado IP Core

- Insert an *AXI GPIO* core.
  - *Right-click -> Customise IP*

![](img_CustomiseAXICore.png)

- *c.f.* Anton's, the Pitaya has two GPIO ports
  - one with both input and output, and the other just input.
- *All inputs* sets this GPIO channel bits in input mode only.
  - Similarly, *All outputs* sets the channel bits in output mode only.
- *GPIO Width* defines the width of the GPIO channel.
  - *Default output value* sets default values of enabled bits in this channel.
  - *Default tri state value*

- *Enable Dual Channel* enables a second channel *GPIO2*.
  - Unchecked by default.
- *Enable interrupt* enables interrupt control logic and interrupt registers in GPIO module.

### Traffic generator

- You can use the *AXI Traffic Generator* to generate AXI traffic.



## Red Pitaya

- See [Official documentation](https://redpitaya.readthedocs.io/en/latest/developerGuide/software/build/fpga/regset_common.html) for how AXI address is used by various apps.

## Implementing AXI

### Add GPIO Block

- Go to *Add IP*, choose *AXI GPIO*.
- *Right-click > customise*
  - Tick *Enable Dual Channel*
  - For channel 2, set *All Inputs*.

This will have three inputs:

- S_AXI
  - This manages the connection to the Zynq board.
  - If you click the plus, you can see this is many inputs grouped as one. Interfacing with a processor requires transmitting a lot of data.
- s_axi_aclk
- s_axi_aresetn

and two outputs:

- GPIO
- GPIO2

Connecting *S_AXI* to the Zynq processing system is quite complicated. Fortunately Vivado can automate this for us. 

- Click *Run Connection Automation* at the top.
- We just want to connect *S_AXI*, so tick that, and click continue.
  - This will create some new blocks.
    - *AXI Interconnect* between the PS and PL
    - *Processor System Reset*
  - It will wire everything together.

### Configure memory addresses

- We need to set the AXI GPIO core's memory address and range
  - We will access this from the Linux side.

- On the top of the window click on the *Address Editor* tab.

### Writing to memory with monitor

The Red Pitaya has a tool called *monitor* that you can use to read and write individual addresses, one bit at a time.
- [Official monitor documentation](https://redpitaya.readthedocs.io/en/latest/appsFeatures/command_line_tools/com_line_tool.html#monitor-utility)
- You can also read analog mixed signals, for example the Zynq temperature, power supply voltage, and other settings.

You can read an address using

```bash
redpitaya> monitor 0x40100014
0x00000001
```

You can write to an address via

```bash
redpitaya> monitor 0x40100014 0x8
```



**High-level scripts in Bash, Python, MATLAB can communicate with the FPGA using monitor**

- But don't be too blasé. The CPU algorithms also communicate with the FPGA through registers, so you might rip them up.

## Monitoring voltages with monitor

Monitor can also read voltage values on the extension connector.

- AIj/AOj are the Analog input and output connectors on E2
  - The analog output can be set using `sdac` switch

```bash
monitor -sdac 0.9 0.8 0.7 0.6
```

- VCCXXXX gives information about the power supply voltage source.

```bash
redpitaya> monitor -ams
#ID         Desc            Raw                 Val
0           Temp(0C-85C)    0x00000b12          75.670
1           AI0(0-3.5V)     0x00000008          0.014
2           AI1(0-3.5V)     0x00000017          0.039
3           AI2(0-3.5V)     0x00000008          0.014
4           AI3(0-3.5V)     0x00000006          0.010
5           AI4(5V0)        0x000004f9          3.800
6           VCCPINT(1V0)    0x0000055e          1.006
7           VCCPAUX(1V8)    0x00000995          1.797
8           VCCBRAM(1V0)    0x00000561          1.009
9           VCCINT(1V0)     0x00000561          1.009
10          VCCAUX(1V8)     0x00000997          1.798
11          VCCDDR(1V5)     0x00000806          1.504
12          AO0(0-1.8V)     0x0000000f          0.173
13          AO1(0-1.8V)     0x0000004e          0.900
14          AO2(0-1.8V)     0x00000075          1.350
15          AO3(0-1.8V)     0x0000009c          1.800
```



![](img_PitayaExtensionConnector.png)