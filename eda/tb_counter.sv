// Simple SystemVerilog testbench for EDA Playground / Verilator
module tb;
    reg clk = 0;
    reg rst = 1;
    wire [3:0] count;

    // Instantiate DUT (place DUT code in another file on EDA Playground)
    counter uut (
        .clk(clk),
        .rst(rst),
        .count(count)
    );

    // Clock generation
    always #5 clk = ~clk; // 100MHz like clock (10ns period)

    initial begin
        // release reset after two half-cycles
        #20; rst = 0;

        int prev = 0;
        // run for 40 clock cycles and check behavior
        for (int i = 0; i < 40; i++) begin
            @(posedge clk);
            $display("cycle %0d: prev=%0d count=%0d", i, prev, count);

            if (prev == 4'd14) begin
                if (count !== 4'd15) begin
                    $display("ASSERT FAIL: expected count==15 after prev==14, got %0d", count);
                    $fatal;
                end
            end else begin
                if (count !== prev + 1) begin
                    $display("ASSERT FAIL: expected count==%0d, got %0d", prev+1, count);
                    $fatal;
                end
            end
            prev = count;
        end

        $display("TEST PASSED");
        $finish;
    end
endmodule
