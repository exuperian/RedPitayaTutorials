# Splitting and joining AXIS data

In the  [input signal feedthrough](/Tutorials/PROJ_IOFeedthrough) tutorial, we feed input data through to the output. The data is contained in a 32 bit AXI Stream combining the two signals. If you want to manipulate the signals individually, you need to split this up.

We'll use two custom source files `join_to_adc.v` and `split_from_dac.v` which you can download from this folder. The code behind these is explained in detail [here](/Tutorials/CORE_SPLIT_JOIN).

## Verilog blocks

Here we'll go through the verilog blocks used to split and re-combine the signal. The code behind these is explained in detail [here](/Tutorials/CORE_SPLIT_JOIN).

### split_from_dac.v

The first code splits the signal from the DAC into two 16 bit streams.



![The split_from_dac block. It has inputs m_axis and adc_clk; m_axis contains a 32 bit vector m_axis_tdata and m_axis_tvalid. It has two 16 bit output vectors o_data_a and o_data_b.](img_splitfromdac.png)



### join_to_adc.v

This block joins two streams into one

![The join_to_adc block. It has inputs adc_clk, t_valid, and two 16 bit vectors o_data_a and o_data_b. It has a single output m_axis, containing a 32 bit vector m_axis_tdata and m_axis_tvalid.](img_jointoadc.png)



## Block design

Begin by creating the block design from [input signal feedthrough](/Tutorials/PROJ_IOFeedthrough). Make sure you remember to *Generate Output Products* and *Create HDL Wrapper*, and also set the wrapper for your main design as top. However, **remove** the data connection between *m_axis* on the ADC and *s_axis* on the DAC. We'll be placing something between these.



![The block design from the input signal feedthrough tutorial](img_FeedthroughBlockDesign.png)

### Add sources

On the left sidebar under *Project Manager* select *Add Sources*. Choose the *Add or create design sources* radio button and press *Next*. Then use the *Add Files* button to add  `join_to_adc.v` and `split_from_dac.v`.  

### Connect split_from_dac

Add *split_from_dac* to the block design. Connect its *s_axis* to the *m_axis* port on the ADC, and its clock signal *aclk* to *adc_clk*.

![](img_split_connections.png)

### Connect join_to_adc

Now add *join_to_adc* to the design. Connect *out1* and *out2* to *in1* and *in2*. Connect *t_valid* to *out1_valid* and *out2_valid*, and connect *aclk* to the *adc_clk* on the ADC.

![](img_join_split_connections.png)



Then connect the *m_axis* port on *join_to_adc* to the *s_axis* port on *axis_red_pitaya_dac*.



The completed design should then look like:![](img_FeedthroughSplitJoined.png)

Since we are just splitting and then recombining the input, this should just pass input straight through to the output. Compile it and make sure it works! 

## What's next?

- At the moment this circuit just passes input data straight through to the input. But now that we've split the input and output channels, we can start 
- For the STEMLAB-14, the data from the ADCs is 14 bit. However these are sign-padded to 16 bits, and we keep the padding bits when we split and join the data. There are two reasons for this. 
  - Firstly many Vivado blocks work with a whole number of bytes by default (for example the [DDS Compiler](/Tutorials/PROJ_IOSignalGeneration)), so we have to work with sixteen bits anyway.
  - Secondly Red Pitaya [also has a model](https://redpitaya.com/product/sdrlab-122-16-standard-kit/) with 16 bits on the ADC (though still only 14 bits on the DAC). Including the extra bits on our splitting and joining code will reduce friction if you also want to run this code on the 16 bit model.