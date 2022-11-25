# Simulating binary counters in Vivado

In this example we'll see how to run simulations in Vivado. Rather than having to compile the entire design, simulations let us see how particular blocks behave, and monitor what signals they are sending to each other. We'll consider as examples the [LED binary counter](/Tutorials/PROJ_LEDCounter) and the [Verilog version](/Tutorials/PROJ_LEDCounterVerilog).

It is possible to simulate the entire ZYNQ7 Processing System, but this is a bit complicated. Instead it makes more sense to generate simple input signals, such as an oscillating clock, and feed these to the blocks we care about. We create what's called a [testbench](https://nandland.com/what-is-a-testbench/), and use this to test a few blocks at a time.

## Procedure

### Create a testbench & set it as top

We'll first create a Verilog file that will be our *testbench*. It will generate a clock signal, feed it to some blocks, and monitor the output.

On the left sidebar choose *Add Sources*, and choose the *Add or create simulation sources* radio button. Create a new file and give it a name, in our case `counter_tb`. Leave all the ports and options as default, ignoring Vivado's warning, since we'll define them manually using Verilog.

After a short delay, you should see your testbench file appear in the *Simulation Sources* folder of the *Sources* tab:

![In the Sources Tab, in the Simulation Sources > sim_1 folder is a file counter_tb.v](img_TestbenchFileInSources.png)

Since we want the testbench to run the simulations, *Right-click* `counter_tb` and select *Set as Top*. The testbench file should become bold. This means that when a simulation is run Vivado will simulate `counter_tb` by default. The other two files are resources that our testbench can use.

### Write the testbench

Double-click the testbench file to edit it. You should see the standard Verilog module code from the [Verilog binary counter](/Tutorials/PROJ_BinaryCounterVerilog), including the code at the top setting the timescale:

```verilog
`timescale 1ns / 1ps
```

As discussed in the [LED binary counter tutorial](/Tutorials/PROJ_LEDCounter) ([and in more detail here](https://www.chipverify.com/verilog/verilog-timescale)), this tells Verilog that the module will be in units of nanoseconds, with picosecond accuracy.

#### Ports

We want our testbench to send in a binary signal representing the clock. This needs to remember its value in-between ticks, so it will be a *register*:

``` verilog
reg clock;
```

For the output however, we just care about the instantaneous value coming out of our blocks. This will thus be a *wire*, a variable which holds no data, but rather gives the instantaneous value of whatever we connect it to.

```verilog
wire [7:0] counter_out;
```

#### Clock signal

We can make the clock tick with the following code:

```verilog
initial 
begin
	clock = 0;
    forever #1 clock = ~clock;
end
```

* An `initial` block executes once at the beginning of the simulation. It's body is bounded by `begin` and `end` statements.
* The value of `clock` will be set to an initial value of 0.
* A `forever`  statement executes continuously for the entire simulation. If you have several lines of code, you can also bound them with `begin` and `end` statements.
* `#1` means to wait for one unit of time, which due to `timescale` is one nanosecond.
* `~` is the logical *not* operator, flipping zeros and ones.

Thus at the start of the simulation this block will set the clock equal to 0, and then flip its value between 0 and 1 every nanosecond.

### Connecting the testbench to a block

We can use this testbench to test either the block design of Verilog LED binary counters. We'll go through each of these in turn.

#### Verilog binary counter

The simplest case is the [Verilog binary counter](/Tutorials/PROJ_LEDCounterVerilog). First you need the name of the module that generated the counter, in our case `binarycounter`. The code is then

```verilog
binarycounter bc (.clk(clock),
                  .count(counter_out));
```

* This creates a new `binarycounter` object, and names it `bc` (the name is arbitrary).
* The `clk` port on `binarycounter` is connected to our `clock` register.
* The `count` port on `binarycounter` is connected to our `counter_out` wire.

In previous tutorials we drew connections between components by clicking and dragging with the mouse in the Design view. This does exactly the same thing, just in script form.

The module is then:

```verilog
module counter_tb();
	reg clock;
    wire [7:0] counter_out;
    
    initial begin
    	clock = 0;
        forever #1 clock = ~clock;
    end
    
    binarycounter bc (.clk(clock),
                      .count(counter_out));
endmodule
```

**If we just simulate this however, we won't see any output.** Recall that we used a binary counter to slow down the output by a factor of $2^{24}$, thus we will need to simulate $2^24\approx 10^7$ clock cycles just to see the first output on the counter.  This would take far too long. Thus for the purposes of simulation, go back to the `binarycounter` module, and change the last line to

```verilog
//assign count = count32[31:24] Commented out for simulation
assign count = count32[7:0]
```

Remember to undo this when you have finished simulating, or next time you synthesis your counter will run at light-speed!

#### Block-design binary counter

The testbench for the [block design binary counter](/Tutorials/PROJ_LEDCounter) is a bit more complicated. If you look in the *Simulation Sources* folder, you'll see that it has a `.v` file for your testbench, and also for the entire block design. We need to create a third file, corresponding to the blocks we care about, which the testbench can access.

In the LED blinker design, we have Binary Counter* and *Slice* blocks connected together. As before, **we need to remove the slowdown we imposed on the output**, so customise the *Slice* block so that it outputs the **first** eight bits:

![The Binary Counter block connected to Slice, with Dout 7 0 rather than 31 24](img_BlockDesignModified.png)

Next, we need to create a Verilog wrapper for just these two blocks. Click on one block, then hold down *Ctrl* and click on the second to select both of them. *Right-click -> Create Hierarchy*. A *Hierarchy* is just a group, combining these two elements into one effective block. You can choose whatever name you like, leave the other options default.

Now, *Right-click* the Hierarchy and select *Validate Design*, then *Right-click -> Create Block Design Container*. Give it a name (we went with `counter_block`), and leave the other options as default. After a short wait, there should now be an extra file in the *Design* and *Simulation Sources*:

![In Design sources, have zynq_led_wrapper.v and counter_block.bd. In Simulation Sources sim1 zynq_led_wrapper.v counter_tb.v and counter_block.bd ](img_SourcesBlockTest.png)

We can see that `counter_block` is yellow and ends in `.bd`, unlike the blue `.v` Verilog files. *Right-click* `counter_block` (either one) and select *Generate HDL Wrapper*, then Vivado will create Verilog files for these:

![Same as above, but now all files end in .v](img_SourcesBlockWrapped.png)

Note in the above `counter_tb` is bold since we have set it as Top. If yours isn't, *Right-click -> Set as Top*.

Finally all that remains is to write the testbench. Either by looking at the Block Design, or opening *counter_block_wrapper*, find the names of the input and output ports. In our case these are `CLK` and `led_o`. Then write `counter_tb.v` as

```verilog
module counter_tb();
    reg clock;
    wire [7:0] counter_out;
    
    initial begin
        clock = 0;
        forever #1 clock = ~clock;
    end
    
    counter_block_wrapper cbw (.CLK(clock), 
                               .led_o(counter_out));
endmodule
```

The line `counter_block_wrapper` must match the name of the Verilog file, since this is telling Vivado what module to instantiate. The name `cbw` is arbitrary.

**Now that you've put the Binary Clock and Slice blocks into a Block Design container, you won't be able to edit these from the main Block Design any more.** To re-add the slowdown to the binary counter, you'll have to open the *counter_block_wrapper* under *Design Sources* and edit that.

### Running the simulation

In the sidebar on the left, under *SIMULATION* click on *Run Simulation*, then select *Run Behavioural Simulation*. At first you might get something that looks like this:

![Two rows, clock and counter_out, with green lines. Above the two the timescale is 999,999 picoseconds](img_SimulationResultInitial.png)

* Use the scrollbar at the bottom to move to the very start of the simulation.
* Click the arrow next to *counter_out[7:0]* to expand it, so that you can see the individual bits.
* You should see that the time increment is picoseconds. Use the zoom button to zoom out until it is in nanoseconds, and you can see the clock switching on and off. Alternative you can press the *Zoom fit* button (*Ctrl + 0*)to the right of the magnifying glass to zoom out and see the entire simulation.
* Double click at a point to summon the yellow cursor to that point, telling you the exact time.
* You can also click and drag horizontally, vertically, or diagonally to change the region you are zoomed in on.

After this your screen should look something like below:

![Zoomed out so that time is in 20nanosecond increments, and counter_out is expanded, we can see the binary counter working](img_SimulatingResultsZoomed.png)

This shows the counter is working perfectly!

If you want to change the simulation length, you can click on *Run* on the top menu bar and choose *Run For*:

![](img_RunFor.png)

## What next?

In future projects, think about creating testbenches that will let you view important pieces of information. And bear in mind how you may have to modify your files for simulation.

You will want to simulate more complex situations, for example taking data with the analog-to-digital converters. Vivado's simulator is quite capable, see the [official documentation](https://www.xilinx.com/content/dam/xilinx/support/documents/sw_manuals/xilinx2022_1/ug937-vivado-design-suite-simulation-tutorial.pdf) for more information.
