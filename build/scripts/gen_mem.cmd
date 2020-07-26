rem scripts to generate memory init files from hex file 
rem example: gen_mem.cmd C:\Users\pulse\AppData\Local\Temp\arduino_build_32247\sketch_jul24a.ino.hex

python ./gen_mem.py %1 0 > ..\lattice\MachXO3D_Breakout\breakout\mem_init_0.mem
python ./gen_mem.py %1 1 > ..\lattice\MachXO3D_Breakout\breakout\mem_init_1.mem
python ./gen_mem.py %1 2 > ..\lattice\MachXO3D_Breakout\breakout\mem_init_2.mem
python ./gen_mem.py %1 3 > ..\lattice\MachXO3D_Breakout\breakout\mem_init_3.mem


