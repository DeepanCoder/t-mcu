module uart_tx (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       tx_start,
    input  logic [7:0] tx_data,
    output logic       tx_busy,
    output logic       tx,
    input  logic [15:0] baud_div
);

    logic [9:0] shift_reg;
    logic [3:0] bit_count;
    logic [15:0] baud_count;
    logic sending;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sending <= 0;
            bit_count <= 0;
            baud_count <= 0;
            tx <= 1; // Idle state
        end else if (tx_start && !sending) begin
            shift_reg <= {1'b1, tx_data, 1'b0}; // Start bit, data, stop bit
            sending <= 1;
            bit_count <= 0;
            baud_count <= 0;
        end else if (sending) begin
            if (baud_count == baud_div) begin
                tx <= shift_reg[0];
                shift_reg <= shift_reg >> 1;
                bit_count <= bit_count + 1;
                baud_count <= 0;
                if (bit_count == 9) sending <= 0;
            end else begin
                baud_count <= baud_count + 1;
            end
        end
    end

    assign tx_busy = sending;

endmodule
