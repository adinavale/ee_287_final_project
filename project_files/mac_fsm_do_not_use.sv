module comp_mult_fsm(
    input logic Clk,
    input logic Reset,
    input logic PushIn,
    input logic PushCoef,
    input logic fifo_empty,

    output logic mux_sel,
    //todo: p_prod_valid
    output logic final_accum_en,
    output logic fifo_PullOut
);

    logic [1:0] group_count;
    logic [2:0] wait_count;
    parameter MULTIPLY_LATENCY = 2; //todo: change to 6?
    
    typedef enum { 
        idle,
        multiplying
    } mac_state_type;

    mult_state_type mac_cs, mac_ns;

    always_ff @ (posedge Clk or posedge Reset) begin
        if (Reset) begin
            mac_cs <= idle;
        end else begin
            mac_cs <= mac_ns;
        end
    end

    always @ (*) begin
        mac_ns = idle;
        final_accum_en = 0;
        fifo_PullOut = 0;

        case(mac_cs)
            idle: begin
                if(!fifo_empty) begin
                    fifo_PullOut = 1;
                    mac_ns = multiplying;
                end
            end
            multiplying: begin
                if(PushCoef || PushIn) begin
                    mac_ns = idle;
                end else if(group_count == 2)begin
                    if(fifo_empty) begin
                        mac_ns = idle;
                    end else begin
                        mac_ns = multiplying;
                        fifo_PullOut = 1;
                    end
                end
            end
        endcase
    end

    always_ff @ (posedge Clk or posedge Reset) begin
        if(Reset) begin
            wait_count <= MULTIPLY_LATENCY;
            group_count <= 0;
        end else begin
            if(wait_count == 0) begin
                wait_count <= MULTIPLY_LATENCY - 1;
            end else begin
                wait_count <= wait_count - 1;
            end
        end

        if(wait_count == 0) begin

        end
    end
    
endmodule : comp_mult_fsm