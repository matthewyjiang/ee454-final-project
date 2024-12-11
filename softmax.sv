module softmax
#(
    parameter int WIDTH = 16,
    parameter int DIMENSION = 10
) 

(
    input  logic signed [WIDTH-1:0] input_data [DIMENSION],
    output logic signed [WIDTH-1:0] output_data [DIMENSION]
);

logic signed [WIDTH-1:0] sum;

// Function to compute factorial in fixed-point
function [WIDTH-1:0] factorial(input int n);
    integer i;
    factorial = 1; // Start with 1
    for (i = 2; i <= n; i++) begin
        factorial = factorial * i;
    end
endfunction

// Function to compute exponential using Taylor series
function [WIDTH-1:0] exp_taylor(input [WIDTH-1:0] x);
    integer i;
    logic [WIDTH-1:0] term;  // Current term in the series
    logic [WIDTH-1:0] power; // x^n numerator
    logic [WIDTH-1:0] sum;   // Accumulated sum

    power = (1 << (WIDTH / 2)); // x^0 = 1 in fixed-point
    sum = (1 << (WIDTH / 2));   // Initialize sum with 1
    term = (1 << (WIDTH / 2));  // First term is 1

    for (i = 1; i < TERMS; i++) begin
        // Compute next power of x (x^n)
        power = (power * x) >> (WIDTH / 2);

        // Compute the term x^n / n!
        term = (power / factorial(i));

        // Add the term to the sum
        sum = sum + term;
    end

    exp_taylor = sum;
endfunction

always_comb begin
    sum = 0;
    for (int i = 0; i < DIMENSION; i++) begin
        sum = sum + exp_taylor(input_data[i]);
    end

    for (int i = 0; i < DIMENSION; i++) begin
        output_data[i] = exp_taylor(input_data[i]) / sum;
    end
end



endmodule