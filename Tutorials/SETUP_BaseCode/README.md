# Base Vivado design

Here we'll describe how to make a model of the Red Pitaya in Vivado. Once you have this up and running, you can start coding it to do things. All of the projects we describe will begin from this base setup.

To make the Vivado model, you need to specify all the physical details of the Pitaya, such as the parameters of all its input and output pins, and how the FPGA logic communicates with the CPU. This is quite laborious, but fortunately [Anton Potočnik](http://antonpotocnik.com/) has written some fantastic scripts that automate the process. available in the [/cfg folder of his GitHub Repo](https://github.com/apotocnik/redpitaya_guide), and also included in this folder. We will use these, with some slight modifications. 

We will use

* rp_base_setup.tcl
* red_pitaya.xml
* ports.xdc and clocks.xdc

The latter three are available in the /cfg folder. You can also download them from this folder. 

## Procedure

Follow these steps to create a model for a Red Pitaya in Vivado.

### 1. Create a Vivado project with the right settings

Open Vivado, and create a *New Project*. There will be a few windows where you specify a name and folder for the project. Use the default project type.

When it asks you to specify the part, give **xc7z010clg400-1**:

![Vivado project window](img_VivadoProject.png)

You don't have to know what those letters, mean but if you're curious:

* the underlying chip is an xc7z010,

* in a cfg400 package, 
* binned into a -1 speed grade (the slowest option, -3 is the fastest).

When you click Next, you will see somewhere that the device family is *Zynq-7000*.

You now need to press *Create Block Design*, under *IP INTEGRATOR* on the left sidebar, to start designing your circuit.

![Dialogue for creating a Block Design](img_CreateBlockDesign.png)

Choose whatever name you like, leaving the other options as default.

This should leave you with a blank design to work on.

### 2. Create base setup

We need to give Vivado a list of the input/output ports on the Pitaya, tell it about the Zynq CPU, and how all these are interconnected. All this information is contained in the *pitaya_base_setup.tcl* file.  Use the TCL console and run 

```source ports.tcl```

See [the tutorial on running TCL scripts](/Tutorials/TCL_RunningTCL/README.md) for more details. After doing this the basic setup should appear in the *Diagram* window:

![Basic Red Pitaya setup](img_BaseSetup_preXML.png)

Let's run through what these things are

* On the the left- and right-hand sides we have the input and output ports respectively. The ports which have points on both sides are bi-directional.
* The *ZYNQ7 Processing System* is the CPU, which itself has input and output ports.
* The *daisy_* ports are used to connect multiple Red Pitaya's together, and allow them to communicate. Data needs to flow in a specified way between them, which is handled by the two Utility Buffers *utils_ds_buf_1* and *util_ds_buf_2*. Even if you don't plan on connecting multiple Pitayas the design won't compile without these, so leave them in.
* Signals from the Analog to Digital Converter (ADC) are delivered as [the difference between to voltages](https://en.wikipedia.org/wiki/Differential_signalling). The upper *util_ds_buf_0* converts these to ones and zeros we can use.

### 3. Final configuration

Now we'll give Vivado the last information it needs about the Red Pitaya.

First, right-click the *ZYNQ7 Processing System* and select *Customize Block*. Click on *Import XPS Settings*, press the '...' button, and choose the *red_pitaya.xml* file. Press the OK button twice to get back to the design, and you should see some extra ports appear on the *ZYNQ7* block:

![Basic Red Pitaya setup](img_BaseSetup.png)

Finally we need to tell Vivado some more information called *constraints*. You don't have to know the details of what these are, but if you are curious see [this post](https://support.xilinx.com/s/article/564948?language=en_US). On the sidebar on the left, click on *Add Sources*, and choose *Add or create constraints*. Use the *Add Files* button to add both *ports.xdc* and *clocks.xdc*, the press *Finish*.

# What next?

You now have a Red Pitaya set up in Vivado! The next step is to play around with it. See our LED Blinking Light tutorial.
