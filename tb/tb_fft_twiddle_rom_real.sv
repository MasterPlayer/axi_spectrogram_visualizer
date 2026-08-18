`timescale 1ps / 1ps



module tb_fft_twiddle_rom_real();

    parameter DATA_WIDTH = 16 ;
    parameter DATA_DEPTH = 128;
    // absolute path 
    parameter DATA_PATH  = "z:/fpga_development/github/axi_spectrogram_visualizer/outputs/twiddle_real_hex_256.hex";


    logic                          clk ;
    logic [$clog2(DATA_DEPTH)-1:0] addr;
    logic [      (DATA_WIDTH-1):0] data;

    integer index = 0;

    initial begin 
        clk = 1'b0;
        forever
        #5000 clk = ~clk;
    end 

    always_ff @(posedge clk) begin 
        index <= index + 1;
    end 

    always_ff @(posedge clk) begin : addr_processing 
        if (index > 100) begin 
            addr <= addr + 1;
        end else begin 
            addr <= '{default:0};
        end 
    end 

    fft_twiddle_rom_real #(
        .DATA_WIDTH(DATA_WIDTH),
        .DATA_DEPTH(DATA_DEPTH),
        .DATA_PATH (DATA_PATH )
    ) fft_twiddle_rom_real_inst (
        .clk   (clk ),
        .i_addr(addr),
        .o_data(data)
    );





endmodule
