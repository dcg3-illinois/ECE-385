module testbench();

timeunit 10ns;	// Half clock cycle at 50 MHz
			// This is the amount of time represented by #1 
timeprecision 1ns;

// These signals are internal because the processor will be 
// instantiated as a submodule in testbench.
logic Clk = 0;
logic Cl_Ld_Res, Run;
logic [7:0] Switches;
logic [9:0] LED;
logic [7:0] Aval,
		 Bval;
logic [6:0] HEX0,
		 HEX1,
		 HEX2,
		 HEX3; 

// To store expected results
logic [7:0] ans_1b, ans_2b;
logic [8:0] adderout;
// A counter to count the instances where simulation results
// do no match with expected results
integer ErrorCnt = 0;
		
// Instantiating the DUT
// Make sure the module and signal names match with those in your design
Processor processor0(.*);	


assign adderout = processor0.Adder_Out;
// Toggle the clock
// #1 means wait for a delay of 1 timeunit
//this makes the square wave
always begin : CLOCK_GENERATION
#1 Clk = ~Clk;
end

initial begin: CLOCK_INITIALIZATION
    Clk = 0;
end 

// Testing begins here
// The initial block is not synthesizable
// Everything happens sequentially inside an initial block
// as in a software program
initial begin: TEST_VECTORS
Cl_Ld_Res = 1;
Run = 1;
Switches = 8'hFF;

//loadc values into B
#2 Cl_Ld_Res = 0;
#2 Cl_Ld_Res = 1;

//run operation of -1x-1
#12 Run = 0;

#2 Run = 1;


ans_1b = (8'h01); // Expected result of 1st cycle
    // Aval is expected to be 4’hB XOR 4’h2
    // Bval is expected to be the original 4’h2
    if (Bval != ans_1b)
	 ErrorCnt++;
    if (Aval != 8'h00)
	 ErrorCnt++;

// Reset = 0;		// Toggle Rest
// LoadA = 0;
// LoadB = 0;
// Execute = 1;
// Din = 4'hB;	// Specify Din, F, and R
// F = 3'b010;
// R = 2'b10;

// #2 Reset = 1;

// #2 LoadA = 1;	// Toggle LoadA
// #2 LoadA = 0;

// #2 LoadB = 1;	// Toggle LoadB
// 	Din = 4'h2;	// Change Din
// #2 LoadB = 0;
// 	Din = 4'h0;	// Change Din again

// #2 Execute = 0;	// Toggle Execute
   
// #22 Execute = 1;
//     ans_1a = (4'hB ^ 4'h2); // Expected result of 1st cycle
//     // Aval is expected to be 4’hB XOR 4’h2
//     // Bval is expected to be the original 4’h2
//     if (Aval != ans_1a)
// 	 ErrorCnt++;
//     if (Bval != 4'h2)
// 	 ErrorCnt++;
//     F = 3'b110;	// Change F and R
//     R = 2'b01;

// #2 Execute = 0;	// Toggle Execute
// #2 Execute = 1;

// #22 Execute = 0;
//     // Aval is expected to stay the same
//     // Bval is expected to be the answer of 1st cycle XNOR 4’h2
//     if (Aval != ans_1a)	
// 	 ErrorCnt++;
//     ans_2b = ~(ans_1a ^ 4'h2); // Expected result of 2nd  cycle
//     if (Bval != ans_2b)
// 	 ErrorCnt++;
//     R = 2'b11;
// #2 Execute = 1;

// // Aval and Bval are expected to swap
// #22 if (Aval != ans_2b)
// 	 ErrorCnt++;
//     if (Bval != ans_1a)
// 	 ErrorCnt++;


if (ErrorCnt == 0)
	$display("Success!");  // Command line output in ModelSim
else
	$display("%d error(s) detected. Try again!", ErrorCnt);
end
endmodule
