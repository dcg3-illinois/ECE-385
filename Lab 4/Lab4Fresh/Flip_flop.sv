module flip_flop (input  logic Clk, Reset, Shift_In, Load, Shift_En, D,
              output logic Data, S_Out);

//    always_ff @ (posedge Clk)
//    begin
//	 	 if (Reset) //notice, this is a sycnrhonous reset, which is recommended on the FPGA
//			  Out <= 1'b0;
//		 else if (Load)
//			  Out <= D;
//		 else if (Shift_En)
//			  Out <= Shift_In;
//    end

	 logic Data_Next;
	 
	 always_ff @ (posedge Clk)
    begin
	 	 Data <= Data_Next;
    end
	
    always_comb
	 begin
		S_Out = Data;
		Data_Next = Data;
		if(Reset)
			Data_Next = 1'b0;
		else if(Load)
			Data_Next = D;
		else if(Shift_En)
			Data_Next = Shift_In;
	 end
endmodule
