// =============================================================================
// Generated by efx_ipmgr
// Version: 2023.2.307
// IP Version: 5.0
// =============================================================================

////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2013-2023 Efinix Inc. All rights reserved.              
//
// This   document  contains  proprietary information  which   is        
// protected by  copyright. All rights  are reserved.  This notice       
// refers to original work by Efinix, Inc. which may be derivitive       
// of other work distributed under license of the authors.  In the       
// case of derivative work, nothing in this notice overrides the         
// original author's license agreement.  Where applicable, the           
// original license agreement is included in it's original               
// unmodified form immediately below this header.                        
//                                                                       
// WARRANTY DISCLAIMER.                                                  
//     THE  DESIGN, CODE, OR INFORMATION ARE PROVIDED “AS IS” AND        
//     EFINIX MAKES NO WARRANTIES, EXPRESS OR IMPLIED WITH               
//     RESPECT THERETO, AND EXPRESSLY DISCLAIMS ANY IMPLIED WARRANTIES,  
//     INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF          
//     MERCHANTABILITY, NON-INFRINGEMENT AND FITNESS FOR A PARTICULAR    
//     PURPOSE.  SOME STATES DO NOT ALLOW EXCLUSIONS OF AN IMPLIED       
//     WARRANTY, SO THIS DISCLAIMER MAY NOT APPLY TO LICENSEE.           
//                                                                       
// LIMITATION OF LIABILITY.                                              
//     NOTWITHSTANDING ANYTHING TO THE CONTRARY, EXCEPT FOR BODILY       
//     INJURY, EFINIX SHALL NOT BE LIABLE WITH RESPECT TO ANY SUBJECT    
//     MATTER OF THIS AGREEMENT UNDER TORT, CONTRACT, STRICT LIABILITY   
//     OR ANY OTHER LEGAL OR EQUITABLE THEORY (I) FOR ANY INDIRECT,      
//     SPECIAL, INCIDENTAL, EXEMPLARY OR CONSEQUENTIAL DAMAGES OF ANY    
//     CHARACTER INCLUDING, WITHOUT LIMITATION, DAMAGES FOR LOSS OF      
//     GOODWILL, DATA OR PROFIT, WORK STOPPAGE, OR COMPUTER FAILURE OR   
//     MALFUNCTION, OR IN ANY EVENT (II) FOR ANY AMOUNT IN EXCESS, IN    
//     THE AGGREGATE, OF THE FEE PAID BY LICENSEE TO EFINIX HEREUNDER    
//     (OR, IF THE FEE HAS BEEN WAIVED, $100), EVEN IF EFINIX SHALL HAVE 
//     BEEN INFORMED OF THE POSSIBILITY OF SUCH DAMAGES.  SOME STATES DO 
//     NOT ALLOW THE EXCLUSION OR LIMITATION OF INCIDENTAL OR            
//     CONSEQUENTIAL DAMAGES, SO THIS LIMITATION AND EXCLUSION MAY NOT   
//     APPLY TO LICENSEE.                                                
//
////////////////////////////////////////////////////////////////////////////////

`define IP_UUID _6291e6d28cae4e8ab124ecb36af444f8
`define IP_NAME_CONCAT(a,b) a``b
`define IP_MODULE_NAME(name) `IP_NAME_CONCAT(name,`IP_UUID)
module divider_unsigned (
input [31:0] numer,
input [31:0] denom,
input clken,
input clk,
input reset,
output [31:0] quotient,
output [31:0] remain
);
`IP_MODULE_NAME(divider) #(
.NREPRESENTATION ("UNSIGNED"),
.WIDTHN (32),
.WIDTHD (32),
.DREPRESENTATION ("UNSIGNED"),
.PIPELINE (1'b1),
.LATENCY (8)
) u_divider(
.numer ( numer ),
.denom ( denom ),
.clken ( clken ),
.clk ( clk ),
.reset ( reset ),
.quotient ( quotient ),
.remain ( remain )
);

endmodule

`timescale 1ns / 1ps

module `IP_MODULE_NAME(divider)  (
    clk,
    reset,
    numer,  
    denom,
    quotient, 
    remain,
    rfd,
    clken   
);
    
parameter WIDTHN = 8;
parameter WIDTHD = 8;
parameter LATENCY = 8;
parameter PIPELINE = 1;
parameter NREPRESENTATION = "UNSIGNED";
parameter DREPRESENTATION = "UNSIGNED";
parameter ENABLE_OUTREG = 0;

input clk;
input reset;
input clken;
input [(WIDTHN-1):0]  numer;
input [(WIDTHD-1):0]  denom;
//output
output reg rfd;
output reg [(WIDTHN-1):0]  quotient;
output reg [(WIDTHD-1):0]  remain;

wire [WIDTHN-1:0] numer_temp; 
wire [WIDTHD-1:0] denom_temp; 
wire              sign_numer;
wire              sign_denom;

wire [(WIDTHN-1):0] quotient_copy;
wire [(WIDTHD-1):0] remain_copy;
reg                 sign_quotient[LATENCY:0];

genvar i, j;
// Main operation
generate begin
    if(NREPRESENTATION == "SIGNED") begin
        assign numer_temp = (numer[(WIDTHN-1)] == 1'b1) ? (~numer + 1) : numer;
        assign sign_numer = (numer[(WIDTHN-1)] == 1'b1) ? 1'b1 : 1'b0;
    end
    else begin
        assign numer_temp = numer;
        assign sign_numer = 1'b0;
    end
    
    if(DREPRESENTATION == "SIGNED") begin
        assign denom_temp = (denom[(WIDTHD-1)] == 1'b1) ? (~denom + 1) : denom;
        assign sign_denom = (denom[(WIDTHD-1)] == 1'b1) ? 1'b1 : 1'b0;
    end
    else begin
        assign denom_temp = denom;
        assign sign_denom = 1'b0;
    end
    
    always @* begin
        sign_quotient[0] = sign_numer ^ sign_denom;
    end
    
    for (i=0; i<LATENCY; i=i+1) begin
        always @(posedge clk or posedge reset) begin
            if (reset) begin
                sign_quotient[i+1] <= 1'b0;
            end
            else if(clken) begin
                sign_quotient[i+1] <= sign_quotient[i];
            end
        end
    end
    
    if (PIPELINE) begin : pipeline
        wire [(WIDTHN+1):0] sub[WIDTHN-1:0];
        reg [WIDTHN-1:0] quotient_temp[WIDTHN:0];
        reg [WIDTHN-1:0] remain_temp[WIDTHN:0];
        reg [WIDTHN-1:0] denom_copy[WIDTHN:0];

        always @* begin
        	rfd              = 1'b0;  //for PIPELINE enable, rfd is not used
            denom_copy[0]    = denom_temp;
            remain_temp[0]   = {WIDTHN{1'b0}};
            quotient_temp[0] = numer_temp;
        end
   
        for (i=0; i<WIDTHN; i=i+1) begin
            assign sub[i] = {remain_temp[i][(WIDTHN-2):0], quotient_temp[i][(WIDTHN-1)]} - denom_copy[i];
        
            if (i < LATENCY) begin
                always @(posedge clk or posedge reset) begin
                    if (reset) begin
                        remain_temp[i+1]   <= {WIDTHN{1'b0}};
                        quotient_temp[i+1] <= {WIDTHN{1'b0}}; 
                        denom_copy[i+1]    <= {WIDTHN{1'b0}};
                    end
                    else if(clken) begin
                        denom_copy[i+1]    <= denom_copy[i];
                    
                        if (sub[i][(WIDTHN)] == 0) begin
                            remain_temp[i+1]   <= sub[i][(WIDTHN-1):0];
                            quotient_temp[i+1] <= {quotient_temp[i][(WIDTHN-2):0], 1'b1};
                        end
                        else begin
                            remain_temp[i+1]   <= {remain_temp[i][(WIDTHN-2):0], quotient_temp[i][(WIDTHN-1)]};
                            quotient_temp[i+1] <= {quotient_temp[i][(WIDTHN-2):0], 1'b0};
                        end
                    end
                end
            end
            else begin
                always @* begin
                    denom_copy[i+1] = denom_copy[i];
                end
                
                always @* begin
                    if (sub[i][(WIDTHN)] == 0) begin
                        remain_temp[i+1] = sub[i][(WIDTHN-1):0];
                    end
                    else begin
                        remain_temp[i+1] = {remain_temp[i][(WIDTHN-2):0], quotient_temp[i][(WIDTHN-1)]};
                    end
                end
                
                always @* begin
                    if (sub[i][(WIDTHN)] == 0) begin
                        quotient_temp[i+1] = {quotient_temp[i][(WIDTHN-2):0], 1'b1};
                    end
                    else begin
                        quotient_temp[i+1] = {quotient_temp[i][(WIDTHN-2):0], 1'b0}; 
                    end
                end
            end
        end
        
        if (NREPRESENTATION == "SIGNED" ||  DREPRESENTATION == "SIGNED") begin
            assign quotient_copy = sign_quotient[LATENCY] ? (~quotient_temp[WIDTHN] + 1) : quotient_temp[WIDTHN];
        end
        else begin
            assign quotient_copy = quotient_temp[WIDTHN];
        end
        
        assign remain_copy = remain_temp[WIDTHN];
    end
    else begin : non_pipeline
    	localparam COMBI_STAGE = WIDTHN - LATENCY;
    	
    	wire [(WIDTHN-1):0] denom_sub;
    	reg [WIDTHN-1:0] denom_reg;   
        reg [(WIDTHN-1):0] quotient_reg;
        reg [(WIDTHN-1):0] remain_reg;
        wire [(WIDTHN+1):0] sub;
        reg  [(WIDTHN-1):0] quotient_combi[COMBI_STAGE:0];
        reg [WIDTHN-1:0] remain_combi[COMBI_STAGE:0];
        wire [(WIDTHN+1):0] sub_combi[COMBI_STAGE:0];
        
        reg clken_IP;

        assign denom_sub = {{(WIDTHN-WIDTHD){1'b0}},denom_temp};

        always @(posedge clk,posedge reset) begin
   	       if(reset) begin
              clken_IP <= 1'b0;
           end
           else begin
              clken_IP <= clken;
           end
        end
        
        if(LATENCY > 0) begin
            reg  [LATENCY-1:0] ready;
            
            assign sub = (ready[0] || ~clken_IP) ? ({{(WIDTHN-2){1'b0}}, numer_temp[(WIDTHN-1)]} - denom_sub) : ({remain_reg[(WIDTHN-2):0], quotient_reg[(WIDTHN-1)]} - denom_reg);
            
            always @(posedge clk,posedge reset) begin
                if(reset) begin
                    ready <= {LATENCY{1'b0}};
                end
                else if(clken) begin
                    if(ready[0] || ~clken_IP) begin
                        ready <= {1'b1, {LATENCY-1{1'b0}}};
                    end
                    else begin
                        ready <= {1'b0, ready[LATENCY-1:1]};
                    end
                end
                else begin
                    ready <= {LATENCY{1'b0}};
                end
            end
              
            always @(posedge clk,posedge reset) begin
                if(reset) begin
                    remain_reg   <= {WIDTHN{1'b0}};
                    quotient_reg <= {WIDTHN{1'b0}};
                    denom_reg    <= {WIDTHN{1'b0}};
                end
                else if(clken) begin
                    if(ready[0] || ~clken_IP) begin
                        denom_reg <= denom_temp; 
                        if (sub[(WIDTHN)] == 0) begin
                            remain_reg   <= sub[(WIDTHN-1):0];
                            quotient_reg <= {numer_temp[(WIDTHN-2):0], 1'b1};
                        end
                        else begin
                            remain_reg   <= {{(WIDTHN-2){1'b0}}, numer_temp[(WIDTHN-1)]};
                            quotient_reg <= {numer_temp[(WIDTHN-2):0], 1'b0};
                        end      	  	 
                    end
                    else begin
                        if (sub[(WIDTHN)] == 0) begin
                            remain_reg   <= sub[(WIDTHN-1):0];
                            quotient_reg <= {quotient_reg[(WIDTHN-2):0], 1'b1};
                        end
                        else begin
                            remain_reg   <= {remain_reg[(WIDTHN-2):0], quotient_reg[(WIDTHN-1)]};
                            quotient_reg <= {quotient_reg[(WIDTHN-2):0], 1'b0};
                        end
                    end  
                end
            end
            
            if (ENABLE_OUTREG) begin
                always @(posedge clk,posedge reset) begin
                    if (reset) begin
                        rfd <= 1'b0;
                    end
                    else begin
                        rfd <= ready[0];
                    end
                end
            end
            else begin
            	always @* begin
                    rfd = ready[0];
                end
            end
            
            always @* begin
                quotient_combi[0] = quotient_reg;
                remain_combi[0] = remain_reg;
            end
            
            for (i=0; i<COMBI_STAGE; i=i+1) begin
                assign sub_combi[i] = {remain_combi[i][(WIDTHN-2):0], quotient_combi[i][(WIDTHN-1)]} - denom_reg;
            end
        end
        else begin
            always @* begin
                rfd = 1'b1;
            end
                
            always @* begin
                quotient_combi[0] = numer_temp;
                remain_combi[0] = {WIDTHN{1'b0}};
            end
            for (i=0; i<COMBI_STAGE; i=i+1) begin
                assign sub_combi[i] = {remain_combi[i][(WIDTHN-2):0], quotient_combi[i][(WIDTHN-1)]} - denom_sub;
            end
        end
        
        for (i=0; i<COMBI_STAGE; i=i+1) begin
            always @* begin
                if(sub_combi[i][(WIDTHN)] == 0) begin
                    remain_combi [i+1] = sub_combi[i][(WIDTHN-1):0];
                    quotient_combi [i+1] = {quotient_combi[i][(WIDTHN-2):0], 1'b1};
                end
                else begin
                    remain_combi[i+1] =  {remain_combi[i][(WIDTHN-2):0], quotient_combi[i][(WIDTHN-1)]};
                    quotient_combi[i+1] = {quotient_combi[i][(WIDTHN-2):0], 1'b0};
                end
            end
        end
        
        if(NREPRESENTATION == "SIGNED" ||  DREPRESENTATION == "SIGNED") begin
	        assign quotient_copy = sign_quotient[LATENCY] ? (~quotient_combi[COMBI_STAGE] + 1): quotient_combi[COMBI_STAGE];//
        end
        else begin
	        assign quotient_copy = quotient_combi[COMBI_STAGE];
        end
        
        assign remain_copy = remain_combi[COMBI_STAGE];
    end
    
    if (ENABLE_OUTREG) begin
        always @(posedge clk or posedge reset) begin
            if (reset) begin
                quotient <= {WIDTHN{1'b0}};
                remain <= {WIDTHD{1'b0}};
            end
            else begin
                quotient <= quotient_copy;
                remain <= remain_copy;
            end
        end
    end
    else begin
        always @* begin
            quotient = quotient_copy;  
            remain = remain_copy;
        end
    end
end
endgenerate

endmodule 
`undef IP_UUID
`undef IP_NAME_CONCAT
`undef IP_MODULE_NAME
