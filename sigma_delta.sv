module sigma_delta  #(
    N = 16
)(
    output          out,
    input[N-1:0]    in,
    input           n_reset,
    input           clk
);


bit[N-1:0] acc, acc_next;
bit        out_next;


always_ff @(posedge clk, negedge n_reset) 
begin
    if (!n_reset) begin
        acc <= 0;
        out <= 0;       
    end else begin
        acc <= acc_next;
        out <= out_next;
    end
end        
    

always_comb 
begin
    bit[N:0]  sum;
    sum = acc + in;
    
    out_next = sum[N];
    acc_next = sum[N-1:0];
end

    
endmodule
