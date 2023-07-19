/************************************************************************
Avalon-MM Interface VGA Text mode display

Register Map:
0x000-0x0257 : VRAM, 80x30 (2400 byte, 600 word) raster order (first column then row)
0x258        : control register

VRAM Format:
X->
[ 31  30-24][ 23  22-16][ 15  14-8 ][ 7    6-0 ]
[IV3][CODE3][IV2][CODE2][IV1][CODE1][IV0][CODE0]

IVn = Draw inverse glyph
CODEn = Glyph code from IBM codepage 437

Control Register Format:
[[31-25][24-21][20-17][16-13][ 12-9][ 8-5 ][ 4-1 ][   0    ] 
[[RSVD ][FGD_R][FGD_G][FGD_B][BKG_R][BKG_G][BKG_B][RESERVED]

VSYNC signal = bit which flips on every Vsync (time for new frame), used to synchronize software
BKG_R/G/B = Background color, flipped with foreground when IVn bit is set
FGD_R/G/B = Foreground color, flipped with background when Inv bit is set

************************************************************************/




//Essentially, this is the graphics controller module

module vga_text_avl_interface (
	// Avalon Clock Input, note this clock is also used for VGA, so this must be 50Mhz
	// We can put a clock divider here in the future to make this IP more generalizable
	input logic CLK,
	
	// Avalon Reset Input
	input logic RESET,
	
	// Avalon-MM Slave Signals
	input  logic AVL_READ,					// Avalon-MM Read
	input  logic AVL_WRITE,					// Avalon-MM Write
	input  logic AVL_CS,					// Avalon-MM Chip Select
	input  logic [3:0] AVL_BYTE_EN,			// Avalon-MM Byte Enable
	input  logic [11:0] AVL_ADDR,			// Avalon-MM Address -- 10 bit address but only 4 bits at a time are used
	input  logic [31:0] AVL_WRITEDATA,		// Avalon-MM Write Data -- the avl wants to write this
	output logic [31:0] AVL_READDATA,		// Avalon-MM Read Data -- we want the avl to read this
	
	// Exported Conduit (mapped to VGA port - make sure you export in Platform Designer)
	output logic [3:0]  red, green, blue,	// VGA color channels (mapped to output pins in top-level)
	output logic hs, vs						// VGA HS/VS
);


//Instantiate On-Chip Memory
//Data_0 - Data from Avalon Bus	A
//Addr_0 - Address from Avalon Bus	A
//Data_1 - Data for VGA B
//Addr_1 - Address for VGA
ram ram0(.address_a(AVL_ADDR), 
		.address_b(register),
		.byteena_a(AVL_BYTE_EN),
		.byteena_b(4'b0000),
		.clock(CLK),
		.data_a(AVL_WRITEDATA),
		.data_b(),
		.wren_a(AVL_WRITE),
		.wren_b(0),
		.q_a(),
		.q_b(memData));


//	input	[10:0]  address_a;
//	input	[10:0]  address_b;
//	input	[3:0]  byteena_a;
//	input	[3:0]  byteena_b;
	//input	  clock;
	//input	[31:0]  data_a;
	//input	[31:0]  data_b;
//	input	  wren_a;
//	input	  wren_b;
//	output	[31:0]  q_a;
//	output	[31:0]  q_b;
//
//put other local variables here
logic display, pixel_clk, sync;
logic [9:0] DrawX, DrawY; //draw variables that come from the VGA controller  

//Declare submodules..e.g. VGA controller, ROMS, etc
	vga_controller vga_controller0(.Clk(CLK), .Reset(RESET), .hs, .vs, 
								.pixel_clk, .blank(display), .sync, .DrawX, .DrawY);

//blank takes in the actual display that is being projected

// Read and write from AVL interface to register block, note that READ waitstate = 1, so this should be in always_ff
	
//if read, then the data from register block goes to the avalon bus

//if write, then the data from the data from avalon bus has to go to the bus

//in both cases, chip select has to b high

//for clarification, look at the Byte Enable Description in the Introduction to Avalon and VGA table


//handle drawing (may either be combinational or sequential - or both).
logic [9:0] OffsetX, OffsetY;
logic [31:0] arr_idx;
logic [7:0] CharX;
logic [6:0] CharY;
logic [10:0] char_addr; //why are we passing a 10 bit char_address?
logic [7:0] character, charRow; 
logic draw;
logic [1:0] regByte;
logic [11:0] register;
logic [31:0] memData;


always_ff @(posedge CLK) begin
	// character <= LOCAL_REG[register][regByte]; // arr/4 mem address,
	if(regByte == 3)
		character <= memData[31:24];
	else if(regByte == 2)
		character <= memData[23:16];
	else if(regByte == 1)
		character <= memData[15:8];
	else if(regByte == 0)
		character <= memData[7:0];
end

always_comb begin
	CharX = DrawX[9:3]; //divide by 8 -> gives us the glypth we are in horizontally
	CharY = DrawY[9:4]; //divide by 16 -> gives us the glypth we are in vertically
	OffsetX = DrawX[2:0]; //% by 8 -> gives us the bit that we offset from the beginning of the glypth
	OffsetY = DrawY[3:0]; /*% by 16 -> gives us the bit we are at byte in the register, so essentially gives us the location of the from the top of the glypth*/
	arr_idx = CharX + 80*CharY; //we have an index that is row major order searching the registers
	char_addr = 16*character[6:0] + OffsetY;   //char_addr in the register	
	regByte = arr_idx[1:0];
	register = arr_idx[11:2];
end



	font_rom font_rom0(.addr(char_addr), .data(charRow));         //we want the data to match what the cpu tells us

	//offset Y tells us the offset from the beginning row of the character in the font_rom.
	//offset X tells us the offset from the beginning bit in the row being looked at in font_rom.


logic [31:0] colorInfo;

always_ff @(posedge CLK) begin
	if(AVL_ADDR == 600)
		colorInfo = AVL_WRITEDATA;
end


always_ff @(posedge pixel_clk) begin
	
		if (display == 1'b0) begin
			red <= 4'b0000;
			green <= 4'b0000;
			blue <= 4'b0000;
		end else begin
			if (character[7] == 1) begin
				draw <= ~charRow[7- OffsetX];
			end
			else begin
				draw <= charRow[7- OffsetX];
			end

			case(draw)
			1'b1: //Foreground
				begin
					red = colorInfo[24:21];
					green = colorInfo[17:20];
					blue = colorInfo[13:16];
					// red <= {LOCAL_REG[`CTRL_REG][3][0], LOCAL_REG[`CTRL_REG][2][7:5]};
					// green <= LOCAL_REG[`CTRL_REG][2][4:1];
					// blue <= {LOCAL_REG[`CTRL_REG][2][0], LOCAL_REG[`CTRL_REG][1][7:5]};
				end
			1'b0: //Background
				begin
					red = colorInfo[12:9];
					green = colorInfo[8:5];
					blue = colorInfo[4:1];
				end
				// begin
				// 	red <= LOCAL_REG[`CTRL_REG][1][4:1];											//[12:9]
				// 	green <= {LOCAL_REG[`CTRL_REG][1][0], LOCAL_REG[`CTRL_REG][0][7:5]};				//[8:5]
				// 	blue <= LOCAL_REG[`CTRL_REG][0][4:1];											//[4:1]
				// end
			endcase
	end
end


endmodule