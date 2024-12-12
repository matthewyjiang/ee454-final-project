module softmax
#(
    parameter int WIDTH = 16,
    parameter int DIMENSION = 10,
    parameter int FIXED_POINT_INDEX = 8,
    parameter int TERMS = 10
) 

(
    input  logic signed [WIDTH-1:0] input_data [DIMENSION],
    output logic signed [WIDTH-1:0] output_data [DIMENSION]
);

logic signed [WIDTH-1:0] sum;

// Function to compute factorial in fixed-point
function [WIDTH-1:0] factorial(input int n);
    localparam int FRAC = FIXED_POINT_INDEX; // The number of fractional bits
    integer i;

    // Represent 1.0 in Q(FRAC) format
    factorial = (1 << FRAC);

    // Compute factorial in Q(FRAC)
    for (i = 2; i <= n; i++) begin
        // Since i is an integer, multiplying factorial (Q(FRAC)) by i (integer)
        // results in another Q(FRAC) number, no additional shift needed.
        factorial = factorial * i;
    end
endfunction


function automatic logic signed [WIDTH-1:0] signed_fixed_point_div(
    input logic signed [WIDTH-1:0] dividend,
    input logic signed [WIDTH-1:0] divisor
);

    // Determine the sign of the result
    logic sign_result;
    logic signed [WIDTH-1:0] abs_dividend;
    logic signed [WIDTH-1:0] abs_divisor;
    logic [WIDTH-1:0] scaled_abs_dividend;
    logic [WIDTH-1:0] q;
    logic [WIDTH-1:0] r;
    logic [WIDTH-1:0] fractional_part;
    logic [WIDTH-1:0] unsigned_final;
    logic signed [WIDTH-1:0] signed_final;

    sign_result = dividend[WIDTH-1] ^ divisor[WIDTH-1];

    // Get absolute values
    abs_dividend = dividend[WIDTH-1] ? -dividend : dividend;
    abs_divisor  = divisor[WIDTH-1]  ? -divisor  : divisor;

    // Scale the dividend by 2^FIXED_POINT_INDEX
    // Shifting left by FIXED_POINT_INDEX on a positive number is just a logical shift
    scaled_abs_dividend = abs_dividend <<< FIXED_POINT_INDEX;

    // Now perform unsigned integer division on (scaled_abs_dividend / abs_divisor)
    // We'll do the shift-and-subtract method inline:
    q = '0;
    r = '0;

    for (int i = WIDTH-1; i >= 0; i--) begin
        r = (r << 1) | scaled_abs_dividend[i];
        if (r >= abs_divisor) begin
            r = r - abs_divisor;
            q[i] = 1'b1; 
        end
    end

    $display("q = %0d.%0d", q >>> FIXED_POINT_INDEX, q & ((1 << FIXED_POINT_INDEX) - 1));
    $display("r = %0d.%0d", r >>> FIXED_POINT_INDEX, r & ((1 << FIXED_POINT_INDEX) - 1));

    // q is the integer part in Q(FIXED_POINT_INDEX) scaled form
    // r is the remainder

    // Incorporate remainder into q:
    // fractional_part = (r << FIXED_POINT_INDEX) / abs_divisor
    fractional_part = (r <<< FIXED_POINT_INDEX) / abs_divisor;

    unsigned_final = q + fractional_part;

    // Apply sign
    signed_final = sign_result ? -$signed(unsigned_final) : $signed(unsigned_final);

    return signed_final;
endfunction

function automatic logic signed [WIDTH-1:0] exp_taylor(
    input logic signed [WIDTH-1:0] x
);
    integer i;
    logic signed [WIDTH-1:0] term;   // Current term in Q(FRAC)
    logic signed [WIDTH-1:0] power;  // x^n in Q(FRAC)
    logic signed [WIDTH-1:0] sum;    // Accumulated sum in Q(FRAC)

    // Represent 1.0 in Q(FRAC) format:
    // This sets the fractional scale factor as 2^(WIDTH/2).
    localparam int FRAC = FIXED_POINT_INDEX;
    logic signed [WIDTH-1:0] one = (1 <<< FRAC);

    // Initialize power, sum, and term to represent the first term of e^x: 1
    power = one; 
    sum   = one; 
    term  = one;

    // Taylor series: e^x = 1 + x/1! + x²/2! + x³/3! + ... up to TERMS
    for (i = 1; i < TERMS; i++) begin
        // Compute next power of x: x^n
        // power * x is Q(FRAC)*Q(FRAC) = Q(2*FRAC), so shift right by FRAC to get back to Q(FRAC)
        power = ( (power * x) >>> FRAC );

        
        // term = x^n / n! in Q(FRAC)
        // factorial(i) returns an integer (assumed positive)
        // Division by factorial will reduce the magnitude and keep term in Q(FRAC)
        term = signed_fixed_point_div(power, factorial(i));
        
        // Add the term to the sum
        sum = sum + term;
    end

    return sum;
endfunction

logic signed [WIDTH-1:0] dividend = 32'h00020000; // 1.0 in fixed-point
logic signed [WIDTH-1:0] divisor = 32'h00020000; // 2.0 in fixed-pointq
logic signed [WIDTH-1:0] result = signed_fixed_point_div(dividend, divisor);
    

always_comb begin

    // test division

    $display("result = %0d.%0d", result >>> FIXED_POINT_INDEX, result & ((1 << FIXED_POINT_INDEX) - 1));

    sum = 0;
    for (int i = 0; i < DIMENSION; i++) begin
        sum = sum + exp_taylor(input_data[i]);
        // $display("sum = %d", sum);
    // $display("sum (fixed-point) = %0d.%0d", sum >>> FIXED_POINT_INDEX, sum & ((1 << FIXED_POINT_INDEX) - 1));
    end


    for (int i = 0; i < DIMENSION; i++) begin
        output_data[i] = signed_fixed_point_div(exp_taylor(input_data[i]), sum);
    end
end



endmodule