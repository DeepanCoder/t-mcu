module tmcu_gpio (
    input  logic        clk,
    input  logic        rst_n,
    input  logic [31:0] gpio_in,
    output logic [31:0] gpio_out
);

    logic [31:0] gpio_reg;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            gpio_reg <= 32'b0;
        else
            gpio_reg <= gpio_in; // Simple GPIO register
    end

    assign gpio_out = gpio_reg;

endmodule
