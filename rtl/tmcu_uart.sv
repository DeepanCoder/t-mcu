module tmcu_uart #(
    parameter CLK_FREQ = 25000000, // 25 MHz clock
    parameter BAUD_RATE = 115200   // Default baud rate
)(
    input  logic        clk,
    input  logic        rst_n,
    input  logic        tx_start,    // TX start signal
    input  logic [7:0]  tx_data,     // TX data input
    output logic        tx_ready,    // TX ready status
    output logic        tx,          // UART TX line

    input  logic        rx,          // UART RX line
    output logic        rx_valid,    // RX valid flag
    output logic [7:0]  rx_data      // RX data output
);

    // Baud rate generation
    localparam integer BAUD_DIV = CLK_FREQ / BAUD_RATE;
    reg [15:0] baud_counter;
    reg baud_tick;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            baud_counter <= 0;
            baud_tick <= 0;
        end else if (baud_counter >= BAUD_DIV / 2) begin
            baud_counter <= 0;
            baud_tick <= ~baud_tick;
        end else begin
            baud_counter <= baud_counter + 1;
        end
    end

    // TX Logic
    reg [9:0] tx_shift_reg;
    reg [3:0] tx_bit_count;
    reg tx_busy;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tx_shift_reg <= 10'b1111111111;
            tx_bit_count <= 0;
            tx_busy <= 0;
            tx <= 1;
        end else if (tx_start && !tx_busy) begin
            tx_shift_reg <= {1'b1, tx_data, 1'b0}; // Start bit (0), Data, Stop bit (1)
            tx_bit_count <= 0;
            tx_busy <= 1;
        end else if (baud_tick && tx_busy) begin
            tx <= tx_shift_reg[0];
            tx_shift_reg <= {1'b1, tx_shift_reg[9:1]};
            tx_bit_count <= tx_bit_count + 1;
            if (tx_bit_count == 9) tx_busy <= 0; // Transmission complete
        end
    end

    assign tx_ready = ~tx_busy;

    // RX Logic
    reg [9:0] rx_shift_reg;
    reg [3:0] rx_bit_count;
    reg rx_busy;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rx_shift_reg <= 0;
            rx_bit_count <= 0;
            rx_busy <= 0;
            rx_valid <= 0;
        end else if (!rx_busy && !rx) begin // Detect start bit
            rx_busy <= 1;
            rx_bit_count <= 0;
        end else if (baud_tick && rx_busy) begin
            rx_shift_reg <= {rx, rx_shift_reg[9:1]};
            rx_bit_count <= rx_bit_count + 1;
            if (rx_bit_count == 9) begin
                rx_busy <= 0;
                rx_valid <= 1;
                rx_data <= rx_shift_reg[8:1]; // Extract data bits
            end
        end else begin
            rx_valid <= 0;
        end
    end

endmodule
