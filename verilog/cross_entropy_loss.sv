module cross_entropy_loss #(
    parameter int WIDTH = 16,
    parameter int DIMENSION = 10
) (
    input  logic signed [WIDTH-1:0] probs [DIMENSION],
    input  logic signed [WIDTH-1:0] labels [DIMENSION],
    output logic signed [WIDTH-1:0] input_error [DIMENSION],
    output logic signed [WIDTH-1:0] loss
);

    // Do we want to compute loss? Maybe don't

    // Compute input error
    always_comb  begin
        for (int i = 0; i < DIMENSION; i++) begin
            input_error[i] = probs[i] - labels[i];
        end
    end
    
endmodule