module clk_div #(
    DIVISOR = 16  
) (
    output clk_en_out,
    input  clk, n_reset
);


bit[$clog2(DIVISOR)-1 : 0] div, div_next;


always_ff @(posedge clk, negedge n_reset)
begin 
    if (!n_reset)
        div <= 0;
    else
        div <= div_next;
end


always_comb 
begin
    if (div == 0) begin
        div_next = DIVISOR - 1;
        clk_en_out = 1;
    end
    else begin
        div_next = div - 1;
        clk_en_out = 0;
    end
end


endmodule
