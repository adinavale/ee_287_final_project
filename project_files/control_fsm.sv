module control_fsm(
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
    reg waiting;
    reg processing;
    reg p_prod_count;

/* Defined in fir_structs.sv

    typedef enum { 
        idle,
        WaitForData,
        Multiplying
    } mult_state_type;

    typedef enum {
        Idle,
        PartialProductsAccumulation,
        FinalProductAccumulation
    } accum_state_type;
*/

    mult_state_type mult_state, next_mult_state;
    accum_state_type accum_state, next_accum_state;

    assign multiplier_mux_sel = group_count;        //output

    always@(posedge clk, posedge reset) 
        if(reset) begin
            mult_state  <= idle;        
            accum_state <= Idle;
        end else begin 
            mult_state  <= next_mult_state;
            accum_state <= next_accum_state;
        end

//Multiplier FSM
    always @ (*) begin 
        next_mult_state  = mult_state;
        //partialProductAccumulate_valid = 0;
        //finalAccumulateRounding_en  = 0;
        fifoPullOut = 0;

        case(mult_state) 
            idle : begin
                if(!fifo_empty) begin
                    fifoPullOut = 1;
                    next_mult_state  = WaitForData;
                end
            end

            WaitForData: begin
                //waits a cycle for pairs to be added
                next_mult_state = Multiplying;
            end

            Multiplying: begin
                if(PushCoef)
                    next_mult_state = idle;
                else if(group_count == 2'd2) begin //think about the second condition, is it required?
                    if(fifo_empty)
                        next_mult_state = idle;
                    else begin
                        next_mult_state = WaitForData;
                        fifoPullOut = 1;
                    end
                end
            end
        endcase
    end

//Multiplier FSM
    always@(posedge clk, posedge reset) begin
        if(reset) begin
            group_count <=  0;
            processing  <=  0;
        end else begin
            if(mult_state == Multiplying) begin
                if(group_count != 2'd2) 
                    group_count <= group_count + 1;
                else begin
                    group_count <= 0;                    
                    processing  <= 1;
                end 
            end else processing <= 0;
        end
    end

//Accumulator FSM
    always @ (*) begin 
        next_accum_state  = accum_state;
        partialProductAccumulate_valid = 0;
        finalAccumulateRounding_en  = 0;

        case(accum_state) 
            idle : begin
                if(processing) 
                    next_accum_state = PartialProductsAccumulation;
            end

            PartialProductsAccumulation: begin
                partialProductAccumulate_valid = 1;
                //wait 2 cycles
                if(p_prod_count == 1)
                    next_accum_state = FinalProductAccumulation;
            end

            FinalProductAccumulation: begin
                finalAccumulateRounding_en = 1;
                next_accum_state           = Idle;
            end
        endcase
    end

//Accumulator FSM
    always@(posedge clk, posedge reset) begin
        if(reset) begin
            p_prod_count <= 0;
        end else begin
            if(accum_state == PartialProductsAccumulation) begin
                if(p_prod_count == 0) 
                    p_prod_count <= 1;
                else p_prod_count <= 0;
            end 
        end
    end

endmodule
