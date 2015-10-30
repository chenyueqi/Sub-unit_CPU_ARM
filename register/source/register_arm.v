`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2015/09/06 14:09:54
// Design Name: 
// Module Name: register_arm
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


module register_arm
#(
parameter DATA_WIDTH = 32,
parameter ADDR_WIDTH = 4,
parameter USE = 5'b10000,
parameter FIQ = 5'b10001,
parameter IRQ = 5'b10010,
parameter SVC = 5'b10011,
parameter ABT = 5'b10111,
parameter UND = 5'b11011,
parameter SYS = 5'b11111
)
(
    input [(ADDR_WIDTH -1):0] Rn_r_addr , Rm_r_addr , Rs_r_addr , Rd_r_addr ,Rn_w_addr , Rd_w_addr,
    input [(DATA_WIDTH -1):0] Rd_in , Rn_in , PC_in , CPSR_in , SPSR_in,
    input CPSR_write_en , SPSR_write_en,
    input [3:0] CPSR_byte_w_en , SPSR_byte_w_en,
    input [3:0] Rd_byte_w_en , Rn_byte_w_en,
    input clk,
    input Rst,
    output [(DATA_WIDTH -1):0] Rn_out,Rm_out , Rs_out , Rd_out , Pc_out , CPSR_out , SPSR_out,
    output [4:0] Mode_out,
    output [2:0] mode
);

    reg [(DATA_WIDTH -1):0] unbanked_register[7:0];//R0-R7
    reg [(DATA_WIDTH -1):0] banked_register[4:0][1:0];//sys&use , fiq
    reg [(DATA_WIDTH -1):0] R13[5:0];//sys&use , fiq  , svc , abt , irq , und
    reg [(DATA_WIDTH -1):0] R14[5:0];//sys&use , fiq ,  svc , abt ,irq , und
    reg [(DATA_WIDTH -1):0] R15;//pc
    reg [(DATA_WIDTH -1):0] CPSR[5:0];//cpsr , fiq , svc , abt , irq , und

    reg [2:0]mode_num;
    reg rst_assert;
    
    integer i ;
    
    initial 
    begin 
        for(i = 0 ; i < 8 ; i = i + 1)//initial unbanked register
            unbanked_register[i]=0;
        for(i = 0 ; i < 5 ; i = i + 1)//initial banked register
        begin
            banked_register[i][0] = 0;
            banked_register[i][1] = 0;
        end
        for(i = 0 ; i < 6 ;i = i + 1)//initial R13 R14 and CPSR
        begin
            R13[i] = 0;
            R14[i] = 0;
            CPSR[i] = 0;
        end
        R15 = 0;//initial PC
        CPSR[5] = 32'b00010000;
    end

    always @(negedge clk , negedge Rst)
    begin
	    if(Rst == 1'b0) begin//put down the Rst
		    rst_assert <= 1'b1;
	    end
	    else begin
		    if(rst_assert == 1'b1) begin
			    if(Rst == 1'b1) begin//Rst recover
				    CPSR[5][7:0] <= 8'b11010011;
				    rst_assert <= 1'b0;
				    R15 <= 32'h0;
			    end
		    end
		    else begin

 //Rn write
            R15 = PC_in;
            mode_num = (CPSR[5][4:0] == USE) ? 5 :
                (CPSR[5][4:0] == FIQ) ? 4 :
                (CPSR[5][4:0] == SVC) ? 3 :
                (CPSR[5][4:0] == ABT) ? 2 :
                (CPSR[5][4:0] == IRQ) ? 1 :
                (CPSR[5][4:0] == UND) ? 0 : 5;	
            
            if(Rn_w_addr < 8)
            begin
                if(Rn_byte_w_en[3] == 0) unbanked_register[Rn_w_addr][31:24] <= Rn_in[31:24];
                if(Rn_byte_w_en[2] == 0) unbanked_register[Rn_w_addr][23:16] <= Rn_in[23:16];
                if(Rn_byte_w_en[1] == 0) unbanked_register[Rn_w_addr][15:8] <= Rn_in[15:8];
                if(Rn_byte_w_en[0] == 0) unbanked_register[Rn_w_addr][7:0] <= Rn_in[7:0];
                
            end
            else if(Rn_w_addr <13)
            begin
                if(Rn_byte_w_en[3] == 0)
                begin
                            case(mode_num)
                                    4:banked_register[Rn_w_addr - 8][0][31:24] <= Rn_in[31:24]; 
                                    default:banked_register[Rn_w_addr - 8][1][31:24] <= Rn_in[31:24];
                            endcase
                end
                if(Rn_byte_w_en[2] == 0)
                begin
                            case(mode_num)
                                    4:banked_register[Rn_w_addr - 8][0][23:16] <= Rn_in[23:16]; 
                                    default:banked_register[Rn_w_addr - 8][1][23:16] <= Rn_in[23:16];
                            endcase
                end
                if(Rn_byte_w_en[1] == 0)
                begin
                            case(mode_num)
                                    4:banked_register[Rn_w_addr - 8][0][15:8] <= Rn_in[15:8]; 
                                    default:banked_register[Rn_w_addr - 8][1][15:8] <= Rn_in[15:8];
                            endcase
                end
                if(Rn_byte_w_en[0] == 0)
                begin
                            case(mode_num)
                                    4:banked_register[Rn_w_addr - 8][0][7:0] <= Rn_in[7:0]; 
                                    default:banked_register[Rn_w_addr - 8][1][7:0] <= Rn_in[7:0];
                            endcase
                end
            end
            else if(Rn_w_addr == 13)
            begin
                if(Rn_byte_w_en[3] == 0) R13[mode_num][31:24] <= Rn_in[31:24];	
                if(Rn_byte_w_en[2] == 0) R13[mode_num][23:16] <= Rn_in[23:16];	
                if(Rn_byte_w_en[1] == 0) R13[mode_num][15:8] <= Rn_in[15:8];	
                if(Rn_byte_w_en[0] == 0) R13[mode_num][7:0] <= Rn_in[7:0];	
            end
            else if(Rn_w_addr == 14)
            begin
                if(Rn_byte_w_en[3] == 0) R14[mode_num][31:24] <= Rn_in[31:24];	
                if(Rn_byte_w_en[2] == 0) R14[mode_num][23:16] <= Rn_in[23:16];	
                if(Rn_byte_w_en[1] == 0) R14[mode_num][15:8] <= Rn_in[15:8];	
                if(Rn_byte_w_en[0] == 0) R14[mode_num][7:0] <= Rn_in[7:0];	
            end
        
         //Rd write        
            if(Rd_w_addr < 8)
            begin
                if(Rd_byte_w_en[3] == 0) unbanked_register[Rd_w_addr][31:24] <= Rd_in[31:24];
                if(Rd_byte_w_en[2] == 0) unbanked_register[Rd_w_addr][23:16] <= Rd_in[23:16];
                if(Rd_byte_w_en[1] == 0) unbanked_register[Rd_w_addr][15:8] <= Rd_in[15:8];
                if(Rd_byte_w_en[0] == 0) unbanked_register[Rd_w_addr][7:0] <= Rd_in[7:0];
                
            end
            else if(Rd_w_addr <13)
            begin
                if(Rd_byte_w_en[3] == 0)
                begin
                            case(mode_num)
                                    4:banked_register[Rd_w_addr - 8][0][31:24] <= Rd_in[31:24]; 
                                    default:banked_register[Rd_w_addr - 8][1][31:24] <= Rd_in[31:24];
                            endcase
                end
                if(Rd_byte_w_en[2] == 0)
                begin
                            case(mode_num)
                                    4:banked_register[Rd_w_addr - 8][0][23:16] <= Rd_in[23:16]; 
                                    default:banked_register[Rd_w_addr - 8][1][23:16] <= Rd_in[23:16];
                            endcase
                end
                if(Rd_byte_w_en[1] == 0)
                begin
                            case(mode_num)
                                    4:banked_register[Rd_w_addr - 8][0][15:8] <= Rd_in[15:8]; 
                                    default:banked_register[Rd_w_addr - 8][1][15:8] <= Rd_in[15:8];
                            endcase
                end
                if(Rd_byte_w_en[0] == 0)
                begin
                            case(mode_num)
                                    4:banked_register[Rd_w_addr - 8][0][7:0] <= Rd_in[7:0]; 
                                    default:banked_register[Rd_w_addr - 8][1][7:0] <= Rd_in[7:0];
                            endcase
                end
            end
            else if(Rd_w_addr == 13)
            begin
                if(Rd_byte_w_en[3] == 0) R13[mode_num][31:24] <= Rd_in[31:24];	
                if(Rd_byte_w_en[2] == 0) R13[mode_num][23:16] <= Rd_in[23:16];	
                if(Rd_byte_w_en[1] == 0) R13[mode_num][15:8] <= Rd_in[15:8];	
                if(Rd_byte_w_en[0] == 0) R13[mode_num][7:0] <= Rd_in[7:0];	
            end
            else if(Rd_w_addr == 14)
            begin
                if(Rd_byte_w_en[3] == 0) R14[mode_num][31:24] <= Rd_in[31:24];	
                if(Rd_byte_w_en[2] == 0) R14[mode_num][23:16] <= Rd_in[23:16];	
                if(Rd_byte_w_en[1] == 0) R14[mode_num][15:8] <= Rd_in[15:8];	
                if(Rd_byte_w_en[0] == 0) R14[mode_num][7:0] <= Rd_in[7:0];	
            end
        
         //CPSR write
                 if(CPSR_write_en == 0)
                 begin
                     if(CPSR_byte_w_en[3] == 0) CPSR[5][31:24] <= CPSR_in[31:24];
                     if(CPSR_byte_w_en[2] == 0) CPSR[5][23:16] <= CPSR_in[23:16];
                     if(CPSR_byte_w_en[1] == 0) CPSR[5][15:8] <= CPSR_in[15:8];
                     if(CPSR_byte_w_en[0] == 0) CPSR[5][7:0] <= CPSR_in[7:0];
                 end
                 
         //SPSR write
                if((SPSR_write_en) == 0 && (mode_num != 5))
                begin
                    if(SPSR_byte_w_en[3] == 0) CPSR[mode_num][31:24] <= SPSR_in[31:24];
                    if(SPSR_byte_w_en[2] == 0) CPSR[mode_num][23:16] <= SPSR_in[23:16];
                    if(SPSR_byte_w_en[1] == 0) CPSR[mode_num][15:8] <= SPSR_in[15:8];
                    if(SPSR_byte_w_en[0] == 0) CPSR[mode_num][7:0] <= SPSR_in[7:0];
                end
		end
		end
 	
      end

       assign Rn_out = (Rn_r_addr < 8) ? unbanked_register[Rn_r_addr] :
                       ((Rn_r_addr < 13) &&(Rn_r_addr > 7) && mode_num == 4) ? banked_register[Rn_r_addr - 8][0] :
                       ((Rn_r_addr < 13) &&(Rn_r_addr > 7) && mode_num != 4) ? banked_register[Rn_r_addr - 8][1] :
                       (Rn_r_addr == 13) ? R13[mode_num]:R14[mode_num];
       assign Rs_out = (Rs_r_addr < 8) ? unbanked_register[Rs_r_addr] :
                       ((Rs_r_addr < 13) &&(Rs_r_addr > 7) && mode_num == 4) ? banked_register[Rs_r_addr - 8][0] :
                       ((Rs_r_addr < 13) &&(Rs_r_addr > 7) && mode_num != 4) ? banked_register[Rs_r_addr - 8][1] :
                       (Rs_r_addr == 13) ? R13[mode_num]:R14[mode_num];
       assign Rm_out = (Rm_r_addr < 8) ? unbanked_register[Rm_r_addr] :
                       ((Rm_r_addr < 13) &&(Rm_r_addr > 7) && mode_num == 4) ? banked_register[Rm_r_addr - 8][0] :
                       ((Rm_r_addr < 13) &&(Rm_r_addr > 7) && mode_num != 4) ? banked_register[Rm_r_addr - 8][1] :
                       (Rm_r_addr == 13) ? R13[mode_num]:R14[mode_num];
       assign Rd_out = (Rd_r_addr < 8) ? unbanked_register[Rd_r_addr] :
                       ((Rd_r_addr < 13) &&(Rd_r_addr > 7) && mode_num == 4) ? banked_register[Rd_r_addr - 8][0] :
                       ((Rd_r_addr < 13) &&(Rd_r_addr > 7) && mode_num != 4) ? banked_register[Rd_r_addr - 8][1] :
                       (Rd_r_addr == 13) ? R13[mode_num]:R14[mode_num];
                                                                                                      
    assign Pc_out = R15;
    assign CPSR_out = CPSR[5];
    assign SPSR_out = CPSR[mode_num];
    assign Mode_out = CPSR[5][4:0];
    assign mode = mode_num;

endmodule
