`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    
// Design Name: 
// Module Name:    carry_skip_adder_256 
// Project Name: 
// Target Devices: Xilinx Zynq-7000 (ZC702)
// Tool versions: 
// Description: 256-bit carry-skip adder using eight 32-bit carry-skip blocks.
//              Uses LUT6_2 and CARRY4 primitives throughout, following the same
//              coding style as the reference FPGA_Fast_Adder files.
//
//              Architecture:
//                8 x carry_skip_block_32, each handling 32 bits
//                Each block: 4 x 8-bit slices (LUT6_2 + CARRY4) + skip MUX
//
//              Critical Path:
//                c_in -> [4 CARRY4 slices in block0] -> skip_MUX(block0) ->
//                        [4 CARRY4 slices in block1] -> skip_MUX(block1) ->
//                        ...
//                        [4 CARRY4 slices in block7] -> skip_MUX(block7) -> c_out
//
//              Note on FPGA performance:
//                On Xilinx Zynq-7000, the standard fast adder (carry_chain_sum)
//                is FASTER than this carry-skip adder. The dedicated hardened
//                CARRY4 routing between adjacent slices is much faster than the
//                general LUT-mux routing used by the skip logic. Refer to the
//                fast_adder_256_ip for the comparison design.
//
// Dependencies: carry_skip_block_32.v
//               single_slice_carry_gen_init.v
//               single_slice_carry_gen.v
//               single_LUT_sum_gen.v
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//   256 bits / 32 bits per block = 8 skip blocks
//
//////////////////////////////////////////////////////////////////////////////////
module carry_skip_adder_256(a, b, c_in, sum, c_out);

parameter W = 256;
parameter BLOCKS = 8;
parameter BLOCK_W = 32;

input  [W-1:0] a, b;
input           c_in;
output [W-1:0] sum;
output          c_out;

// Inter-block carry: c_blk[0]=c_in, c_blk[8]=c_out
wire [BLOCKS:0] c_blk;

assign c_blk[0] = c_in;
assign c_out     = c_blk[BLOCKS];

// Eight 32-bit carry-skip blocks
genvar i;

generate for (i = 0; i < BLOCKS; i = i + 1)
begin: skip_blocks
    carry_skip_block_32 block (
        .a    (a[i*BLOCK_W +: BLOCK_W]),
        .b    (b[i*BLOCK_W +: BLOCK_W]),
        .c_in (c_blk[i]),
        .sum  (sum[i*BLOCK_W +: BLOCK_W]),
        .c_out(c_blk[i+1])
    );
end
endgenerate

endmodule
