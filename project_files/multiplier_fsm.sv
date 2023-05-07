module multiplier_fsm(
    input clk,
    input reset,
    input PushIn,
    input PushCoef,
    input fifo_empty,
    output [1:0] multiplier_mux_sel,
    output reg   partialProductAccumulate_valid,
    output reg   finalAccumulateRounding_en,
    output reg   fifoPullOut
);

    reg [1:0] group_count;
    parameter MULTIPLY_LATENCY = 2; //declare as a parameter
    reg wait_count;                 // MULTIPLY_LATENCY - 1;

    typedef enum { 
        idle,
        readyToPullData,
        Multiplying
    } mult_state_type;

    mult_state_type mult_state, next_state;

    assign multiplier_mux_sel = group_count;        //output

    always@(posedge clk, posedge reset) 
        if(reset)
            mult_state <= idle;        
        else mult_state <= next_state;

    always @ (*) begin 
        next_state  = mult_state;
        partialProductAccumulate_valid = 0;
        finalAccumulateRounding_en  = 0;
        fifoPullOut = 0;

        case(mult_state) 
            idle : begin
                if(!fifo_empty) begin
                    fifoPullOut = 1;
                    next_state  = Multiplying;
                end
            end

            Multiplying: begin
                if(PushCoef || PushIn)
                    next_state = idle;
                else if(group_count == 2'd2 && wait_count == 0) begin //think about the second condition, is it required?
                    if(fifo_empty)
                        next_state = idle;
                    else begin
                        next_state = Multiplying;
                        fifoPullOut = 1;
                    end 
                end
            end
        endcase
    end

    always@(posedge clk, posedge reset) begin
        if(reset) begin
            wait_count  <=  MULTIPLY_LATENCY - 1;
            group_count <=  0;
        end else begin
            if(wait_count == 0)
                wait_count  <= MULTIPLY_LATENCY - 1;
            else wait_count <= wait_count - 1;

            if(wait_count == 0) begin
                partialProductAccumulate_valid <= 1;
                if(group_count == 2) begin
                    group_count  <= 0;
                    finalAccumulateRounding_en <= 1;
                end else begin 
                    group_count <= group_count + 1; 
                    finalAccumulateRounding_en <= 0;
                end
            end else partialProductAccumulate_valid <= 0;

        end
    end

endmodule