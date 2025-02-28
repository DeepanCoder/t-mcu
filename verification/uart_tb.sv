module tmcu_uart_tb;

    logic clk;
    logic rst_n;
    logic tx_start;
    logic [7:0] tx_data;
    logic tx_busy;
    logic tx;
    logic rx;
    logic rx_valid;
    logic [7:0] rx_data;
    logic [15:0] baud_div = 16'd16; // Example baud rate divider

    // Instantiate UART TX
    uart_tx uut_tx (
        .clk(clk),
        .rst_n(rst_n),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx_busy(tx_busy),
        .tx(tx),
        .baud_div(baud_div)
    );

    // Instantiate UART RX
    uart_rx uut_rx (
        .clk(clk),
        .rst_n(rst_n),
        .rx(tx), // Loopback connection
        .rx_valid(rx_valid),
        .rx_data(rx_data),
        .baud_div(baud_div)
    );

    // Clock Generation
    always #5 clk = ~clk;

    // Test Sequence
    initial begin
        clk = 0;
        rst_n = 0;
        tx_start = 0;
        tx_data = 0;
        #20;
        rst_n = 1;
        
        // Send Data
        tx_data = 8'hA5;
        tx_start = 1;
        #10;
        tx_start = 0;
        
        // Wait for RX Valid
        wait (rx_valid);
        $display("Received Data: %h", rx_data);
        
        #100;
        $finish;
    end

endmodule
