module LFSR #(parameter WIDTH=16)(
    input  logic clk,        // Clock signal
    input  logic rst,        // Reset signal
    output logic [WIDTH-1:0] out // 16 outputs, each 4 bits wide
);

    logic [WIDTH-1:0][3:0] op;

    // Loop through each of the 16 LFSRs
    always_ff @(posedge clk or negedge rst) begin
        if (!rst) begin
            // Initialize all 16 LFSRs to their reset values (all 4'hF)
            for (int i = 0; i < WIDTH; i++) begin
                op[i] <= (i+WIDTH) >> 1; // Set each LFSR to 4'hF on reset
                out[i] <= op[i][3]; // Output the initial value
            end
        end else begin
            // For each LFSR, calculate the new 4-bit value based on feedback
            for (int i = 0; i < WIDTH; i++) begin
                // LFSR update: op[i] = {op[i][2:0], op[i][3] ^ op[i][2]}
                op[i] <= {op[i][2:0], op[i][3] ^ op[i][2]};
                out[i] <= op[i][3];
            end
        end
    end

endmodule
