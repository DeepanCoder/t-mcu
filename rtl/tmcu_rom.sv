module tmcu_rom (
    input  logic        clk,
    input  logic [31:0] addr,
    output logic [31:0] rdata
);

    logic [31:0] rom_mem [0:255]; // 1KB ROM

    initial $readmemh("bootloader.hex", rom_mem);

    always_ff @(posedge clk) begin
        rdata <= rom_mem[addr[9:2]]; // Word-aligned access
    end

endmodule
