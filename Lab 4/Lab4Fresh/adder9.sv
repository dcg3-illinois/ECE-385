module adder9(input [8:0] A, B,
	input logic Cin,
	output logic [8:0] S,
	output logic Cout);
	
	//SInput is the 8 bit input to the adders, AInput is the other 8 bit input
	logic c1, c2, c3, c4, c5, c6, c7, c8;
	
//	ADDER4 f30( .A(A[3:0]), .B(B[3:0]), .c_in(cin), .S(S[3:0]), .c_out(c1));
//	ADDER4 f74( .A(A[7:4]), .B(B[7:4]), .c_in(c1), .S(S[7:4]), .c_out(c2));
//	full_adder f8( .x(A[7]), .y(B[7]), .z(c2), .s(S[8]), .c(Cout));
//	logic [8:0] A1, B1;
//	assign cin = 1'b0;
//	assign A1 = 9'b111111111;
//	assign B1 = 9'b000000000;
	
	full_adder f0( .x(A[0]), .y(B[0]), .z(Cin), .s(S[0]), .c(c1));
	full_adder f1( .x(A[1]), .y(B[1]), .z(c1), .s(S[1]), .c(c2));
	full_adder f2( .x(A[2]), .y(B[2]), .z(c2), .s(S[2]), .c(c3));
	full_adder f3( .x(A[3]), .y(B[3]), .z(c3), .s(S[3]), .c(c4));
	full_adder f4( .x(A[4]), .y(B[4]), .z(c4), .s(S[4]), .c(c5));
	full_adder f5( .x(A[5]), .y(B[5]), .z(c5), .s(S[5]), .c(c6));
	full_adder f6( .x(A[6]), .y(B[6]), .z(c6), .s(S[6]), .c(c7));
	full_adder f7( .x(A[7]), .y(B[7]), .z(c7), .s(S[7]), .c(c8));
	full_adder f8( .x(A[8]), .y(B[8]), .z(c8), .s(S[8]), .c(Cout));
//assign S = 9'h111111111;
	
endmodule
