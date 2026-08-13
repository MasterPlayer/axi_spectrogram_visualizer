

module fft_tdpbram #(
    parameter DATA_DEPTH = 1024,
    parameter DATA_WIDTH = 16
) (
    input  logic                            i_clka ,
    input  logic                            i_ena  ,
    input  logic                            i_wea  ,
    input  logic [($clog2(DATA_DEPTH)-1):0] i_addra,
    input  logic [        (DATA_WIDTH-1):0] i_dia  ,
    output logic [        (DATA_WIDTH-1):0] o_doa  ,
    input  logic                            i_clkb ,
    input  logic                            i_enb  ,
    input  logic                            i_web  ,
    input  logic [($clog2(DATA_DEPTH)-1):0] i_addrb,
    input  logic [        (DATA_WIDTH-1):0] i_dib  ,
    output logic [        (DATA_WIDTH-1):0] o_dob
);

    logic [DATA_WIDTH-1:0] ram_memory[0:DATA_DEPTH-1];

    always_ff @(posedge i_clka) begin : o_doa_processing 
        if (i_ena) begin 
            o_doa <= ram_memory[i_addra];
        end 
    end

    always_ff @(posedge i_clka) begin : ram_memory_porta_processing 
        if (i_ena) begin 
            if (i_wea) begin 
                ram_memory[i_addra] <= i_dia;
            end 
        end 
    end 

    always_ff @(posedge i_clkb) begin : o_dob_processing 
        if (i_enb) begin 
            o_dob <= ram_memory[i_addrb];
        end 
    end

    always_ff @(posedge i_clkb) begin : ram_memory_portb_processing 
        if (i_enb) begin 
            if (i_web) begin 
                ram_memory[i_addrb] <= i_dib;
            end 
        end 
    end 

endmodule 