module multiplier_fsm_tb(
);

reg clk, reset, PushIn, PushCoef, fifo_empty;
wire [1:0] multiplier_mux_sel;
wire partialProductAccumulate_valid, finalAccumulateRounding_en, fifoPullOut;

multiplier_fsm dut(
    clk,
    reset,
    PushIn,
    PushCoef,
    fifo_empty,
    multiplier_mux_sel,
    partialProductAccumulate_valid,
    finalAccumulateRounding_en,
    fifoPullOut
);

always #5 clk = ~clk;

initial begin
    clk = 1;
    reset = 1;
    fifo_empty = 1;
    PushIn = 0;
    PushCoef = 0;
    #18;
    reset = 0;

    fifo_empty = 0;
    #100;
    fifo_empty = 1;
    #30;
    $finish();

end

initial begin
    $dumpfile("fsm.vcd");
    $dumpvars(0);
end

endmodule