module lookahead_adder (
	input  [15:0] A, B,
	input         cin,
	output [15:0] S,
	output        cout
);

	logic PG, GG, PG0, PG4, PG8, PG12,
					GG0, GG4, GG8, GG12,
				c4, c8, c12;

		
	  lookahead_unit_4 BLOCK0( .A(A[3:0]), .B(B[3:0]), .c_in(cin), .S(S[3:0]), .PG(PG0), .GG(GG0));
	  lookahead_unit_4 BLOCK1( .A(A[7:4]), .B(B[7:4]), .c_in(c4), .S(S[7:4]), .PG(PG4), .GG(GG4));
	  lookahead_unit_4 BLOCK2( .A(A[11:8]), .B(B[11:8]), .c_in(c8), .S(S[11:8]), .PG(PG8), .GG(GG8));
	  lookahead_unit_4 BLOCK3( .A(A[15:12]), .B(B[15:12]), .c_in(c12), .S(S[15:12]), .PG(PG12), .GG(GG12));
	
	
	always_comb
	begin
		c4 = (cin & PG0) | GG0;
		c8 = (cin & PG0 & PG4) | (GG0 & PG4) | GG4;
		c12 = (cin & PG8 & PG4 & PG0) | (GG0 & PG8 & PG4) | (GG4 & PG8) |	GG8;
		PG = PG0 & PG4 & PG8 & PG12;
		GG = GG12 | (GG8 & PG12) | (GG4 & PG12 & PG8) | (GG0 & PG12 & PG8 & PG4);
		cout = GG | (PG & c12);
	end


    /* TODO
     *
     * Insert code here to implement a CLA adder.
     * Your code should be completly combinational (don't use always_ff or always_latch).
     * Feel free to create sub-modules or other files. */
	  
	  
endmodule




module lookahead_unit_4(
	input logic [3:0] A,B,
	input logic c_in,

	output logic [3:0] S,
	output logic PG, GG);
	
	logic [3:0] P,G;
		
	always_comb
	begin
 
		c1 = (c_in & P[0]) | G[0];
		c2 = (c_in & P[0] & P[1]) | (G[0] & P[1]) | G[1];
		c3 = (c_in & P[0] & P[1] & P[2]) | (G[0] & P[1] & P[2]) | (G[1] & P[2]) |	G[2]; 
		PG = P[0] & P[1] & P[2]& P[3]; //get the propogation signal at the end of 4 bits
		GG = G[3] | (G[2] & P[3]) | (G[1] & P[3] & P[2]) | (G[0] & P[3] & P[2] & P[1]); //get the generation signal at the end of 4 bits

	end
		lookahead_bit BLOCK0(.A(A[0]), .B(B[0]), .cin(c_in), .G(G[0]), .P(P[0]), .S(S[0]));
		lookahead_bit BLOCK1(.A(A[1]), .B(B[1]), .cin(c1), .G(G[1]), .P(P[1]), .S(S[1]));
		lookahead_bit BLOCK2(.A(A[2]), .B(B[2]), .cin(c2), .G(G[2]), .P(P[2]), .S(S[2]));
		lookahead_bit BLOCK3(.A(A[3]), .B(B[3]), .cin(c3), .G(G[3]), .P(P[3]), .S(S[3]));
	
endmodule

					  
module lookahead_bit(
		input logic A, B, cin,
		output logic G, P, S);
		
		assign G = A & B;
		assign P = (A ^ B) & cin;
		assign S = cin ^ (A ^ B); //only generating S with each bit
		
endmodule
