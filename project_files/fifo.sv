module fifo(
    input           clk,
    input           reset,
    input           PushIn,   //wr_en
    input  [23:0]   SampI,
    input  [23:0]   SampQ,
    input           PullOut,  //rd_en
    output [23:0]   SampI_datapath,
    output [23:0]   SampQ_datapath,
    output          full,
    output          empty

);


    reg full, empty;
    reg [2:0] read_ptr, write_ptr;        //1 bit extra for full/empty distinction
    reg [23:0] fifoI [0:3];
    reg [23:0] fifoQ [0:3];

    always@(posedge clk, posedge reset) begin
        if(reset) begin
            read_ptr    <= 0;
            write_ptr   <= 0;
        end else begin
            //1. wr_en & !full => fifo[write_ptr] = data, write_ptr++
            if(PushIn & !full) begin
                write_ptr        <= write_ptr + 1;
                fifoI[write_ptr] <= SampI;
                fifoQ[write_ptr] <= SampQ;
            end

            //2. rd_en & !empty => rd_ptr++
            if(PullOut) begin
                read_ptr        <= read_ptr + 1;
            end
        end
    end

    always@(*) begin
        if(reset) begin
            full    = 0;
            empty   = 0;
        end else begin
            //if(read == write) empty
            empty = (read_ptr == write_ptr);

            //if read[1:0] == write[1:0] && read[2] != write[2] full
            full  = (read_ptr[1:0] == write_ptr[1:0]) & (read_ptr[2] != write_ptr[2]);
        end
    end

always@* begin
    SampI_datapath  = fifoI[read_ptr];
    SampQ_datapath  = fifoQ[read_ptr];
end

endmodule