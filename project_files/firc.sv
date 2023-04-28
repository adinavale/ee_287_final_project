`timescale 1ns/10ps

module firc(
    input logic Clk,
    input logic Reset,
    input logic PushIn,
    output logic StopIn,
    input logic [23:0] SampI,
    input logic [23:0] SampQ,
    input logic PushCoef,
    input logic [4:0] CoefAddr,
    input logic [26:0] CoefI,
    input logic [26:0] CoefQ,
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

    //State logic for idle
    always_ff @ (posedge Clk) begin
        if(cur_state == idle) begin
            FI = 0;
            FQ = 0;
            PushOut = 0;
            StopIn = 0;
        end
    end

    //State logic for store_coef
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

endmodule : firc