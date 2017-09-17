module sid_filter(
    output[15:0]    audio_out,
    
    input[11:0]     voice[3],
    input[10:0]     reg_fc,
    input[3:0]      reg_res,
    input[3:0]      reg_en,
    input           reg_off3, reg_hp, reg_bp, reg_lp,
    input[3:0]      reg_vol,
    
    input           clk, clk_en, n_reset
);


int low,  low_next;
int band, band_next;
int high, high_next;

int out_next;


always_ff @(posedge clk, negedge n_reset)
begin
    if (!n_reset) begin
        low  <= 0;
        band <= 0;
        high <= 0;
        audio_out <= 0;
    end
    else if (clk_en) begin
        low  <= low_next;
        band <= band_next;
        high <= high_next;
        audio_out <= out_next;
    end
end


always_comb
begin       
    int out_filt;
    int fc, res;

    // 3*12 Bit Voice -> 14 bit out_filt/next
    //
    out_filt = 0;
    out_next = 0;
    
    for (int i=0; i<3; i++) begin
        if (reg_en[i])
            out_filt += voice[i];
        else if (!(i == 2 && reg_off3))
            out_next += voice[i];   
    end  
    
    fc  = reg_fc + 64;
    res = 256 - reg_res * 10;
        
    high_next = out_filt - low - ((band * res) >>> 8);
    band_next = band + ((high_next * fc) >>> 16);
    low_next  = low  + ((band_next * fc) >>> 16);
    
    if (reg_lp)  out_next += low;
    if (reg_bp)  out_next += band;
    if (reg_hp)  out_next += high;

    if (out_next < 0)
        out_next = 0;
    if (out_next > 65535)
        out_next = 65535;    

    out_next = (out_next * reg_vol) >> 2;
end


endmodule
