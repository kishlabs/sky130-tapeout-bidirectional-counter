`timescale 1ns/1ps

module up_down_counter(
        input wire clk,
        input wire rst_n,
        input wire en,
        input wire up_down,
        output reg [7:0] count,
        output wire tc
);

wire [7:0] step = up_down ? 8'h01 : 8'hFF;

always @(posedge clk) begin
        if (!rst_n)
                count <= 8'h00;
        else if (en)
                count <= count + step;
end

assign tc = up_down ? &count : ~|count;

endmodule
