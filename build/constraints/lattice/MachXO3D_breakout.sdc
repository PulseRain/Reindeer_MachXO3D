
create_clock -name osc_input -period 83.3333 [get_ports osc_12MHz] 

create_generated_clock -divide_by 1 -multiply_by 2  -source [get_ports osc_12MHz]  [get_pins pll_i/CLKOP]