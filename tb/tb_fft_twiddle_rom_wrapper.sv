`timescale 1ps / 1ps



module tb_fft_twiddle_rom_wrapper();

    parameter DATA_WIDTH = 16 ;
    parameter DATA_DEPTH = 128;
    parameter DATA_PATH_REAL = "z:/fpga_development/github/axi_spectrogram_visualizer/outputs/twiddle_real_hex_256.hex";
    parameter DATA_PATH_IMAG = "z:/fpga_development/github/axi_spectrogram_visualizer/outputs/twiddle_imag_hex_256.hex";

    logic                          clk   ;
    logic [$clog2(DATA_DEPTH)-1:0] i_addr;
    logic [      (DATA_WIDTH-1):0] o_tr  ;
    logic [      (DATA_WIDTH-1):0] o_ti  ;

    initial begin 
        clk = 1'b0;
        forever 
        #5000 clk = ~clk;
    end 

    integer index = 0;

    always_ff @(posedge clk) begin 
        index <= index + 1;
    end 

    always_ff @(posedge clk) begin 
        if (index > 100) begin 
            i_addr <= i_addr + 1;
        end else begin 
            i_addr <= '{default:0};
        end 
    end 


    fft_twiddle_rom_wrapper #(
        .DATA_WIDTH    (DATA_WIDTH    ),
        .DATA_DEPTH    (DATA_DEPTH    ),
        .DATA_PATH_REAL(DATA_PATH_REAL),
        .DATA_PATH_IMAG(DATA_PATH_IMAG)
    ) fft_twiddle_rom_wrapper_inst (
        .clk   (clk   ),
        .i_addr(i_addr),
        .o_tr  (o_tr  ),
        .o_ti  (o_ti  )
    );



endmodule : tb_fft_twiddle_rom_wrapper