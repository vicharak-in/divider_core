module rah_cont_meta_stable (
	input               clk,
	input               divider_clk,
	input               empty,
	input [47:0]        data,
	input               write_in,
	input               almost_empty,
	input  [143:0]      in_data,
	output reg          write_sync = 0,
	output reg          RD_en = 0,
	output reg          wr_en = 0,
	output reg [47:0]   wr_data = 0,
	output reg [143:0]  out_data_hold = 0
);

reg [143:0] temp_out_data = 0;
reg [1:0] count = 3;
reg latch_data = 0;
reg latch_complete = 0;
reg prev_re = 0;
reg [1:0] state = 0;

localparam READ_1 = 0, READ_2 = 1, READ_3 = 2, READ_4 = 3;

always @(posedge clk) begin
    prev_re <= RD_en;

    if (prev_re) begin
        temp_out_data[(count * 48) - 1 -: 48] <= data;
        count <= count - 1;
    end else if (count == 0) begin
        count <= 3;
    end

    if (~latch_complete) begin
        if ((count == 0) | latch_data) begin
            latch_data <= 1;
        end else if (~empty & ~RD_en) begin
            latch_data <= 0;
            RD_en <= 1;
        end else if (almost_empty) begin
            latch_data <= 0;
            RD_en <= 0;
        end else begin
            latch_data <= 0;
        end
    end else begin
        latch_data <= 0;
    end
end

always @(posedge divider_clk) begin
    if (latch_data) begin
        out_data_hold <= temp_out_data;
        latch_complete <= 1;
        write_sync <= 1;
    end else begin
        latch_complete <= 0;
        write_sync <= 0;
    end
end

always @(posedge divider_clk) begin
    if (state == READ_1) begin
        if (write_in) begin
            wr_data <= in_data[143:96];
            wr_en <= 1;
            state <= READ_2;
        end else begin
            wr_en <= 0;
            state <= READ_1;
        end
    end else if (state == READ_2) begin
        wr_data <= in_data[95:48];
        state <= READ_3;
    end else if (state == READ_3) begin
        wr_data <= in_data[47:0];
        state <= READ_1;
   end
end

endmodule

