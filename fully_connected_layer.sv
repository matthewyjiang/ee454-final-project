module fully_connected_layer 
    #(
        parameter int WIDTH = 16, 
        parameter int INPUT_DIM = 4, 
        parameter int OUTPUT_DIM, 
        parameter int LEARNING_RATE
    )
(
    input  logic clk,
    input  logic reset,
    input  logic signed [WIDTH-1:0] input_data [INPUT_DIM],
    input  logic signed [WIDTH-1:0] output_error [OUTPUT_DIM],
    input  logic signed [WIDTH-1:0] input_weights [OUTPUT_DIM][INPUT_DIM+1],
    output logic signed [WIDTH-1:0] output_data [OUTPUT_DIM],
    output logic signed [WIDTH-1:0] input_error [INPUT_DIM]
    output logic signed [WIDTH-1:0] output_weights [OUTPUT_DIM][INPUT_DIM+1]
    
);
    // weights is a 2D array of size OUTPUT_DIM x (INPUT_DIM+1)
    // bias is the first row of weights 
    
    always_comb begin
        // Forward pass
        for (int i = 0; i < OUTPUT_DIM; i++) begin
            output_data[i] = weights[i][0]; // bias
            for (int j = 1; j <= INPUT_DIM; j++) begin
                output_data[i] += input_data[j] * weights[i][j];
            end
        end
        // Backward pass
        for (int i = 0; i < OUTPUT_DIM; i++) begin
            output_weights[i][0] = input_weights[i][0] + LEARNING_RATE * output_error[i];
            for (int j = 1; j <= INPUT_DIM; j++) begin
                output_weights[i][j] = input_weights[i][j] + LEARNING_RATE * output_error[i] * input_data[j];
            end
        end
    end

endmodule
