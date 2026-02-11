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
        // Cycle counter for temporal covers
        reg [5:0] cycles_since_start;
        initial started = 0;

        always @(posedge clk) begin
            if (rst) begin
                prev_count <= 4'b0;
                started <= 0;
            end else begin
                prev_count <= count;
                started <= 1;
                if (cycles_since_start < 6'd63)
                    cycles_since_start <= cycles_since_start + 1'b1;
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

                // --- Cover properties ---
                // Reachability: counter hits each value 0..15 after start
                cover (started && count == 4'd0);
                cover (started && count == 4'd1);
                cover (started && count == 4'd2);
                cover (started && count == 4'd3);
                cover (started && count == 4'd4);
                cover (started && count == 4'd5);
                cover (started && count == 4'd6);
                cover (started && count == 4'd7);
                cover (started && count == 4'd8);
                cover (started && count == 4'd9);
                cover (started && count == 4'd10);
                cover (started && count == 4'd11);
                cover (started && count == 4'd12);
                cover (started && count == 4'd13);
                cover (started && count == 4'd14);
                cover (started && count == 4'd15);

                // Wrap-around and transition covers
                cover (started && prev_count == 4'd15 && count == 4'd0);
                cover (started && prev_count == 4'd14 && count == 4'd15);

                // Bug-detection cover (if the counter erroneously wraps at 14)
                cover (started && prev_count == 4'd14 && count == 4'd0);

                // Reset-related covers
                cover (rst && count == 4'd0);

                // Temporal cover: reach 15 within 16 cycles after start
                cover (started && cycles_since_start <= 6'd16 && count == 4'd15);
            end
        end

    `endif

endmodule