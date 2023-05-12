`timescale 1ns/10ps

module fir_datapath(
    input logic clk,
    input logic reset,
    
    //Control signals from state machine
    input [1:0] mux_sel, 
        
    input Samp samp[29],
    input Coef coef[15],

    input partialProductAccumulate_valid,
    input finalAccumulateRounding_en,

    output [31:0] FI,       //8.24 FilterOutput I
    output [31:0] FQ,       //8.24 FilterOutput Q
    output reg PushOut

);

    Sum sum[4:0];                   //2.23 format
    Partial_product p_prod[14:0];   //4.47 format 
    Partial_product sub_prod[4:0];  //4.47 format //TO DO: Is 4.47 enough?????
    Partial_product sub_prod_d[4:0];
    Full_Product    truncatedSubProduct[4:0]; //9.29
    Full_Product    fullProduct;    //9.29
    Full_Product    roundedProduct; //9.29
    
    //---------------- DataPath starts---------------------------------//

    // 1. Adding all sample pairs.-------------------------------------//
    genvar block;
    generate
        for(block = 0; block < 5; block = block + 1) begin    

    // 1. Adding -----------------------------------------------------//
        always@(posedge clk) begin
            if(block == 4 && mux_sel == 2'd2) begin    //coef14,sample14
                sum[block].I <= samp[block*3 + mux_sel].I;
                sum[block].Q <= samp[block*3 + mux_sel].Q; 
            end else begin       
                sum[block].I <= samp[block*3 + mux_sel].I + samp[28 - block*3 - mux_sel].I;
                sum[block].Q <= samp[block*3 + mux_sel].Q + samp[28 - block*3 - mux_sel].Q;
            end
        end

    // 2. Multiplying--------------------------------------------------//

            complexMultiplier multiplier_block(clk, sum[block], coef[mux_sel + block*3], p_prod[block]);

            always @ (*) begin
                sub_prod_d[block].I = (partialProductAccumulate_valid) ? p_prod[block].I + sub_prod[block].I : p_prod[block].I;
                sub_prod_d[block].Q = (partialProductAccumulate_valid) ? p_prod[block].Q + sub_prod[block].Q : p_prod[block].Q;
            end
            //            ┌───┐
            //         ┌──┤mux├──────────────┐
            //         │  │   │              │
            //         │  └───┘              │
            //         │                     │
            // ┌────┐  │  ┌─────┐    ┌────┐  │
            // │    │  └──┤     │    │ sub├──┴───
            // │  x │     │  +  ├────┤prod│
            // │    ├─────┤     │    │    │
            // └────┘     └─────┘    └────┘
            
            always @ (posedge clk) 
                sub_prod[block] <= sub_prod_d[block];           //??? Can I assign like this for a struct?

    // 3. Truncating the sub_products----------------------------------//

            always @ (*) begin
                truncatedSubProduct[block].I = {{4{sub_prod[block].I[51]}}, sub_prod[block].I[51:18]};    //9.29
                truncatedSubProduct[block].Q = {{4{sub_prod[block].Q[51]}}, sub_prod[block].Q[51:18]};    //9.29
            end
        
        end
    endgenerate
    

    // 4. Final accumulation------------------------------------------//
    always @ (posedge clk or posedge reset) begin
        if(reset) begin
            fullProduct <= 0;
            PushOut     <= 0;
        end else if(finalAccumulateRounding_en) begin   //5-input 9.29 38bit adder
            PushOut       <= 1;
            fullProduct.I[37] <= truncatedSubProduct[0].I + truncatedSubProduct[1].I + truncatedSubProduct[2].I + truncatedSubProduct[3].I + truncatedSubProduct[4].I;
            fullProduct.Q[37] <= truncatedSubProduct[0].Q + truncatedSubProduct[1].Q + truncatedSubProduct[2].Q + truncatedSubProduct[3].Q + truncatedSubProduct[4].Q;
        end else 
            PushOut  <= 0;
    end

    // 5. Rounding----------------------------------------------------//
    always@(*) begin
        if(fullProduct.I) //negative
            roundedProduct = fullProduct + 4'b1000; //rounding towards 0
        else roundedProduct= fullProduct;   
    end

    assign FI = roundedProduct.I[36:5];
    assign FQ = roundedProduct.Q[36:5];

endmodule : fir_datapath

