---
layout: post
title: Converting an HP Chromebox to run Ubuntu 14.04
---

**NOTE:** Standard Disclaimer, and yada yada, this works fine for me. But could totally brick your Chromebox. So you know there's that.

### Things you'll need to get started
1. ChromeBox, keyboard, mouse, monitor, internet connection
1. USB Flash Drive >= 4GB
1. Phillips Head Screwdriver
1. Flat Screwdriver


1. Disable Write Protect - Remove Internal Screw
1. Plug in Chromebox, connect to wired network if possible.
1. Enable Developer mode
  * Hold down reset button while booting
  * Press CTRL-D
  * Press reset button again
1. Boot partially into ChromeOS, but do not worry about logging in.
1. Verify you're connected to the network / internet (if you need to use Wifi, do it here)
1. Press Ctrl-Alt-F2 to get to an alternative TTY.
1. Login with the username `chronos` no password.
1. Download and run the EZ-Chromebox Setup `curl -L -O http://goo.gl/3Tfu5W && sudo bash 3Tfu5W`
1. Choose to download and install Coreboot Firmware
1. Insert a USB drive and backup the existing firmware. You know, just incase.
1. ChromeBox Finishes installing the firmware.
1. Power Down the ChromeBox
1.
