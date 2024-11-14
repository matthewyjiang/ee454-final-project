import random

# Function to convert a floating point number to 16.16 fixed-point hexadecimal representation
def float_to_fixed_hex(value):
    # 16 bits for whole and 16 bits for fractional (total 32 bits)
    fixed_point_val = int(value * (1 << 16))  # Scale by 2^16
    # Handle negative numbers with two's complement
    if fixed_point_val < 0:
        fixed_point_val = (1 << 32) + fixed_point_val
    # Convert to hex and pad to 8 characters for 32-bit representation
    return f"{fixed_point_val:08X}"

# Parameters
num_samples = 100  # Number of samples to generate
noise_level = 0.05  # Noise level around y = x

# Generate (x, y) pairs around the line y = x with some noise
fixed_point_pairs = []
for x in range(-num_samples // 2, num_samples // 2):
    y = x + random.uniform(-noise_level, noise_level)  # y = x + noise
    x_fixed_hex = float_to_fixed_hex(x)  # Convert x to hex
    y_fixed_hex = float_to_fixed_hex(y)  # Convert y to hex
    fixed_point_pairs.append((x_fixed_hex, y_fixed_hex))

# Write results to a file
with open("fixed_point_values.txt", "w") as file:
    file.write("X (hex), Y (hex)\n")  # Header line
    for x_hex, y_hex in fixed_point_pairs:
        #file.write(f"{x_hex}, {y_hex}\n")
        file.write(f"input_data = 32'h{x_hex}\n")
        file.write(f"#10\n")

print("Fixed-point (x, y) values saved to fixed_point_values.txt")

