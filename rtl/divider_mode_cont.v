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

reg [1:0] state;
reg [95:0] out_data_mode;
reg store_next;
reg [7:0] set;
reg [7:0] wr_count;

reg [31:0] nu_data, de_data;
reg [31:0] o_x2, o_y2;

always @(posedge divider_clk) begin
    if (write) begin
        case (out_data[47:40])
            8'h1: begin
                if (out_data[39:32] == 1) begin  // 8-bit mode
                    nu_data <= {24'b0, out_data[7:0]};
                    store_next <= 1;
                end
            end

            8'h2: begin  //16-bit mode
                if (out_data[39:32] == 1) begin
                    nu_data <= {16'b0, out_data[15:0]};
                    store_next <= 1;
                end
            end

            8'h3: begin  //24-bit mode
                if (out_data[39:32] == 1) begin
                    nu_data <= {8'b0, out_data[23:0]};
                    store_next <= 1;
                end
            end

            8'h4: begin  //32-bit mode
                if (out_data[39:32] == 1) begin
                    nu_data <= out_data[31:0];
                    store_next <= 1;
                end
            end

            default: begin
                nu_data <= 0;
                store_next <= 0;
            end
        endcase

        case (out_data[95:88])
            8'h1: begin
                if (out_data[87:80] == 0) begin
                    de_data <= {24'b0, out_data[55:48]};
                    store_next <= 1;
                end
            end

            8'h2: begin
                if (out_data[87:80] == 0) begin  // 16-bit mode
                    de_data <= {16'b0, out_data[63:48]};
                    store_next <= 1;
                end
            end

            8'h3: begin
                if (out_data[87:80] == 0) begin  // 24-bit mode
                    de_data <= {8'b0, out_data[71:48]};
                    store_next <= 1;
                end
            end

            8'h4: begin
                if (out_data[87:80] == 0) begin  // 32-bit mode
                    de_data <= out_data[79:48];
                    store_next <= 1;
                end
            end

            default: begin
                de_data <= 0;
                store_next <= 0;
            end
        endcase
    end else begin
        store_next <= 0;
        de_data <= 0;
        nu_data <= 0;
    end
end

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
