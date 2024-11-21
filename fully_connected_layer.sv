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
    output logic signed [WIDTH-1:0] output_data [OUTPUT_DIM],
    output logic signed [WIDTH-1:0] input_error [INPUT_DIM]
);

    logic signed [WIDTH-1:0] weights [OUTPUT_DIM][INPUT_DIM];
    logic signed [WIDTH-1:0] bias [OUTPUT_DIM];
    logic signed [2*WIDTH-1:0] sum [OUTPUT_DIM];

    logic [WIDTH*OUTPUT_DIM-1:0] lfsr_out;
    // Instantiate a LFSR module
    LFSR #(.WIDTH(WIDTH*OUTPUT_DIM)) lfsr (
        .clk(clk),
        .rst(reset),
        .out(lfsr_out)
    );

    logic state;
    logic [$clog2(INPUT_DIM)-1:0] j;

    // Forward pass (combinational logic)
    always_comb begin
        if(state != 0) begin
            for (int i = 0; i < OUTPUT_DIM; i++) begin
                output_data[i] = bias[i];
                for (int j = 0; j < INPUT_DIM; j++) begin
                    output_data[i] += input_data[j] * weights[i][j];
                end
            end
        end
    end

    logic signed [WIDTH-1:0] temp_val;

    // Backward pass (sequential logic)
    always_ff @(posedge clk or negedge reset) begin
        if (!reset) begin
            state <= 0;
            j <= 0;
        end else begin
            if(state == 0) begin
                // Initialize weights and biases to zero (or random later)
                for(int i = 0; i < OUTPUT_DIM; i++) begin
                    bias[i] <= 0;
                    weights[j][i] <= lfsr_out[i*WIDTH-1 +: WIDTH];
                end
                j <= j + 1;
            end
            else begin
            // Placeholder for backward pass logic
            // Compute input_error and weight updates based on output_error
            // Update weights and biases using learning rate

            // Example of weight update using learning rate:
            // weights[i][j] <= weights[i][j] + LEARNING_RATE * output_error[i] * input_data[j];
            end
        end
    end

endmodule
