module fully_connected_layer 
    #(
        parameter int WIDTH = 16, 
        parameter int INPUT_DIM, 
        parameter int OUTPUT_DIM, 
        parameter int LEARNING_RATE
    )
(
    input  logic clk,
    input  logic reset,
    input  logic signed [WIDTH-1:0] input_data [INPUT_DIM],
    input  logic signed [WIDTH-1:0] output_error [OUTPUT_DIM],
    output logic signed [WIDTH-1:0] output_data [OUTPUT_DIM],
    output logic signed [WIDTH-1:0] input_error [INPUT_DIM]
);

    logic signed [WIDTH-1:0] weights [OUTPUT_DIM][INPUT_DIM];
    logic signed [WIDTH-1:0] bias [OUTPUT_DIM];
    logic signed [2*WIDTH-1:0] sum [OUTPUT_DIM];

    // Forward pass (combinational logic)
    always_comb begin
        for (int i = 0; i < OUTPUT_DIM; i++) begin
            output_data[i] = bias[i];
            for (int j = 0; j < INPUT_DIM; j++) begin
                output_data[i] += input_data[j] * weights[i][j];
            end
        end
    end

    // Backward pass (sequential logic)
    always_ff @(posedge clk or negedge reset) begin
        if (!reset) begin
            // Initialize weights and biases to zero (or random later)
            for (int i = 0; i < OUTPUT_DIM; i++) begin
                bias[i] <= '0;
                for (int j = 0; j < INPUT_DIM; j++) begin
                    weights[i][j] <= '0;
                end
            end
        end else begin
            // Placeholder for backward pass logic
            // Compute input_error and weight updates based on output_error
            // Update weights and biases using learning rate

            // Example of weight update using learning rate:
            // weights[i][j] <= weights[i][j] + LEARNING_RATE * output_error[i] * input_data[j];
        end
    end

endmodule
