`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    
// Design Name: 
// Module Name:    single_LUT_sum_gen 
// Project Name: 
// Target Devices: Xilinx Zynq-7000 (ZC702)
// Tool versions: 
// Description: Computes a 2-bit sum using a single LUT6_2 primitive.
//              Takes 2 bits of a, 2 bits of b, and a carry-in.
//              Outputs the 2-bit sum s[1:0].
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//   INIT = 64'hC936936CA5A55A5A
//   O5 = s[0] = a[0] XOR b[0] XOR c_in
//   O6 = s[1] = a[1] XOR b[1] XOR carry_from_bit0
//
//////////////////////////////////////////////////////////////////////////////////
module single_LUT_sum_gen(a, b, c_in, s);

input  [1:0] a, b;
input        c_in;
output [1:0] s;

LUT6_2 #(
    .INIT(64'hC936936CA5A55A5A) // Specify LUT Contents
) LUT6_inst_1 (
    .O6(s[1]),    // LUT general output
    .O5(s[0]),    // LUT 5-bit output
    .I0(b[0]),    // LUT input
    .I1(b[1]),    // LUT input
    .I2(a[0]),    // LUT input
    .I3(a[1]),    // LUT input
    .I4(c_in),    // LUT input
    .I5(1'd1)     // LUT input (must be 1 to enable O6)
);

endmodule
