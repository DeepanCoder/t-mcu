module uart_rx (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       rx,
    output logic       rx_valid,
    output logic [7:0] rx_data,
    input  logic [15:0] baud_div
);

    logic [7:0] shift_reg;
    logic [3:0] bit_count;
    logic [15:0] baud_count;
    logic receiving;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            receiving <= 0;
            bit_count <= 0;
            baud_count <= 0;
            rx_valid <= 0;
        end else if (!receiving && !rx) begin // Start bit detected
            receiving <= 1;
            bit_count <= 0;
            baud_count <= baud_div >> 1; // Center sampling
        end else if (receiving) begin
            if (baud_count == baud_div) begin
                shift_reg <= {rx, shift_reg[7:1]};
                bit_count <= bit_count + 1;
                baud_count <= 0;
                if (bit_count == 9) begin
                    rx_valid <= 1;
                    rx_data <= shift_reg;
                    receiving <= 0;
                end
            end else begin
                baud_count <= baud_count + 1;
            end
        end
    end

endmodule
