
module fft_complex_adder #(parameter WIDTH = 32) (
    input  logic               clk ,
    input  logic [(WIDTH-1):0] i_ar,
    input  logic [(WIDTH-1):0] i_ai,
    input  logic [(WIDTH-1):0] i_br,
    input  logic [(WIDTH-1):0] i_bi,
    output logic [    WIDTH:0] o_cr,
    output logic [    WIDTH:0] o_ci
);

    always_ff @(posedge clk) begin : p_real_processing 
        o_cr <= $signed({i_ar[WIDTH-1], i_ar[WIDTH-1:0]}) + $signed({i_br[WIDTH-1], i_br[WIDTH-1:0]});
    end 

    always_ff @(posedge clk) begin : p_imag_processing 
        o_ci <= $signed({i_ai[WIDTH-1], i_ai[WIDTH-1:0]}) + $signed({i_bi[WIDTH-1], i_bi[WIDTH-1:0]});
    end 
    
endmodule : fft_complex_adder