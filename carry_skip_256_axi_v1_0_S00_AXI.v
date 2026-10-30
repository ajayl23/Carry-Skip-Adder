`timescale 1 ns / 1 ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: carry_skip_256_axi_v1_0_S00_AXI
// Description: AXI4-Lite slave interface for the 256-bit Carry-Skip Adder IP.
//
// AXI Register Map (base_addr + offset):
//   WRITE:
//     0x00 - 0x1C  (Reg  0-7 ) : Operand A [255:0]  -- 8 x 32-bit words, LSW at 0x00
//     0x20 - 0x3C  (Reg  8-15) : Operand B [255:0]  -- 8 x 32-bit words, LSW at 0x20
//     0x40         (Reg 16   ) : Control   [1:0]    -- bit[0]=CI (carry-in)
//   READ (result, read-only):
//     0x44 - 0x60  (Reg 17-24) : Result S  [255:0]  -- 8 x 32-bit words, LSW at 0x44
//     0x64         (Reg 25   ) : Status    [0]      -- bit[0]=CO (carry-out)
//
// Target: Xilinx Zynq-7000 (ZC702)
//////////////////////////////////////////////////////////////////////////////////

module carry_skip_256_axi_v1_0_S00_AXI #
(
    parameter integer C_S_AXI_DATA_WIDTH = 32,
    parameter integer C_S_AXI_ADDR_WIDTH = 7
)
(
    input  wire                                S_AXI_ACLK,
    input  wire                                S_AXI_ARESETN,
    input  wire [C_S_AXI_ADDR_WIDTH-1 : 0]    S_AXI_AWADDR,
    input  wire [2 : 0]                        S_AXI_AWPROT,
    input  wire                                S_AXI_AWVALID,
    output wire                                S_AXI_AWREADY,
    input  wire [C_S_AXI_DATA_WIDTH-1 : 0]    S_AXI_WDATA,
    input  wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB,
    input  wire                                S_AXI_WVALID,
    output wire                                S_AXI_WREADY,
    output wire [1 : 0]                        S_AXI_BRESP,
    output wire                                S_AXI_BVALID,
    input  wire                                S_AXI_BREADY,
    input  wire [C_S_AXI_ADDR_WIDTH-1 : 0]    S_AXI_ARADDR,
    input  wire [2 : 0]                        S_AXI_ARPROT,
    input  wire                                S_AXI_ARVALID,
    output wire                                S_AXI_ARREADY,
    output wire [C_S_AXI_DATA_WIDTH-1 : 0]    S_AXI_RDATA,
    output wire [1 : 0]                        S_AXI_RRESP,
    output wire                                S_AXI_RVALID,
    input  wire                                S_AXI_RREADY
);

    reg [C_S_AXI_ADDR_WIDTH-1:0] axi_awaddr;
    reg  axi_awready, axi_wready, axi_bvalid, axi_arready, axi_rvalid, aw_en;
    reg [1:0] axi_bresp, axi_rresp;
    reg [C_S_AXI_ADDR_WIDTH-1:0] axi_araddr;
    reg [C_S_AXI_DATA_WIDTH-1:0] axi_rdata;

    localparam integer ADDR_LSB          = (C_S_AXI_DATA_WIDTH/32) + 1;
    localparam integer OPT_MEM_ADDR_BITS = 4;

    reg [31:0] slv_reg0,  slv_reg1,  slv_reg2,  slv_reg3;
    reg [31:0] slv_reg4,  slv_reg5,  slv_reg6,  slv_reg7;
    reg [31:0] slv_reg8,  slv_reg9,  slv_reg10, slv_reg11;
    reg [31:0] slv_reg12, slv_reg13, slv_reg14, slv_reg15;
    reg [31:0] slv_reg16;

    wire slv_reg_wren, slv_reg_rden;
    reg [31:0] reg_data_out;
    integer    byte_index;

    assign S_AXI_AWREADY = axi_awready;
    assign S_AXI_WREADY  = axi_wready;
    assign S_AXI_BRESP   = axi_bresp;
    assign S_AXI_BVALID  = axi_bvalid;
    assign S_AXI_ARREADY = axi_arready;
    assign S_AXI_RDATA   = axi_rdata;
    assign S_AXI_RRESP   = axi_rresp;
    assign S_AXI_RVALID  = axi_rvalid;

    always @(posedge S_AXI_ACLK) begin
        if (!S_AXI_ARESETN) begin axi_awready <= 0; aw_en <= 1; end
        else if (!axi_awready && S_AXI_AWVALID && S_AXI_WVALID && aw_en) begin
            axi_awready <= 1; aw_en <= 0;
        end else if (S_AXI_BREADY && axi_bvalid) begin
            aw_en <= 1; axi_awready <= 0;
        end else axi_awready <= 0;
    end

    always @(posedge S_AXI_ACLK) begin
        if (!S_AXI_ARESETN) axi_awaddr <= 0;
        else if (!axi_awready && S_AXI_AWVALID && S_AXI_WVALID && aw_en)
            axi_awaddr <= S_AXI_AWADDR;
    end

    always @(posedge S_AXI_ACLK) begin
        if (!S_AXI_ARESETN) axi_wready <= 0;
        else if (!axi_wready && S_AXI_WVALID && S_AXI_AWVALID && aw_en)
            axi_wready <= 1;
        else axi_wready <= 0;
    end

    assign slv_reg_wren = axi_wready && S_AXI_WVALID && axi_awready && S_AXI_AWVALID;

    always @(posedge S_AXI_ACLK) begin
        if (!S_AXI_ARESETN) begin
            slv_reg0  <= 0; slv_reg1  <= 0; slv_reg2  <= 0; slv_reg3  <= 0;
            slv_reg4  <= 0; slv_reg5  <= 0; slv_reg6  <= 0; slv_reg7  <= 0;
            slv_reg8  <= 0; slv_reg9  <= 0; slv_reg10 <= 0; slv_reg11 <= 0;
            slv_reg12 <= 0; slv_reg13 <= 0; slv_reg14 <= 0; slv_reg15 <= 0;
            slv_reg16 <= 0;
        end else if (slv_reg_wren) begin
            case (axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB])
                5'h00: for(byte_index=0;byte_index<=3;byte_index=byte_index+1) if(S_AXI_WSTRB[byte_index]) slv_reg0 [(byte_index*8)+:8] <= S_AXI_WDATA[(byte_index*8)+:8];
                5'h01: for(byte_index=0;byte_index<=3;byte_index=byte_index+1) if(S_AXI_WSTRB[byte_index]) slv_reg1 [(byte_index*8)+:8] <= S_AXI_WDATA[(byte_index*8)+:8];
                5'h02: for(byte_index=0;byte_index<=3;byte_index=byte_index+1) if(S_AXI_WSTRB[byte_index]) slv_reg2 [(byte_index*8)+:8] <= S_AXI_WDATA[(byte_index*8)+:8];
                5'h03: for(byte_index=0;byte_index<=3;byte_index=byte_index+1) if(S_AXI_WSTRB[byte_index]) slv_reg3 [(byte_index*8)+:8] <= S_AXI_WDATA[(byte_index*8)+:8];
                5'h04: for(byte_index=0;byte_index<=3;byte_index=byte_index+1) if(S_AXI_WSTRB[byte_index]) slv_reg4 [(byte_index*8)+:8] <= S_AXI_WDATA[(byte_index*8)+:8];
                5'h05: for(byte_index=0;byte_index<=3;byte_index=byte_index+1) if(S_AXI_WSTRB[byte_index]) slv_reg5 [(byte_index*8)+:8] <= S_AXI_WDATA[(byte_index*8)+:8];
                5'h06: for(byte_index=0;byte_index<=3;byte_index=byte_index+1) if(S_AXI_WSTRB[byte_index]) slv_reg6 [(byte_index*8)+:8] <= S_AXI_WDATA[(byte_index*8)+:8];
                5'h07: for(byte_index=0;byte_index<=3;byte_index=byte_index+1) if(S_AXI_WSTRB[byte_index]) slv_reg7 [(byte_index*8)+:8] <= S_AXI_WDATA[(byte_index*8)+:8];
                5'h08: for(byte_index=0;byte_index<=3;byte_index=byte_index+1) if(S_AXI_WSTRB[byte_index]) slv_reg8 [(byte_index*8)+:8] <= S_AXI_WDATA[(byte_index*8)+:8];
                5'h09: for(byte_index=0;byte_index<=3;byte_index=byte_index+1) if(S_AXI_WSTRB[byte_index]) slv_reg9 [(byte_index*8)+:8] <= S_AXI_WDATA[(byte_index*8)+:8];
                5'h0A: for(byte_index=0;byte_index<=3;byte_index=byte_index+1) if(S_AXI_WSTRB[byte_index]) slv_reg10[(byte_index*8)+:8] <= S_AXI_WDATA[(byte_index*8)+:8];
                5'h0B: for(byte_index=0;byte_index<=3;byte_index=byte_index+1) if(S_AXI_WSTRB[byte_index]) slv_reg11[(byte_index*8)+:8] <= S_AXI_WDATA[(byte_index*8)+:8];
                5'h0C: for(byte_index=0;byte_index<=3;byte_index=byte_index+1) if(S_AXI_WSTRB[byte_index]) slv_reg12[(byte_index*8)+:8] <= S_AXI_WDATA[(byte_index*8)+:8];
                5'h0D: for(byte_index=0;byte_index<=3;byte_index=byte_index+1) if(S_AXI_WSTRB[byte_index]) slv_reg13[(byte_index*8)+:8] <= S_AXI_WDATA[(byte_index*8)+:8];
                5'h0E: for(byte_index=0;byte_index<=3;byte_index=byte_index+1) if(S_AXI_WSTRB[byte_index]) slv_reg14[(byte_index*8)+:8] <= S_AXI_WDATA[(byte_index*8)+:8];
                5'h0F: for(byte_index=0;byte_index<=3;byte_index=byte_index+1) if(S_AXI_WSTRB[byte_index]) slv_reg15[(byte_index*8)+:8] <= S_AXI_WDATA[(byte_index*8)+:8];
                5'h10: for(byte_index=0;byte_index<=3;byte_index=byte_index+1) if(S_AXI_WSTRB[byte_index]) slv_reg16[(byte_index*8)+:8] <= S_AXI_WDATA[(byte_index*8)+:8];
                default: begin end
            endcase
        end
    end

    always @(posedge S_AXI_ACLK) begin
        if (!S_AXI_ARESETN) begin axi_bvalid <= 0; axi_bresp <= 0; end
        else if (axi_awready && S_AXI_AWVALID && !axi_bvalid && axi_wready && S_AXI_WVALID) begin
            axi_bvalid <= 1; axi_bresp <= 0;
        end else if (S_AXI_BREADY && axi_bvalid) axi_bvalid <= 0;
    end

    always @(posedge S_AXI_ACLK) begin
        if (!S_AXI_ARESETN) begin axi_arready <= 0; axi_araddr <= 0; end
        else if (!axi_arready && S_AXI_ARVALID) begin
            axi_arready <= 1; axi_araddr <= S_AXI_ARADDR;
        end else axi_arready <= 0;
    end

    always @(posedge S_AXI_ACLK) begin
        if (!S_AXI_ARESETN) begin axi_rvalid <= 0; axi_rresp <= 0; end
        else if (axi_arready && S_AXI_ARVALID && !axi_rvalid) begin
            axi_rvalid <= 1; axi_rresp <= 0;
        end else if (axi_rvalid && S_AXI_RREADY) axi_rvalid <= 0;
    end

    assign slv_reg_rden = axi_arready & S_AXI_ARVALID & ~axi_rvalid;

    // -----------------------------------------------------------------------
    // carry_skip_adder_256 instantiation
    // -----------------------------------------------------------------------
    wire [255:0] A_in = {slv_reg7,  slv_reg6,  slv_reg5,  slv_reg4,
                         slv_reg3,  slv_reg2,  slv_reg1,  slv_reg0};
    wire [255:0] B_in = {slv_reg15, slv_reg14, slv_reg13, slv_reg12,
                         slv_reg11, slv_reg10, slv_reg9,  slv_reg8};
    wire         CI_in = slv_reg16[0];

    wire [255:0] S_out;
    wire         CO_out;

    carry_skip_adder_256 u_carry_skip_adder_256 (
        .a    (A_in),
        .b    (B_in),
        .c_in (CI_in),
        .sum  (S_out),
        .c_out(CO_out)
    );

    // Read mux
    always @(*) begin
        case (axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB])
            5'h00: reg_data_out = slv_reg0;
            5'h01: reg_data_out = slv_reg1;
            5'h02: reg_data_out = slv_reg2;
            5'h03: reg_data_out = slv_reg3;
            5'h04: reg_data_out = slv_reg4;
            5'h05: reg_data_out = slv_reg5;
            5'h06: reg_data_out = slv_reg6;
            5'h07: reg_data_out = slv_reg7;
            5'h08: reg_data_out = slv_reg8;
            5'h09: reg_data_out = slv_reg9;
            5'h0A: reg_data_out = slv_reg10;
            5'h0B: reg_data_out = slv_reg11;
            5'h0C: reg_data_out = slv_reg12;
            5'h0D: reg_data_out = slv_reg13;
            5'h0E: reg_data_out = slv_reg14;
            5'h0F: reg_data_out = slv_reg15;
            5'h10: reg_data_out = slv_reg16;
            5'h11: reg_data_out = S_out[31:0];
            5'h12: reg_data_out = S_out[63:32];
            5'h13: reg_data_out = S_out[95:64];
            5'h14: reg_data_out = S_out[127:96];
            5'h15: reg_data_out = S_out[159:128];
            5'h16: reg_data_out = S_out[191:160];
            5'h17: reg_data_out = S_out[223:192];
            5'h18: reg_data_out = S_out[255:224];
            5'h19: reg_data_out = {31'b0, CO_out};
            default: reg_data_out = 32'b0;
        endcase
    end

    always @(posedge S_AXI_ACLK) begin
        if (!S_AXI_ARESETN) axi_rdata <= 0;
        else if (slv_reg_rden) axi_rdata <= reg_data_out;
    end

endmodule
