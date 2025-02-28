module ahb_apb_bridge (
    input  logic        clk,
    input  logic        rst_n,
    
    // AHB Interface
    input  logic        hsel,
    input  logic [31:0] haddr,
    input  logic        hwrite,
    input  logic [31:0] hwdata,
    input  logic [1:0]  htrans,
    input  logic [2:0]  hsize,
    output logic [31:0] hrdata,
    output logic        hready,
    
    // APB Interface
    output logic        psel,
    output logic [31:0] paddr,
    output logic        penable,
    output logic        pwrite,
    output logic [31:0] pwdata,
    input  logic [31:0] prdata,
    input  logic        pready
);

    typedef enum logic [1:0] { IDLE, SETUP, ACCESS } state_t;
    state_t state, next_state;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            state <= IDLE;
        else
            state <= next_state;
    end

    always_comb begin
        case (state)
            IDLE:    next_state = hsel ? SETUP : IDLE;
            SETUP:   next_state = ACCESS;
            ACCESS:  next_state = pready ? IDLE : ACCESS;
            default: next_state = IDLE;
        endcase
    end

    assign psel    = (state == SETUP);
    assign penable = (state == ACCESS);
    assign paddr   = haddr;
    assign pwrite  = hwrite;
    assign pwdata  = hwdata;
    assign hrdata  = prdata;
    assign hready  = (state == IDLE || pready);

endmodule
