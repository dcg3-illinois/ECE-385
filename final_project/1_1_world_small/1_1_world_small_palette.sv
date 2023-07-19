module 1_1_world_small_palette (
	input logic [3:0] index,
	output logic [3:0] red, green, blue
);

localparam [0:15][11:0] palette = {
	{4'hC, 4'h4, 4'h0},
	{4'hC, 4'h4, 4'h0},
	{4'h0, 4'h0, 4'h0},
	{4'hF, 4'hB, 4'hB},
	{4'h0, 4'hA, 4'h0},
	{4'h8, 4'hC, 4'h0},
	{4'hF, 4'hF, 4'hF},
	{4'hF, 4'h9, 4'h3},
	{4'h3, 4'hB, 4'hF},
	{4'hC, 4'h4, 4'h0},
	{4'h5, 4'h9, 4'hF},
	{4'hC, 4'h4, 4'h0},
	{4'hC, 4'h4, 4'h0},
	{4'hC, 4'h4, 4'h0},
	{4'hC, 4'h4, 4'h0},
	{4'hC, 4'h4, 4'h0}
};

assign {red, green, blue} = palette[index];

endmodule
