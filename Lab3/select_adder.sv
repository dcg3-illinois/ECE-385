	module select_adder (
	input  [15:0] A, B,
	input         cin,
	output [15:0] S,
	output        cout
);

    /* TODO
     *
     * Insert code here to implement a CSA adder.
     * Your code should be completly combinational (don't use always_ff or always_latch).
     * Feel free to create sub-modules or other files. */
	  
	  logic c1, c2, c3;
	
	  CSA_unit BLOCK0( .A(A[3:0]), .B(B[3:0]), .cin(cin), .S(S[3:0]), .cout(c1));
	  CSA_unit BLOCK1( .A(A[7:4]), .B(B[7:4]), .cin(c1), .S(S[7:4]), .cout(c2));
	  CSA_unit BLOCK2( .A(A[11:8]), .B(B[11:8]), .cin(c2), .S(S[11:8]), .cout(c3));
	  CSA_unit BLOCK3( .A(A[15:12]), .B(B[15:12]), .cin(c3), .S(S[15:12]), .cout(cout));

	  

endmodule

//individual 4 bit units within the 16 bit select adder
module CSA_unit ( input 	[3:0] A, B,
						input 			cin,
						output	[3:0] S,
						output 			cout);
		
		logic [3:0] S0, S1;
		logic 		cout0, cout1;
		
		ADDER4 ZEROA( .A(A), .B(B), .c_in(0), .S(S0), .c_out(cout0));
		ADDER4 ONEA( .A(A), .B(B), .c_in(1), .S(S1), .c_out(cout1));
		
		always_comb
		begin
			unique case (cin)
				1'b0	:	S = S0;
				1'b1	:	S = S1;
			endcase
			unique case (cin)
				1'b0	:	cout = cout0;
				1'b1	:	cout = cout1;
			endcase	
		end
		
		
						
endmodule
		