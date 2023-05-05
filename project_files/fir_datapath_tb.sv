//`include "fir_structs.sv"
`timescale 1ns/10ps

module fir_datapath_tb();
    logic Clk;
    logic Reset;
    logic [1:0] count;
    logic valid;
    
    typedef struct packed {
        logic [23:0] I;
        logic [23:0] Q;
    } Samp;

    typedef struct packed {
        logic [26:0] I;
        logic [26:0] Q;
    } Coef;

    Samp samp[29];
    Coef coef[14];

    fir_datapath inst_1(
        .Clk            (Clk),
        .Reset          (Reset),
        .count          (count),
        .valid          (valid),

        .samp           (samp),
        .coef           (coef)
    );
    
    initial begin
        Clk = 0;
        Reset = 0;
        count = 0;
        valid = 0;
    end
    
    always begin
        #10 
        Clk = ~Clk;
    end
    
    integer dummy_count= 0;
    
    always begin
        #20;
        dummy_count = dummy_count + 1;
        count = dummy_count % 3;
    end
    
    always_comb begin
        for(int i = 0; i < 29; i = i + 1) begin
            samp[i].I = $urandom_range(100);
            samp[i].Q = $urandom_range(100);
        end
        
        for(int i = 0; i < 16; i = i + 1) begin
            coef[i].I = $urandom_range(100);
            coef[i].Q = $urandom_range(100);
        end
    end
    
endmodule : fir_datapath_tb