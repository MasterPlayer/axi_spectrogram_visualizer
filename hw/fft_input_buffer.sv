

module fft_input_buffer #(
    parameter RAM_WIDTH = 16 ,
    parameter RAM_DEPTH = 512
) (
    input  logic                           i_clk ,
    input  logic [($clog2(RAM_DEPTH)-1):0] i_addr,
    input  logic [        (RAM_WIDTH-1):0] i_din ,
    input  logic                           i_we  ,
    output logic [        (RAM_WIDTH-1):0] o_dout
);

    (* ram_style="block" *)logic [RAM_WIDTH-1:0]input_buffer_ram[0:(RAM_DEPTH-1)];

    always_ff @(posedge i_clk) begin : input_buffer_ram_processing
        if (i_we) begin
            input_buffer_ram[i_addr] <= i_din;
        end else begin 
            input_buffer_ram[i_addr] <= input_buffer_ram[i_addr];
        end 
    end 

    always_ff @(posedge i_clk) begin : o_dout_processing 
        o_dout <= input_buffer_ram[i_addr];
    end 

endmodule 