`timescale 1ns/1ps

module up_down_counter(
        input wire clk,
        input wire rst_n,
        input wire en,
        input wire up_down,
        output reg [7:0] count,
        output wire tc
);

always @(posedge clk) begin
        if (!rst_n)
                count <= 8'h00;
        else if (en) begin
                if (up_down)
                        count <= count + 8'd1;
                else
                        count <= count - 8'd1;
                end
        end

assign tc = (up_down && ( count == 8'hFF)) || (!up_down && (count == 8'h00));

endmodule
