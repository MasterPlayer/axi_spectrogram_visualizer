`timescale 1ps / 1ps


module tb_fft();


    logic        clk                      ;
    logic        reset                    ;
    logic [15:0] i_tdata_re = '{default:0};
    logic [15:0] i_tdata_im = '{default:0};
    logic        i_tvalid   = 1'b0        ;
    logic        o_tready                 ;
    logic [15:0] o_tdata_re               ;
    logic [15:0] o_tdata_im               ;
    logic [ 9:0] o_xk_index               ;
    logic        o_tvalid                 ;

    logic        allow_work     = 1'b0        ;
    logic [31:0] data_index     = '{default:0};
    logic        has_new_sample = 1'b0        ;



    initial begin 
        clk = 0;
        forever
        #5000 clk = ~clk;
    end 

    integer index = 0;

    always_ff @(posedge clk) begin 
        index <= index + 1;
    end 

    always_ff @(posedge clk) begin : reset_processing 
        if (index < 100) begin 
            reset <= 1'b1;
        end else begin 
            reset <= 1'b0;
        end 
    end 



    always_ff @(posedge clk) begin : allow_work_processing 
        if (index == 1000) begin 
            allow_work <= 1'b1;
        end else begin 
            allow_work <= allow_work;
        end 
    end 


    always_ff @(posedge clk) begin : data_index_processing 
        if (allow_work) begin 
            if (data_index < 4096) begin 
                data_index <= data_index + 1;
            end else begin 
                data_index <= '{default:0};
            end 
        end else begin 
            data_index <= '{default:0};
        end 
    end 


    always_ff @(posedge clk) begin : new_sample_processing 
        if (allow_work) begin 
            if (data_index == 0) begin 
                has_new_sample <= 1'b1;
            end else begin 
                has_new_sample <= 1'b0;
            end 
        end else begin 
            has_new_sample <= 1'b0;
        end 
    end 


    int fdr0;

    string line_read;

    initial begin
        // 1. Open the file in read mode ("r")
        fdr0 = $fopen("Z:/sine_signal_fixed_hex.hex", "r");
    end
        


    always_ff @(posedge clk) begin : s_axis_tdata_processing 
        if (has_new_sample) begin  
            // i_tdata_re <= i_tdata_re + 1;
            if ($fgets(line_read, fdr0)) begin
                i_tdata_re <= line_read.atohex();
            end

        end else begin 
            i_tdata_re <= i_tdata_re;
        end 
    end 

    always_comb i_tvalid = has_new_sample;


    fft_sv fft_sv_inst (
        .i_clk     (clk       ),
        .i_resetn  (~reset    ),
        .i_tdata_re(i_tdata_re),
        .i_tdata_im(i_tdata_im),
        .i_tvalid  (i_tvalid  ),
        .o_tready  (o_tready  ),
        .o_tdata_re(o_tdata_re),
        .o_tdata_im(o_tdata_im),
        .o_xk_index(o_xk_index),
        .o_tvalid  (o_tvalid  )
    );

    logic [31:0] magnitude         ;
    logic        magnitude_valid   ;
    logic [ 9:0] magnitude_xk_index;

    fft_magnitude_calculator #(
        .INPUT_WIDTH(16 ),
        .NFFT       (256)
    ) fft_magnitude_calculator_inst (
        .i_clk          (clk               ),
        .i_tdata_re     (o_tdata_re        ),
        .i_tdata_im     (o_tdata_im        ),
        .i_xk_index     (o_xk_index        ),
        .i_tvalid       (o_tvalid          ),
        .magnitude      (magnitude         ),
        .magnitude_valid(magnitude_valid   ),
        .o_xk_index     (magnitude_xk_index)
    );


    logic [31:0] magnitude_limited      ;
    logic        magnitude_limited_valid;

    fft_limiter #(
        .LIMIT_FACTOR(2  ),
        .FFT_POINTS  (128)
    ) fft_limiter_inst (
        .i_clk          (clk                    ),
        .i_resetn       (~reset                 ),
        .i_s_axis_tdata (magnitude              ),
        .i_s_axis_tvalid(magnitude_valid        ),
        .o_m_axis_tdata (magnitude_limited      ),
        .o_m_axis_tvalid(magnitude_limited_valid)
    );


    logic [31:0] amplitude      ;
    logic        amplitude_valid;


    // fft_combiner #(.COMBINE_FACTOR(4)) fft_combiner_inst (
    //     .i_clk          (clk                    ),
    //     .i_resetn       (~reset                 ),
    //     .i_s_axis_tdata (magnitude_limited      ),
    //     .i_s_axis_tvalid(magnitude_limited_valid),
    //     .o_m_axis_tdata (amplitude              ),
    //     .o_m_axis_tvalid(amplitude_valid        )
    // );

    logic [31:0] decoded_value      ;
    logic        decoded_value_valid;

    amplitude_decoder amplitude_decoder_inst (
        .i_clk    (clk                    ),
        .i_resetn (~reset                 ),
        .acc_data (magnitude_limited      ),
        .acc_valid(magnitude_limited_valid),
        .amp_data (decoded_value          ),
        .amp_valid(decoded_value_valid    )
    );

    logic [7:0] address_former_data ;
    logic [8:0] address_former_addr ;
    logic       address_former_valid;

    // address_former address_former_inst (
    //     .i_clk          (clk                 ),
    //     .i_resetn       (~reset              ),
    //     .i_s_axis_tdata (decoded_value       ),
    //     .i_s_axis_tvalid(decoded_value_valid ),
    //     .o_data         (address_former_data ),
    //     .o_addr         (address_former_addr ),
    //     .o_valid        (address_former_valid)
    // );

    // logic [7:0] o_data_0 ;
    // logic [6:0] o_addr_0 ;
    // logic       o_valid_0;
    // logic [7:0] o_data_1 ;
    // logic [6:0] o_addr_1 ;
    // logic       o_valid_1;
    // logic [7:0] o_data_2 ;
    // logic [6:0] o_addr_2 ;
    // logic       o_valid_2;
    // logic [7:0] o_data_3 ;
    // logic [6:0] o_addr_3 ;
    // logic       o_valid_3;

    // fft_address_former_segment #(.ADDRESS_LIMIT(128)) fft_address_former_segment_inst (
    //     .i_clk        (clk                ),
    //     .i_resetn     (~reset             ),
    //     //
    //     .s_axis_tdata (decoded_value      ),
    //     .s_axis_tvalid(decoded_value_valid),
    //     //
    //     .o_data_0     (o_data_0           ),
    //     .o_addr_0     (o_addr_0           ),
    //     .o_valid_0    (o_valid_0          ),
    //     //
    //     .o_data_1     (o_data_1           ),
    //     .o_addr_1     (o_addr_1           ),
    //     .o_valid_1    (o_valid_1          ),
    //     //
    //     .o_data_2     (o_data_2           ),
    //     .o_addr_2     (o_addr_2           ),
    //     .o_valid_2    (o_valid_2          ),
    //     //
    //     .o_data_3     (o_data_3           ),
    //     .o_addr_3     (o_addr_3           ),
    //     .o_valid_3    (o_valid_3          )
    // );


    logic [ 3:0] m_axi_awid    ;
    logic [31:0] m_axi_awaddr  ;
    logic [ 7:0] m_axi_awlen   ;
    logic [ 2:0] m_axi_awsize  ;
    logic [ 1:0] m_axi_awburst ;
    logic        m_axi_awlock  ;
    logic [ 3:0] m_axi_awcache ;
    logic [ 2:0] m_axi_awprot  ;
    logic [ 3:0] m_axi_awqos   ;
    logic [ 3:0] m_axi_awregion;
    logic        m_axi_awvalid ;
    logic        m_axi_awready ;
    logic [31:0] m_axi_wdata   ;
    logic [ 3:0] m_axi_wstrb   ;
    logic        m_axi_wlast   ;
    logic        m_axi_wvalid  ;
    logic        m_axi_wready  ;
    logic [ 3:0] m_axi_bid     ;
    logic [ 1:0] m_axi_bresp   ;
    logic        m_axi_bvalid  ;
    logic        m_axi_bready  ;


    axi_fft_memory_remapper #(
        .S_AXI_UCODE_ID_WIDTH  (4 ),
        .S_AXI_UCODE_ADDR_WIDTH(32),
        .S_AXI_UCODE_DATA_WIDTH(32)
    ) axi_fft_memory_remapper_inst (
        .i_clk         (clk                ),
        .i_resetn      (~reset             ),
        //
        .s_axis_tdata  (decoded_value      ),
        .s_axis_tvalid (decoded_value_valid),
        // .i_data        (address_former_data ),
        // .i_addr        (address_former_addr ),
        // .i_valid       (address_former_valid),
        //
        .M_AXI_AWID    (m_axi_awid         ),
        .M_AXI_AWADDR  (m_axi_awaddr       ),
        .M_AXI_AWLEN   (m_axi_awlen        ),
        .M_AXI_AWSIZE  (m_axi_awsize       ),
        .M_AXI_AWBURST (m_axi_awburst      ),
        .M_AXI_AWLOCK  (m_axi_awlock       ),
        .M_AXI_AWCACHE (m_axi_awcache      ),
        .M_AXI_AWPROT  (m_axi_awprot       ),
        .M_AXI_AWQOS   (m_axi_awqos        ),
        .M_AXI_AWREGION(m_axi_awregion     ),
        .M_AXI_AWVALID (m_axi_awvalid      ),
        .M_AXI_AWREADY (m_axi_awready      ),
        .M_AXI_WDATA   (m_axi_wdata        ),
        .M_AXI_WSTRB   (m_axi_wstrb        ),
        .M_AXI_WLAST   (m_axi_wlast        ),
        .M_AXI_WVALID  (m_axi_wvalid       ),
        .M_AXI_WREADY  (m_axi_wready       ),
        .M_AXI_BID     (m_axi_bid          ),
        .M_AXI_BRESP   (m_axi_bresp        ),
        .M_AXI_BVALID  (m_axi_bvalid       ),
        .M_AXI_BREADY  (m_axi_bready       )
    );

    blk_mem_gen_0 blk_mem_gen_0_inst (
        .rsta_busy    (             ),
        .rstb_busy    (             ),
        .s_aclk       (clk          ),
        .s_aresetn    (~reset       ),
        .s_axi_awid   (m_axi_awid   ),
        .s_axi_awaddr (m_axi_awaddr ),
        .s_axi_awlen  (m_axi_awlen  ),
        .s_axi_awsize (m_axi_awsize ),
        .s_axi_awburst(m_axi_awburst),
        .s_axi_awvalid(m_axi_awvalid),
        .s_axi_awready(m_axi_awready),
        .s_axi_wdata  (m_axi_wdata  ),
        .s_axi_wstrb  (m_axi_wstrb  ),
        .s_axi_wlast  (m_axi_wlast  ),
        .s_axi_wvalid (m_axi_wvalid ),
        .s_axi_wready (m_axi_wready ),
        .s_axi_bid    (m_axi_bid    ),
        .s_axi_bresp  (m_axi_bresp  ),
        .s_axi_bvalid (m_axi_bvalid ),
        .s_axi_bready (m_axi_bready ),
        .s_axi_arid   (4'h0         ),
        .s_axi_araddr (32'h00000000 ),
        .s_axi_arlen  (8'h00        ),
        .s_axi_arsize (3'b010       ),
        .s_axi_arburst(2'b00        ),
        .s_axi_arvalid(1'b0         ),
        .s_axi_arready(             ),
        .s_axi_rid    (             ),
        .s_axi_rdata  (             ),
        .s_axi_rresp  (             ),
        .s_axi_rlast  (             ),
        .s_axi_rvalid (             ),
        .s_axi_rready (1'b0         )
    );


        logic fd_in;

        int    fdr_sample ;
        int    fdw_sample ;
        string sample_line;

        initial begin
            // 1. Open the file in read mode ("r")
            fdr_sample = $fopen("Z:/sine_signal_fixed.txt", "r");
            fdw_sample = $fopen("Z:/sine_signal_fixed_hex.hex", "w");

            // 2. Loop through the file line by line
            while (!$feof(fdr_sample)) begin
                // $fgets returns the number of characters read, or 0 on error/EOF
                if ($fgets(sample_line, fdr_sample)) begin
                    // Process the line (e.g., print it)

                    // $displayh("%h", line.atoi());
                    $fwrite(fdw_sample,"%h\n", sample_line.atoi());
                end
            end

            // 3. Close the file handle
            $fclose(fdr_sample);
            $fclose(fdw_sample);
        end


        // xfft_0 fft (
        //     .aclk                       (clk                     ),   // input wire aclk
        //     .s_axis_config_tdata        (16'h0000                ),   // input wire [15 : 0] s_axis_config_tdata
        //     .s_axis_config_tvalid       (1'b0                    ),   // input wire s_axis_config_tvalid
        //     .s_axis_config_tready       (                        ),   // output wire s_axis_config_tready
        //     .s_axis_data_tdata          ({i_tdata_im, i_tdata_re}),   // input wire [31 : 0] s_axis_data_tdata
        //     .s_axis_data_tvalid         (i_tvalid                ),   // input wire s_axis_data_tvalid
        //     .s_axis_data_tready         (                        ),   // output wire s_axis_data_tready
        //     .s_axis_data_tlast          (1'b0                    ),   // input wire s_axis_data_tlast
        //     .m_axis_data_tdata          (                        ),   // output wire [31 : 0] m_axis_data_tdata
        //     .m_axis_data_tvalid         (                        ),   // output wire m_axis_data_tvalid
        //     .m_axis_data_tready         (1'b1                    ),   // input wire m_axis_data_tready
        //     .m_axis_data_tlast          (                        ),   // output wire m_axis_data_tlast
        //     .event_frame_started        (                        ),   // output wire event_frame_started
        //     .event_tlast_unexpected     (                        ),   // output wire event_tlast_unexpected
        //     .event_tlast_missing        (                        ),   // output wire event_tlast_missing
        //     .event_status_channel_halt  (                        ),   // output wire event_status_channel_halt
        //     .event_data_in_channel_halt (                        ),   // output wire event_data_in_channel_halt
        //     .event_data_out_channel_halt(                        )    // output wire event_data_out_channel_halt
        // );



    endmodule
