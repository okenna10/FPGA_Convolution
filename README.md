# FPGA_Convolution
2D convolution fully implemented in an FPGA

This project will take image pixels streamed from left to right one pixel at a time and convolve the image over using a 3x3 filter. Valid inputs must be accompanied with a valid signal and valid outputs will also have a corresponding flag. Input pixels are unsigned 8-bit values. Output values are truncated to either 0 or 255 as this is the highest permitted range. This design uses intel IP to instantiate FIFO's with a depth of 512 and a width of 8-bits. Outputs from the FIFO are registered and put through 2 additional registers before being passed into the next FIFO. Future work will center around inferring the FIFOs for improved portability. The architecture is shown below
![image](https://github.com/okenna10/FPGA_exponential_function/assets/101345398/d01cad58-57e5-4992-a193-2fd2a806bd39)
