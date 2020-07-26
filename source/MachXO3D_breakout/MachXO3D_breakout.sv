/*
###############################################################################
# Copyright (c) 2020, PulseRain Technology LLC 
#
# This program is distributed under a dual license: an open source license, 
# and a commercial license. 
# 
# The open source license under which this program is distributed is the 
# GNU Public License version 3 (GPLv3).
#
# And for those who want to use this program in ways that are incompatible
# with the GPLv3, PulseRain Technology LLC offers commercial license instead.
# Please contact PulseRain Technology LLC (www.pulserain.com) for more detail.
#
###############################################################################
*/

`include "common.vh"
`include "debug_coprocessor.vh"
`include "config.vh"

module MachXO3D_breakout (
    input   wire                                osc_12MHz,
    output  wire   [7:0]                        LED,
    
    //------------------------------------------------------------------------
    //  UART
    //------------------------------------------------------------------------
        
        input   wire                            UART_RXD,
        output  logic                           UART_TXD
);

    //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    // Signal
    //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        wire                                    reset_n;  
        wire                                    clk;
    
        logic unsigned [2 : 0]                  init_start = 0;
        
        wire                                    uart_tx_ocd;
        wire                                    uart_tx_cpu;
        
        wire                                    ocd_read_enable;
        wire                                    ocd_write_enable;
        
        wire  [`MEM_ADDR_BITS - 1 : 0]          ocd_rw_addr;
        wire  [`XLEN - 1 : 0]                   ocd_write_word;

        wire                                    ocd_mem_enable_out;
        wire  [`XLEN - 1 : 0]                   ocd_mem_word_out;
        
        wire                                    debug_uart_tx_sel_ocd1_cpu0;
        
        wire                                    cpu_reset;
        wire  [`DEBUG_PRAM_ADDR_WIDTH - 3 : 0]  pram_read_addr;
        wire  [`DEBUG_PRAM_ADDR_WIDTH - 3 : 0]  pram_write_addr;
        
        wire                                    cpu_start;
        wire  [`XLEN - 1 : 0]                   cpu_start_addr;
        
        logic                                   actual_cpu_start;
        logic unsigned [`XLEN - 1 : 0]          actual_start_addr;
        
        wire                                    processor_paused;
        
        localparam int C_DEBUG_UART_PERIOD      = (`MCU_MAIN_CLK_RATE) / (`DEBUG_UART_BAUD);
                
          
        
    //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    // PLL
    //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        
        
        assign LED = {7'h0A, reset_n};
    
        PLL pll_i (
            .CLKI  (osc_12MHz), 
            .CLKOP (clk), 
            .LOCK  (reset_n)
        );


    //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    // RISC-V
    //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   
        always_ff @(posedge clk, negedge reset_n) begin
            if (!reset_n) begin
                init_start <= 0;
                actual_cpu_start <= 0;
                actual_start_addr <= 0;
            end else begin
                init_start <= {init_start [$high(init_start) - 1 : 0], 1'b1};
                actual_cpu_start <= cpu_start | ((~init_start [$high(init_start)]) & init_start [$high(init_start) - 1]);
                //actual_cpu_start <= cpu_start | loader_done;
                if (cpu_start) begin
                    actual_start_addr <= cpu_start_addr;
                end else begin
                    actual_start_addr <= `DEFAULT_START_ADDR;
                end
            end
        end
        
        PulseRain_Reindeer_MCU PulseRain_Reindeer_MCU_i(
        //=====================================================================
        // clock and reset
        //=====================================================================
            .clk                                    (clk),
            .reset_n                                ((~cpu_reset) & reset_n),
            .sync_reset                             (1'b0),

        //=====================================================================
        // External Interrupt
        //=====================================================================
            .INTx                                   (2'b00),
            
        //=====================================================================
        // Interface Onchip Debugger
        //=====================================================================
            .ocd_read_enable                        (ocd_read_enable),
            .ocd_write_enable                       (ocd_write_enable),
            
            .ocd_rw_addr                            (ocd_rw_addr),
            .ocd_write_word                         (ocd_write_word),
            
            .ocd_mem_enable_out                     (ocd_mem_enable_out),
            .ocd_mem_word_out                       (ocd_mem_word_out),
        
            .ocd_reg_read_addr                      (5'd2),
            .ocd_reg_we                             (cpu_start),
            .ocd_reg_write_addr                     (5'd2),
            .ocd_reg_write_data                     (`DEFAULT_STACK_ADDR),
        

        //=====================================================================
        // UART
        //=====================================================================
            .RXD                                    (UART_RXD),
            .TXD                                    (uart_tx_cpu),
    
        //=====================================================================
        // GPIO
        //=====================================================================
            .GPIO_IN                                (0),
            .GPIO_OUT                               (),
     
        //=====================================================================
        // Interface for init/start
        //=====================================================================
            .start                                  (actual_cpu_start),
            .start_address                          (actual_start_addr),
        
            .processor_paused                       (processor_paused),
        
        //=====================================================================
        // Interface for DRAM
        //=====================================================================
            .dram_ack                               (1'b0),
            .dram_mem_read_data                     (0),
        
            .dram_mem_addr                          (),
            .dram_mem_read_en                       (),
            .dram_mem_write_en                      (),
            .dram_mem_byte_enable                   (),
            .dram_mem_write_data                    (),
            
            .peek_pc                                (),
            .peek_ir                                (),
            .peek_mem_write_en                      (),
            .peek_mem_write_data                    (),
            .peek_mem_addr                          ()
        );
        
    //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    // Hardware Loader
    //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        
        debug_coprocessor_wrapper #(.BAUD_PERIOD (C_DEBUG_UART_PERIOD)) hw_loader_i (
                    .clk                            (clk),
                    .reset_n                        (reset_n),
                    
                    .RXD                            (UART_RXD),
                    .TXD                            (uart_tx_ocd),
                        
                    .pram_read_enable_in            (ocd_mem_enable_out),
                    .pram_read_data_in              (ocd_mem_word_out),
                    
                    .pram_read_enable_out           (ocd_read_enable),
                    .pram_read_addr_out             (pram_read_addr),
                    
                    .pram_write_enable_out          (ocd_write_enable),
                    .pram_write_addr_out            (pram_write_addr),
                    .pram_write_data_out            (ocd_write_word),
                    
                    .cpu_reset                      (cpu_reset),
                    
                    .cpu_start                      (cpu_start),
                    .cpu_start_addr                 (cpu_start_addr),        
                    
                    .debug_uart_tx_sel_ocd1_cpu0    (debug_uart_tx_sel_ocd1_cpu0));
                             
        
        assign ocd_rw_addr = ocd_read_enable ? pram_read_addr [$high(ocd_rw_addr) : 0] : pram_write_addr [$high(ocd_rw_addr) : 0];        
         
         always_ff @(posedge clk, negedge reset_n) begin : uart_proc
              if (!reset_n) begin
                    UART_TXD <= 0;
              end else if (!debug_uart_tx_sel_ocd1_cpu0) begin
                    UART_TXD <= uart_tx_cpu;
              end else begin
                    UART_TXD <= uart_tx_ocd;
              end
         end 
         
         
endmodule
