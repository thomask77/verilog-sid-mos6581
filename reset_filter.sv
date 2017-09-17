module reset_filter
#(
    DELAY = 2
) (
    input   n_reset_in,
    output  n_reset_out,
    input   clk
);


bit[DELAY-1:0] delay;


always_ff @(posedge clk, negedge n_reset_in) 
    if (!n_reset_in)
        delay <= '0;
    else
        delay <= { 1'b1, delay[DELAY-1:1] };
    

always_comb
    n_reset_out = delay[0];

    
endmodule
