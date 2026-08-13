
module fft_twiddle_rom_wrapper #(
    DATA_WIDTH = 16,
    DATA_DEPTH = 32
) (
    input  logic                          clk   ,
    input  logic [$clog2(DATA_DEPTH)-1:0] i_addr,
    output logic [      (DATA_WIDTH-1):0] o_tr  ,
    output logic [      (DATA_WIDTH-1):0] o_ti
);

    fft_twiddle_rom_real #(
        .DATA_WIDTH(DATA_WIDTH),
        .DATA_DEPTH(DATA_DEPTH)
    ) fft_twiddle_rom_real_inst (
        .clk   (clk   ),
        .i_addr(i_addr),
        .o_data(o_tr  )
    );

    fft_twiddle_rom_imag #(
        .DATA_WIDTH(DATA_WIDTH),
        .DATA_DEPTH(DATA_DEPTH)
    ) fft_twiddle_rom_imag_inst (
        .clk   (clk   ),
        .i_addr(i_addr),
        .o_data(o_ti  )
    );

endmodule