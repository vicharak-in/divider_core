module divider_mode_cont(
    input               divider_clk,
    input               write,
    input [95:0]        out_data,
    input [31:0]        o_x,
    input [31:0]        o_y,
    output reg          i_call,
    output reg          reset_n,
    output reg          write_in,
    output reg [31:0]   num_data,
    output reg [31:0]   dem_data,
    output reg [95:0]   write_out
);
parameter SIGNED = 1'b0;
reg [1:0] state;
reg [95:0] out_data_mode;
reg store_next;
reg [7:0] set;
reg [7:0] wr_count;

reg [31:0] nu_data, de_data;
reg [31:0] o_x2, o_y2;

generate 
    if (SIGNED) begin: signed_block

        task get_signed_data;
            input [3:0] mode;
            input [31:0] data_in;
            output [31:0] data_out;
            begin
                case (mode)
                    4'h1: data_out = {{24{data_in[7]}},data_in[7:0]};
                    4'h2: data_out = {{16{data_in[15]}},data_in[15:0]};
                    4'h3: data_out = {{8{data_in[23]}},data_in[23:0]};
                    4'h4: data_out = data_in;
                    default: data_out = 32'b0;
                endcase
            end
        endtask

        always @(posedge divider_clk) begin
            if (write) begin
                get_signed_data(out_data[43:40],out_data[31:0], nu_data);
                get_signed_data(out_data[91:88],out_data[79:48], de_data);
                store_next <= 1;
            end else begin
                store_next <= 0;
                de_data <= 0;
                nu_data <= 0;
            end
        end
    end

    else begin: unsigned_block

        task get_unsigned_data;
            input [3:0] mode;
            input [31:0] data_in;
            output [31:0] data_out;
            begin
                case (mode)
                    4'h1: data_out = {24'b0,data_in[7:0]};
                    4'h2: data_out = {16'b0,data_in[15:0]};
                    4'h3: data_out = {8'b0,data_in[23:0]};
                    4'h4: data_out = data_in;
                    default: data_out = 32'b0;
                endcase
            end
        endtask
    
        always @(posedge divider_clk) begin
            if (write) begin
                get_unsigned_data(out_data[43:40], out_data[31:0], nu_data);
                get_unsigned_data(out_data[91:88], out_data[79:48], de_data);
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

        if (set == 8) begin
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
                if (wr_count < 7) wr_count <= wr_count + 1;
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
            write_out[95:48] <= {16'h000a, o_x2} ;
            state <= 3;
        end

        3: begin
            write_out[47:0] <= {16'h000b, o_y2} ;
            state <= 0;
        end
    endcase
end
endmodule
