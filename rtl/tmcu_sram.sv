module tmcu_sram (
    input  logic        clk,
    input  logic [31:0] addr,
    input  logic [31:0] wdata,
    output logic [31:0] rdata,
    input  logic        write,
    input  logic        read
);

    logic [31:0] sram_mem [0:1023]; // 4KB SRAM

    always_ff @(posedge clk) begin
        if (write)
            sram_mem[addr[11:2]] <= wdata; // Word-aligned write
        if (read)
            rdata <= sram_mem[addr[11:2]];  // Word-aligned read
    end

endmodule
