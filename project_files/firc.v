`timescale 1ns/10ps
`include "fir_structs.sv"
`include "fir_datapath.sv"
`include "fifo.sv"
`include "control_fsm.sv"
`include "complexMultiplier.sv" 
//`include "DW02_mult_2_stage.v"

module firc(
    input logic clk,
    input logic Reset,
    input logic PushIn,
    output      StopIn,
    input logic signed [23:0] SampI,
    input logic signed [23:0] SampQ,
    input logic PushCoef,
    input logic [4:0] CoefAddr,
    input logic signed [26:0] CoefI,
    input logic signed [26:0] CoefQ,
    output logic PushOut,
    output signed [31:0] FI,
    output signed [31:0] FQ
);

    
    Coef [14:0] coef;    //3.24 format. One middle coef and first 14 coefs are mirrored.
    Coef [14:0] coef_temp;    //3.24 format. One middle coef and first 14 coefs are mirrored.
    Samp [28:0] s;       //1.23 format

    wire multiplier_idle;
    wire fifoPullOut; //Handled in multiplier_fsm
    wire fifo_full;
    wire fifo_empty;
    Samp fifo_samp;
    wire [1:0] multiplier_mux_sel;
    wire partialProductAccumulate_valid, finalAccumulateRounding_en;
    

//---------------- Coeff storing ---------------------------------//
    always@(posedge clk) begin
        if(PushCoef && CoefAddr < 15) begin
            coef_temp[CoefAddr[3:0]].I    <= CoefI;      //because addr is 1-15 
            coef_temp[CoefAddr[3:0]].Q    <= CoefQ;      //not 0-14
        end
    end

    //always@(posedge PushIn) begin
    //    coef <= coef_temp;
    //end
//---------------------------------------------------------------//


//---------------- Sample Shifting ---------------------------------//
    always @ (posedge clk or posedge Reset) begin
        if(Reset) begin
            for(int i = 0; i < 29; i = i + 1) begin     //does verilog allow "int i" for loops??
                s[i] <= 0;
            end
        end else if(fifoPullOut) begin
            //Shift in the newest sample
            s[0].I <= fifo_samp.I;
            s[0].Q <= fifo_samp.Q;

            //Shift out the oldest sample
            for(int i = 0; i < 28; i = i + 1) begin
                s[i + 1].I <= s[i].I;
                s[i + 1].Q <= s[i].Q;
            end

            //Display for debug
            for(int i = 0; i < 29; i = i + 1) begin
              //  $display("Time: %d ns \t s[%d].I = %b \t s[%d].Q = %b", $realtime, i, s[i].I, i, s[i].Q);
            end
        end
    end
//---------------------------------------------------------------//


//---------------- FIFO ----------------------------------------//
    fifo fifo_inst(
        //Inputs
        .Clk                (clk),
        .Reset              (Reset),
        .PushIn             (PushIn),
        .SampI              (SampI),
        .SampQ              (SampQ),
        .fifo_PullOut       (fifoPullOut),

        //Outputs
        .fifo_samp          (fifo_samp),
        .fifo_full          (fifo_full),
        .fifo_empty         (fifo_empty)
    );

    //StopIn logic
    assign StopIn = fifo_full;
//---------------------------------------------------------------//


//-------- Datapath ---------------------------------------------//
    fir_datapath datapath(
        .clk                (clk),
        .reset              (Reset),
        .mux_sel            (multiplier_mux_sel), 
        .samp               (s),
        .coef               (coef),

        .partialProductAccumulate_valid(partialProductAccumulate_valid),
        .finalAccumulateRounding_en(finalAccumulateRounding_en),

        .FI_o                 (FI),
        .FQ_o                 (FQ),
        .PushOut_o          (PushOut)
    );
//assign PushOut = 1'b0;
//---------------------------------------------------------------//

//-------- Control FSM  -----------------------------------------//
    control_fsm fsm(
        clk,
        Reset,
        PushIn,
        PushCoef,
        fifo_empty,
        multiplier_mux_sel,
        partialProductAccumulate_valid,
        finalAccumulateRounding_en,
        fifoPullOut,
        multiplier_idle
    );
//---------------------------------------------------------------//


//Coef tracking
// shifted -> -> -> -> -> shift
// if (shift == shifted) coef <= coef_temp;
/*
reg shifted, shift;

always @ (posedge clk or posedge reset) begin
    if(reset) begin
        shifted <= 0;
        shift   <= 0;
    end else begin
        if()
            shift <= shifted;
    end
end
*/

//----------Handling new coef shifting----------//
wire new_coefs;
reg [2:0] waiting_to_shift_new_coefs;
assign new_coefs = PushIn;
// always @ (posedge PushIn or negedge PushIn) begin
//     if(PushIn) begin
//         new_coefs   <= 1;
//     end else new_coefs = 0;
// end

always@(posedge clk or posedge Reset) begin
    if(Reset)
        waiting_to_shift_new_coefs <= 3'd2;
    else if(new_coefs && waiting_to_shift_new_coefs != 3'b0)
        waiting_to_shift_new_coefs <= waiting_to_shift_new_coefs - 1;
    else begin
        if(multiplier_idle)
            waiting_to_shift_new_coefs <= 3'd2;
        else waiting_to_shift_new_coefs <= 3'd5;
    end
end
always@(posedge clk) begin
    if(waiting_to_shift_new_coefs == 3'b0)
    coef <= coef_temp;
end
//---------------------------------------------------------------//



//---------------- Debug ---------------------------------------//
integer i, block_i, addr;
/*always@(negedge PushCoef) begin
    for(addr = 0; addr < 15; i = i + 1) begin
            $display("coef[%d].I: %d", i, datapath.samp[i].I, 28-i, datapath.samp[28 - i].I, i/5, datapath.sum[i/5].I);
            $display("samp[%d].Q: %d \t samp[%d].Q: %d \t Q_sum %d: %d", i, datapath.samp[i].Q, 28-i, datapath.samp[28 - i].Q, i/5, datapath.sum[i/5].Q);
            $display();
        end
end

always @ (*) begin
    if(fsm.mult_state == Multiplying) begin
        $display("group_count = %d", multiplier_mux_sel);
        for(i = 0; i < 15; i = i + 1) begin
            $display("samp[%d].I: %d \t samp[%d].I: %d \t I_sum %d: %d", i, datapath.samp[i].I, 28-i, datapath.samp[28 - i].I, i/5, datapath.sum[i/5].I);
            $display("samp[%d].Q: %d \t samp[%d].Q: %d \t Q_sum %d: %d", i, datapath.samp[i].Q, 28-i, datapath.samp[28 - i].Q, i/5, datapath.sum[i/5].Q);
            $display();
        end
    end  
    if(finalAccumulateRounding_en) begin
        for(block_i = 0; block_i < 5; block_i = block_i + 1) begin
            $display("sub product %d I = %d ", block_i, datapath.sub_prod[block_i].I);
            $display("sub product %d Q = %d \n", block_i, datapath.sub_prod[block_i].Q);
            
            $display("truncated sub product %d I = %d ", block_i, datapath.truncatedSubProduct[block_i].I);
            $display("truncated sub product %d Q = %d \n", block_i, datapath.truncatedSubProduct[block_i].Q);
        end
    end

    if(PushOut) begin
        $display("time: %d \t full product I = %d ", $realtime(), datapath.fullProduct.I);
        $display("full product Q = %d ", datapath.fullProduct.Q);

        $display("final output I = %d ", FI);
        $display("final output Q = %d ", FQ);
    end

end
*/
//---------------------------------------------------------------//

endmodule : firc
