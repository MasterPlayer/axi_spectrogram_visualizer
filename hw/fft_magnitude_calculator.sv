


module fft_magnitude_calculator #(
    parameter INPUT_WIDTH = 16  ,
    parameter NFFT        = 1024
) (
    input  logic                       i_clk          ,
    input  logic [    INPUT_WIDTH-1:0] i_tdata_re     ,
    input  logic [    INPUT_WIDTH-1:0] i_tdata_im     ,
    input  logic [   $clog2(NFFT)-1:0] i_xk_index     ,
    input  logic                       i_tvalid       ,
    output logic [(INPUT_WIDTH*2)-1:0] magnitude      ,
    output logic                       magnitude_valid,
    output logic [   $clog2(NFFT)-1:0] o_xk_index
);

    logic                    d_i_tvalid  ;
    logic [$clog2(NFFT)-1:0] d_i_xk_index;

    logic unsigned [(INPUT_WIDTH*2)-1:0] tdata_re_pow2;
    logic unsigned [(INPUT_WIDTH*2)-1:0] tdata_im_pow2;


    always_ff @(posedge i_clk) begin
        // tdata_re_pow2 <= $unsigned({{16{i_tdata_re[15]}}, i_tdata_re} * {{16{i_tdata_re[15]}}, i_tdata_re});
        // tdata_im_pow2 <= $unsigned({{16{i_tdata_im[15]}}, i_tdata_im} * {{16{i_tdata_im[15]}}, i_tdata_im});

        tdata_re_pow2 <= $unsigned({{INPUT_WIDTH{i_tdata_re[INPUT_WIDTH-1]}}, i_tdata_re[INPUT_WIDTH-1:0]} * {{INPUT_WIDTH{i_tdata_re[INPUT_WIDTH-1]}}, i_tdata_re[INPUT_WIDTH-1:0]});
        tdata_im_pow2 <= $unsigned({{INPUT_WIDTH{i_tdata_im[INPUT_WIDTH-1]}}, i_tdata_im[INPUT_WIDTH-1:0]} * {{INPUT_WIDTH{i_tdata_im[INPUT_WIDTH-1]}}, i_tdata_im[INPUT_WIDTH-1:0]});

    end 

    always_ff @(posedge i_clk) begin : d_i_tvalid_processing 
        d_i_tvalid <= i_tvalid;
    end 

    always_ff @(posedge i_clk) begin : d_i_xk_index_processing 
        d_i_xk_index <= i_xk_index;
    end 

    always_ff @(posedge i_clk) begin : magnitude_processing 
        magnitude <= tdata_re_pow2 + tdata_im_pow2;
    end 

    always_ff @(posedge i_clk) begin : magnitude_valid_processing 
        magnitude_valid <= d_i_tvalid;
    end 

    always_ff @(posedge i_clk) begin : o_xk_index_processing 
        o_xk_index <= d_i_xk_index;
    end 


    endmodule