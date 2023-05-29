# Splitting and joining AXIS data

In the  [input signal feedthrough](/Tutorials/PROJ_IOFeedthrough) tutorial, we feed input data through to the output. The data is contained in a 32 bit AXI Stream combining the two signals. If you want to manipulate the signals individually, you need to split this up.

We'll use two custom source files `join_to_adc.v` and `split_from_dac.v`.

## Block design

Begin by creating the block design from [input signal feedthrough](/Tutorials/PROJ_IOFeedthrough). Make sure you remember to *Generate Output Products* and *Create HDL Wrapper*.

![The block design from the input signal feedthrough tutorial](img_FeedthroughBlockDesign.png)

### Add sources

On the left sidebar under *Project Manager* select *Add Sources*. 

Choose the *Add or create design sources* radio button and press *Next*. Then use the *Add Files* button to add the two source files. Add these to the design.

![](img_FeedthroughSplitJoined.png)

## What's next?

- 