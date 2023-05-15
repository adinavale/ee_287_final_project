module fifo(
    input logic Clk,
    input logic Reset,
    input logic PushIn,   //wr_en
    input logic [23:0] SampI,
    input logic [23:0] SampQ,
    input logic fifo_PullOut,  //rd_en

    output Samp fifo_samp,
    output logic fifo_full,
    output logic fifo_empty

);

    //debug signals
    wire fifo_samp_I  = fifo_samp.I;
    wire fifo_samp_Q  = fifo_samp.Q;
    wire fifo_data0_I = fifo_mem[0].I;
    wire fifo_data1_I = fifo_mem[1].I;
    wire fifo_data2_I = fifo_mem[2].I;
    wire fifo_data3_I = fifo_mem[3].I;

    logic full, empty;
    logic [2:0] read_ptr, write_ptr;        //1 bit extra for full/empty distinction
    Samp fifo_mem[8];

    always_ff @ (posedge Clk or posedge Reset) begin
        if(Reset) begin
            read_ptr    <= 0;
            write_ptr   <= 0;
            fifo_mem[0] <= 0;
            fifo_mem[1] <= 0;
            fifo_mem[2] <= 0;
            fifo_mem[3] <= 0;
        end else begin
            //1. wr_en & !full => fifo[write_ptr] = data, write_ptr++
            if(PushIn && !full) begin
                write_ptr        <= write_ptr + 1;
                fifo_mem[write_ptr].I <= SampI;
                fifo_mem[write_ptr].Q <= SampQ;
            end

            //2. rd_en & !empty => rd_ptr++
            if(fifo_PullOut) begin
                read_ptr        <= read_ptr + 1;
            end
        end
    end

    always @ (*) begin
        if(Reset) begin
            full    = 0;
            empty   = 0;
        end else begin
            //if(read == write) empty
            empty = (read_ptr == write_ptr);

            //if read[1:0] == write[1:0] && read[2] != write[2] full
            full  = (read_ptr[1:0] == write_ptr[1:0]) && (read_ptr[2] != write_ptr[2]);
        end
    end

    //Output signals
    always @ (*) begin
        fifo_samp.I  = fifo_mem[read_ptr].I;
        fifo_samp.Q  = fifo_mem[read_ptr].Q;
        fifo_full = full;
        fifo_empty = empty;
    end
//edits
endmodule