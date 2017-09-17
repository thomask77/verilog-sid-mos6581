module MOS6581 (
    output[15:0]    audio_out,
    input[4:0]      addr,
    input[7:0]      data,       // TODO: inout
    input           n_cs,
    input           rw,
    input           clk, clk_en, n_reset,
    
    input[11:0]     debug_in,
    output[7:0]     debug_out
);


typedef struct { 
    // register bits
    //
    bit[15:0]   freq;
    bit[11:0]   pw;
    bit         noise, pulse, saw, triangle;
    bit         test, ring, sync, gate;
    bit[3:0]    atk, dcy, stn, rls;

    // internal state
    //
    bit[23:0]   acc;
    bit[22:0]   lfsr;
    bit         sync_out;  
    bit[7:0]    env_vol;
    bit[11:0]   out;  
} voice_t;


typedef struct {
    bit[10:0]   fc;
    bit[3:0]    res;
    bit[3:0]    filt;
    bit         off3, hp, bp, lp;
    bit[3:0]    vol;
} filter_t;


voice_t     v[3];
filter_t    filter;


// ---------- Memory interface ----------
//
always_ff @(posedge clk, negedge n_reset)
begin
    if (!n_reset) begin
        // TODO: reset all registers     
    end 
    else if (!n_cs && !rw) begin
        unique case(addr)
        // Voice 0
        //
        'h00:   v[0].freq[7:0]  <= data;
        'h01:   v[0].freq[15:8] <= data;
        'h02:   v[0].pw[7:0]    <= data;
        'h03:   v[0].pw[11:8]   <= data[3:0];
        'h04:   { v[0].noise, v[0].pulse, v[0].saw, v[0].triangle, 
                  v[0].test,  v[0].ring,  v[0].sync, v[0].gate } <= data;
        'h05:   { v[0].atk, v[0].dcy } <= data;
        'h06:   { v[0].stn, v[0].rls } <= data;
        
        // Voice 1
        //
        'h07:   v[1].freq[7:0]  <= data;
        'h08:   v[1].freq[15:8] <= data;
        'h09:   v[1].pw[7:0]    <= data;
        'h0A:   v[1].pw[11:8]   <= data[3:0];
        'h0B:   { v[1].noise, v[1].pulse, v[1].saw,  v[1].triangle, 
                  v[1].test,  v[1].ring,  v[1].sync, v[1].gate } <= data;
        'h0C:   { v[1].atk, v[1].dcy } <= data;
        'h0D:   { v[1].stn, v[1].rls } <= data;
        
        // Voice 2
        //
        'h0E:   v[2].freq[7:0]  <= data;
        'h0F:   v[2].freq[15:8] <= data;
        'h10:   v[2].pw[7:0]    <= data;
        'h11:   v[2].pw[11:8]   <= data[3:0];
        'h12:   { v[2].noise, v[2].pulse, v[2].saw,  v[2].triangle, 
                  v[2].test,  v[2].ring,  v[2].sync, v[2].gate } <= data;
        'h13:   { v[2].atk, v[2].dcy } <= data;
        'h14:   { v[2].stn, v[2].rls } <= data;
        
        // Filter
        //
        'h15:   filter.fc[2:0]  <= data[2:0];
        'h16:   filter.fc[10:3] <= data;
        'h17:   { filter.res, filter.filt } <= data;
        'h18:   { filter.off3, filter.hp, filter.bp, filter.lp, filter.vol } <= data;

        default:    ;
        endcase
    end
end


/*
TODO: Read access
always_comb
begin
    data = 'z;
end
*/    


genvar i;
generate
    for (i=0; i<3; i++) 
    begin: voice
        const int prev_i = (i+5) % 3;

        sid_acc acc(
            .freq(v[i].freq), 
            .acc (v[i].acc),
            .lfsr(v[i].lfsr),
            .test(v[i].test),
            .sync(v[i].sync),

            .sync_in(v[prev_i].sync_out),
            .sync_out(v[i].sync_out),

            .clk(clk),
            .clk_en(clk_en),
            .n_reset(n_reset) 
        );  
    
        sid_env env (
            .vol(v[i].env_vol),
            .gate(v[i].gate),
            .atk(v[i].atk),
            .dcy(v[i].dcy),
            .stn(v[i].stn),
            .rls(v[i].rls),

            .clk(clk),
            .clk_en(clk_en),
            .n_reset(n_reset) 
        );   

        sid_wave wave(
            .out(       v[i].out ),
            .acc(       v[i].acc ),
            .lfsr(      v[i].lfsr ),
            .vol(       v[i].env_vol ),
            .noise(     v[i].noise ),
            .pulse(     v[i].pulse ),
            .saw(       v[i].saw ),
            .triangle(  v[i].triangle ),
            .pw(        v[i].pw ),
            .ring(      v[i].ring ),
            .ring_in(   v[prev_i].acc[23])
        );
    end
endgenerate


sid_filter  filt(
    .audio_out(audio_out),

    .voice( '{ v[0].out, v[1].out, v[2].out } ),
    
    .reg_fc     ( filter.fc     ),
    .reg_res    ( filter.res    ),
    .reg_en     ( filter.filt   ),
    .reg_off3   ( filter.off3   ),
    .reg_hp     ( filter.hp     ),
    .reg_bp     ( filter.bp     ),
    .reg_lp     ( filter.lp     ),
    .reg_vol    ( filter.vol    ),
    
    .clk(clk),
    .clk_en(clk_en),
    .n_reset(n_reset)
);


/*
    // TODO: Im Moment wird nur 3/4 des Wertebereichs ausgenutzt..
    //
    audio_out += 12'( (20'(v[i].out) * ) >> 6 );
*/


always_comb begin
    debug_out[0] = !filter.filt[0];
    debug_out[1] = !filter.filt[1];
    debug_out[2] = !filter.filt[2];
    
    debug_out[5] = !v[0].gate;
    debug_out[6] = !v[1].gate;
    debug_out[7] = !v[2].gate;
end


endmodule
