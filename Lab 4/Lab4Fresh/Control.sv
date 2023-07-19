//Two-always example for state machine

module control (input  logic Clk, Run, Clr_Ld_Reset,
                output logic Subtract, Add, Shift, CLXA);


//     // Declare signals curr_state, next_state of type enum
//     // with enum values of A, B, ..., F as the state values
// 	 // Note that the length implies a max of 8 states, so you will need to bump this up for 8-bits
//     enum logic [3:0] {A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R}   curr_state, next_state; //added 4 states for the 8 bits

// 	//updates the value out to be 0.


//     always_ff @ (posedge Clk)
//     begin
//         if (Reset)
//             curr_state <= A;
//         else
//             curr_state <= next_state;
//     end

//     //Assign outputs based on state
// 	always_comb
//     begin
//         if ()
        
// 	    next_state  = curr_state;	//required because I haven't enumerated all possibilities below


// //Substate descriptions 1 and 2
//     //Substate 1: 
//         unique case (curr_state) 
//         A :    if (Execute)
//                next_state = A_2;
//         A_2:   next_state = B;
//         B :    next_state = C;
//         C :    next_state = D;
//         D :    next_state = E;
//         E :    next_state = F;
//         F :    next_state = G;
//         G :    next_state = H;
//         H :    next_state = I;
//         I :    next_state = J;
//         J :    next_state = K;
//         K :    next_state = L;
//         L :    next_state = M;
//         M :    next_state = N;
//         N :    next_state = O;
//         O :    next_state = P;
//         P :    next_state = Q;
//         Q :    next_state = A;
//         A :    next_state = R;
// 		R :    if (~Execute)

//         next_state = A;
//         endcase
   
// 		//Assign outputs based on ‘state’
//         case (curr_state) 
// 	   	   A: 
// 	         begin
//                 Subtract = 1'b0;
//                 Add = 1'b0;
//                 Shift = 1'b0;
//                 LDB = 1'b1;
//                 CLXA = 1'b1;
// 		     end
// 	   	   R: 
// 		      begin
//                 Subtract = 1'b0;
//                 Add = 1'b;
//                 Shift = 1'b;
//                 LDB = 1'b1;
//                 CLXA = 1'b;
// 		      end
            
// 	   	   default:  //Shift by default

//             //Case 2: Add

//             //Case 3: Clear XA
// 		      begin 
//                 Subtract = 1'b0;
//                 Add = 1'b0;
//                 Shift = 1'b0;
//                 LDB = 1'b0;
//                 CLXA = 1'b0;
// 		      end
//         endcase
//     end

// Declare signals curr_state, next_state of type enum
    // with enum values of A, B, ..., F as the state values
	 // Note that the length implies a max of 8 states, so you will need to bump this up for 8-bits
    enum logic [4:0] {Idle, A1, S1, A2, S2, A3, S3, A4, S4, A5, S5, A6, S6, A7, S7, A8, S8, CXA1} curr_state, next_state; //added 4 states for the 8 bits

	//updates the value out to be 0.


    always_ff @ (posedge Clk)
    begin
        if (Clr_Ld_Reset)
            curr_state <= Idle;
        else
            curr_state <= next_state;
    end

    //Assign outputs based on state
	always_comb
    begin
	    next_state  = curr_state;	//required because I haven't enumerated all possibilities below
    //Substate descriptions 1 and 2
    //Substate 1: 
        unique case (curr_state) 
		  
        Idle :  
					begin
					 if (Run)
						next_state = CXA1;
					end
        CXA1:   next_state = A1;
        A1 :    next_state = S1;
        S1 :    next_state = A2;
        A2 :    next_state = S2;
        S2 :    next_state = A3;
        A3 :    next_state = S3;
        S3 :    next_state = A4;
        A4 :    next_state = S4;
        S4 :    next_state = A5;
        A5 :    next_state = S5;
        S5 :    next_state = A6;
        A6 :    next_state = S6;
        S6 :    next_state = A7;
        A7 :    next_state = S7;
        S7 :    next_state = A8;
        A8 :    next_state = S8;
        S8 :    if(~Run)
                next_state = Idle;
		  
        endcase
   
		//Assign outputs based on ‘state’
        case (curr_state) 
	   	   Idle: 
					begin
                Subtract = 1'b0;
                Add = 1'b0;
                Shift = 1'b0;
                CLXA = 1'b0;
					end
	   	    A1, A2, A3, A4, A5, A6, A7: 
					begin
                Subtract = 1'b0;
                Add = 1'b1;
                Shift = 1'b0;
                CLXA = 1'b0;
					end
            A8:
					begin
                Subtract = 1'b1;
                Add = 1'b1;
                Shift = 1'b0;
                CLXA = 1'b0;
					end
            CXA1:
					begin
                Subtract = 1'b0;
                Add = 1'b0;
                Shift = 1'b0;
                CLXA = 1'b1;
					end
	   	   default:  //Shift by default
		      begin 
                Subtract = 1'b0;
                Add = 1'b0;
                Shift = 1'b1;
                CLXA = 1'b0;
		      end
        endcase
    end

endmodule
