module complexMultiplier(
    input       clk,
    input Sum   samplePair,
    input Coef  coef,
    output Partial_product  partialProduct 
);
    //debug signals
    wire [51:0] partialProduct_I = partialProduct.I;
    wire [51:0] partialProduct_Q = partialProduct.Q;
    reg samplePair_I     = samplePair.I;
    reg samplePair_Q     = samplePair.Q;
    reg coef_I           = coef.I;
    reg coef_Q           = coef.Q;

    wire signed [51:0] p_prod_II, p_prod_IQ, p_prod_QI, p_prod_QQ;
    
    //(2.23 * 3.24)
    DW02_mult_3_stage #(25, 27) IxI (samplePair.I, coef.I, 1'b1, clk, p_prod_II);
    DW02_mult_3_stage #(25, 27) IxQ (samplePair.I, coef.Q, 1'b1, clk, p_prod_IQ);
    DW02_mult_3_stage #(25, 27) QxI (samplePair.Q, coef.I, 1'b1, clk, p_prod_QI);
    DW02_mult_3_stage #(25, 27) QxQ (samplePair.Q, coef.Q, 1'b1, clk, p_prod_QQ);    

    assign partialProduct.I = $signed( p_prod_II - p_prod_QQ);
    assign partialProduct.Q = $signed(p_prod_IQ + p_prod_QI);

endmodule