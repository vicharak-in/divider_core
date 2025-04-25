module divider_mode_cont(
    input               divider_clk,
    input               write,
    input [143:0]       out_data,
    input [63:0]        o_x,
    input [63:0]        o_y,
    output reg          i_call,
    output reg          reset_n,
    output reg          write_in,
    output reg [63:0]   num_data,
    output reg [63:0]   dem_data,
    output reg [143:0]  write_out
);
parameter SIGNED = 1'b0;
reg [2:0] state;
reg store_next;
reg [7:0] set;
reg [7:0] wr_count;

reg [63:0] nu_data, de_data;
reg [63:0] o_x2, o_y2;

generate 
    if (SIGNED) begin: signed_block
        always @(posedge divider_clk) begin
            if (write) begin
                case (out_data[135:128])
                    8'h1: begin 
                        de_data <= {{56{out_data[7]}},out_data[7:0]};
                        nu_data <= {{56{out_data[75]}},out_data[79:64]};
                    end
                    8'h2: begin 
                        de_data <= {{48{out_data[15]}},out_data[15:0]};
                        nu_data <= {{48{out_data[83]}},out_data[87:64]};
                    end
                    8'h3: begin 
                        de_data <= {{40{out_data[23]}},out_data[23:0]};
                        nu_data <= {{40{out_data[91]}},out_data[95:64]};
                    end 
                    8'h4: begin 
                        de_data <= {{32{out_data[31]}},out_data[31:0]};
                        nu_data <= {{32{out_data[99]}},out_data[103:64]};
                    end
                    8'h5: begin
                         de_data <= out_data[63:0];
                         nu_data <= out_data[127:64];
                    end
                    default: begin 
                     	de_data <= 64'b0;
                     	nu_data <= 64'b0;
                    end
                endcase
                store_next <= 1;
            end else begin
                store_next <= 0;
                de_data <= 0;
                nu_data <= 0;
            end
        end
    end

    else begin: unsigned_block
        always @(posedge divider_clk) begin
            if (write) begin
                case (out_data[135:128])
                    8'h1: begin 
                        de_data <= {56'b0,out_data[7:0]};
                        nu_data <= {56'b0,out_data[79:64]};
                    end
                    8'h2: begin 
                        de_data <= {48'b0,out_data[15:0]};
                        nu_data <= {48'b0,out_data[87:64]};
                    end
                    8'h3: begin 
                        de_data <= {40'b0,out_data[23:0]};
                        nu_data <= {40'b0,out_data[95:64]};
                    end 
                    8'h4: begin 
                        de_data <= {32'b0,out_data[31:0]};
                        nu_data <= {32'b0,out_data[103:64]};
                    end
                    8'h5: begin
                         de_data <= out_data[63:0];
                         nu_data <= out_data[127:68];
                    end
                    default: begin            	
                     	de_data <= 64'b0;           	
                     	nu_data <= 64'b0;
                    end
                endcase
                store_next <= 1;
            end else begin
                store_next <= 0;
                de_data <= 0;
                nu_data <= 0;
            end
        end
    end
endgenerate

always @(posedge divider_clk) begin
    if (store_next) begin
        i_call <= 1;
        reset_n <= 0;
        set <= 0;
        num_data <= nu_data;
        dem_data <= de_data;
    end else begin
        set <= set + 1;

        if (set == 64) begin
            set <= 0;
            i_call <= 0;
            reset_n <= 1;
        end
    end
end

always @(posedge divider_clk) begin
    case (state)
        0: begin
            write_in <= 0;

            if (i_call) begin
                if (wr_count < 63) wr_count <= wr_count + 1;
                else state <= 1;
            end else begin
                wr_count <= 0;
            end
        end

        1: begin
            o_x2 <= o_x;
            o_y2 <= o_y;
            state <= 2;
            wr_count <= 0;
        end

        2: begin
            write_in <= 1;
            write_out[143:96] <= {8'h0a,o_x2[63:24]};
            state <= 3;
        end
        3: begin
            write_out[95:48] <= {o_x2[23:0],8'h0b,o_y2[63:48]};
            state <= 4;
        end
        4: begin
            write_out[47:0] <= {o_y2[47:0]};
            state <= 0;
        end
    endcase
end
endmodule
