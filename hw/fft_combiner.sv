

module fft_combiner #(parameter COMBINE_FACTOR = 8) (
    input  logic        i_clk          ,
    input  logic        i_resetn       ,
    input  logic [31:0] i_s_axis_tdata ,
    input  logic        i_s_axis_tvalid,
    output logic [31:0] o_m_axis_tdata ,
    output logic        o_m_axis_tvalid
);

    parameter CF_WIDTH = $clog2(COMBINE_FACTOR);

    typedef enum {
        ACC_VALUE_ST,
        SHIFT_ST
    } fsm;

    fsm current_state = ACC_VALUE_ST;

    logic d_s_axis_tvalid;

    logic [($clog2(COMBINE_FACTOR)-1):0] sample_counter  ;
    logic [($clog2(COMBINE_FACTOR)-1):0] d_sample_counter;
    logic [           (32+CF_WIDTH)-1:0] acc_value       ;

    logic [(32+CF_WIDTH)-1:0] shift_value;
    logic                     shift_valid;

    always_ff @(posedge i_clk, negedge i_resetn) begin 
        if (~i_resetn) begin 
            sample_counter <= '{default:0};
        end else begin 
            if (i_s_axis_tvalid) begin 
                if (sample_counter < COMBINE_FACTOR-1) begin 
                    sample_counter <= sample_counter + 1;
                end else begin 
                    sample_counter <= '{default:0};
                end 
            end else begin 
                sample_counter <= sample_counter;
            end 
        end 
    end 

    always_ff @(posedge i_clk) begin 
        d_sample_counter <= sample_counter;
    end 

    always_ff @(posedge i_clk) begin 
        d_s_axis_tvalid <= i_s_axis_tvalid;
    end 

    always_ff @(posedge i_clk, negedge i_resetn) begin 
        if (~i_resetn) begin 
            acc_value <= '{default:0};
        end else begin 
            if (i_s_axis_tvalid) begin 
                if (sample_counter == 0) begin 
                    acc_value <= i_s_axis_tdata;
                end else begin 
                    acc_value <= acc_value + i_s_axis_tdata;
                end  
            end else begin 
                acc_value <= acc_value;
            end 
        end 
    end


    always_ff @(posedge i_clk, negedge i_resetn) begin 
        if (~i_resetn) begin 
            shift_value <= '{default:0};
        end else begin 
            if (d_s_axis_tvalid) begin 
                if (sample_counter == 0) begin 
                    shift_value <= acc_value;
                end else begin 
                    shift_value <= shift_value;
                end 
            end else begin 
                shift_value <= shift_value;
            end 
        end 
    end 

    always_ff @(posedge i_clk, negedge i_resetn) begin 
        if (~i_resetn) begin 
            shift_valid <= 1'b0;
        end else begin 
            if (d_s_axis_tvalid) begin 
                if (d_sample_counter == 3) begin 
                    shift_valid <= 1'b1;
                end else begin 
                    shift_valid <= 1'b0;
                end 
            end else begin 
                shift_valid <= 1'b0;
            end 
        end 
    end
    

    always_ff @(posedge i_clk, negedge i_resetn) begin : o_m_axis_tdata_processing 
        if (~i_resetn) begin 
            o_m_axis_tdata <= '{default:0};
        end else begin 
            o_m_axis_tdata <= shift_value[(32+CF_WIDTH)-1:CF_WIDTH];
        end 
    end 


    always_ff @(posedge i_clk, negedge i_resetn) begin : o_m_axis_tvalid_processing 
        if (~i_resetn) begin 
            o_m_axis_tvalid <= 1'b0;
        end else begin 
            o_m_axis_tvalid <= shift_valid;
        end 
    end 

endmodule : fft_combiner
