module tmcu_gpio (
    input  logic        clk,
    input  logic        rst_n,

    // APB Interface
    input  logic        psel,
    input  logic        penable,
    input  logic        pwrite,
    input  logic [7:0]  paddr,
    input  logic [31:0] pwdata,
    output logic [31:0] prdata,
    output logic        pready,

    // GPIO Signals
    inout  wire  [31:0] gpio_pins
);

    logic [31:0] gpio_out;  // GPIO output register
    logic [31:0] gpio_dir;  // GPIO direction register (1 = input, 0 = output)

    // Tristate buffer for GPIO pins
    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin : gpio_tristate
            assign gpio_pins[i] = gpio_dir[i] ? 1'bz : gpio_out[i]; // Tristate logic
        end
    endgenerate

    // APB Read & Write Logic
    always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        prdata   <= 0;
        pready   <= 0;
        gpio_out <= 0;
        gpio_dir <= 0;
    end else if (psel && penable) begin
        pready <= 1; // Transaction complete

        if (pwrite) begin
            case (paddr[3:0])
                4'h0: gpio_out <= pwdata;  // Write GPIO output register
                4'h4: gpio_dir <= pwdata;  // Write GPIO direction register
                default: ;
            endcase
        end else begin
            case (paddr[3:0])
                4'h0: prdata <= gpio_pins; // Read actual GPIO pin values
                4'h4: prdata <= gpio_dir;  // Read GPIO direction
                default: prdata <= 32'h0;
            endcase
        end
    end else begin
        pready <= 0; // No transaction
    end
    end

endmodule
