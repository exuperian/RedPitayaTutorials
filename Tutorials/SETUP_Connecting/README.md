# Setting up and connecting to a Red Pitaya

In this post we'll go through how to set up a Red Pitaya, and communicate it via your computer.

## What you need out of the box

The Red Pitaya looks like this:

![The Red Pitaya board seen from above. In the rear, a white sticker on the Ethernet port contains the connectino information for the board.](img_boardtop.jpg)

On your Pitaya there will be a sticker over the rectangular ethernet port, which we have covered with a white square and labelled 'Connection Information'. Yours will contain your Pitaya's MAC address, which you use to connect to it over the network.

In addition to the Red Pitaya, you also need the
* power supply,
* ethernet cable,
* and the micro SD card containing the operating system.

![A black micro USB power supply, red ethernet cable, and small black microSD storage card](img_cables.jpg)

## Plugging things in

You first need to insert the microSD card containing the operating system. Before this however, **we recommend updating the operating system to the latest version**, see [the official instructions on how to do this](https://redpitaya.readthedocs.io/en/latest/quickStart/SDcard/SDcard.html#). Old versions of the software may have trouble connecting to the network. Once you've updated your microSD card, insert it as below. It should make a satisfying click.

![The microSD card being inserted into the slot, which is directly above the micro USB ports.](img_InsertingSD.jpg)

We will now use two of the ports on the rear:

![Rear ports on the Red Pitaya. We have circled the small micro USB power port on one end of the rear, and large square ethernet data port on the other](img_Ports.jpg)

* The board has two micro USB ports. The outer one is labelled 'PWR', and is used to supply power. <span class="sidenote">The inner one, labeled 'CON', [can be used to transfer data with the computer](https://redpitaya.readthedocs.io/en/latest/developerGuide/software/console/console/console.html), but we won't do that.</span> The official recommendation is to supply power using the included power supply. You can instead connect the PWR port to your computer with a micro USB cable, and it will also transfer power (but not data) to the board. We've done this many times without problem, the company warns that if the port doesn't provide enough power the Pitaya could behave incorrectly. A similar warning applies if you use a different power supply.

* The rectangular port is ethernet, which exchanges data with the computer. You can connect this directly to your computer if you have a spare ethernet port, and we've also used ethernet to USB adaptors without issues. **Note that if you are on Linux, you have to set the Pitaya's network connection to 'Share to other computers' as mentioned in [the documentation](https://redpitaya.readthedocs.io/en/latest/quickStart/connect/connect.html).** Another option is to connect this to an ethernet port on your router. This lets you access it from any other device on the network &mdash; even wireless ones like a phone or laptop. 

When you plug these cables in, LED lights will appear:
* The LED lights on the side turn on as soon as power is connected. 
* If the ethernet is communicating properly with your PC or network, red and green lights on the face of the port will start flashing.

![The power and ethernet cables have been plugged into the corresponding ports. There are a strip of power light LEDs on the side of the ethernet port, and a green and orange data LEDs on the face of the ethernet port.](img_PluggedIn.jpg)

The Pitaya gets quite hot after being plugged in for a few minutes, even if you aren't doing anything with it. So make sure it has adequate ventilation!

## Accessing the Pitaya via web browser

The sticker above the ethernet port, which I called 'Connection information' in previous pictures, will look something like this image from the [official documentation](https://redpitaya.com/rtd-iframe/?iframe=https://redpitaya.readthedocs.io/en/latest/quickStart/first.html):

![A white sticker with a series of numbers and letters printed on it](img_AddressSticker.png)

The bottom sequence,  twelve numbers and letters separated by colons, is the _MAC address_ of the ethernet port. Every device that can connect to a network, such as your cellphone, has a unique MAC address associated with it. On the top of the sticker there is a web address, made up of *rp-*, followed by the last six digits of your MAC address, and then *.local/*. In this case, as shown on the sticker, you enter _rp-f07863.local/_ into your web browser (it doesn't matter if you use capitals or lowercase). This should take you to the console:

![A black background with square icons. The icons have labels like 'Logic analyser', 'Bode analyser', etc.](img_WebConsole.png)

You're now connected! You can click on these buttons to use the various tools the Red Pitaya comes with.

## Conclusion

Hopefully you can now access your Red Pitaya, and control it via the web browser. If you do have issues check out the [official documentation on getting started](https://redpitaya.readthedocs.io/en/latest/quickStart/quickStart.html). The two main things to look out for are updating the SD card beforehand, and changing the network settings if you are using Linux. 
