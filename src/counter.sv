// -----------------------------------------------------------------------------
// Module: counter
// Description: A 4-bit up-counter with an intentional reset bug.
// -----------------------------------------------------------------------------

module counter (
    input  logic       clk,
    input  logic       rst,
    output logic [3:0] count
);

    // --- Counter Logic ---
    always_ff @(posedge clk) begin
        if (rst) begin
            count <= 4'b0;
        end else begin
            // BUG: The counter resets at 14 instead of waiting for 15.
            // This is a "corner case" that random simulation might miss.
            if (count == 4'd14) 
                count <= 4'b0;
            else
                count <= count + 1;
        end
    end

    // --- Formal Verification Block ---
    // This code is only visible to the Formal Engine (SBY)
    `ifdef FORMAL
        
        // Ensure the design starts in a known state
        initial restrict(rst);

        // Logic to track the previous state
        logic [3:0] prev_count;
        always_ff @(posedge clk) begin
            prev_count <= count;
        end

        // Property 1: The counter should never skip a value.
        // It should always be (Previous + 1) unless it resets.
        assert_increment: assert property (
            @(posedge clk) disable iff (rst)
            (count == prev_count + 1'b1) || (prev_count == 4'd15)
        );

        // Property 2: The counter must reach 15.
        // Our bug at '14' will cause this to fail.
        assert_reaches_15: assert property (
            @(posedge clk) disable iff (rst)
            (prev_count == 4'd14) |-> (count == 4'd15)
        );

    `endif

endmodule