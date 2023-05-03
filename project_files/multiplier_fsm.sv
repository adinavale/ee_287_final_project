module multiplier_fsm(
    input clk,
    input reset,
    input PushIn,
    input PushCoef,
    input fifo_empty,
    output [1:0] multiplier_mux_sel,
    output [1:0] partialProductAccumulate_valid,
    output       finalAccumulateRounding_en,
    output       fifoPullOut
);

    typedef enum { 
        idle,
        readyToPullData,
        Multiplying
    } mult_state_type;

    mult_state_type mult_state, next_state;

    always@(posedge clk, posedge reset) 
        if(reset)
            mult_state <= idle;        
        else mult_state <= next_state;

    always @ (*) begin 
        next_state = mult_state;

        case(mult_state) 
            idle : begin
                if(!Reset) begin
                    n_state = store_coef;
                end
            end

            readyToPullData : begin
                if(!PushCoef && PushIn) begin
                    n_state = mac;
                end
            end

            Multiplying: begin

            end
        endcase
    end


endmodule