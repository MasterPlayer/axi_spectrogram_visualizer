
module fft_twiddle_rom_wrapper #(
    parameter DATA_WIDTH     = 16                                                                                      ,
    parameter DATA_DEPTH     = 32                                                                                      ,
    parameter DATA_PATH_REAL = "z:/fpga_development/github/axi_spectrogram_visualizer/outputs/twiddle_real_hex_256.hex",
    parameter DATA_PATH_IMAG = "z:/fpga_development/github/axi_spectrogram_visualizer/outputs/twiddle_imag_hex_256.hex"
) (
    input  logic                          clk   ,
    input  logic [$clog2(DATA_DEPTH)-1:0] i_addr,
    output logic [      (DATA_WIDTH-1):0] o_tr  ,
    output logic [      (DATA_WIDTH-1):0] o_ti
);

    fft_twiddle_rom_real #(
        .DATA_WIDTH(DATA_WIDTH    ),
        .DATA_DEPTH(DATA_DEPTH    ),
        .DATA_PATH (DATA_PATH_REAL)
    ) fft_twiddle_rom_real_inst (
        .clk   (clk   ),
        .i_addr(i_addr),
        .o_data(o_tr  )
    );

    fft_twiddle_rom_imag #(
        .DATA_WIDTH(DATA_WIDTH    ),
        .DATA_DEPTH(DATA_DEPTH    ),
        .DATA_PATH (DATA_PATH_IMAG)
    ) fft_twiddle_rom_imag_inst (
        .clk   (clk   ),
        .i_addr(i_addr),
        .o_data(o_ti  )
    );

endmodule