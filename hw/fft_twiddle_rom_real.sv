


module fft_twiddle_rom_real #(
    parameter DATA_WIDTH = 16                                                                                      ,
    parameter DATA_DEPTH = 5                                                                                       ,
    parameter DATA_PATH  = "Z:/fpga_development/github/axi_spectrogram_visualizer/scripts/twiddle_real_hex_256.hex"
) (
    input  logic                          clk   ,
    input  logic [$clog2(DATA_DEPTH)-1:0] i_addr,
    output logic [      (DATA_WIDTH-1):0] o_data
);

    (* ram_style="block" *)logic [DATA_WIDTH-1:0] rom_memory[0:DATA_DEPTH-1];

    initial begin
        $display("loading memory for store %s values used in real part...", 2**DATA_DEPTH);
        $readmemh(DATA_PATH, rom_memory);
    end

    always_ff @(posedge clk) begin : o_data_processing
        o_data <= rom_memory[i_addr];
    end


endmodule 