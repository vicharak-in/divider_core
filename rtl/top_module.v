module top_module (
    input clk,
    input divider_clk,
    input empty,
    input almost_empty,
    input [47:0] data,
    output RD_en,
    output wr_en,
    output [47:0] wr_data
);

wire [143:0] out_data;
wire write;
wire write_in;
wire [63:0] o_x;
wire [63:0] o_y;
wire i_call;
wire reset_n;
wire [63:0] nu_data;
wire [63:0] de_data;
wire [191:0] write_out;

parameter SIGNED = 1'b0;

rah_cont_meta_stable inst (
    .clk(clk),
    .divider_clk(divider_clk),
    .empty(empty),
    .data(data),
    .wr_en(wr_en),
    .RD_en(RD_en),
    .almost_empty(almost_empty),
    .wr_data(wr_data),
    .in_data(write_out),
    .write_sync(write),
    .out_data_hold(out_data),
    .write_in(write_in)
);

divider_mode_cont #(
    .SIGNED(SIGNED)
) inst2 (
    .divider_clk(divider_clk),
    .write(write),
    .out_data(out_data),
    .o_x(o_x),
    .o_y(o_y),
    .i_call(i_call),
    .reset_n(reset_n),
    .write_in(write_in),
    .num_data(nu_data),
    .dem_data(de_data),
    .write_out(write_out)
);

generate
    if (SIGNED) begin
        divider_signed  divider_inst (
            .clk(divider_clk),
            .clken(i_call),
            .reset(reset_n),
            .numer(nu_data),
            .denom(de_data),
            .quotient (o_x),
            .remain (o_y)
);
    end else begin
        divider_unsigned divider_inst (
            .clk(divider_clk),
            .clken(i_call),
            .reset(reset_n),
            .numer(nu_data),
            .denom(de_data),
            .quotient (o_x),
            .remain (o_y)
);
    end
endgenerate

endmodule 
