module accumulator_fsm(
    input clk,
    input reset,
    input finalAccumulateRounding_en,
    input PushCoef,
    output [1:0] multiplier_mux_sel,
    output PushOut
);

    typedef enum { 
        idle,
        readyToPullData,
        Multiplying
    } accumulator_state_type;

    accumulator_state_type accumulator_state, next_state;

    always@(posedge clk, posedge reset) 
        if(reset)
            accumulator_state   <= idle;        
        else accumulator_state  <= next_state;

    always @ (*) begin 
        next_state      = accumulator_state;
        finalAdd_valid  = 0;
        PushOut         = 0;

        case(accumulator_state) 
            idle : begin
                if(finalAccumulateRounding_en)
                    next_state = finalAdd;
            end

            finalAdd : begin
                if(!finalAdd_valid) 
                    finalAdd_valid = 1;
                else next_state = rounding;
            end

            roundingAdd: begin
                if(!PushOut)
                    PushOut = 1;
                else begin
                    if(finalAccumulateRounding_en)
                        next_state = finalAdd;
                    else next_state = idle;
                end
            end
        endcase
    end


endmodule