module tmcu_gpio (
    input  logic        clk,
    input  logic        rst_n,
    
    // AHB/APB Interface
    input  logic        psel,
    input  logic        penable,
    input  logic        pwrite,
    input  logic [31:0] paddr,
    input  logic [31:0] pwdata,
    output logic [31:0] prdata,
    output logic        pready,

    // GPIO Pins
    inout  logic [31:0] gpio_pins
);

    logic [31:0] gpio_data;  // GPIO output values
    logic [31:0] gpio_dir;   // GPIO direction (1 = Input, 0 = Output)

    // APB Read Logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            prdata <= 0;
        end else if (psel && !pwrite) begin
            case (paddr[3:0])
                4'h0: prdata <= gpio_pins;   // Read GPIO pin values
                4'h4: prdata <= gpio_dir;    // Read GPIO direction
                default: prdata <= 32'h0;
            endcase
        end
    end

    // APB Write Logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            gpio_data <= 0;
            gpio_dir  <= 32'hFFFFFFFF; // Default all as inputs
        end else if (psel && pwrite && penable) begin
            case (paddr[3:0])
                4'h0: gpio_data <= pwdata;   // Write GPIO output values
                4'h4: gpio_dir  <= pwdata;   // Set GPIO direction
            endcase
        end
    end

    // GPIO Tristate Logic
    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin
            assign gpio_pins[i] = (gpio_dir[i] == 0) ? gpio_data[i] : 1'bz;
        end
    endgenerate

endmodule
