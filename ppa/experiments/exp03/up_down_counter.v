`timescale 1ns/1ps

module up_down_counter(
        input wire clk,
        input wire rst_n,
        input wire en,
        input wire up_down,
        output reg [7:0] count,
        output wire tc
);

wire [7:0] y;
wire prefix_0;
wire prefix_1;
wire prefix_2;
wire prefix_3;
wire prefix_4;
wire prefix_5;
wire prefix_6;
wire prefix_7;
wire prefix_8;
wire [7:0] toggle;

assign y = count ^ {8{~up_down}};

assign prefix_0 = 1'b1;
assign prefix_1 = prefix_0 & y[0];
assign prefix_2 = prefix_1 & y[1];
assign prefix_3 = prefix_2 & y[2];
assign prefix_4 = prefix_3 & y[3];
assign prefix_5 = prefix_4 & y[4];
assign prefix_6 = prefix_5 & y[5];
assign prefix_7 = prefix_6 & y[6];
assign prefix_8 = prefix_7 & y[7];

assign tc = prefix_8;
assign toggle = {
    en & prefix_7,
    en & prefix_6,
    en & prefix_5,
    en & prefix_4,
    en & prefix_3,
    en & prefix_2,
    en & prefix_1,
    en & prefix_0
};

always @(posedge clk) begin
        if (!rst_n)
                count <= 8'h00;
        else
                count <= count ^ toggle;
end

endmodule
