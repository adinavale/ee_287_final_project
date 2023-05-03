`timescale 1ns/10ps
//To Do
//1. Make a struct for {SampI, SampQ}, and {CoefI, CoefQ)} and change all the code by using the struct -adi
//2. Write Datapath - ked
//3. Figure out control FSM - both

module firc(
    input logic Clk,
    input logic Reset,
    input logic PushIn,
    output      StopIn,
    input logic [23:0] SampI,
    input logic [23:0] SampQ,
    input logic PushCoef,
    input logic [4:0] CoefAddr, //0-14 valid //Why 5 bits?
    input logic [26:0] CoefI,
    input logic [26:0] CoefQ,
    output logic PushOut,
    output logic [31:0] FI,
    output logic [31:0] FQ
);

    //3.24 format. One middle coef and first 14 coefs are mirrored.
    logic [26:0] coefI [14:0]; 
    logic [26:0] coefQ [14:0]; 

    reg  [23:0] SampI_datapath [28:0];          ///??? bits vs depth
    reg  [23:0] SampQ_datapath [28:0];          ///??? bits vs depth
    wire [23:0] SampI_in, SampQ_in;

    assign StopIn = full;

    fifo sample_fifo(       //fifo
        Clk,    
        Reset,
        PushIn,
        SampI,
        SampQ,
        PullOut,
        SampI_in,
        SampQ_in,
        full,
        empty
    );

    integer i;
    generate            //datapath
        for() begin     //5 iterations, i = 0 to 4  //rewrite line in proper syntax
            reg [2:0] SampI_pair, SampQ_pair;           //correct the bitwidth

            adder2_47 addI0(SampI_datapath[0+i], SampI_datapath[28-0-i], SampI_pair[0]);
            adder2_47 add(SampI_datapath[1+i], SampI_datapath[28-1-i], SampI_pair[1]);
            adder2_47 add(SampI_datapath[2+i], SampI_datapath[28-2-i], SampI_pair[2]);
            adder2_47 add(SampQ_datapath[0+i], SampQ_datapath[28-0-i], SampQ_pair[0]);
            adder2_47 add(SampQ_datapath[1+i], SampQ_datapath[28-1-i], SampQ_pair[1]);
            adder2_47 add(SampQ_datapath[2+i], SampQ_datapath[28-2-i], SampQ_pair[2]);
            
            always@* begin
                case(count_fsm) begin
                    2'b0: begin
                        SampI_pair_mux  = SampI_pair[0+i];
                        SampQ_pair_mux  = SampI_pair[0+i];
                        coefI_mux       = coefI[0+i];
                        coefQ_mux       = coefQ[0+i ]
                    end 
                    2'b1:
                    2'b2:
                    default:
                end
                endcase
            end

            complexMult(SampI_pair_mux[], SampQ_pair[], coefI[], coefQ[])                 //rewrite line in proper syntax
            
        end
    endgenerate

    multiplier_fsm mult_fsm(    //control state machine 
    //in
        //empty
        //PushCoef
        //PushIn?
    //internal signal
        //ready
    //out
        //count_fsm
        //PartialProduct Accumulate
        //product accumulate and rounding -> moved to another fsm
        //Product   ???
        //PullOut_fsm
        //PushOut_fsm                     -> moved to another fsm
    );

    accumulator_fsm accumulate_fsm(

    );

    always@(posedge Clk, posedge Reset) begin   //shifting samples
        if(Reset) begin
            SampI_datapath <= 0;
            SampQ_datapath <= 0;
        end else begin
            if(PullOut) begin
                SampI_datapath[0]       <=  SampI_in;
                SampQ_datapath[0]       <=  SampQ_in;
                SampI_datapath[28:1]    <=  SampI_datapath[27:0];
                SampQ_datapath[28:1]    <=  SampQ_datapath[27:0];
            end
        end
    end

    always@(posedge Clk or posedge Reset) begin     //loading coefs
        if(Reset) begin
            coefI[14:0] = 0;
            coefQ[14:0] = 0;
        end else begin
            if(PushCoef) begin
                coefI[CoefAddr] <= CoefI;
                coefQ[CoefAddr] <= CoefQ;
            end
        end
    end



endmodule : firc