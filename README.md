# Researching energy consumption on ARM

## Prerequisites

### Installs

Following package (numpy) needs to be installed for the calculation of the Pearson Correlation Coefficient! (pip is needed for python packages)
```
sudo apt install python-pip
python -m pip install --user numpy
```

An environment that can execute PATUS is assumed. bash and python should already be installed on any conventional linux distribution. Please also check "Using the Measurement Device" section.


### Raspberry Pi Set Up

The script assumes the PATUS folder to be in the *home directory* of the Raspberry Pi:
```
/home/pi/ OR ~/
```
If not there, then almost none of the SSH commands will work.


### Patus folder name

By default the PATUS folder name is *patus*. This can be changed at the very beginning of the script (*patus_folder* variable). The folder name is used for local and host, so they need to be same on both machines.

The results of the measurements go into a folder called *patus_results*. This can also be changed at the beginning of the script (*results_folder* variable).


### Using the Measurement Device

The software for the Measurement Device was written by [Jan Lucas](https://www.aes.tu-berlin.de/menue/mitarbeiterinnen/ehemalige_mitarbeiterinnen/lucas_jan) at the TU Berlin. Only the compiled software was kept (client), the source files were omitted. You can find it in the *tub_measurement folder*.

A small rule file needs to be added to **/etc/udev/rules.d/** ( e.g. **/etc/rules.d/71-tub.rules** ) to use the client.

The file needs to include the following line:

```
SUBSYSTEM=="usb", ATTR{idVendor}=="aabb", MODE="0664", GROUP="plugdev"
```

All users in group "plugdev" can then use the device without being root. Your user needs to be in the group.

The client can be used with different settings, adjustable in the measure script. Different sample rate settings are:
* -s 1 is ~3,9 kHz
* -s 2 is ~7,8 kHz
* ...
* -s 5 is ~62,5 kHz
* -b 64 is a small low pass filter (reduces noise)

Higher sample rates give more samples per second but also more noise.



## How to use

### Overview of functionality

The scripts can be used in a few different ways:

* Do a single measurement of performance on ARM and/or Intel
* Do the same measurement of performance but multiple times in a row (default is 2 when using the multiple keyword)
* Do a single measurement of performance AND energy consumption on ARM (without thread count adjustment)
* Do a single measurement of performance AND energy consumption on ARM (with thread count adjustment)
* Doing the last two measurements multiple times in a row has to be done manually


### Examples

Single measurement of performance on **Intel** using blur-float stencil specification with dimensions 2048x2048
```
./measure.sh local blur-float 2048 2048
```
... on **ARM** 
```
./measure.sh host <IP-Address> blur-float 2048 2048
```
*IP-Address has to be the IP-Address of the Raspberry Pi (See below for a shortcut)*
... or both (ARM is first)
```
./measure.sh both <IP-Address> blur-float 2048 2048
```


**10x** measurement of performance on Intel using wave-1-float stencil specification with dimensions 128x128x128
```
./measure.sh multiple 10 local wave-1-float 128 128 128
```
... on ARM  
```
./measure.sh multiple 10 host <IP-Address> wave-1-float 128 128 128
```
... or both
```
./measure.sh multiple 10 both <IP-Address> wave-1-float 128 128 128
```


Measurement of performance & **energy consumption** on Intel using laplacian-float stencil specification with dimensions 258x258x258 *(NO THREAD ADJUSTMENT)*
```
./measure.sh +measure host <IP-Address> laplacian-float 258 258 258
```


Measurement of performance & **energy consumption** on Intel using gradient-float stencil specification with dimensions 130x130x130 *(THREAD ADJUSTMENT! Here up to 8 threads in the example)*
```
./measure.sh +measure 8 host <IP-Address> gradient-float 130 130 130
```


### IP-Address Shortcuts
In the file ```ip_address_config.txt``` the ip_address can be set for connecting to the ARM via cable and WLAN for easier usage.
After it was set, the IP address does not need to be inserted manually anymore, and instead of ```host / both``` the following 2 shortcuts can be used:
* host-cable / both-cable
* host-network / both-network


## Additional Info

### Error Checks

The scripts do have a few error checks in place, but not all possible misusages have been covered.

Try to follow these guidelines:
* If you input a multiple or +measure value less than 1 it defaults to 2 for both.
* I would advise against trying to use multiple and +measure together, but maybe there is an error check for it anyway...
* The name for the stencil codes has to be precise.
* There is no check for the dimensions of stencil codes. Make sure beforehand that you use valid dimensions (e.g. multiple of 4 for blur etc.).


### SSH Connection & Check

To do the measurements on the ARM many SSH commands are used. I set up a passwordless system to connect to the Pi. I can't guarantee for a working behaviour if that is not the case, as I have never tried my scripts without having a passwordless ssh set up to connect to the Pi.

There is a check of whether or not a SSH Connection to the Raspberry Pi can be established or not.


### Measurement Device Check

There is **no check** whether or not the measurement device has been connected to the PC. If not the case, the files from the supposed measurement stay empty and if I remember correctly it errors off somewhere in the process. I think it still moves all the files into the patus_results folder, but I might be wrong here.


### Limitations

As only the ___-float stencils worked, only these has been implemented. Cancelling the script while it is running can lead to unpredictable results, for example 'zombie files/folders' in the benchmark folder of PATUS.


### script_help.sh

Just an additional help script to speed up the process of measurement. It should be pretty self-explanatory (scroll down). Make sure to set the *connection_type* variable (cable/network) when you use it.


### __ERROR__

This file includes the errors from the failed compilation using the patus-aa folder.



## Acknowledgements

* [PATUS](https://github.com/matthias-christen/patus) by Matthias Christen
* [ARM backend for PATUS](https://github.com/bcosenza/patus-aa) by Biagio Cosenza
* Jan Lucas for the software to use measurement device (see above)
