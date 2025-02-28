// tmcu_memory_map.sv - Defines memory and peripheral addresses

`ifndef TMCU_MEMORY_MAP_SV
`define TMCU_MEMORY_MAP_SV

// AHB Bus Address Map
parameter logic [31:0] ROM_BASE_ADDR   = 32'h00000000;
parameter logic [31:0] SRAM_BASE_ADDR  = 32'h00008000;

// APB Bus Address Map (Peripherals)
parameter logic [31:0] UART_BASE_ADDR  = 32'h40000000;
parameter logic [31:0] GPIO_BASE_ADDR  = 32'h40001000;
parameter logic [31:0] SPI_BASE_ADDR   = 32'h40002000; // Reserved for SPI in future

`endif
