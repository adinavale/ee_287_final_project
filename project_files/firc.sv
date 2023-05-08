`timescale 1ns/10ps
`include "fir_structs.sv"

module firc(
    input logic Clk,
    input logic Reset,
    input logic PushIn,
    output logic StopIn,
    input logic signed [23:0] SampI,
    input logic signed [23:0] SampQ,
    input logic PushCoef,
    input logic [4:0] CoefAddr,
    input logic signed [26:0] CoefI,
    input logic signed [26:0] CoefQ,
    output logic PushOut,
    output logic [31:0] FI,
    output logic [31:0] FQ
);

    typedef enum { 
        idle,
        store_coef,
        mac
    } data_state;

    data_state cur_state, n_state;

    always_ff @ (posedge Clk) begin
        if(Reset) begin
            cur_state <= idle;
        end else begin
            cur_state <= n_state;
        end
    end

    //State transitions
    always @ (*) begin 
        n_state = cur_state;
        case(cur_state) 
            idle : begin
                if(!Reset) begin
                    n_state = store_coef;
                end
            end
            store_coef : begin
                if(!PushCoef && PushIn) begin
                    n_state = mac;
                end
            end
            //default : n_state = idle;
        endcase
    end

    //State logic for control signals
    always_ff @ (posedge Clk) begin
        if(cur_state == idle) begin
            FI = 0;
            FQ = 0;
            PushOut = 0;
            StopIn = 0;
        end

        if(cur_state == mac) begin
            PushOut = 1;
        end
    end

    //State logic for storing coefficients
    //3.24 format. One middle coef and first 14 coefs are mirrored.
    logic [26:0] coefI [15:1]; 
    logic [26:0] coefQ [15:1]; 

    always @ (*) begin
        if(cur_state == store_coef) begin
            coefI[CoefAddr] = CoefI;
            coefQ[CoefAddr] = CoefQ;
            $display("Time: %dns \t CoefAddr: %d \t coefI: %x", $realtime, CoefAddr, coefI[CoefAddr]);
            $display("Time: %dns \t CoefAddr: %d \t coefQ: %x \n", $realtime, CoefAddr, coefQ[CoefAddr]);
        end
    end

    //Handling of samples that are being input to the adders before they go through complex multiplies.
    Samp cur_samp[29]; //1.23 format

    always @ (posedge Clk or posedge Reset) begin
        if(cur_state == idle && Reset) begin
            for(int i = 0; i < 29; i = i + 1) begin
                cur_samp[i] <= 0;
            end
        end else if(cur_state == mac && PushIn) begin
            //Shift out the oldest sample
            for(int i = 0; i < 28; i = i + 1) begin
                cur_samp[i + 1].I <= cur_samp[i].I;
                cur_samp[i + 1].Q <= cur_samp[i].Q;
            end

            //Shift in the newest sample
            cur_samp[0].I <= SampI;
            cur_samp[0].Q <= SampQ;

            //Display for debug
            for(int i = 0; i < 29; i = i + 1) begin
                $display("Time: %d ns \t cursamp[%d].I = %d \t cursamp[%d].Q = %d", $realtime, i, cur_samp[i].I, i, cur_samp[i].Q);
            end
        end
    end
endmodule : firc