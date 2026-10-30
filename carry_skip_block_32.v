`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    
// Design Name: 
// Module Name:    carry_skip_block_32 
// Project Name: 
// Target Devices: Xilinx Zynq-7000 (ZC702)
// Tool versions: 
// Description: 32-bit carry-skip block built from four 8-bit carry slices
//              (one init slice + three regular slices).
//
//              Block structure (32 bits = 4 x 8-bit slices):
//                Slice 0 [7:0]   : single_slice_carry_gen_init (CYINIT=c_in)
//                Slice 1 [15:8]  : single_slice_carry_gen (CI=carry from slice 0)
//                Slice 2 [23:16] : single_slice_carry_gen (CI=carry from slice 1)
//                Slice 3 [31:24] : single_slice_carry_gen (CI=carry from slice 2)
//
//              Skip logic:
//                block_prop = AND of all 16 group-propagate signals (4 slices x 4 groups)
//                If block_prop=1, the carry skips the entire block: c_out = c_in
//                Otherwise, c_out is the ripple carry from slice 3
//
// Dependencies: single_slice_carry_gen_init.v
//               single_slice_carry_gen.v
//               single_LUT_sum_gen.v
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//   32-bit block gives a good skip granularity for a 256-bit adder (8 blocks).
//
//////////////////////////////////////////////////////////////////////////////////
module carry_skip_block_32(a, b, c_in, sum, c_out);

input  [31:0] a, b;
input          c_in;
output [31:0] sum;
output         c_out;

// Internal carry chain between slices
// c_sl[0] = c_in (conceptual), c_sl[4] = carry out of slice 0, etc.
wire [3:0] c_sl0, c_sl1, c_sl2, c_sl3; // 4 carry bits out of each slice

// Propagate buses from each slice (used to form block propagate)
wire [3:0] prop0, prop1, prop2, prop3;

// -----------------------------------------------------------------------
// Slice 0: a[7:0], b[7:0] -- init slice (CYINIT=c_in)
// -----------------------------------------------------------------------
single_slice_carry_gen_init slice0 (
    .a       (a[7:0]),
    .b       (b[7:0]),
    .c_in    (c_in),
    .c_out   (c_sl0),
    .prop_out(prop0)
);

// -----------------------------------------------------------------------
// Slice 1: a[15:8], b[15:8] -- chained (CI = c_sl0[3])
// -----------------------------------------------------------------------
single_slice_carry_gen slice1 (
    .a       (a[15:8]),
    .b       (b[15:8]),
    .c_in    (c_sl0[3]),
    .c_out   (c_sl1),
    .prop_out(prop1)
);

// -----------------------------------------------------------------------
// Slice 2: a[23:16], b[23:16] -- chained (CI = c_sl1[3])
// -----------------------------------------------------------------------
single_slice_carry_gen slice2 (
    .a       (a[23:16]),
    .b       (b[23:16]),
    .c_in    (c_sl1[3]),
    .c_out   (c_sl2),
    .prop_out(prop2)
);

// -----------------------------------------------------------------------
// Slice 3: a[31:24], b[31:24] -- chained (CI = c_sl2[3])
// -----------------------------------------------------------------------
single_slice_carry_gen slice3 (
    .a       (a[31:24]),
    .b       (b[31:24]),
    .c_in    (c_sl2[3]),
    .c_out   (c_sl3),
    .prop_out(prop3)
);

// -----------------------------------------------------------------------
// Block propagate: ALL 16 group-propagates must be 1
// -----------------------------------------------------------------------
wire block_prop = (&prop0) & (&prop1) & (&prop2) & (&prop3);

// Skip mux: if entire block propagates, pass c_in directly to c_out
assign c_out = block_prop ? c_in : c_sl3[3];

// -----------------------------------------------------------------------
// Sum generation: 16 x single_LUT_sum_gen per block
// c_temp reconstruction for sum:
//   Bits [7:0]   use carries c_in, c_sl0[0], c_sl0[1], c_sl0[2]
//   Bits [15:8]  use carries c_sl0[3], c_sl1[0], c_sl1[1], c_sl1[2]
//   Bits [23:16] use carries c_sl1[3], c_sl2[0], c_sl2[1], c_sl2[2]
//   Bits [31:24] use carries c_sl2[3], c_sl3[0], c_sl3[1], c_sl3[2]
// -----------------------------------------------------------------------
wire [15:0] c_for_sum;
assign c_for_sum[0]  = c_in;
assign c_for_sum[1]  = c_sl0[0];
assign c_for_sum[2]  = c_sl0[1];
assign c_for_sum[3]  = c_sl0[2];
assign c_for_sum[4]  = c_sl0[3];
assign c_for_sum[5]  = c_sl1[0];
assign c_for_sum[6]  = c_sl1[1];
assign c_for_sum[7]  = c_sl1[2];
assign c_for_sum[8]  = c_sl1[3];
assign c_for_sum[9]  = c_sl2[0];
assign c_for_sum[10] = c_sl2[1];
assign c_for_sum[11] = c_sl2[2];
assign c_for_sum[12] = c_sl2[3];
assign c_for_sum[13] = c_sl3[0];
assign c_for_sum[14] = c_sl3[1];
assign c_for_sum[15] = c_sl3[2];

genvar j;
generate for (j = 0; j < 16; j = j + 1)
begin: sum_gen
    single_LUT_sum_gen sum_mod (
        .a    (a[2*j+1:2*j]),
        .b    (b[2*j+1:2*j]),
        .c_in (c_for_sum[j]),
        .s    (sum[2*j+1:2*j])
    );
end
endgenerate

endmodule
