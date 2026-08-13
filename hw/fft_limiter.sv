

module fft_limiter #(
    parameter LIMIT_FACTOR = 2  ,
    parameter FFT_POINTS   = 512
) (
    input  logic        i_clk          ,
    input  logic        i_resetn       ,
    input  logic [31:0] i_s_axis_tdata ,
    input  logic        i_s_axis_tvalid,
    output logic [31:0] o_m_axis_tdata ,
    output logic        o_m_axis_tvalid
);

    logic has_no_limit; 

    logic [$clog2(FFT_POINTS)-1:0] data_counter;

    logic [$clog2(LIMIT_FACTOR)-1:0] limit_counter;

    always_ff @(posedge i_clk, negedge i_resetn) begin 
        if (~i_resetn) begin 
            data_counter <= '{default:0};
        end else begin 
            if (i_s_axis_tvalid) begin 
                if (data_counter < FFT_POINTS-1) begin 
                    data_counter <= data_counter + 1;
                end else begin 
                    data_counter <= '{default:0};
                end 
            end else begin 
                data_counter <= data_counter;
            end
        end 
    end 

    always_ff @(posedge i_clk, negedge i_resetn) begin : limit_counter_processing 
        if (~i_resetn) begin 
            limit_counter <= '{default:0};
        end else begin 
            if (i_s_axis_tvalid) begin 
                if (data_counter < FFT_POINTS-1) begin 
                    limit_counter <= limit_counter;
                end else begin 
                    limit_counter <= limit_counter + 1;
                end  
            end else begin 
                limit_counter <= limit_counter;
            end 
        end 
    end 


    always_comb has_no_limit = (limit_counter == 0);


    always_ff @(posedge i_clk) begin : o_m_axis_tdata_processing 
        o_m_axis_tdata <= i_s_axis_tdata;
    end 


    always_ff @(posedge i_clk) begin : o_m_axis_tvalid_processing 
        o_m_axis_tvalid <= i_s_axis_tvalid & has_no_limit;
    end 


endmodule