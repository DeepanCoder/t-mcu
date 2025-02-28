module tmcu_gpio (
    input  logic        clk,
    input  logic        rst_n,
    input  logic [31:0] gpio_write, // Data to write to GPIO
    input  logic [31:0] gpio_dir,   // 1 = Input, 0 = Output
    output logic [31:0] gpio_read,  // Read data from GPIO
    inout  wire  [31:0] gpio_pins   // GPIO bidirectional pins
);

    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin : gpio_control
            assign gpio_pins[i] = gpio_dir[i] ? 1'bz : gpio_write[i]; // Output mode if dir=0, else High-Z
            assign gpio_read[i] = gpio_pins[i]; // Always read the pin value
        end
    endgenerate

endmodule
