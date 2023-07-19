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
`define NUM_REGS 601 //80*30 characters / 4 characters per register
`define CTRL_REG 600 //index of control register

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
	input  logic [9:0] AVL_ADDR,			// Avalon-MM Address -- 10 bit address but only 4 bits at a time are used
	input  logic [31:0] AVL_WRITEDATA,		// Avalon-MM Write Data -- the avl wants to write this
	output logic [31:0] AVL_READDATA,		// Avalon-MM Read Data -- we want the avl to read this
	
	// Exported Conduit (mapped to VGA port - make sure you export in Platform Designer)
	output logic [3:0]  red, green, blue,	// VGA color channels (mapped to output pins in top-level)
	output logic hs, vs						// VGA HS/VS
);

logic [3:0][7:0] LOCAL_REG       [`NUM_REGS]; // Registers
//
//put other local variables here
logic display, pixel_clk, sync;
logic [9:0] DrawX, DrawY; //draw variables that come from the VGA controller  

//Declare submodules..e.g. VGA controller, ROMS, etc
	vga_controller vga_controller0(.Clk(CLK), .Reset(RESET), .hs, .vs, 
								.pixel_clk, .blank(display), .sync, .DrawX, .DrawY);

//blank takes in the actual display that is being projected

// Read and write from AVL interface to register block, note that READ waitstate = 1, so this should be in always_ff
always_ff @(posedge CLK) begin
	
	if (RESET) begin
			for (int i = 0; i < `NUM_REGS; i++) begin
			
				LOCAL_REG[i][3] <= 8'b0;
				LOCAL_REG[i][2] <= 8'b0;
				LOCAL_REG[i][1] <= 8'b0;
				LOCAL_REG[i][0] <= 8'b0;
				
			end
			
		end
	else if(AVL_CS) begin
		
				if(AVL_WRITE) begin
					if (AVL_BYTE_EN[3] == 1) begin
						LOCAL_REG[AVL_ADDR][3] <= AVL_WRITEDATA[31:24];
					end
					if (AVL_BYTE_EN[2] == 1) begin
						LOCAL_REG[AVL_ADDR][2] <= AVL_WRITEDATA[23:16];
					end
					if (AVL_BYTE_EN[1] == 1) begin
						LOCAL_REG[AVL_ADDR][1] <= AVL_WRITEDATA[15:8]; 
					end
					if (AVL_BYTE_EN[0] == 1) begin
						LOCAL_REG[AVL_ADDR][0] <= AVL_WRITEDATA[7:0];
					end
					//reverse order? each address has 32 bits, which is 4 bytes. Each addres is essentially 1 "word"
//					case(AVL_BYTE_EN)
//					//An issue with the NIOS II is that it is little endian, so avl reads from the NIOS II in reverse.
//						4'b1111: LOCAL_REG[AVL_ADDR] = AVL_WRITEDATA; 					//Write full 32-bits
//						4'b1100: LOCAL_REG[AVL_ADDR][3:2] = AVL_WRITEDATA[31:16];		//Write upper 2 bytes
//						4'b0011: LOCAL_REG[AVL_ADDR][1:0] = AVL_WRITEDATA[15:0];		//Write lower 2 bytes
//						4'b1000: LOCAL_REG[AVL_ADDR][3] = AVL_WRITEDATA[31:24];		//Write 3rd byte only
//						4'b0100: LOCAL_REG[AVL_ADDR][2] = AVL_WRITEDATA[23:16];		//Write 2nd byte only
//						4'b0010: LOCAL_REG[AVL_ADDR][1] = AVL_WRITEDATA[15:8];		//Write 1st byte only
//						4'b0001: LOCAL_REG[AVL_ADDR][0] = AVL_WRITEDATA[7:0];			//Write 0th byte only
//
//						4'b1111: 
//								begin																				//Write full 32-bits
//									LOCAL_REG[AVL_ADDR][3] = AVL_WRITEDATA[7:0]; 					
//									LOCAL_REG[AVL_ADDR][2] = AVL_WRITEDATA[15:8];
//									LOCAL_REG[AVL_ADDR][1] = AVL_WRITEDATA[23:16];
//									LOCAL_REG[AVL_ADDR][0] = AVL_WRITEDATA[31:24];
//								end
//						4'b1100: 																				//Write upper 2 bytes
//								begin
//									LOCAL_REG[AVL_ADDR][3] = AVL_WRITEDATA[7:0];
//									LOCAL_REG[AVL_ADDR][2] = AVL_WRITEDATA[15:8];
//								end
//						4'b0011: 
//								begin
//									LOCAL_REG[AVL_ADDR][1] = AVL_WRITEDATA[23:16];		//Write lower 2 bytes
//									LOCAL_REG[AVL_ADDR][0] = AVL_WRITEDATA[31:24];
//								end
//						4'b1000: LOCAL_REG[AVL_ADDR][3] = AVL_WRITEDATA[7:0];		//Write 3rd byte only
//						4'b0100: LOCAL_REG[AVL_ADDR][2] = AVL_WRITEDATA[15:8];		//Write 2nd byte only
//						4'b0010: LOCAL_REG[AVL_ADDR][1] = AVL_WRITEDATA[23:16];		//Write 1st byte only
//						4'b0001: LOCAL_REG[AVL_ADDR][0] = AVL_WRITEDATA[31:24];			//Write 0th byte only						
//						
//					endcase
				end
				
				else if(AVL_READ) begin
					AVL_READDATA <= LOCAL_REG[AVL_ADDR];
				end
	
		end
end


//handle drawing (may either be combinational or sequential - or both).
logic [9:0] OffsetX, OffsetY;
logic [31:0] arr_idx;
logic [7:0] CharX;
logic [6:0] CharY;
logic [10:0] char_addr; //why are we passing a 10 bit char_address?
logic [7:0] character, charRow; 
logic draw;
logic [1:0] regByte;
logic [9:0] register;


/*  >> = logical shift right
**  << = logical shift left
*/
always_ff @(posedge CLK) begin
	character = LOCAL_REG[register][regByte]; // arr/4 mem address,
end

always_comb begin
	CharX = DrawX[9:3]; //divide by 8 -> gives us the glypth we are in horizontally
	CharY = DrawY[9:4]; //divide by 16 -> gives us the glypth we are in vertically
	OffsetX = DrawX[2:0] -1; //% by 8 -> gives us the bit that we offset from the beginning of the glypth
	OffsetY = DrawY[3:0]; /*% by 16 -> gives us the bit we are at byte in the register, so essentially gives us the location of the from the top of the glypth*/
	arr_idx = CharX + 80*CharY; //we have an index that is row major order searching the registers
	char_addr = 16*character[6:0] + OffsetY;   //char_addr in the register	
	regByte = arr_idx[1:0];
	register = arr_idx[11:2];
end



	font_rom font_rom0(.addr(char_addr), .data(charRow));         //we want the data to match what the cpu tells us

	//offset Y tells us the offset from the beginning row of the character in the font_rom.
	//offset X tells us the offset from the beginning bit in the row being looked at in font_rom.


logic [3:0][7:0] colorInfo;

always_ff @(posedge pixel_clk) begin
//colorInfo[31:24] = LOCAL_REG[`CTRL_REG][3];
//colorInfo[23:16] = LOCAL_REG[`CTRL_REG][2];
//colorInfo[15:8] = LOCAL_REG[`CTRL_REG][1];
//colorInfo[7:0] = LOCAL_REG[`CTRL_REG][0];

colorInfo <= LOCAL_REG[`CTRL_REG];
	begin
		if (display == 1'b0) begin
			red <= 4'b0000;
			green <= 4'b0000;
			blue <= 4'b0000;
		end
		if (character[7] == 1) begin
			draw <= ~charRow[7- OffsetX];
		end
		else begin
			draw <= charRow[7- OffsetX];
		end
	end

	case(draw)
	1'b1: //Foreground
		begin
//			red = colorInfo[24:21];
//			green = colorInfo[17:20];
//			blue = colorInfo[13:16];
			red <= {colorInfo[3][0], colorInfo[2][7:5]};
			green <= colorInfo[2][4:1];
			blue <= {colorInfo[2][0], colorInfo[1][7:5]};
		end
	1'b0: //Background
//		begin
//			red = colorInfo[12:9];
//			green = colorInfo[8:5];
//			blue = colorInfo[4:1];
//		end
		begin
			red <= colorInfo[1][4:1];											//[12:9]
			blue <= {colorInfo[1][4:0], colorInfo[0][7:5]};				//[8:5]
			green <= colorInfo[0][4:1];											//[4:1]
		end
	endcase
end


endmodule