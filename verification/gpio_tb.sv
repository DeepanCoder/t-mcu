module tmcu_gpio_tb;

    logic clk;
    logic rst_n;
    logic psel;
    logic penable;
    logic pwrite;
    logic [31:0] paddr;
    logic [31:0] pwdata;
    logic [31:0] prdata;
    logic pready;
    wire [31:0] gpio_pins;

    // Instantiate GPIO
    tmcu_gpio uut_gpio (
        .clk(clk),
        .rst_n(rst_n),
        .psel(psel),
        .penable(penable),
        .pwrite(pwrite),
        .paddr(paddr),
        .pwdata(pwdata),
        .prdata(prdata),
        .pready(pready),
        .gpio_pins(gpio_pins)
    );

    // Clock Generation
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst_n = 0;
        psel = 0;
        penable = 0;
        pwrite = 0;
        paddr = 0;
        pwdata = 0;
        #20;
        rst_n = 1;

        // Set GPIO Direction (0 = Output, 1 = Input)
        psel = 1;
        penable = 1;
        pwrite = 1;
        paddr = 4'h4;
        pwdata = 32'hFFFFFFF0; // Last 4 pins as output
        #10;
        psel = 0;
        penable = 0;

        // Write Data to GPIO
        psel = 1;
        penable = 1;
        pwrite = 1;
        paddr = 4'h0;
        pwdata = 32'h0000000F; // Set last 4 pins HIGH
        #10;
        psel = 0;
        penable = 0;

        #100;
        $finish;
    end

endmodule
