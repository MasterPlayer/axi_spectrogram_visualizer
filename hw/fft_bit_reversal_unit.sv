

module fft_bit_reversal_unit #(
    parameter DATA_WIDTH      = 16,
    parameter DATA_DEPTH_LOG2 = 11
) (
    input  logic                         i_clk           ,
    input  logic                         i_resetn        ,
    // Data Input
    input  logic [       DATA_WIDTH-1:0] i_tdata_re      ,
    input  logic [       DATA_WIDTH-1:0] i_tdata_im      ,
    input  logic                         i_tvalid        ,
    // Data Output
    output logic [     (DATA_WIDTH-1):0] o_tdata_re      ,
    output logic [     (DATA_WIDTH-1):0] o_tdata_im      ,
    output logic [(DATA_DEPTH_LOG2-1):0] o_taddr_reversed,
    output logic [(DATA_DEPTH_LOG2-1):0] o_taddr_normal  ,
    output logic                         o_tvalid
);


    logic [DATA_DEPTH_LOG2-1:0] taddr;


    always_ff @(posedge i_clk, negedge i_resetn) begin 
        if (~i_resetn) begin 
            o_tvalid <= 1'b0;
        end else begin 
            o_tvalid <= i_tvalid;
        end 
    end 


    always_ff @(posedge i_clk, negedge i_resetn) begin : o_tdata_re_processing 
        if (~i_resetn) begin 
            o_tdata_re <= '{default:0};
        end else begin 
            o_tdata_re <= i_tdata_re;
        end 
    end


    always_ff @(posedge i_clk, negedge i_resetn) begin : o_tdata_im_processing 
        if (~i_resetn) begin 
            o_tdata_im <= '{default:0};
        end else begin 
            o_tdata_im <= i_tdata_im;
        end 
    end

    always_ff @(posedge i_clk, negedge i_resetn) begin : taddr_processing 
        if (~i_resetn) begin 
            taddr <= '{default:0};
        end else begin        
            if (i_tvalid) begin 
                taddr <= taddr + 1;
            end else begin 
                taddr <= taddr;
            end 
        end 
    end 


    always_ff @(posedge i_clk, negedge i_resetn) begin : o_taddr_normal_processing 
        if (~i_resetn) begin 
            o_taddr_normal <= '{default:0};
        end else begin 
            if (i_tvalid) begin 
                o_taddr_normal <= taddr;
            end else begin 
                o_taddr_normal <= o_taddr_normal;
            end 
        end 
    end 


    generate
        for (genvar index = 0; index < DATA_DEPTH_LOG2; index++) begin 
            always_comb o_taddr_reversed[(DATA_DEPTH_LOG2-1)-index] = o_taddr_normal[index];
        end
    endgenerate


endmodule : fft_bit_reversal_unit