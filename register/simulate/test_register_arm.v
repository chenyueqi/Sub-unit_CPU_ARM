`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2015/09/06 20:08:41
// Design Name: 
// Module Name: test_register_arm
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


module test_register_arm();
parameter DATA_WIDTH = 32;
parameter ADDR_WIDTH = 4;
    reg [(ADDR_WIDTH -1):0] Rn_r_addr , Rm_r_addr , Rs_r_addr , Rd_r_addr ,Rn_w_addr , Rd_w_addr;
    reg [(DATA_WIDTH -1):0] Rd_in , Rn_in , PC_in , CPSR_in , SPSR_in;
    reg CPSR_write_en , SPSR_write_en;
    reg [3:0] CPSR_byte_w_en , SPSR_byte_w_en;
    reg [3:0] Rd_byte_w_en , Rn_byte_w_en;
    reg clk;
    reg Rst;
    wire [(DATA_WIDTH -1):0] Rn_out,Rm_out , Rs_out , Rd_out , Pc_out , CPSR_out , SPSR_out;
    wire [4:0] Mode_out;
    wire [2:0] mode;
    
    register_arm t1(
    .Rn_r_addr(Rn_r_addr),
    .Rm_r_addr(Rm_r_addr),
    .Rs_r_addr(Rs_r_addr),
    .Rd_r_addr(Rd_r_addr),
    .Rn_w_addr(Rn_w_addr),
    .Rd_w_addr(Rd_w_addr),
    .Rd_in(Rd_in),
    .Rn_in(Rn_in),
    .PC_in(PC_in),
    .CPSR_in(CPSR_in),
    .SPSR_in(SPSR_in),
    .CPSR_write_en(CPSR_write_en),
    .SPSR_write_en(SPSR_write_en),
    .CPSR_byte_w_en(CPSR_byte_w_en),
    .SPSR_byte_w_en(SPSR_byte_w_en),
    .Rd_byte_w_en(Rd_byte_w_en),
    .Rn_byte_w_en(Rn_byte_w_en),
    .Rn_out(Rn_out),
    .Rs_out(Rs_out),
    .Rd_out(Rd_out),
    .Rm_out(Rm_out),
    .Pc_out(Pc_out),
    .CPSR_out(CPSR_out),
    .SPSR_out(SPSR_out),
    .Mode_out(Mode_out),
    .mode(mode),
    .clk(clk),
    .Rst(Rst)
    );
    
    initial begin
        clk = 1'b1;
	Rst = 0;
	#1
	clk = 1'b0;
	#1
	clk = 1'b1;
	Rst = 1;
	#1
	clk = 1'b0;	
	#1
	clk = 1'b1;
	if(!(CPSR_out == 32'h000000d3))
		$stop;
        Rn_r_addr = 12;
        Rm_r_addr = 12;
        Rs_r_addr = 14;
        Rd_r_addr = 14;
        Rn_w_addr = 12;
        Rd_w_addr = 14;
        Rn_in = 12;
        Rd_in = 14;
        Rn_byte_w_en = 0;
        Rd_byte_w_en = 0;
        PC_in = 32'h00000010;
        CPSR_write_en = 1;
        SPSR_write_en = 1;
        CPSR_in = 0;
        SPSR_in = 0;
        CPSR_byte_w_en = 0;
        SPSR_byte_w_en = 0;
        #1
	clk = 1'b0;
	//the 1st period , 2ns , 
	/*is Rn_w_addr , Rd_w_addr , Rn_in , Rd_in , Rm_r_addr , Rn_r_addr , Rs_r_addr , Rd_r_addr , Rm_out , Rn_out , Rs_out , Rd_out , PC_in ,Pc_out OK ? */ 

        #1
	if(!((Rn_out == 12)&& (Rm_out == 12) &&(Rs_out == 14) && (Rd_out == 14) && (Pc_out == 32'h00000010)))
		$stop;// to see whether it runs ok in the 1st period
	clk = 1'b1;
        PC_in = 32'h00000020;
	CPSR_write_en = 0;
	SPSR_write_en = 0;
	CPSR_in = 32'hf0100011;
	SPSR_in = 32'hf0100011;
	CPSR_byte_w_en = 4'b0100;
	SPSR_byte_w_en = 4'b0100;
        #1
        clk = 1'b0;
	//the 2nd period , 4ns
	/*is CPSR_write_en  , SPSR_write_in , SPSR_byte_in , CPSR_byte_in OK ? And change the mode to FIQ*/

	#1
	if(!((CPSR_out == 32'hf0000011) && (SPSR_out == 32'hf0000011)))
		$stop;// to see whether it runs ok in the 2nd period
	clk = 1'b1;
	PC_in = 32'h00000030;
	CPSR_write_en = 1;
	SPSR_write_en = 0;
	#1
	clk = 1'b0;
	//the 3th period , 6ns
	/* is mode == 4 ?  is Rst OK ? */

	#1
	if(!((mode == 4)))
		$stop;// to see whether the mode is FIQ and Rst is enabled
	clk = 1'b1;
	Rn_in = 112;
	Rd_in = 114;
	#1
	clk = 1'b0;
	// the 4th period , 8ns 
	/* is R12_fiq R14_fiq OK? */

	#1
	if(!((Rn_out == 112) && (Rd_out == 114)))
		$stop;// to see whether it runs ok in the 4th period
	clk = 1'b1;
	CPSR_write_en = 0;
	CPSR_in = 32'h00000013;
	SPSR_in = 32'h00000013;
	CPSR_byte_w_en = 4'b0000;
	SPSR_byte_w_en = 4'b0000;
	#1
	clk = 1'b0;
	// the 5th period, 10ns
	/* change the mode to SVC*/

	#1
	if(!((CPSR_out == 32'h00000013) && (SPSR_out == 32'h00000013)))
		$stop;// to see whether it runs ok in the 5th period
	clk = 1'b1;
	Rn_byte_w_en = 4'b1111;
	Rd_in = 214;
	#1
	clk = 1'b0;
	// the 6th period , 12ns
	/*is R12 R14_svc OK ?*/
	#1
	if(!((Rn_out == 12) && (Rd_out == 214)))
		$stop;// to see whether it runs ok in the 6th period
	clk = 1'b1;
	#1

        $stop;

    end
endmodule
