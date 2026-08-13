

module fft_complex_mult #(
    parameter WIDTH_A = 16,
    parameter WIDTH_B = 16
) (
    input  logic                       clk ,
    // Term A
    input  logic [      (WIDTH_A-1):0] i_ar,
    input  logic [      (WIDTH_A-1):0] i_ai,
    // Term B
    input  logic [      (WIDTH_B-1):0] i_br,
    input  logic [      (WIDTH_B-1):0] i_bi,
    // Output
    output logic [(WIDTH_A+WIDTH_B):0] o_pr,
    output logic [(WIDTH_A+WIDTH_B):0] o_pi
); 

    logic signed [          WIDTH_A:0] add_common ;
    logic signed [(WIDTH_A+WIDTH_B):0] mult_common;
    logic signed [(WIDTH_A+WIDTH_B):0] common     ;

    logic signed [WIDTH_B:0] add_re;
    logic signed [WIDTH_B:0] add_im;

    logic signed [(WIDTH_A+WIDTH_B):0] mult_re;
    logic signed [(WIDTH_A+WIDTH_B):0] mult_im;

    logic signed [2:0][(WIDTH_A-1):0] ar_pipeline;
    logic signed [2:0][(WIDTH_A-1):0] ai_pipeline;
    logic signed [2:0][(WIDTH_A-1):0] br_pipeline;
    logic signed [2:0][(WIDTH_A-1):0] bi_pipeline;

///////////////////////////////////////////////////////////////////////////

    always_ff @(posedge clk) begin : ar_pipeline_processing 
        ar_pipeline <= {ar_pipeline[1:0], i_ar};
    end 

    always_ff @(posedge clk) begin : ai_pipeline_processing 
        ai_pipeline <= {ai_pipeline[1:0], i_ai};
    end 

    always_ff @(posedge clk) begin : br_pipeline_processing 
        br_pipeline <= {br_pipeline[1:0], i_br};
    end 

    always_ff @(posedge clk) begin : bi_pipeline_processing 
        bi_pipeline <= {bi_pipeline[1:0], i_bi};
    end 

///////////////////////////////////////////////////////////////////////////

    always_ff @(posedge clk) begin : add_common_processing 
        add_common <= $signed(ar_pipeline[0]) - $signed(ai_pipeline[0]);
    end 

    always_ff @(posedge clk) begin : mult_common_processing 
        mult_common <= $signed(add_common) * $signed(bi_pipeline[1]);
    end 

    always_ff @(posedge clk) begin : common_processing 
        common <= mult_common;
    end 

///////////////////////////////////////////////////////////////////////////

    always_ff @(posedge clk) begin : add_re_processing 
        add_re <= $signed(br_pipeline[1]) - $signed(bi_pipeline[1]);
    end 

    always_ff @(posedge clk) begin : mult_re_processing 
        mult_re <= $signed(ar_pipeline[2]) * $signed(add_re);
    end 

    always_ff @(posedge clk) begin : o_pr_processing 
        o_pr <= $signed(mult_re) + $signed(common);
    end 

///////////////////////////////////////////////////////////////////////////

    always_ff @(posedge clk) begin : add_im_processing 
        add_im  <= $signed(bi_pipeline[1]) + $signed(br_pipeline[1]);
    end 

    always_ff @(posedge clk) begin : mult_im_processing 
        mult_im <= $signed(ai_pipeline[2]) * $signed(add_im);
    end 

    always_ff @(posedge clk) begin : o_pi_processing 
        o_pi      <= $signed(mult_im) + $signed(common);
    end 

endmodule 