module tmcu_uart (
    input  logic       clk,
    input  logic       rst_n,
    
    // AHB/APB Interface
    input  logic       psel,
    input  logic       penable,
    input  logic       pwrite,
    input  logic [31:0] paddr,
    input  logic [31:0] pwdata,
    output logic [31:0] prdata,
    output logic        pready,

    // UART Signals
    input  logic       rx,
    output logic       tx
);

    // UART Registers
    logic [7:0] tx_data;
    logic       tx_start;
    logic       tx_busy;
    
    logic [7:0] rx_data;
    logic       rx_valid;
    
    logic       uart_enable;
    logic [15:0] baud_divider;

    // APB Read Logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            prdata <= 0;
        end else if (psel && !pwrite) begin
            case (paddr[3:0])
                4'h0: prdata <= {24'b0, tx_data};        // TX Data
                4'h4: prdata <= {24'b0, rx_data};        // RX Data
                4'h8: prdata <= {30'b0, rx_valid, tx_busy}; // Status
                4'hC: prdata <= {15'b0, uart_enable, baud_divider}; // Control
                default: prdata <= 32'h0;
            endcase
        end
    end

    // APB Write Logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tx_start <= 0;
            uart_enable <= 0;
            baud_divider <= 16'd325;  // Default for 115200 baud @ 25MHz
        end else if (psel && pwrite && penable) begin
            case (paddr[3:0])
                4'h0: begin
                    tx_data  <= pwdata[7:0];
                    tx_start <= 1'b1;
                end
                4'hC: begin
                    uart_enable <= pwdata[16];
                    baud_divider <= pwdata[15:0];
                end
            endcase
        end
    end

    // Instantiate TX and RX modules
    uart_tx u_tx (
        .clk(clk),
        .rst_n(rst_n),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx_busy(tx_busy),
        .tx(tx),
        .baud_div(baud_divider)
    );

    uart_rx u_rx (
        .clk(clk),
        .rst_n(rst_n),
        .rx(rx),
        .rx_valid(rx_valid),
        .rx_data(rx_data),
        .baud_div(baud_divider)
    );

endmodule
