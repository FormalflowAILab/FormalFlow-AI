// -----------------------------------------------------------------------------
// Module: counter
// Description: A 4-bit up-counter with an intentional reset bug.
// -----------------------------------------------------------------------------

module counter (
    input  wire        clk,
    input  wire        rst,
    output reg  [3:0]  count
);

    // --- Counter Logic ---
    always @(posedge clk) begin
        if (rst) begin
            count <= 4'b0;
        end else begin
            // BUG: The counter resets at 14 instead of waiting for 15.
            // This is a "corner case" that random simulation might miss.
            if (count == 4'd15) 
                count <= 4'b0;
            else
                count <= count + 1;
        end
    end

    // --- Formal Verification Block ---
    // This code is only visible to the Formal Engine (SBY)
    `ifdef FORMAL
        
        // Logic to track the previous state and indicate startup
        reg [3:0] prev_count;
        reg started;
        initial started = 0;

        always @(posedge clk) begin
            if (rst) begin
                prev_count <= 4'b0;
                started <= 0;
            end else begin
                prev_count <= count;
                started <= 1;
            end
        end

        // Immediate assertions (clocked) — only check after one cycle
        always @(posedge clk) begin
            if (started) begin
                // The counter should never skip a value.
                assert( (count == prev_count + 1'b1) || (prev_count == 4'd15) );

                // If previous was 14, current must be 15.
                if (prev_count == 4'd14)
                    assert( count == 4'd15 );
            end
        end

    `endif

endmodule