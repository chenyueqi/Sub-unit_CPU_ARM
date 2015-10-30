`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2015/09/20 13:35:10
// Design Name: 
// Module Name: test_alu
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


module test_alu();
	reg [31:0] a_in , b_in ;
	reg [3:0] alu_op;
	reg cin;
	wire negative , zero , carry ,  overflow;
	wire [31:0] alu_out;

	alu a1(
	.a_in(a_in),
	.b_in(b_in),
	.cin(cin),
	.alu_out(alu_out),
	.alu_op(alu_op),
	.negative(negative),
	.zero(zero),
	.carry(carry),
	.overflow(overflow)
	);

	initial begin
		a_in = 32'h01234561;
		b_in = 32'h8edcba91;	
		cin = 0;
		alu_op = 4'b0000;//and
		#1
		if(!((alu_out == 32'h00000001) && (negative == 0) && (zero == 0) && (carry == 0)))
			$stop;
		alu_op = 4'b0001;//eor
		#1
		if(!((alu_out == 32'h8ffffff0) && (negative == 1) && (zero == 0) && (carry == 0)))
			$stop;
		alu_op = 4'b0010;//sub
		#1
		if(!((alu_out == 32'h72468ad0) && (negative == 0) && (zero == 0) && (carry == 0) && (overflow == 0)))
			$stop;
		alu_op = 4'b0011;//rsb
		#1
		if(!((alu_out == 32'h8db97530) && (negative == 1) && (zero == 0) && (carry == 1) && (overflow == 0)))
			$stop;
		alu_op = 4'b0100;//add
		#1
		if(!((alu_out == 32'h8ffffff2) && (negative == 1) && (zero == 0) && (carry == 0) && (overflow == 0)))
			$stop;
		alu_op = 4'b0101;//adc
		cin = 1;
		a_in = 32'hffffffff;
		b_in = 0;
		#1
		if(!((alu_out == 32'h00000000) && (negative == 0) && (zero == 1) && (carry == 1) && (overflow == 0)))
			$stop;
		alu_op = 4'b0110;//sbc
		#1
		if(!((alu_out == 32'h00000001) && (negative == 0) && (zero == 0) && (carry == 0) && (overflow == 0)))
			$stop;
		alu_op = 4'b0111;//rsc
		#1
		if(!((alu_out == 32'h00000003) && (negative == 0) && (zero == 0) && (carry == 0) && (overflow == 0)))
			$stop;
		alu_op = 4'b1000;//tst
		#1
		if(!((alu_out == 32'h00000000) && (negative == 0) && (zero == 1) && (carry == 1)))
			$stop;
		alu_op = 4'b1001;//teq
		a_in = 32'h0000ffff;
		b_in = 32'hffff0000;
		#1
		if(!((alu_out == 32'hffffffff) && (negative == 1) && (zero == 0) && (carry == 1)))
			$stop;
		alu_op = 4'b1010;//cmp
		#1
		if(!((alu_out == 32'h0001ffff) && (negative == 0) && (zero == 0) && (carry == 0)))
			$stop;
		alu_op = 4'b1011;//cmn
		a_in = 32'hffff0000;
		b_in = 32'h80000000;
		#1
		if(!((alu_out == 32'h7fff0000) && (negative == 0) && (zero == 0) && (carry == 1) && (overflow == 1)))
			$stop;
		alu_op = 4'b1100;//orr
		#1
		if(!((alu_out == 32'hffff0000) && (negative == 1) && (zero == 0) && (carry == 1)))
			$stop;
		alu_op = 4'b1101;//mov
		cin = 0;
		#1
		if(!((alu_out == 32'h80000000) && (negative == 1) && (zero == 0) && (carry == 0)))
			$stop;
		alu_op = 4'b1110;//bic
		#1
		if(!((alu_out == 32'h7fff0000) && (negative == 0) && (zero == 0) && (carry == 0)))
			$stop;
		alu_op = 4'b1111;//mvn
		#1
		if(!((alu_out == 32'h7fffffff) && (negative == 0) && (zero == 0) && (carry == 0)))
			$stop;
		#1
		$stop;
	end
endmodule
