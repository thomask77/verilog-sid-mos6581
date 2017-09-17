// SID phase accumulator
//
module sid_acc(
    input[15:0]     freq,
    output[23:0]    acc,
    output[22:0]    lfsr,
    
    input   test, sync,
    input   sync_in,
    output  sync_out,
 
    input   clk, clk_en, n_reset
);

bit [23:0]  acc_next;
bit [22:0]  lfsr_next;


always_ff @(posedge clk, negedge n_reset)
begin
    if (!n_reset) begin
        acc <= 0;
        lfsr <= '1;
    end
    else if (clk_en) begin
        acc <= acc_next;
        
        if (!acc[19] && acc_next[19])
            lfsr <= lfsr_next;
    end   
end


always_comb
begin
    acc_next = acc + freq;
    lfsr_next = { lfsr[21:0], lfsr[17] ^ lfsr[22] };
    
    if (sync && sync_in)
        acc_next = 0;

    if (test) begin
        acc_next = 0;
        lfsr_next = '1;
    end

    sync_out  = !acc[23] && acc_next[23];
end


endmodule



