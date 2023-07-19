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

ram ram0(.address_a(AVL_ADDR), 
		.address_b((arr_idx>>1) + lookahead),
		.byteena_a(AVL_BYTE_EN),
		.byteena_b(0),
		.clock(CLK),
		.data_a(AVL_WRITEDATA),
		.data_b(0),
		.wren_a(AVL_WRITE && AVL_CS && (!AVL_ADDR[11])),
		.wren_b(0),
		.q_a(readVal),
		.q_b(memData));

//put other local variables here
logic display, pixel_clk, sync;
logic [9:0] DrawX, DrawY; //draw variables that come from the VGA controller  

//Declare submodules..e.g. VGA controller, ROMS, etc
	vga_controller vga_controller0(.Clk(CLK), .Reset(RESET), .hs, .vs, 
								.pixel_clk, .blank(display), .sync, .DrawX, .DrawY);

//handle drawing (may either be combinational or sequential - or both).
logic [9:0] OffsetX, OffsetY;
logic [31:0] arr_idx;
logic [7:0] CharX;
logic [6:0] CharY;
logic [10:0] char_addr; //why are we passing a 10 bit char_address?
logic [7:0] character, charRow;
logic draw;
logic regByte;
logic [11:0] register;
logic [31:0] memData;
logic [31:0] readVal;
logic [31:0] paletteVal;

//determine which register we want to access
always_comb 
	begin
	//CharX = DrawX[9:3]; //divide by 8 -> gives us the glypth we are in horizontally
	//CharY = DrawY[9:4]; //divide by 16 -> gives us the glypth we are in vertically
	//OffsetX = DrawX[2:0]; //% by 8 -> gives us the bit that we offset from the beginning of the glypth
	//OffsetY = DrawY[3:0]; /*% by 16 -> gives us the bit we are at byte in the register, so essentially gives us the location of the from the top of the glypth*/
	arr_idx = DrawX[9:3] + 80*DrawY[9:4]; // get the glyph number that we are looking at
	char_addr = 16*character[6:0] + DrawY[3:0];   // character address in font_rom
//	char_addr = 16*character[6:0] + DrawY[3:0];   // character address in font_rom	
	regByte = arr_idx[0]; //the byte within the mem that we care about
	register = arr_idx[12:1]; //the memory address that we need to access
end


font_rom font_rom0(.addr(char_addr), .data(charRow));         //we want the data to match what the cpu tells us

	//offset Y tells us the offset from the beginning row of the character in the font_rom.
	//offset X tells us the offset from the beginning bit in the row being looked at in font_rom.

logic [3:0] bgIdx, fgIdx;
//7:0 color first char
//15:8 fontrom first char
	
always_ff @(posedge CLK) begin
	
	case (regByte) //this writes corresponding memdata to the character. Could be the color of the glypth or
						//the glypth itself
		1'b1: begin
			character <= memData[31:24];
			bgIdx <= memData[19:16];
			fgIdx <= memData[23:20];
		end
		1'b0: begin
			character <= memData[15:8];
			bgIdx <= memData[3:0];
			fgIdx <= memData[7:4];
		end
	endcase
end


// create the palette in VRAM
logic [31:0] palette[8];
logic [15:0] charColor;
logic [11:0] fgRGB, bgRGB;
logic lookahead;


always_comb
	begin
		if((DrawX + 1) % 16 == 10'b0000000000)
		begin
			lookahead = -1;
		end
		else begin
			lookahead = 0;
		end
	end

// if the AVL_ADDR is 8, we want to write the data into the palette registers
always_ff @(posedge CLK) begin
	
	if(AVL_CS && AVL_READ && (!AVL_ADDR[11])) begin
		AVL_READDATA <= readVal;
	end
	else if(AVL_CS && AVL_READ && AVL_ADDR[11]) begin
		AVL_READDATA <= palette[AVL_ADDR[2:0]];
	end
	if(AVL_CS && AVL_WRITE && AVL_ADDR[11]) begin
		palette[AVL_ADDR[2:0]] <= AVL_WRITEDATA;
	end 	
end

always_comb
begin 
	if(!fgIdx[0]) begin
		fgRGB = palette[fgIdx[3:1]][12:1];
	end
	else begin
		fgRGB = palette[fgIdx[3:1]][24:13];
	end
	
	if(!bgIdx[0]) begin
		bgRGB = palette[bgIdx[3:1]][12:1];
	end
	else begin
		bgRGB = palette[bgIdx[3:1]][24:13];
	end
end 

always_ff @(posedge pixel_clk) begin
	
		if (display == 1'b0) begin
			red <= 4'b0000;
			green <= 4'b0000;
			blue <= 4'b0000;
		end 
		
		else begin
			if (character[7] == 1) begin
				draw <= ~charRow[7- DrawX[2:0]];
			end
			else begin
				draw <= charRow[7- DrawX[2:0]];
			end

			case(draw) //case statements are sequential
			1'b1: //Foreground
				begin
					red <= fgRGB[11:8];
					green <= fgRGB[7:4];
					blue <= fgRGB[3:0];
				end
			1'b0: //Background
				begin
					red <= bgRGB[11:8];
					green <= bgRGB[7:4];
					blue <= bgRGB[3:0];
				end
			endcase
	end
end


endmodule

