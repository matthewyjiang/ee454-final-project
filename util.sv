package utilities;
    class util#(parameter WIDTH, FIXED_POINT_INDEX);
        function logic [WIDTH-1:0] fixed_point_multiply (
            input logic [WIDTH-1:0] a,
            input logic [WIDTH-1:0] b
        );

            logic [2*WIDTH-1:0] product;
            logic [WIDTH-1:0] result;
            product = a * b;
            product = product >>> FIXED_POINT_INDEX;
            
            result = product;
            return result;  
        endfunction
    endclass

    
endpackage

// is there any case where we need to pad 0's to make sure it's exactly 32 bit ? << maybe only for inputs