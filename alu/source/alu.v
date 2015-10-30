`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2015/09/19 23:44:20
// Design Name: 
// Module Name: alu
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


module alu
#(parameter DATA_WIDTH = 32)
(
	input  [(DATA_WIDTH -1):0] a_in, b_in,
	input  [3:0] alu_op,
	input cin,
	output reg   negative , zero , carry , overflow,
	output reg [(DATA_WIDTH -1):0] alu_out
);
	
	always@(*)
	begin
		case(alu_op)
			4'b0000://and
				alu_out = a_in & b_in;
			4'b0001://eor
				alu_out = a_in ^ b_in;
			4'b0010://sub
			begin
				{carry , alu_out} = a_in - b_in;
				carry = ~carry;
			end
			4'b0011://rsb
			begin
				{carry , alu_out} = b_in - a_in;
				carry = ~carry;
			end
			4'b0100://add
				{carry , alu_out} = a_in + b_in;
			4'b0101://adc
				{carry , alu_out} = a_in + b_in + cin;
			4'b0110://sbc
			begin
				{carry , alu_out} = a_in - b_in - (~cin);
				carry = ~carry;
			end
			4'b0111://rsc
			begin
				{carry , alu_out} = b_in - a_in - (~cin);
				carry = ~carry;
			end
			4'b1000://tst
				alu_out = a_in & b_in;
			4'b1001://teq
				alu_out = a_in ^ b_in;
			4'b1010://cmp
			begin
				{carry , alu_out} = a_in - b_in;
				carry = ~carry;
			end
			4'b1011://cmn
				{carry , alu_out} = a_in + b_in;
			4'b1100://orr
				alu_out = a_in | b_in;
			4'b1101://mov
				alu_out = b_in;
			4'b1110://bic
				alu_out = a_in & (~b_in);
			4'b1111://mvn
				alu_out = ~(b_in);
		endcase

		zero = (alu_out == 0)? 1 : 0;
		negative = alu_out[31];
		if((alu_op[3:2] == 1) || (alu_op[2:1] == 1))
			overflow = ((~a_in[31])&(~b_in[31])&(alu_out[31]) | (a_in[31]&b_in[31]&(~alu_out[31])));
		if((alu_op[3:2] == 3) || (alu_op[2:1] == 0))
			carry = cin;
	end	
endmodule
