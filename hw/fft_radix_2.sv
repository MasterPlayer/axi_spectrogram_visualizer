
module fft_radix_2 #(
    parameter DATA_WIDTH = 16,
    parameter QFORMAT    = 15
) (
    input  logic                    clk ,
    // Input A
    input  logic [DATA_WIDTH-1:0] i_ar,
    input  logic [DATA_WIDTH-1:0] i_ai,
    // Input B
    input  logic [DATA_WIDTH-1:0] i_br,
    input  logic [DATA_WIDTH-1:0] i_bi,
    // Input TW
    input  logic [DATA_WIDTH-1:0] i_tr,
    input  logic [DATA_WIDTH-1:0] i_ti,
    // Output A
    output logic [DATA_WIDTH-1:0] o_xr,
    output logic [DATA_WIDTH-1:0] o_xi,
    // Output B
    output logic [DATA_WIDTH-1:0] o_yr,
    output logic [DATA_WIDTH-1:0] o_yi
);

    parameter C_MULT_PIPE_STAGE = 6;

    logic [0:(C_MULT_PIPE_STAGE-1)][DATA_WIDTH:0] pipe_data_re;
    logic [0:(C_MULT_PIPE_STAGE-1)][DATA_WIDTH:0] pipe_data_im;

    logic [(2*DATA_WIDTH):0] cmult_out_re      ;
    logic [(2*DATA_WIDTH):0] cmult_out_im      ;
    logic [    DATA_WIDTH:0] cmult_out_re_trunc;
    logic [    DATA_WIDTH:0] cmult_out_im_trunc;
    logic [(DATA_WIDTH+1):0] xr                ;
    logic [(DATA_WIDTH+1):0] xi                ;
    logic [(DATA_WIDTH+1):0] yr                ;
    logic [(DATA_WIDTH+1):0] yi                ;
    logic                    overflow_mult     ;
    logic                    overflow_out      ;

    always_ff @(posedge clk) begin : pipe_data_re_processing 
        pipe_data_re <= {{i_ar[(DATA_WIDTH-1)], i_ar[(DATA_WIDTH-1):0]}, pipe_data_re[0:(C_MULT_PIPE_STAGE-2)]};
    end

    always_ff @(posedge clk) begin : pipe_data_im_processing 
        pipe_data_im <= {{i_ai[(DATA_WIDTH-1)], i_ai[(DATA_WIDTH-1):0]}, pipe_data_im[0:(C_MULT_PIPE_STAGE-2)]};
    end 


    fft_complex_mult #(
        .WIDTH_A(DATA_WIDTH),
        .WIDTH_B(DATA_WIDTH)
    ) fft_complex_mult_inst (
        .clk (clk         ),
        .i_ar(i_br        ),
        .i_ai(i_bi        ),
        .i_br(i_tr        ),
        .i_bi(i_ti        ),
        .o_pr(cmult_out_re),
        .o_pi(cmult_out_im)
    );


    // Right shift by Q Format
    always_ff @(posedge clk) begin : trunc_and_ovf_processing

        overflow_mult <= 1'b0;

        if (cmult_out_re[(2*DATA_WIDTH)] != cmult_out_re[((2*DATA_WIDTH)-1)]) begin
            cmult_out_re_trunc <= {cmult_out_re[(2*DATA_WIDTH)], {(DATA_WIDTH-1){cmult_out_re[((2*DATA_WIDTH)-1)]}}};
            overflow_mult    <= 1'b1;
        end else begin
            cmult_out_re_trunc <= $signed(cmult_out_re[((2*DATA_WIDTH)-1):(2*DATA_WIDTH)-1-QFORMAT-1]);
        end

        if (cmult_out_im[(2*DATA_WIDTH)] != cmult_out_im[((2*DATA_WIDTH)-1)]) begin
            cmult_out_im_trunc <= {cmult_out_im[(2*DATA_WIDTH)], {(DATA_WIDTH-1){cmult_out_im[(2*DATA_WIDTH)-1]}}};
            overflow_mult      <= 1'b1;
        end else begin
            cmult_out_im_trunc <= $signed(cmult_out_im[((2*DATA_WIDTH)-1):(2*DATA_WIDTH)-1-QFORMAT-1]);
        end

    end



    fft_complex_adder #(.WIDTH(DATA_WIDTH+1)) fft_complex_adder_a_inst (
        .clk (clk                                ),
        .i_ar(pipe_data_re[(C_MULT_PIPE_STAGE-1)]),
        .i_ai(pipe_data_im[(C_MULT_PIPE_STAGE-1)]),
        .i_br(cmult_out_re_trunc                 ),
        .i_bi(cmult_out_im_trunc                 ),
        .o_cr(xr                                 ),
        .o_ci(xi                                 )
    );


    fft_complex_adder #(.WIDTH(DATA_WIDTH+1)) fft_complex_adder_b_inst (
        .clk (clk                                ),
        .i_ar(pipe_data_re[(C_MULT_PIPE_STAGE-1)]),
        .i_ai(pipe_data_im[(C_MULT_PIPE_STAGE-1)]),
        .i_br(-cmult_out_re_trunc                ),
        .i_bi(-cmult_out_im_trunc                ),
        .o_cr(yr                                 ),
        .o_ci(yi                                 )
    );

    always_ff @(posedge clk) begin : output_processing 
        // Two cases:
        // A. Clip to max pos/neg if MSB /= MSB-1
        // produces 10000... or 01111...
        // B. <<1 to compensate for bit gain loss

        overflow_out <= 1'b0; // for debug purposes

        if (xr[(DATA_WIDTH)] != xr[(DATA_WIDTH+1)] ) begin
            o_xr <= {xr[DATA_WIDTH+1], {DATA_WIDTH{xr[DATA_WIDTH]}}};
            overflow_out <= 1'b1;
        end else begin 
            o_xr <= xr[DATA_WIDTH:1];
        end

        if (xi[DATA_WIDTH] != xi[(DATA_WIDTH+1)] ) begin
            o_xi <= {xi[DATA_WIDTH+1], {DATA_WIDTH{xi[DATA_WIDTH]}}};
            overflow_out <= 1'b1;
        end else begin 
            o_xi <= xi[DATA_WIDTH:1];
        end

        if (yr[DATA_WIDTH] != yr[(DATA_WIDTH+1)] ) begin
            o_yr <= {yr[DATA_WIDTH+1], {DATA_WIDTH{yr[DATA_WIDTH]}}};
            overflow_out <= 1'b1;
        end else begin 
            o_yr <= yr[DATA_WIDTH:1];
        end

        if (yi[DATA_WIDTH] != yi[(DATA_WIDTH+1)] ) begin
            o_yi <= {yi[DATA_WIDTH+1], {DATA_WIDTH{yi[DATA_WIDTH]}}};
            overflow_out <= 1'b1;
        end else begin 
            o_yi <= yi[DATA_WIDTH:1];
        end
    end


endmodule