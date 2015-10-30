`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2015/09/17 14:54:52
// Design Name: 
// Module Name: test_barrel_shift_arm
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module test_barrel_shift_arm();
parameter DATA_WIDTH = 32;
parameter ADDR_WIDTH = 5;
    reg [(DATA_WIDTH -1):0] shift_in;
    reg [(ADDR_WIDTH -1):0] shift_amount;
    reg [1:0] shift_op;
    reg carry_flag;
    wire [(DATA_WIDTH -1):0] shift_out;
    wire shift_carry_out;
    
    barrel_shift_arm t1(
    .shift_in(shift_in),
    .shift_amount(shift_amount),
    .shift_op(shift_op),
    .carry_flag(carry_flag),
    .shift_out(shift_out),
    .shift_carry_out(shift_carry_out)
    );

    initial begin
	    shift_in = 32'h12345678;
	    shift_amount = 4;
	    shift_op = 0;
	    carry_flag = 1;
	    #1
	    shift_amount = 3;
	    shift_op = 1;
	    #1
	    shift_amount = 0;
	    #1
	    shift_in = 32'hf2345678;
	    shift_amount = 2;
	    shift_op = 2;
	    #1
	    shift_amount = 0;
	    #1
	    shift_amount = 1;
	    shift_op = 3;
	    #1
	    shift_amount = 0;
	    #1
	    carry_flag = 0;
	    #1
	   $stop; 
    end
endmodule
