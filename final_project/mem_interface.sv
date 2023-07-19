module mem_interface(input logic CLK, RESET,
		input  logic pixel_clk,
		input  logic AVL_WRITE,	// write enable for AVL
		input  logic AVL_READ, // read enable for AVL
		input  logic AVL_CS,					// chip select
		input  logic blank,
		input  logic [3:0]  AVL_BYTE_EN,			// Avalon-MM Byte Enable
		input  logic [16:0] AVL_ADDR,			// this is in terms of the words (32 bits)
		input  logic [16:0] bloke_idx,		// the bloke that we want to access in raster order
		input  logic [31:0] AVL_WRITEDATA,		// Avalon-MM Write Data -- the avl wants to write this
		output logic [31:0] AVL_READDATA,		// Avalon-MM Read Data -- we want the avl to read this
		output logic [3:0]  red, green, blue);	// the RGB that we want to send to the VGA
					
	// the register that we're using to determine which frame
	// we're reading/writing from
	int frame_select = 0;
	int counter = 0;
	// the addresses that we are sending to memory
	logic [17:0] frame1_addr, frame0_addr;
	// color palette
	logic [31:0] palette[8];
	// address that we will be sending to the memory to get the bloke
	logic [16:0] bloke_addr;
	// 4 bit palette index that we will get from the data retreived from memory
	logic [3:0] palette_idx;
	// 12 bit RGB to be gotten from palette
	logic [11:0] RGB;
	logic [2:0] bloke_slot;
	logic [31:0] readVal0, readVal1, readVal;
	
	
	always_comb begin
		// bloke addr = bloke_idx / 8
		bloke_addr = bloke_idx[16:3];
		// bloke_slot is the slot within the 32-bit chunk
		// bloke_slot = bloke_idx % 8
		bloke_slot = bloke_idx[2:0];
	end
	
	
	always_ff @(posedge CLK) begin
		
		if(!frame_select) begin
			// write to frame 0
			frame0_addr <= AVL_ADDR; //address in memory to write to
			// read from frame 1
			frame1_addr <= bloke_addr + 16'h2580; //read from the bloke address to find the RGB data for that bloke
			// we want to keep readVal1
			readVal <= readVal1; 
		end
		else begin
			// read from frame 0
			frame0_addr <= bloke_addr;
			// write to frame 1
			frame1_addr <= AVL_ADDR + 16'h2580;
			// we want to keep readVal0
			readVal <= readVal0;
		end
	
	end

	//logic to switch frames
	always_ff @(posedge pixel_clk) begin
		// if we are reading from the last pixel, switch frame select
		if (bloke_addr == 76799) begin
			counter <= counter + 1;	
		end
		if(counter == 4) begin
			counter <= 0;
			frame_select <= 1 - frame_select;
		end

	end
	
	
	always_ff @(posedge CLK) begin
		//2580 is where the palette starts
		if(AVL_CS && AVL_READ && !(AVL_ADDR[15:4] == 12'h258)) begin
			AVL_READDATA <= readVal;
		end
		else if(AVL_CS && AVL_READ && (AVL_ADDR[15:4] == 12'h258)) begin
			AVL_READDATA <= palette[AVL_ADDR[2:0]];
		end
		else if(AVL_CS && AVL_WRITE && (AVL_ADDR[15:4] == 12'h258)) begin
			palette[AVL_ADDR[2:0]] <= AVL_WRITEDATA;
		end 
	end
	
	always_comb begin
		// get the 4 bits representing palette_idx in the data read from memory
		case(bloke_slot)
			3'b111 : palette_idx = readVal[31:28];
			3'b110 : palette_idx = readVal[27:24];
			3'b101 : palette_idx = readVal[23:20];
			3'b100 : palette_idx = readVal[19:16];
			3'b011 : palette_idx = readVal[15:12];
			3'b010 : palette_idx = readVal[11:8];
			3'b001 : palette_idx = readVal[7:4];
			3'b000 : palette_idx = readVal[3:0];
		endcase
		
		// if palette_idx is even, take the right half
		if(!palette_idx[0]) begin
			RGB = palette[palette_idx[3:1]][12:1];
		end
		// else it's odd so take the left half
		else begin
			RGB = palette[palette_idx[3:1]][24:13];
		end
	end
	
	// assign RGB on the clock
	always_ff @(posedge pixel_clk) begin
		if(!blank) begin
			red <= 4'b0000;
			green <= 4'b0000;
			blue <= 4'b0000;
		end 
		
		else begin
			red <= RGB[11:8];
			green <= RGB[7:4];
			blue <= RGB[3:0];
		end
	end
	
	
ram 	ram0(.address_a(frame0_addr), 
		.address_b(frame1_addr),
		.byteena_a(AVL_BYTE_EN),
		.byteena_b(AVL_BYTE_EN),
		.clock(CLK),
		.data_a(AVL_WRITEDATA),
		.data_b(AVL_WRITEDATA),
		.wren_a(AVL_WRITE && AVL_CS && !frame_select),
		.wren_b(AVL_WRITE && ALV_CS && frame_select),
		.q_a(readVal0),
		.q_b(readVal1));
					
endmodule
