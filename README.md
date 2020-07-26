# Reindeer_MachXO3D
Port RISC-V to Lattice MachXO3D Breakout board

## Clone the GitHub Repository

$ git clone https://github.com/PulseRain/Reindeer_MachXO3D.git
$ cd Reindeer_MachXO3D
$ git submodule update --init --recursive

## Install Diamond 

Visit 

https://www.latticesemi.com/Products/DesignSoftwareAndIP/FPGAandLDS/LatticeDiamond

Install Lattice Diamond and the correspondent license


## Program the MachXO3D Breakout board with new image
* Connect the Lattice MachXO3D Breakout board to PC through USB cable
* Launch Diamond Programmer, point the image to Reindeer_MachXO3D\build\lattice\MachXO3D_Breakout\breakout\MachXO3D_breakout_a.jed, as illustrated below:

![Programmer](https://github.com/PulseRain/Reindeer_MachXO3D/raw/master/doc/programmer.png "Programmer")




