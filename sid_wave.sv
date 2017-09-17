module sid_wave(
    output[11:0]    out,
    input[23:0]     acc,
    input[22:0]     lfsr,
    input[7:0]      vol,
    input           noise, pulse, saw, triangle,
    input[11:0]     pw,
    input           ring, ring_in
);


always_comb
begin
    bit [11:0]  out_noise, out_pulse, out_saw, out_triangle;
    
    out_noise = {
        lfsr[20], lfsr[18], lfsr[14], lfsr[11],
        lfsr[ 9], lfsr[ 5], lfsr[ 2], lfsr[ 0], 4'b0 
    };

    out_pulse    = acc[23:12] < pw ? '1 : '0;
    out_saw      = acc[23:12];
    out_triangle = acc[22:12] << 1;

    if (acc[23])
        out_triangle ^= '1;
        
    if (ring && ring_in)
        out_triangle ^= '1; 
    
    out = '1;
    if (noise)      out &= out_noise;
    if (pulse)      out &= out_pulse;
    if (saw)        out &= out_saw;
    if (triangle)   out &= out_triangle;
    
    out  = 12'( (20'(out) * vol) >> 8 );
end


endmodule