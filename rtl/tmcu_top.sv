module tmcu_top (
    input  logic        clk,
    input  logic        rst_n,
    output logic [31:0] gpio_out,
    input  logic [31:0] gpio_in,
    input  logic        uart_rx,
    output logic        uart_tx
);

    // AHB Interconnect Signals
    logic [31:0] ahb_addr;
    logic [31:0] ahb_wdata;
    logic [31:0] ahb_rdata;
    logic        ahb_write;
    logic        ahb_read;

    // Instantiate CV32E40P Core
    cv32e40p_core u_cpu (
        .clk      (clk),
        .rst_n    (rst_n),
        .ahb_addr (ahb_addr),
        .ahb_wdata(ahb_wdata),
        .ahb_rdata(ahb_rdata),
        .ahb_write(ahb_write),
        .ahb_read (ahb_read)
    );

    // Instantiate ROM
    tmcu_rom u_rom (
        .clk   (clk),
        .addr  (ahb_addr),
        .rdata (ahb_rdata)
    );

    // Instantiate SRAM
    tmcu_sram u_sram (
        .clk    (clk),
        .addr   (ahb_addr),
        .wdata  (ahb_wdata),
        .rdata  (ahb_rdata),
        .write  (ahb_write),
        .read   (ahb_read)
    );

    // Instantiate GPIO
    tmcu_gpio u_gpio (
        .clk     (clk),
        .rst_n   (rst_n),
        .gpio_in (gpio_in),
        .gpio_out(gpio_out)
    );

    // Instantiate UART
    tmcu_uart u_uart (
        .clk    (clk),
        .rst_n  (rst_n),
        .rx     (uart_rx),
        .tx     (uart_tx)
    );

endmodule
