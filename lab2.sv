// This module implements 2D covolution between a 3x3 filter and a 512-pixel-wide image of any height.
// It is assumed that the input image is padded with zeros such that the input and output images have
// the same size. The filter coefficients are symmetric in the x-direction (i.e. f[0][0] = f[0][2], 
// f[1][0] = f[1][2], f[2][0] = f[2][2] for any filter f) and their values are limited to integers
// (but can still be positive of negative). The input image is grayscale with 8-bit pixel values ranging
// from 0 (black) to 255 (white).
module lab2 (
	input  clk,			// Operating clock
	input  reset,			// Active-high reset signal (reset when set to 1)
	input  [71:0] i_f,		// Nine 8-bit signed convolution filter coefficients in row-major format (i.e. i_f[7:0] is f[0][0], i_f[15:8] is f[0][1], etc.)
	input  i_valid,			// Set to 1 if input pixel is valid
	input  i_ready,			// Set to 1 if consumer block is ready to receive a new pixel
	input  [7:0] i_x,		// Input pixel value (8-bit unsigned value between 0 and 255)
	output o_valid,			// Set to 1 if output pixel is valid
	output o_ready,			// Set to 1 if this block is ready to receive a new pixel
	output [7:0] o_y		// Output pixel value (8-bit unsigned value between 0 and 255)
);

localparam FILTER_SIZE = 3;	// Convolution filter dimension (i.e. 3x3)
localparam PIXEL_DATAW = 8;	// Bit width of image pixels and filter coefficients (i.e. 8 bits)

reg i_valid_r, valid, valid2;
reg [7:0] x, stage1_1, stage1_2, stage2_1, stage2_2, stage3_1, stage3_2;
reg [7:0] fifo1_out, fifo2_out, fifo3_out;
reg signed [7:0] sums [FILTER_SIZE-1:0], temp_out2;
reg signed [16:0] temp_out;
reg [2:0] wr, rd, full, empty;
reg [11:0] counter;

reg [8:0] used_wd1, used_wd2, used_wd3;

//FSM Signals
typedef enum {init_1, init_2, init_3, image_out} state;
state current_state, next_state;

// The following code is intended to show you an example of how to use paramaters and
// for loops in SytemVerilog. It also arrages the input filter coefficients for you
// into a nicely-arranged and easy-to-use 2D array of registers. However, you can ignore
// this code and not use it if you wish to.

logic signed [PIXEL_DATAW-1:0] r_f [FILTER_SIZE-1:0][FILTER_SIZE-1:0]; // 2D array of registers for filter coefficients
logic signed [PIXEL_DATAW:0] conv_window [FILTER_SIZE-1:0][FILTER_SIZE-1:0]; // 2D array of registers for images-images to be convolved. MSB set to 0 for accurate signed arithmetic.
integer col, row, col1, row1; // variables to use in the for loop
always_ff @ (posedge clk) begin
	// If reset signal is high, set all the filter coefficient registers to zeros
	// We're using a synchronous reset, which is recommended style for recent FPGA architectures
	if(reset)begin
		for(row = 0; row < FILTER_SIZE; row = row + 1) begin
			for(col = 0; col < FILTER_SIZE; col = col + 1) begin
				r_f[row][col] <= 0;
			end
		end
	// Otherwise, register the input filter coefficients into the 2D array signal
	end else begin
		for(row = 0; row < FILTER_SIZE; row = row + 1) begin
			for(col = 0; col < FILTER_SIZE; col = col + 1) begin
				// Rearrange the 72-bit input into a 3x3 array of 8-bit filter coefficients.
				// signal[a +: b] is equivalent to signal[a+b-1 : a]. You can try to plug in
				// values for col and row from 0 to 2, to understand how it operates.
				// For example at row=0 and col=0: r_f[0][0] = i_f[0+:8] = i_f[7:0]
				//	       at row=0 and col=1: r_f[0][1] = i_f[8+:8] = i_f[15:8]
				r_f[row][col] <= i_f[(row * FILTER_SIZE * PIXEL_DATAW)+(col * PIXEL_DATAW) +: PIXEL_DATAW];
			end
		end
	end
end

assign conv_window[0][0] = fifo1_out;
assign conv_window[0][1] = stage1_1;
assign conv_window[0][2] = stage1_2;
assign conv_window[1][0] = fifo2_out;
assign conv_window[1][1] = stage2_1;
assign conv_window[1][2] = stage2_2;
assign conv_window[2][0] = fifo3_out;
assign conv_window[2][1] = stage3_1;
assign conv_window[2][2] = stage3_2;

always_comb begin
	if (current_state == image_out) begin
		temp_out = 0;

		for(row1 = 0; row1 < FILTER_SIZE; row1 = row1 + 1) begin
			for(col1 = 0; col1 < FILTER_SIZE; col1 = col1 + 1) begin
				temp_out = (r_f[row1][col1] * conv_window[row1][col1]) + temp_out;
			end
		end

	end
end

// Start of your code
always_ff @ (posedge clk) begin
	if (reset) 
		current_state <= init_1;
	else 
		current_state <= next_state;
	
	i_valid_r <= i_valid;
	x 		  <= i_x;
	//ready	  <= i_ready;
end

always_comb begin
	case (current_state)
		init_1 : begin
			rd = 3'b000;
			wr = 2'b00;

			if (counter >= 511)
				rd = 3'b001;

			if (counter < 513)
				next_state = init_1;
			else
				next_state = init_2;
		end

		init_2 : begin
			wr = 2'b01;

			if (counter >= 511)
				rd = 3'b011;
			else
				rd = 3'b001;
                
			if (counter < 513)
				next_state = init_2;
			else
				next_state = init_3;
		end

		init_3 : begin
			wr = 2'b11;

			if (counter >= 511)
				rd = 3'b111;
			else
				rd = 3'b011;

			if (counter < 513)
				next_state = init_3;
			else
				next_state = image_out;
		end

		image_out : begin
			valid = 1'b1;

			if (counter > 511)
				valid = 1'b0;

			if (reset)
				next_state = image_out;
		end
	endcase
end

fifo fifo_1 (
		.data  (x),         		//   input,  width = 8,  fifo_input.datain
		.wrreq (i_valid_r), 		//   input,  width = 1,            .wrreq
		.rdreq (rd[0] && i_ready),  //   input,  width = 1,            .rdreq
		.clock (clk),       		//   input,  width = 1,            .clk
		.sclr  (reset),     		//   input,  width = 1,            .sclr
        //Outputs
		.q     (fifo1_out), //  output,  width = 8, fifo_output.dataout
		.usedw (used_wd1),  //  output,  width = 9,            .usedw
		.full  (full[0]),   //  output,  width = 1,            .full
		.empty (empty[0])   //  output,  width = 1,            .empty
	);

fifo fifo_2 (
		.data  (stage1_2),         //   input,  width = 8,  fifo_input.datain
		.wrreq (wr[0]), 		   //   input,  width = 1,            .wrreq
		.rdreq (rd[1] && i_ready), //   input,  width = 1,            .rdreq
		.clock (clk),       	   //   input,  width = 1,            .clk
		.sclr  (reset),     	   //   input,  width = 1,            .sclr
        //Outputs
		.q     (fifo2_out), //  output,  width = 8, fifo_output.dataout
		.usedw (used_wd2),  //  output,  width = 9,            .usedw
		.full  (full[1]),   //  output,  width = 1,            .full
		.empty (empty[1])   //  output,  width = 1,            .empty
	);

fifo fifo_3 (
		.data  (stage2_2),          //   input,  width = 8,  fifo_input.datain
		.wrreq (wr[1]), 		    //   input,  width = 1,            .wrreq
		.rdreq (rd[2] && i_ready),  //   input,  width = 1,            .rdreq
		.clock (clk),       		//   input,  width = 1,            .clk
		.sclr  (reset),     		//   input,  width = 1,            .sclr
        //Outputs
		.q     (fifo3_out), //  output,  width = 8, fifo_output.dataout
		.usedw (used_wd3),  //  output,  width = 9,            .usedw
		.full  (full[2]),   //  output,  width = 1,            .full
		.empty (empty[2])   //  output,  width = 1,            .empty
	);

always_ff @(posedge clk) begin
	if (reset)
		counter <= 0;
	else
		if (current_state == init_1) begin
			if (i_valid_r && i_ready) 
				counter <= counter + 1'b1;
		end 
		else
			if (i_ready)
			counter <= counter + 1'b1;

        if (counter == 513)
            counter <= 0; 
	
	if (i_ready) begin
		//Assign output
		if (temp_out >= 255)
			temp_out2 <= 255;
		else if (temp_out <= 0)
			temp_out2 <= 0;
		else
			temp_out2 <= temp_out;

		valid2 <= valid;				

		stage1_1 <= fifo1_out;
		stage1_2 <= stage1_1;

		stage2_1 <= fifo2_out;
		stage2_2 <= stage2_1;
		
		stage3_1 <= fifo3_out;
		stage3_2 <= stage3_1;
	end
end

assign o_y = temp_out2;
assign o_valid = valid2;
assign o_ready = ~(| full);
//assign o_ready = i_ready;
 
// End of your code

endmodule

