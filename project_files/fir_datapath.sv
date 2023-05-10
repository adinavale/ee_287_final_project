`timescale 1ns/10ps

module fir_datapath(
    input logic Clk,
    input logic Reset,
    
    //Control signals from state machine
    input int count, 
    
    //Control signal for when data is being pulled from the FIFO
//    input logic PullOut, 
    
    input Samp samp[29],
    input Coef coef[15],

    output Partial_product sub_prod_0,
    output Partial_product sub_prod_1,
    output Partial_product sub_prod_2,
    output Partial_product sub_prod_3,
    output Partial_product sub_prod_4
);

    Sum sum[15]; //1.23 format
    Partial_product p_prod[15]; //4.47 format 
    Partial_product sub_prod[5]; //4.47 format

    //FIRST COMPLEX MULTIPLIER
    //Adder block  
    always @ (*) begin
        case(count)
            0 : begin
                    sum[0].I = samp[0].I + samp[28].I;
                    sum[0].Q = samp[0].Q + samp[28].Q;
                    $display("Count = 0");
                    $display("samp[0].I: %d \t samp[28].I: %d \t I_sum: %d", samp[0].I, samp[28].I, sum[0].I);
                    $display("samp[0].Q: %d \t samp[28].Q: %d \t Q_sum: %d", samp[0].Q, samp[28].Q, sum[0].Q);
                    $display();
                end
            1 : begin
                    sum[1].I = samp[1].I + samp[27].I;
                    sum[1].Q = samp[1].Q + samp[27].Q;
                    $display("Count = 1");
                    $display("samp[0].I: %d \t samp[28].I: %d \t I_sum: %d", samp[1].I, samp[27].I, sum[1].I);
                    $display("samp[0].Q: %d \t samp[28].Q: %d \t Q_sum: %d", samp[1].Q, samp[27].Q, sum[1].Q);
                    $display();
                end
            2 : begin
                    sum[2].I = samp[2].I + samp[26].I;
                    sum[2].Q = samp[2].Q + samp[26].Q;
                    $display("Count = 2");
                    $display("samp[0].I: %d \t samp[28].I: %d \t I_sum: %d", samp[2].I, samp[26].I, sum[2].I);
                    $display("samp[0].Q: %d \t samp[28].Q: %d \t Q_sum: %d", samp[2].Q, samp[26].Q, sum[2].Q);
                    $display();
                end
        endcase
    end
    
    //Multiplier block
    always @ (*)  begin
        case(count)
            0 : begin
                p_prod[0].I = sum[0].I * coef[0].I;
                p_prod[0].Q = sum[0].Q * coef[0].Q;
            end
            1 : begin
                p_prod[1].I = sum[1].I * coef[1].I;
                p_prod[1].Q = sum[1].Q * coef[1].Q;
            end
            2 : begin
                p_prod[2].I = sum[2].I * coef[2].I;
                p_prod[2].Q = sum[2].Q * coef[2].Q;
            end
        endcase

        sub_prod[0].I = p_prod[0].I + p_prod[1].I + p_prod[2].I;
        sub_prod[0].Q = p_prod[0].Q + p_prod[1].Q + p_prod[2].Q;
    end
    
    
    //SECOND COMPLEX MULTIPLIER
    //Adder block  
    always @ (*) begin
        case(count)
            0 : begin
                    sum[3].I = samp[3].I + samp[25].I;
                    sum[3].Q = samp[3].Q + samp[25].Q;
                end
            1 : begin
                    sum[4].I = samp[4].I + samp[24].I;
                    sum[4].Q = samp[4].Q + samp[24].Q;
                end
            2 : begin
                    sum[5].I = samp[5].I + samp[23].I;
                    sum[5].Q = samp[5].Q + samp[23].Q;
                end
        endcase
    end
    
    //Multiplier block
    always @ (*)  begin
        case(count)
            0 : begin
                p_prod[3].I = sum[3].I * coef[3].I;
                p_prod[3].Q = sum[3].Q * coef[3].Q;
            end
            1 : begin
                p_prod[4].I = sum[4].I * coef[4].I;
                p_prod[4].Q = sum[4].Q * coef[4].Q;
            end
            2 : begin
                p_prod[5].I = sum[5].I * coef[5].I;
                p_prod[5].Q = sum[5].Q * coef[5].Q;
                
                sub_prod[1].I = p_prod[3].I + p_prod[4].I + p_prod[5].I;
                sub_prod[1].Q = p_prod[3].Q + p_prod[4].Q + p_prod[5].Q;
            end
        endcase
    end
    
    //THIRD COMPLEX MULTIPLIER
    //Adder block  
    always @ (*) begin
        case(count)
            0 : begin
                    sum[6].I = samp[6].I + samp[22].I;
                    sum[6].Q = samp[6].Q + samp[22].Q;
                end
            1 : begin
                    sum[7].I = samp[7].I + samp[21].I;
                    sum[7].Q = samp[7].Q + samp[21].Q;
                end
            2 : begin
                    sum[8].I = samp[8].I + samp[20].I;
                    sum[8].Q = samp[8].Q + samp[20].Q;
                end
        endcase
    end
    
    //Multiplier block
    always @ (*)  begin
        case(count)
            0 : begin
                p_prod[6].I = sum[6].I * coef[6].I;
                p_prod[6].Q = sum[6].Q * coef[6].Q;
            end
            1 : begin
                p_prod[7].I = sum[7].I * coef[7].I;
                p_prod[7].Q = sum[7].Q * coef[7].Q;
            end
            2 : begin
                p_prod[8].I = sum[8].I * coef[8].I;
                p_prod[8].Q = sum[8].Q * coef[8].Q;
                
                sub_prod[2].I = p_prod[6].I + p_prod[7].I + p_prod[8].I;
                sub_prod[2].Q = p_prod[6].Q + p_prod[7].Q + p_prod[8].Q;
            end
        endcase
    end
    
    //FORTH COMPLEX MULTIPLIER
    //Adder block  
    always @ (*) begin
        case(count)
            0 : begin
                    sum[9].I = samp[9].I + samp[19].I;
                    sum[9].Q = samp[9].Q + samp[19].Q;
                end
            1 : begin
                    sum[10].I = samp[10].I + samp[18].I;
                    sum[10].Q = samp[10].Q + samp[18].Q;
                end
            2 : begin
                    sum[11].I = samp[11].I + samp[17].I;
                    sum[11].Q = samp[11].Q + samp[17].Q;
                end
        endcase
    end
    
    //Multiplier block
    always @ (*)  begin
        case(count)
            0 : begin
                // p_prod[9].I = sum[9].I * coef[9].I;
                // p_prod[9].Q = sum[9].Q * coef[9].Q;
                p_prod[9].I = sum[9].I * coef[9].I - sum[9].Q * coef[9].Q;
                p_prod[9].Q = sum[9].Q * coef[9].I + sum[9].I * coef[9].Q;
            end
            1 : begin
                p_prod[10].I = sum[10].I * coef[10].I;
                p_prod[10].Q = sum[10].Q * coef[10].Q;
            end
            2 : begin
                p_prod[11].I = sum[11].I * coef[11].I;
                p_prod[11].Q = sum[11].Q * coef[11].Q;
                
                sub_prod[3].I = p_prod[9].I + p_prod[10].I + p_prod[11].I;
                sub_prod[3].Q = p_prod[9].Q + p_prod[10].Q + p_prod[11].Q;
            end
        endcase
    end
    
    //FIFTH COMPLEX MULTIPLIER
    //Adder block  
    always @ (*) begin
        case(count)
            0 : begin
                    sum[12].I = samp[12].I + samp[16].I;
                    sum[12].Q = samp[12].Q + samp[16].Q;
                end
            1 : begin
                    sum[13].I = samp[13].I + samp[15].I;
                    sum[13].Q = samp[13].Q + samp[15].Q;
                end
            2 : begin
                    sum[14].I = samp[14].I;
                    sum[14].Q = samp[14].Q;
                end
        endcase
    end
    
    //Multiplier block
    always @ (*)  begin
        case(count)
            0 : begin
                p_prod[12].I = sum[12].I * coef[12].I;
                p_prod[12].Q = sum[12].Q * coef[12].Q;
            end
            1 : begin
                p_prod[13].I = sum[13].I * coef[13].I;
                p_prod[13].Q = sum[13].Q * coef[13].Q;
            end
            2 : begin
                p_prod[14].I = sum[14].I * coef[14].I;
                p_prod[14].Q = sum[14].Q * coef[14].Q;
                
                sub_prod[4].I = p_prod[12].I + p_prod[13].I + p_prod[14].I;
                sub_prod[4].Q = p_prod[12].Q + p_prod[13].Q + p_prod[14].Q;
            end
        endcase
    end

    //Output to the accumulator module
    always @ (*) begin
        sub_prod_0 = sub_prod[0];
        sub_prod_1 = sub_prod[1];
        sub_prod_2 = sub_prod[2];
        sub_prod_3 = sub_prod[3];
        sub_prod_4 = sub_prod[4];
    end

endmodule : fir_datapath