`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2015/09/17 14:06:23
// Design Name: 
// Module Name: barrel_shift_arm
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


module barrel_shift_arm
#(parameter DATA_WIDTH = 32 , parameter ADDR_WIDTH = 5)
(  
    	input [(DATA_WIDTH -1):0] shift_in,
   	input [(ADDR_WIDTH -1):0] shift_amount,
    	input [1:0] shift_op,
    	input carry_flag,
    	output reg [(DATA_WIDTH -1):0] shift_out,
    	output reg shift_carry_out
);
	integer i;
    	reg [(DATA_WIDTH -1):0] inter1;
    	reg [(DATA_WIDTH -1):0] inter2;

	always@(*)
	begin
		shift_out = shift_in;
		shift_carry_out = carry_flag;
		case(shift_amount)
			0:begin shift_carry_out = shift_out[0];	
			    case(shift_op)
					1:shift_out=0;
					2:if(shift_out[(DATA_WIDTH -1)] == 0) shift_out = 0; else shift_out = 32'hffffffff;
					3:if(carry_flag == 0) shift_out = {1'b0 , shift_out[(DATA_WIDTH -1):1]}; else shift_out = {1'b1 , shift_out[(DATA_WIDTH -1):1]};
				endcase
				end
			default:
					case(shift_op)
						0: begin shift_carry_out = shift_out[(DATA_WIDTH -1)]; shift_out = shift_in << shift_amount;end
						1: begin shift_carry_out = shift_out[0]; shift_out = shift_in >> shift_amount;end
						2: begin shift_carry_out = shift_out[0]; shift_out = $signed(shift_in) >>>shift_amount ;end
						3: begin shift_carry_out = shift_out[0]; inter1 <= shift_in >> shift_amount; inter2 <= shift_in << (DATA_WIDTH -2-shift_amount); shift_out = inter1 + inter2;end						
					endcase
		endcase
	end


    
endmodule
