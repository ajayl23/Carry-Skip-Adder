`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    
// Design Name: 
// Module Name:    single_slice_carry_gen 
// Project Name: 
// Target Devices: Xilinx Zynq-7000 (ZC702)
// Tool versions: 
// Description: Middle/non-first 8-bit carry slice for carry-skip adder.
//              Uses CI (carry cascade input) to chain from previous CARRY4.
//              Also outputs the 4 individual propagate signals for the
//              block-propagate (skip) condition computation.
//
// Dependencies: None
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//   INIT = 64'h000006600000F880
//
//////////////////////////////////////////////////////////////////////////////////
module single_slice_carry_gen(a, b, c_in, c_out, prop_out);

input  [7:0] a, b;
input        c_in;
output [3:0] c_out;
output [3:0] prop_out;  // Individual 2-bit group propagates for skip logic

wire [3:0] prop, gen;

// Bits [1:0]
LUT6_2 #(
    .INIT(64'h000006600000F880) // Specify LUT Contents
) LUT6_inst_1 (
    .O6(prop[0]),  // LUT general output - group propagate
    .O5(gen[0]),   // LUT 5-bit output   - group generate
    .I0(a[0]),     // LUT input
    .I1(b[0]),     // LUT input
    .I2(a[1]),     // LUT input
    .I3(b[1]),     // LUT input
    .I4(1'd0),     // LUT input
    .I5(1'd1)      // LUT input (must be 1 to enable O6)
);

// Bits [3:2]
LUT6_2 #(
    .INIT(64'h000006600000F880) // Specify LUT Contents
) LUT6_inst_2 (
    .O6(prop[1]),  // LUT general output - group propagate
    .O5(gen[1]),   // LUT 5-bit output   - group generate
    .I0(a[2]),     // LUT input
    .I1(b[2]),     // LUT input
    .I2(a[3]),     // LUT input
    .I3(b[3]),     // LUT input
    .I4(1'd0),     // LUT input
    .I5(1'd1)      // LUT input (must be 1 to enable O6)
);

// Bits [5:4]
LUT6_2 #(
    .INIT(64'h000006600000F880) // Specify LUT Contents
) LUT6_inst_3 (
    .O6(prop[2]),  // LUT general output - group propagate
    .O5(gen[2]),   // LUT 5-bit output   - group generate
    .I0(a[4]),     // LUT input
    .I1(b[4]),     // LUT input
    .I2(a[5]),     // LUT input
    .I3(b[5]),     // LUT input
    .I4(1'd0),     // LUT input
    .I5(1'd1)      // LUT input (must be 1 to enable O6)
);

// Bits [7:6]
LUT6_2 #(
    .INIT(64'h000006600000F880) // Specify LUT Contents
) LUT6_inst_4 (
    .O6(prop[3]),  // LUT general output - group propagate
    .O5(gen[3]),   // LUT 5-bit output   - group generate
    .I0(a[6]),     // LUT input
    .I1(b[6]),     // LUT input
    .I2(a[7]),     // LUT input
    .I3(b[7]),     // LUT input
    .I4(1'd0),     // LUT input
    .I5(1'd1)      // LUT input (must be 1 to enable O6)
);

assign prop_out = prop;

// CARRY4: chained slices use CI, CYINIT is 0
CARRY4 CARRY4_inst (
    .CO(c_out),     // 4-bit carry out
    .O(),           // 4-bit carry chain XOR data out (unused - sum via LUT)
    .CI(c_in),      // 1-bit carry cascade input
    .CYINIT(1'd0),  // 1-bit carry initialization (tied low for chained slices)
    .DI(gen),       // 4-bit carry-MUX data in (generate)
    .S(prop)        // 4-bit carry-MUX select input (propagate)
);

endmodule
