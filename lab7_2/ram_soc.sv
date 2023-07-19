module ram_soc( //32 bits in each reg, 8 bits at a time input/output
		output logic [31:0] out_a,out_b,
		input logic [31:0] data_a,data_b,
		input logic [3:0] byte_en_a,byte_en_b,
		input [11:0] write_addr_a, write_addr_b, read_address_a,read_address_b,
		input clk,we_a,we_b,re_a, re_b, reset
);


logic [31:0] mem [1200];  // mem-> creates on chip memory 32 bits register, 1200 registers

always_ff @(posedge clk) begin
	if (reset) begin
			for (int i = 0; i < 1200; i++) begin
			
				LOCAL_REG[i] <= 32'b0;				
			end		
	end
	
	
	if (we_a) 
		mem[write_address_a];
		q_a <= mem[read_address_a];
	else if (we_b)
		mem[write_address_b];
		q_b <= mem[read_address_b];
	
end
endmodule