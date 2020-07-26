# Reindeer_MachXO3D
Port RISC-V to Lattice MachXO3D Breakout board (Rev A)

## Clone the GitHub Repository

$ git clone https://github.com/PulseRain/Reindeer_MachXO3D.git

$ cd Reindeer_MachXO3D

$ git submodule update --init --recursive

## Install Lattice Diamond Software

Visit 

https://www.latticesemi.com/Products/DesignSoftwareAndIP/FPGAandLDS/LatticeDiamond

Install Lattice Diamond and the correspondent license


## Program the MachXO3D Breakout board with new image
* Connect the Lattice MachXO3D Breakout board to PC through USB cable
* Launch Diamond Programmer, point the image to [Reindeer_MachXO3D\build\lattice\MachXO3D_Breakout\breakout\MachXO3D_breakout_a.jed](https://github.com/PulseRain/Reindeer_MachXO3D/raw/master/build/lattice/MachXO3D_Breakout/breakout/MachXO3D_breakout_a.jed), as illustrated below:

![Programmer](https://github.com/PulseRain/Reindeer_MachXO3D/raw/master/doc/programmer.png "Programmer")

The FPGA image above contains PulseRain FRV2100 RISC-V core, and it will light up the led in a rotating fashion. Please set DIP-SW 1 and 2 for LED pattern, and set DIP-SW 3 and 4 for LED refreshing rate.


## Prepare the board for UART
* The RISC-V core needs a UART for programming and communication. The MachXO3D Breakout board carries a FTDI FT2232H chip, with 2 channels. Channel A is used for FPGA programming. And Channel B can be used as a UART for RISC-V.

* However, to enable the UART, some extra work has to be done
  1. The resistors R14 and R14 are DNI on the board. They should be installed (0 Ohm or simply connect with bard solder), as shown below:
     ![Breakout](https://github.com/PulseRain/Reindeer_MachXO3D/raw/master/doc/Breakout.png "Breakout")
  2. The EEPROM for the FT2232H needs to be reconfigued. To do that, please install the [FT_PROG utility](https://www.ftdichip.com/Support/Utilities.htm#FT_PROG) from [Future Technology Devices International Ltd](https://www.ftdichip.com/index.html)
  3. Launch [FT_PROG utility](https://www.ftdichip.com/Support/Utilities.htm#FT_PROG), press F5 to scan the devices, set Hardware Specific/Port B/Hardware to be RS232 UART, as illustrated below:
     ![FT_PROG](https://github.com/PulseRain/Reindeer_MachXO3D/raw/master/doc/FT_PROG.png "FT_PROG")
  4. Press Ctrl+P to program the FT2232H
  5. In Windows Device Manager, use mouse to right click "Universal Serial Bus controller / USB Serial Converter B", choose Properties / Advanced Tab, and click the "Load VCP", as illustrated below:
     ![USB Load VCP](https://github.com/PulseRain/Reindeer_MachXO3D/raw/master/doc/USB_Load_VCP.png "USB Load VCP")
  6. Unplug and replug the USB cable
  
  

## Use Arduino to program the software on RISC-V
PulseRain FRV2100(Reindeer) RISC-V core can be developed and programmed through Arduino.
* Install [Arudino IDE](https://www.arduino.cc/en/Main/Software). For Windows 10, it can also be installed through Microsoft Store
* Launch [Arudino IDE](https://www.arduino.cc/en/Main/Software). In Menu File / Preferences, set Additional Boards Manager URLs to https://raw.githubusercontent.com/PulseRain/Arduino_RISCV_IDE/master/package_pulserain.com_index.json, as shown below:
![URL](https://github.com/PulseRain/Reindeer_MachXO3D/raw/master/doc/arduino.png "URL")
* In Menu Tools/ Boards / Boards Manager..., Search Reindder, and Install PulseRain Reindeer 1.3.7 or higher, as shown below:
![Boards Manager](https://github.com/PulseRain/Reindeer_MachXO3D/raw/master/doc/board_manager.png "Boards Manager")
* After the board package is installed, please select Menu / Boards / PulseRain RISC-V (Reindeer)/MachXO3D Breakout
* Also, after the Breakout board is plugged in, please set Menu / Tools / Port acoordingly.
* Now feel free to do the programming. The sketch used in the demo can be found in [Reindeer_MachXO3D/sketch/breakout_demo](https://github.com/PulseRain/Reindeer_MachXO3D/tree/master/sketch/breakout_demo)



