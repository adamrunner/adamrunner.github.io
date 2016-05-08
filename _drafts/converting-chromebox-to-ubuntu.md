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
1. Drain power from Chromebox - Disconnect AC Adapter and press power button
1. Plug back in normally, and boot
1. Plug in bootable USB Flash Drive w/Ubuntu on it. I use [Rufus](https://rufus.akeo.ie/) - Run it on a virtual Windows install, to make my bootable flash drives. I suggest you do the same.
1. Press ESC to see boot menu
1. Choose the boot device of the USB drive that you plugged in.
1. You should boot into Ubuntu Setup!
1. Choose, "Install Ubuntu"
1. Choose to format the hard drive and remove any other operating systems
1. Wait for Ubuntu to install (this guide won't cover the Ubuntu install as it's out of scope for this)
1. Reboot! Enjoy your UbuntuBox!
