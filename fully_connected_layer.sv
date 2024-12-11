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
    input  logic signed [WIDTH-1:0] input_weights [INPUT_DIM+1][OUTPUT_DIM],
    output logic signed [WIDTH-1:0] output_data [OUTPUT_DIM],
    output logic signed [WIDTH-1:0] input_error [INPUT_DIM],
    output logic signed [WIDTH-1:0] output_weights [INPUT_DIM+1][OUTPUT_DIM]
    
);
    // weights is a 2D array of size (INPUT_DIM+1) x OUTPUT_DIM
    // bias is the first row of weights 
    
    always_comb begin
        // Forward pass
        for (int i = 0; i < OUTPUT_DIM; i++) begin
            output_data[i] = input_weights[0][i]; // bias
            for (int j = 1; j <= INPUT_DIM; j++) begin
                output_data[i] += input_data[j-1] * input_weights[j][i];
            end
        end
        // Backward pass
        for (int i = 0; i < OUTPUT_DIM; i++) begin
            output_weights[0][i] = input_weights[0][i] + LEARNING_RATE * output_error[i];
            for (int j = 1; j <= INPUT_DIM; j++) begin
                output_weights[j][i] = input_weights[j][i] + LEARNING_RATE * output_error[i] * input_data[j-1];
            end
        end
    end

endmodule
