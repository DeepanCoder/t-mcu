module tmcu_top (
    input  logic        clk,
    input  logic        rst_n,
    
    // UART signals
    input  logic        uart_rx,
    output logic        uart_tx,
    
    // GPIO signals
    inout  logic [7:0]  gpio
);

    // External parameter file will provide addresses
    extern parameter logic [31:0] UART_BASE_ADDR;
    extern parameter logic [31:0] GPIO_BASE_ADDR;

    // AHB signals
    logic [31:0] ahb_haddr, ahb_hwdata, ahb_hrdata;
    logic        ahb_hsel, ahb_hwrite, ahb_hready;
    logic [1:0]  ahb_htrans;
    logic [3:0]  ahb_hsize;

    // APB signals
    logic [31:0] apb_paddr, apb_pwdata, apb_prdata;
    logic        apb_psel, apb_penable, apb_pwrite, apb_pready;

    // Instantiate CPU Core
    cv32e40p_core u_cpu (
        .clk_i(clk),
        .rst_ni(rst_n),
        .ahb_haddr_o(ahb_haddr),
        .ahb_hwdata_o(ahb_hwdata),
        .ahb_hrdata_i(ahb_hrdata),
        .ahb_hsel_o(ahb_hsel),
        .ahb_hwrite_o(ahb_hwrite),
        .ahb_hready_o(ahb_hready),
        .ahb_htrans_o(ahb_htrans),
        .ahb_hsize_o(ahb_hsize)
    );

    // Instantiate AHB-to-APB Bridge
    ahb_apb_bridge u_ahb_apb (
        .clk(clk),
        .rst_n(rst_n),
        .hsel(ahb_hsel),
        .haddr(ahb_haddr),
        .hwrite(ahb_hwrite),
        .hwdata(ahb_hwdata),
        .htrans(ahb_htrans),
        .hsize(ahb_hsize),
        .hrdata(ahb_hrdata),
        .hready(ahb_hready),
        .psel(apb_psel),
        .paddr(apb_paddr),
        .penable(apb_penable),
        .pwrite(apb_pwrite),
        .pwdata(apb_pwdata),
        .prdata(apb_prdata),
        .pready(apb_pready)
    );

    // Instantiate UART
    tmcu_uart u_uart (
        .clk(clk),
        .rst_n(rst_n),
        .tx_start(apb_psel && (apb_paddr == UART_BASE_ADDR) && apb_pwrite),
        .tx_data(apb_pwdata[7:0]),
        .tx_ready(),
        .tx(uart_tx),
        .rx(uart_rx),
        .rx_valid(),
        .rx_data()
    );

    // Instantiate GPIO
    tmcu_gpio u_gpio (
        .clk(clk),
        .rst_n(rst_n),
        .gpio(gpio)
    );

endmodule
