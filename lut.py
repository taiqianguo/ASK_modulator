import numpy as np

# Parameters for the unsigned 8-bit values
num_entries = 199
bit_width = 8
max_value = 255  # Maximum value for an 8-bit unsigned number

# Generating sine values over one period (0 to 2pi)
angles = np.linspace(0, 2*np.pi, num_entries, endpoint=False)
sine_values = np.sin(angles)

# Adjusting sine values to the 8-bit unsigned range [0, 255]
adjusted_sine_values = np.round((sine_values * 127.5) + 127.5).astype(int)  # Scale and offset

# Convert to 8-bit binary representation for unsigned values
binary_unsigned_sine_values = [np.binary_repr(value, width=bit_width) for value in adjusted_sine_values]

# Prepare content for the text file
unsigned_file_content = "\n".join(binary_unsigned_sine_values)

# Save to a .txt file
unsigned_file_path = '../single_port_rom_init_unsigned.txt'
with open(unsigned_file_path, 'w') as file:
    file.write(unsigned_file_content)

unsigned_file_path, binary_unsigned_sine_values[:199]  # Show the path and first 5 entries for verification

