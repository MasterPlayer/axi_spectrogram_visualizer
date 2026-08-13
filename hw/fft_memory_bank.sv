

module fft_memory_bank #(
    parameter DATA_WIDTH      = 16,
    parameter DATA_DEPTH_LOG2 = 5
) (
    input  logic                       i_clk      ,
    input  logic                       i_wren_re_a,
    input  logic                       i_wren_re_b,
    input  logic [DATA_DEPTH_LOG2-1:0] i_addr_re_a,
    input  logic [DATA_DEPTH_LOG2-1:0] i_addr_re_b,
    input  logic [     DATA_WIDTH-1:0] i_data_re_a,
    input  logic [     DATA_WIDTH-1:0] i_data_re_b,
    output logic [     DATA_WIDTH-1:0] o_data_re_a,
    output logic [     DATA_WIDTH-1:0] o_data_re_b,
    input  logic                       i_wren_im_a,
    input  logic                       i_wren_im_b,
    input  logic [DATA_DEPTH_LOG2-1:0] i_addr_im_a,
    input  logic [DATA_DEPTH_LOG2-1:0] i_addr_im_b,
    input  logic [     DATA_WIDTH-1:0] i_data_im_a,
    input  logic [     DATA_WIDTH-1:0] i_data_im_b,
    output logic [     DATA_WIDTH-1:0] o_data_im_a,
    output logic [     DATA_WIDTH-1:0] o_data_im_b
);


    fft_tdpbram #(
        .DATA_DEPTH(2 ** DATA_DEPTH_LOG2),
        .DATA_WIDTH(DATA_WIDTH          )
    ) fft_tdpbram_real_inst (
        .i_clka (i_clk      ),
        .i_clkb (i_clk      ),
        .i_ena  (1'b1       ),
        .i_enb  (1'b1       ),
        .i_wea  (i_wren_re_a),
        .i_web  (i_wren_re_b),
        .i_addra(i_addr_re_a),
        .i_addrb(i_addr_re_b),
        .i_dia  (i_data_re_a),
        .i_dib  (i_data_re_b),
        .o_doa  (o_data_re_a),
        .o_dob  (o_data_re_b)
    );


    fft_tdpbram #(
        .DATA_DEPTH(2 ** DATA_DEPTH_LOG2),
        .DATA_WIDTH(DATA_WIDTH          )
    ) fft_tdpbram_imag_inst (
        .i_clka (i_clk      ),
        .i_clkb (i_clk      ),
        .i_ena  (1'b1       ),
        .i_enb  (1'b1       ),
        .i_wea  (i_wren_im_a),
        .i_web  (i_wren_im_b),
        .i_addra(i_addr_im_a),
        .i_addrb(i_addr_im_b),
        .i_dia  (i_data_im_a),
        .i_dib  (i_data_im_b),
        .o_doa  (o_data_im_a),
        .o_dob  (o_data_im_b)
    );            


endmodule