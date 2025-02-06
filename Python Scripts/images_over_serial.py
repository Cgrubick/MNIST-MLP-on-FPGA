from PIL import Image
import serial
import numpy as np

# Step 1: Load and preprocess the image
def image_to_bytes(image_path):
    # Open the image
    img = Image.open(image_path)

    # Convert to grayscale
    img = img.convert('L')

    # Resize the image (optional)
    img = img.resize((28, 28))  # Example size for MNIST

    # Convert image to numpy array
    pixel_data = np.array(img, dtype=np.uint8)

    # Flatten the array and convert to bytes
    byte_data = pixel_data.flatten().tobytes()

    return byte_data

# Step 2: Send the bytes over serial
def send_image_over_serial(image_path, port, baudrate=9600):
    # Convert the image to bytes
    byte_data = image_to_bytes(image_path)

    # Initialize serial communication
    with serial.Serial(port, baudrate, timeout=1) as ser:
        # Send the byte data
        ser.write(byte_data)
        print(f"Sent {len(byte_data)} bytes over serial")

# Example usage
image_path = "example.png"  # Path to your .png file
serial_port = "COM3"  # Replace with your serial port
baudrate = 115200  # Replace with your desired baudrate

# Send the image
send_image_over_serial(image_path, serial_port, baudrate)
