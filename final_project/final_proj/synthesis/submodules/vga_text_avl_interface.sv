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
	input  logic [16:0] AVL_ADDR,			// Avalon-MM Address -- 10 bit address but only 4 bits at a time are used
	input  logic [31:0] AVL_WRITEDATA,		// Avalon-MM Write Data -- the avl wants to write this
	output logic [31:0] AVL_READDATA,		// Avalon-MM Read Data -- we want the avl to read this
	
	// Exported Conduit (mapped to VGA port - make sure you export in Platform Designer)
	output logic [3:0]  red, green, blue,	// VGA color channels (mapped to output pins in top-level)
	output logic hs, vs						// VGA HS/VS
);


logic display, pixel_clk, sync;
logic [9:0] DrawX, DrawY; //draw variables that come from the VGA controller  
logic [16:0] bloke_idx;
logic [8:0] BlokeX, BlokeY;

//Declare submodules..e.g. VGA controller, ROMS, etc
	vga_controller vga_controller0(.Clk(CLK), .Reset(RESET), .hs, .vs, 
								.pixel_clk, .blank(display), .sync, .DrawX, .DrawY);
								
//Memory interface module to deal with reading from and writing to memory							
mem_interface	mi(.CLK, .RESET,
		.AVL_WRITE,	// write enable for AVL
		.AVL_READ, // read enable for AVL
		.AVL_CS,					// chip select
		.AVL_BYTE_EN,			// Avalon-MM Byte Enable
		.AVL_ADDR,			// this is in terms of the words (32 bits)
		.bloke_idx,		// the bloke that we want to access in raster order
		.blank(display),
		.AVL_WRITEDATA,		// Avalon-MM Write Data -- the avl wants to write this
		.AVL_READDATA,		// Avalon-MM Read Data -- we want the avl to read this
		.red, .green, .blue);

//determine which register we want to access
always_comb 
	begin
	BlokeX = DrawX[9:1]; //divide by 2 to get horizontal bloke
	BlokeY = DrawY[9:1]; //divide by 2 to get vertical bloke
	bloke_idx = BlokeX + BlokeY; // get the glyph number that we are looking at
end


//font_rom font_rom0(.addr(char_addr), .data(charRow));         //we want the data to match what the cpu tells us


endmodule

