// 4-bit counter DUT (EDA Playground copy)
module counter (
    input  wire        clk,
    input  wire        rst,
    output reg  [3:0]  count
);

    always @(posedge clk) begin
        if (rst) begin
            count <= 4'b0;
        end else begin
            if (count == 4'd15)
                count <= 4'b0;
            else
                count <= count + 1;
        end
    end

endmodule
