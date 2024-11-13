# design considerations

after taking a look through the project, here are my initial questions/thoughts on the design from my intuition.

## how do we represent our numbers?
- floating point
- fixed point

fixed point seems much simpler. we can choose a width and designate half for left side, half to right side of point. for example, 16-bit -> 8 bits fractional, 8 bits whole

## how to store weights?

- do we store them in individual modules and have them be created when we create an instance of the layer? (i'm leaning towards this)
- do we manually create arrays for weights on the top module and pass them into modules as inputs?

## random weight initialization

We want to initialize weights using random initialization. the python file example uses the gaussian distribution with variance 1 to initialize weights. how should we implement this?

should we skip the gaussian distribution and just implement a uniform random variable? we can use an LFSR for this if so.

## more points

- i think that the forward pass should be combinational logic. backward pass should be based on a clocked block.
- we create a gated clock. this will turn on and off the backward pass logic, enabling the clock when we want to learn weights.
- i think that we should probably be creating a different module for a different type of layer.