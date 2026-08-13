

module fft_memory_bank_wrapper #(
    parameter DATA_WIDTH      = 16,
    parameter DATA_DEPTH_LOG2 = 5
) (
    input  logic                       i_clk             ,
    // Control
    input  logic                       i_bank_select     ,
    input  logic                       i_load_unload     ,
    input  logic [DATA_DEPTH_LOG2-1:0] i_addr_load       ,
    input  logic [DATA_DEPTH_LOG2-1:0] i_addr_load_bitrev,
    // Input/Output
    input  logic [     DATA_WIDTH-1:0] i_re              ,
    input  logic [     DATA_WIDTH-1:0] i_im              ,
    output logic [     DATA_WIDTH-1:0] o_re              ,
    output logic [     DATA_WIDTH-1:0] o_im              ,
    output logic [DATA_DEPTH_LOG2-1:0] o_index           ,
    // R/W
    input  logic                       i_wren_1          ,
    input  logic [DATA_DEPTH_LOG2-1:0] i_wr_addr_x       ,
    input  logic [DATA_DEPTH_LOG2-1:0] i_rd_addr_x       ,
    
    input  logic                       i_wren_2          ,
    input  logic [DATA_DEPTH_LOG2-1:0] i_wr_addr_y       ,
    input  logic [DATA_DEPTH_LOG2-1:0] i_rd_addr_y       ,
    // BFU
    input  logic [     DATA_WIDTH-1:0] i_xr              ,
    input  logic [     DATA_WIDTH-1:0] i_xi              ,
    input  logic [     DATA_WIDTH-1:0] i_yr              ,
    input  logic [     DATA_WIDTH-1:0] i_yi              ,
    output logic [     DATA_WIDTH-1:0] o_xr              ,
    output logic [     DATA_WIDTH-1:0] o_xi              ,
    output logic [     DATA_WIDTH-1:0] o_yr              ,
    output logic [     DATA_WIDTH-1:0] o_yi
);

    // Bank 1
    logic [DATA_DEPTH_LOG2-1:0] r_addr_1_x     ;
    logic [DATA_DEPTH_LOG2-1:0] r_addr_1_y     ;
    logic [     DATA_WIDTH-1:0] r_data_in_1_xr ;
    logic [     DATA_WIDTH-1:0] r_data_in_1_xi ;
    logic [     DATA_WIDTH-1:0] r_data_in_1_yr ;
    logic [     DATA_WIDTH-1:0] r_data_in_1_yi ;
    logic [     DATA_WIDTH-1:0] w_data_out_1_xr;
    logic [     DATA_WIDTH-1:0] w_data_out_1_xi;
    logic [     DATA_WIDTH-1:0] w_data_out_1_yr;
    logic [     DATA_WIDTH-1:0] w_data_out_1_yi;
    logic                       r_wren_1_x     ;
    logic                       r_wren_1_y     ;
    // Bank 2
    logic [DATA_DEPTH_LOG2-1:0] r_addr_2_x     ;
    logic [DATA_DEPTH_LOG2-1:0] r_addr_2_y     ;
    logic [     DATA_WIDTH-1:0] r_data_in_2_xr ;
    logic [     DATA_WIDTH-1:0] r_data_in_2_xi ;
    logic [     DATA_WIDTH-1:0] r_data_in_2_yr ;
    logic [     DATA_WIDTH-1:0] r_data_in_2_yi ;
    logic [     DATA_WIDTH-1:0] w_data_out_2_xr;
    logic [     DATA_WIDTH-1:0] w_data_out_2_xi;
    logic [     DATA_WIDTH-1:0] w_data_out_2_yr;
    logic [     DATA_WIDTH-1:0] w_data_out_2_yi;
    logic                       r_wren_2_x     ;
    logic                       r_wren_2_y     ;
    // Output logic
    logic                            r_last_write_mem_1     = 1'b0;
    logic [1:0]                      r_load_unload_pipeline       ;
    logic [1:0][DATA_DEPTH_LOG2-1:0] r_index_out_pipeline         ;

    // =================================================================

    always_ff @(posedge i_clk) begin :p_addr_mux
            if (i_bank_select) begin 
                r_addr_1_x <= i_rd_addr_x;
                r_addr_1_y <= i_rd_addr_y;
                r_addr_2_x <= i_wr_addr_x;
                r_addr_2_y <= i_wr_addr_y;
            end else begin 
                r_addr_1_x <= i_wr_addr_x;
                r_addr_1_y <= i_wr_addr_y;
                r_addr_2_x <= i_rd_addr_x;
                r_addr_2_y <= i_rd_addr_y;
            end

            if (i_load_unload) begin 
                if (r_last_write_mem_1) begin 
                    r_addr_2_x <= i_addr_load_bitrev;
                    r_addr_1_x <= i_addr_load;
                end else begin 
                    r_addr_1_x <= i_addr_load_bitrev;
                    r_addr_2_x <= i_addr_load;
                end
            end

    end 

    // =================================================================

    always_ff @(posedge i_clk) begin :p_data_in_mux

            r_data_in_1_xr <= i_xr;
            r_data_in_1_xi <= i_xi;
            r_data_in_1_yr <= i_yr;
            r_data_in_1_yi <= i_yi;
            r_data_in_2_xr <= i_xr;
            r_data_in_2_xi <= i_xi;
            r_data_in_2_yr <= i_yr;
            r_data_in_2_yi <= i_yi;

            if (i_load_unload) begin 
                if (r_last_write_mem_1) begin 
                    r_data_in_2_xr <= i_re;
                    r_data_in_2_xi <= i_im;
                    r_data_in_2_yr <= '{default:0};
                    r_data_in_2_yi <= '{default:0};
                end else begin 
                    r_data_in_1_xr <= i_re;
                    r_data_in_1_xi <= i_im;
                    r_data_in_1_yr <= '{default:0};
                    r_data_in_1_yi <= '{default:0};
                end
            end

    end 

    // =================================================================

    always_ff @(posedge i_clk) begin :p_data_out_mux

            if (i_bank_select) begin 
                o_xr <= w_data_out_1_xr;
                o_xi <= w_data_out_1_xi;
                o_yr <= w_data_out_1_yr;
                o_yi <= w_data_out_1_yi;
            end else begin
                o_xr <= w_data_out_2_xr;
                o_xi <= w_data_out_2_xi;
                o_yr <= w_data_out_2_yr;
                o_yi <= w_data_out_2_yi;
            end

            if (r_load_unload_pipeline[1]) begin 
                o_index <= r_index_out_pipeline[1];
                if (r_last_write_mem_1) begin 
                    o_re <= w_data_out_1_xr;
                    o_im <= w_data_out_1_xi;
                end else begin 
                    o_re <= w_data_out_2_xr;
                    o_im <= w_data_out_2_xi;
                end
            end

    end

    // =================================================================

    always_ff @(posedge i_clk) begin :p_data_wren_mux
        r_wren_1_x <= i_wren_1;
        r_wren_1_y <= i_wren_1;
        r_wren_2_x <= i_wren_2;
        r_wren_2_y <= i_wren_2;

        if (i_load_unload) begin 
            if (r_last_write_mem_1) begin 
                r_wren_2_x <= i_load_unload;
            end else begin 
                r_wren_1_x <= i_load_unload;
            end
        end
    end 

    // =================================================================

    always_ff @(posedge i_clk) begin : p_track_last_write
        if (r_wren_1_y) begin 
            r_last_write_mem_1 <= 1'b1;
        end else begin  
            if (r_wren_2_y) begin 
                r_last_write_mem_1 <= 1'b0;
            end else begin 
                r_last_write_mem_1 <= r_last_write_mem_1;
            end
        end 
    end 

    // =================================================================

    always_ff @(posedge i_clk) begin : p_pipeline
        r_load_unload_pipeline <= {r_load_unload_pipeline[0], i_load_unload};
        r_index_out_pipeline   <= {r_index_out_pipeline[0], i_addr_load};
    end 


    fft_memory_bank #(
        .DATA_WIDTH     (DATA_WIDTH     ),
        .DATA_DEPTH_LOG2(DATA_DEPTH_LOG2)
    ) fft_memory_bank_0_inst (
        .i_clk      (i_clk          ),
        // Real X/Y
        .i_wren_re_a(r_wren_1_x     ),
        .i_wren_re_b(r_wren_1_y     ),
        .i_addr_re_a(r_addr_1_x     ),
        .i_addr_re_b(r_addr_1_y     ),
        .i_data_re_a(r_data_in_1_xr ),
        .i_data_re_b(r_data_in_1_yr ),
        .o_data_re_a(w_data_out_1_xr),
        .o_data_re_b(w_data_out_1_yr),
        // imag x/y
        .i_wren_im_a(r_wren_1_x     ),
        .i_wren_im_b(r_wren_1_y     ),
        .i_addr_im_a(r_addr_1_x     ),
        .i_addr_im_b(r_addr_1_y     ),
        .i_data_im_a(r_data_in_1_xi ),
        .i_data_im_b(r_data_in_1_yi ),
        .o_data_im_a(w_data_out_1_xi),
        .o_data_im_b(w_data_out_1_yi)
    );

    fft_memory_bank #(
        .DATA_WIDTH     (DATA_WIDTH     ),
        .DATA_DEPTH_LOG2(DATA_DEPTH_LOG2)
    ) fft_memory_bank_1_inst (
        .i_clk      (i_clk          ),
        // Real X/Y
        .i_wren_re_a(r_wren_2_x     ),
        .i_wren_re_b(r_wren_2_y     ),
        .i_addr_re_a(r_addr_2_x     ),
        .i_addr_re_b(r_addr_2_y     ),
        .i_data_re_a(r_data_in_2_xr ),
        .i_data_re_b(r_data_in_2_yr ),
        .o_data_re_a(w_data_out_2_xr),
        .o_data_re_b(w_data_out_2_yr),
        // imag x/y
        .i_wren_im_a(r_wren_2_x     ),
        .i_wren_im_b(r_wren_2_y     ),
        .i_addr_im_a(r_addr_2_x     ),
        .i_addr_im_b(r_addr_2_y     ),
        .i_data_im_a(r_data_in_2_xi ),
        .i_data_im_b(r_data_in_2_yi ),
        .o_data_im_a(w_data_out_2_xi),
        .o_data_im_b(w_data_out_2_yi)
    );

endmodule : fft_memory_bank_wrapper