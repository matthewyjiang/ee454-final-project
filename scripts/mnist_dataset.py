import numpy as np
import struct
import os
import kagglehub

# Download latest version
path = "../mnist"

print("Path to dataset files:", path)

def read_idx_file(filepath):
    """
    Reads an IDX file and returns its contents as a NumPy array.
    """
    with open(filepath, 'rb') as f:
        magic_number, num_items = struct.unpack('>II', f.read(8))
        if magic_number == 2051:  # Images file
            rows, cols = struct.unpack('>II', f.read(8))
            data = np.fromfile(f, dtype=np.uint8).reshape(num_items, rows, cols)
        elif magic_number == 2049:  # Labels file
            data = np.fromfile(f, dtype=np.uint8)
        else:
            raise ValueError("Unknown file format")
    return data

# Paths to your files (update these as necessary)
train_images_path = path+"/train-images-idx3-ubyte/train-images-idx3-ubyte"
train_labels_path = path+"/train-labels-idx1-ubyte/train-labels-idx1-ubyte"
test_images_path = path+"/t10k-images-idx3-ubyte/t10k-images-idx3-ubyte"
test_labels_path = path+"/t10k-labels-idx1-ubyte/t10k-labels-idx1-ubyte"

# Load the data
train_images = read_idx_file(train_images_path)
train_labels = read_idx_file(train_labels_path)
test_images = read_idx_file(test_images_path)
test_labels = read_idx_file(test_labels_path)

# Example usage
print("Train Images Shape:", train_images.shape)
print("Train Labels Shape:", train_labels.shape)
print("Test Images Shape:", test_images.shape)
print("Test Labels Shape:", test_labels.shape)

# Convert the first 100 images into Verilog test bench format
def convert_to_verilog(image):
    """
    Converts a single image (28x28) into Verilog test bench format.
    """
    verilog_lines = []
    for row in image:
        line = "'{" + ", ".join([f"32'sh{int(pixel * 256):04X}0000" for pixel in row]) + "}"
        verilog_lines.append(line)
    return "{ " + ", ".join(verilog_lines) + " };"

# Save the first 100 images to a file
output_file = "mnist_images_verilog.txt"
with open(output_file, "w") as f:
    for i in range(100):
        verilog_code = convert_to_verilog(train_images[i] / 255.0)  # Normalize the 8-bit values to [0, 1]
        f.write(f"input_image = {verilog_code}\n\n")

print(f"Converted first 100 images saved to {output_file}")
