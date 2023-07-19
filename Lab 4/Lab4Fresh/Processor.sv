//4-bit logic processor top level module
//for use with ECE 385 Spring 2021
//last modified by Zuofu Cheng


//Always use input/output logic types when possible, prevents issues with tools that have strict type enforcement

module Processor (input logic   Clk,     // Internal
                                Cl_Ld_Res,   // Push button 0
                                Run, // Push button 3
                  input  logic [7:0]  Switches,     // input data // change to 7 for 8 bit
                  output logic [9:0]  LED,     // DEBUG
                  output logic [7:0]  Aval,    // DEBUG // changed to 7
                                Bval,    // DEBUG
                  output logic [6:0]  HEX0,
                                HEX1,
                                HEX2,
                                HEX3);

      logic CLR_SH, Run_SH;
	
      //local logic variables here
      logic Shift_OA, Shift_OB, Shift_OX, CLXA, LDB, Shift, Add,
            Subtract, Res_B, Adder_Cout, M, X_Out;

      logic [7:0] Switches_SH;
      logic [8:0] Adder_Out;

	assign Res_B = 0;

      logic [7:0] SXOR, SInput, MExtended, SubExtended;
	logic cin;

	always_comb
	begin
		//M is the LSB of B
      //M = Bval[0];
      //Extend M and Subtract to 8 bits     
		//MExtended = {8{Bval[0]}};      
		//SubExtended = {8{Subtract}};
            //XOR Switches and Subtract extended
		//SXOR = Switches_SH^{8{Subtract}};
            //And M and SXOR to get the input to the adder
		SInput = {8{Bval[0]}} & (Switches_SH^{8{Subtract}});
		//SInput = 8'b00000001;
            //And M and Subtract to get the cin for the adder
		cin = Bval[0] & Subtract;
//		Aval = A;
//		Bval = B;
		LED = {Run_SH, CLR_SH, Switches_SH};
	end
	
      //Instantiation of modules here
      flip_flop      X (.Clk(Clk),
                        .Reset(CLR_SH | CLXA),
                        .Shift_In(Shift_OX),
                        .Load(Add),
                        .Shift_En(Shift),
                        .D(Adder_Out[8]),
                        .Data(X_Out),
								.S_Out(Shift_OX));

      reg_8          RegA (
                        .Clk(Clk),
                        .Reset(CLR_SH | CLXA),
                        .Shift_In(Shift_OX),
                        .Load(Add),
                        .Shift_En(Shift),
                        .D(Adder_Out[7:0]),
                        .Shift_Out(Shift_OA),
                        .Data_Out(Aval));

      reg_8          RegB (
                        .Clk(Clk),
                        .Reset(Res_B),
                        .Shift_In(Shift_OA),
                        .Load(CLR_SH),
                        .Shift_En(Shift),
                        .D(Switches_SH),
                        .Shift_Out(Shift_OB),
                        .Data_Out(Bval));
      
	control          control_unit (
                        .Clk(Clk),
                        .Clr_Ld_Reset(CLR_SH),
                        .Run(Run_SH),
                        .Subtract(Subtract),
                        .Add(Add),
                        .Shift(Shift),
                        .CLXA(CLXA));

      adder9           adder (
                        .A({Aval[7], Aval}),
                        .B({SInput[7], SInput}),
                        .Cin(cin),
                        .S(Adder_Out),
                        .Cout(Adder_Cout));

	HexDriver        Hex2 (
                        .In0(Aval[3:0]),
                        .Out0(HEX2) );
	HexDriver        Hex0 (
                        .In0(Bval[3:0]),
                        .Out0(HEX0) );
								
	 //When you extend to 8-bits, you will need more HEX drivers to view upper nibble of registers, for now set to 0
	HexDriver        Hex3 (
                        .In0(Aval[7:4]),
                        .Out0(HEX3) );	
	HexDriver        Hex1 (
                       .In0(Bval[7:4]),
                        .Out0(HEX1) );
								
	  //Input synchronizers required for asynchronous inputs (in this case, from the switches)
	  //These are array module instantiations
	  //Note: S stands for SYNCHRONIZED, H stands for active HIGH
	  //Note: We can invert the levels inside the port assignments
	  sync button_sync[1:0] (Clk, {~Cl_Ld_Res, ~Run}, {CLR_SH, Run_SH});
	  sync Din_sync[7:0] (Clk, Switches, Switches_SH);
	  
endmodule
