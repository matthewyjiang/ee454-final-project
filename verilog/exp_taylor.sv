`include "util.sv"

module exp_taylor #(
    parameter WIDTH = 16,               // Data width
    parameter FIXED_POINT_INDEX = 8,    // Fixed-point fractional bits
    parameter TERMS = 8                // Number of terms in the Taylor series
)(
    input  logic clk,                   // Clock signal
    input  logic reset,                 // Reset signal
    input  logic start,                 // Start signal
    input  logic signed [WIDTH-1:0] x,  // Input value in Q(FRAC) format
    output logic signed [WIDTH-1:0] result, // Result in Q(FRAC) format
    output logic done,                   // Done signal
    output logic busy
);
    import utilities::*;
    util#(WIDTH, FIXED_POINT_INDEX) util_inst = new();

    logic div_start;  // start calculation
    logic div_busy;   // calculation in progress
    logic div_done;   // calculation is complete (high for one tick)
    logic div_valid;  // result is valid
    logic div_dbz;    // divide by zero
    logic div_ovf;    // overflow
    logic signed [WIDTH-1:0] div_a;   // dividend (numerator)
    logic signed [WIDTH-1:0] div_b;   // divisor (denominator)
    logic signed [WIDTH-1:0] div_val;  // result value: quotient

    div #(.WIDTH(WIDTH), .FBITS(FIXED_POINT_INDEX)) div_inst (
        .clk(clk),
        .rst(reset),
        .start(div_start),
        .busy(div_busy),
        .done(div_done),
        .valid(div_valid),
        .dbz(div_dbz),
        .ovf(div_ovf),
        .a(div_a),
        .b(div_b),
        .val(div_val)
    );

    // Internal signals
    logic [$clog2(TERMS):0] current_term;           // Current term index
    logic signed [WIDTH-1:0] power;     // x^n in Q(FRAC)
    logic signed [WIDTH-1:0] sum;       // Accumulated sum in Q(FRAC)
    logic signed [WIDTH-1:0] term;      // Current term in Q(FRAC)

    // Fixed-point representation of 1.0
    localparam int FRAC = FIXED_POINT_INDEX;
    localparam signed [WIDTH-1:0] ONE = (1 <<< FRAC);

    // State machine states
    typedef enum logic [2:0] {
        IDLE,
        COMPUTE_POWER,
        COMPUTE_TERM,
        ADD_TERM,
        DONE
    } state_t;

    state_t state, next_state;

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

    // Sequential state transition
    always_ff @(posedge clk or negedge reset) begin
        if (!reset) begin
            state <= IDLE;
            current_term <= 0;
            power <= ONE;
            sum <= ONE;
            done <= 0;
        end else begin
            state <= next_state;

            // Update signals based on state
            case (state)
                IDLE: begin
                    done <= 0;
                    if (start) begin
                        current_term <= 1; // Start from the second term
                        power <= ONE;      // Initialize x^0 = 1
                        sum <= 0;        // Initialize sum with the first term
                        done <= 0;
                        term <= 0;
                        busy <= 1;
                    end
                end

                COMPUTE_POWER: begin
                    power <= util_inst.fixed_point_multiply(power, x);
                end

                COMPUTE_TERM: begin
                    div_a <= power;
                    div_b <= factorial(current_term);
                    if (div_busy) begin
                        div_start <= 0;
                    end else begin
                        div_start <= 1;
                    end

                    if (div_done) begin
                        if (div_valid)
                            term <= div_val;
                    end

                end

                ADD_TERM: begin
                    // Add term to the sum
                    sum <= sum + term;
                    
                    // Check if done or move to the next term
                    if (current_term < TERMS) begin
                        current_term <= current_term + 1;
                    end
                end
                DONE: begin
                    result <= sum;    // Output the final result
                    // display sum in fixed point
                    
                    done <= 1;
                    if (div_busy)
                        busy <= 1;
                    else
                        busy <= 0;
                end

            endcase
        end
    end

    // Combinational next state logic
    always_comb begin
        next_state = state;
        case (state)
            IDLE: begin
                if (start) next_state = COMPUTE_POWER;
            end

            COMPUTE_POWER: begin
                next_state = COMPUTE_TERM;
            end

            COMPUTE_TERM: begin
                if (div_done) 
                    next_state = ADD_TERM;
            end

            ADD_TERM: begin
                if (current_term < TERMS)
                    next_state = COMPUTE_POWER;
                else
                    next_state = DONE;
            end
                
            DONE: begin
                if (div_busy)
                    next_state = DONE;
                else
                    next_state = IDLE;
            end
        endcase
    end

endmodule
