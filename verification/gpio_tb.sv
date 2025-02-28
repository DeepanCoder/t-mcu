module tmcu_gpio_tb;

    logic        clk;
    logic        rst_n;
    logic        psel;
    logic        penable;
    logic        pwrite;
    logic [7:0]  paddr;
    logic [31:0] pwdata;
    logic [31:0] prdata;
    logic        pready;
    tri   [31:0] gpio_pins;  // Use 'tri' for bidirectional behavior
    logic [31:0] gpio_drive; // Internal driver for testbench

    // Instantiate GPIO Module
    tmcu_gpio uut (
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

    // Drive GPIO Pins
    assign gpio_pins = gpio_drive; // Controlled by testbench

    // Clock Generation
    always #5 clk = ~clk;

    initial begin
        // Initialize Signals
        clk = 0;
        rst_n = 0;
        psel = 0;
        penable = 0;
        pwrite = 0;
        paddr = 0;
        pwdata = 0;
        gpio_drive = 32'h0; // Start with all 0

        #20 rst_n = 1;  // Release Reset

        // --- WRITE GPIO DIRECTION (Set as Input) ---
        #10;
        psel = 1;
        penable = 1;
        pwrite = 1;
        paddr = 8'h04;  // GPIO Direction Register
        pwdata = 32'hFFFFFFFF; // Set all GPIOs as input
        #10;
        psel = 0;
        penable = 0;

        // --- DRIVE GPIO PINS EXTERNALLY ---
        #10;
        gpio_drive = 32'hDEADBEEF; // Simulate external input

        // --- READ GPIO PINS ---
        #10;
        psel = 1;
        penable = 1;
        pwrite = 0;
        paddr = 8'h00; // GPIO Pin Read
        #10;
        $display("GPIO Pin Values = %h", prdata); // Should show 0xDEADBEEF
        psel = 0;
        penable = 0;

        #20;
        $finish;
    end

endmodule
