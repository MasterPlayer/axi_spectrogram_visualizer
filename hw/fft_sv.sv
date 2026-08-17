

module fft_sv #(
    parameter NFFT       = 256,
    parameter DATA_WIDTH = 16 ,
    parameter QFORMAT    = 15
) (
    input  logic                      i_clk     ,
    input  logic                      i_resetn  ,
    // Input
    input  logic [  (DATA_WIDTH-1):0] i_tdata_re,
    input  logic [  (DATA_WIDTH-1):0] i_tdata_im,
    input  logic                      i_tvalid  ,
    output logic                      o_tready  ,
    // Output
    output logic [  (DATA_WIDTH-1):0] o_tdata_re,
    output logic [  (DATA_WIDTH-1):0] o_tdata_im,
    output logic [($clog2(NFFT)-1):0] o_xk_index,
    output logic                      o_tvalid
);

    parameter C_BFU_LATENCY  = 13;

    logic [$clog2(NFFT)-1:0] input_buffer_address;
    logic [(DATA_WIDTH-1):0] input_buffer_dout_re;
    logic [(DATA_WIDTH-1):0] input_buffer_dout_im;

    logic input_buffer_tvalid;

    logic [  DATA_WIDTH-1:0] br_tdata_re       ;
    logic [  DATA_WIDTH-1:0] br_tdata_im       ;
    logic [$clog2(NFFT)-1:0] br_taddr_reversed ;
    logic [$clog2(NFFT)-1:0] br_taddr_normal   ;
    logic [             3:0] br_tvalid_pipeline;

    logic                        agu_start        ;
    logic                        agu_done         ;
    logic                        agu_wr_en        ;

    logic [C_BFU_LATENCY-1:0][($clog2(NFFT)-1):0] agu_raddr_mem_a_pipeline;
    logic [C_BFU_LATENCY-1:0][($clog2(NFFT)-1):0] agu_raddr_mem_b_pipeline;

    logic [C_BFU_LATENCY-1:0][($clog2(NFFT)-2):0] agu_raddr_twiddle_pipeline;

    logic [4:0] hold_counter;

    logic mem_select;

    logic [DATA_WIDTH-1:0] twiddle_rom_dout_real;
    logic [DATA_WIDTH-1:0] twiddle_rom_dout_imag;

    logic [DATA_WIDTH-1:0] stored_xr    ;
    logic [DATA_WIDTH-1:0] stored_xi    ;
    logic [DATA_WIDTH-1:0] stored_yr    ;
    logic [DATA_WIDTH-1:0] stored_yi    ;
    logic [DATA_WIDTH-1:0] calculated_xr;
    logic [DATA_WIDTH-1:0] calculated_xi;
    logic [DATA_WIDTH-1:0] calculated_yr;
    logic [DATA_WIDTH-1:0] calculated_yi;

    logic [C_BFU_LATENCY-1:0] agu_wr_en_pipeline;


    always_comb o_tvalid = br_tvalid_pipeline[3];


    typedef enum {
        IDLE_ST , 
        FILL_BUFFER_ST, 
        LOAD_UNLOAD_ST, 
        RUN_ST, 
        HOLD_ST
    } fsm;

    fsm current_state;


    always_ff @(posedge i_clk, negedge i_resetn) begin : current_state_processing 
        if (~i_resetn) begin 
            current_state <= IDLE_ST;
        end else begin 
            case (current_state)
                IDLE_ST : 
                    current_state <= FILL_BUFFER_ST;

                FILL_BUFFER_ST : 
                    if (i_tvalid) begin 
                        if (input_buffer_address < NFFT-1) begin 
                            current_state <= current_state;
                        end else begin 
                            current_state <= LOAD_UNLOAD_ST;
                        end 
                    end else begin 
                        current_state <= current_state;
                    end 

                LOAD_UNLOAD_ST : 
                    if (input_buffer_address == NFFT-1) begin 
                        current_state <= RUN_ST;
                    end else begin 
                        current_state <= current_state;
                    end 

                RUN_ST : 
                    if (agu_done) begin 
                        current_state <= HOLD_ST;
                    end else begin 
                        current_state <= current_state;
                    end 

                HOLD_ST :
                    if (hold_counter[4]) begin 
                        current_state <= FILL_BUFFER_ST;
                    end else begin 
                        current_state <= current_state; 
                    end 

                default : current_state <= current_state;               
            endcase // current_state
        end 
    end


    always_ff @(posedge i_clk, negedge i_resetn) begin : input_buffer_address_processing 
        if (~i_resetn) begin 
            input_buffer_address <= '{default:0};
        end else begin 

            case (current_state)

                FILL_BUFFER_ST : 
                    if (i_tvalid) begin 
                        if (input_buffer_address < NFFT-1) begin 
                            input_buffer_address <= input_buffer_address + 1;
                        end else begin 
                            input_buffer_address <= '{default:0};
                        end 
                    end else begin 
                        input_buffer_address <= input_buffer_address;
                    end 

                LOAD_UNLOAD_ST : 
                    if (input_buffer_address < NFFT-1) begin 
                        input_buffer_address <= input_buffer_address + 1;
                    end else begin 
                        input_buffer_address <= '{default:0};
                    end 

                default : 
                    input_buffer_address <= '{default:0};
            endcase // current_state

        end 
    end 


    always_ff @(posedge i_clk, negedge i_resetn) begin : hold_counter_processing 
        if (~i_resetn) begin 
            hold_counter <= '{default:0};
        end else begin 
            case (current_state)
                HOLD_ST : 
                    hold_counter <= hold_counter + 1;

                default : 
                    hold_counter <= '{default:0};
            endcase // current_state

        end 
    end 


    always_ff @(posedge i_clk) begin : mem_select_processing 
        case (current_state)

            IDLE_ST : 
                mem_select <= 1'b0;

            RUN_ST : 
                if (~agu_wr_en_pipeline[1] & agu_wr_en_pipeline[0]) begin 
                    mem_select <= ~mem_select;
                end else begin 
                    mem_select <= mem_select;
                end 

            HOLD_ST : 
                if (hold_counter[4]) begin 
                    mem_select <= ~mem_select;
                end else begin 
                    mem_select <= mem_select;
                end 

            default : 
                mem_select <= mem_select;

        endcase // current_state
    end 


    fft_input_buffer #(
        .RAM_WIDTH((DATA_WIDTH*2)),
        .RAM_DEPTH(NFFT          )
    ) fft_input_buffer_inst (
        .i_clk (i_clk                                       ),
        .i_addr(input_buffer_address                        ),
        .i_din ({i_tdata_im, i_tdata_re}                    ),
        .i_we  (i_tvalid                                    ),
        .o_dout({input_buffer_dout_im, input_buffer_dout_re})
    );


    always_ff @(posedge i_clk, negedge i_resetn) begin : input_buffer_tvalid_processing 
        if (~i_resetn) begin 
            input_buffer_tvalid <= 1'b0;
        end else begin 

            case (current_state)
                LOAD_UNLOAD_ST : 
                    input_buffer_tvalid <= 1'b1;

                default : 
                    input_buffer_tvalid <= 1'b0;

            endcase // current_state
        end 
    end 


    fft_bit_reversal_unit #(
        .DATA_WIDTH     (DATA_WIDTH  ),
        .DATA_DEPTH_LOG2($clog2(NFFT))
    ) fft_bit_reversal_unit_inst (
        .i_clk           (i_clk                ),
        .i_resetn        (i_resetn             ),
        // Data Input
        .i_tdata_re      (input_buffer_dout_re ),
        .i_tdata_im      (input_buffer_dout_im ),
        .i_tvalid        (input_buffer_tvalid  ),
        // Data Output
        .o_tdata_re      (br_tdata_re          ),
        .o_tdata_im      (br_tdata_im          ),
        .o_taddr_reversed(br_taddr_reversed    ),
        .o_taddr_normal  (br_taddr_normal      ),
        .o_tvalid        (br_tvalid_pipeline[0])
    );

    always_ff @(posedge i_clk) begin : br_tvalid_pipeline_processing 
        br_tvalid_pipeline[3:1] <= br_tvalid_pipeline[2:0];
    end 

    always_comb agu_start = (br_taddr_normal == NFFT-1) ? br_tvalid_pipeline[0] : 1'b0;


    fft_address_generator #(
        .NFFT(NFFT)) 
    fft_address_generator_inst (
        .i_clk          (i_clk                        ),
        .i_resetn       (i_resetn                     ),
        // Control
        .i_start        (agu_start                    ),
        .o_done         (agu_done                     ),
        // Memory Control
        .o_wr_en        (agu_wr_en_pipeline[0]        ),
        // Output Address
        .o_raddr_mem_a  (agu_raddr_mem_a_pipeline[0]  ),
        .o_raddr_mem_b  (agu_raddr_mem_b_pipeline[0]  ),
        .o_raddr_twiddle(agu_raddr_twiddle_pipeline[0])
    );


    always_ff @(posedge i_clk) begin 
        agu_raddr_mem_a_pipeline[C_BFU_LATENCY-1:1] <= {agu_raddr_mem_a_pipeline[C_BFU_LATENCY-2:0]};
    end 

    always_ff @(posedge i_clk) begin 
        agu_raddr_mem_b_pipeline[C_BFU_LATENCY-1:1] <= {agu_raddr_mem_b_pipeline[C_BFU_LATENCY-2:0]};
    end 

    always_ff @(posedge i_clk) begin : agu_wr_en_pipeline_processing 
        agu_wr_en_pipeline[C_BFU_LATENCY-1:1] <= agu_wr_en_pipeline[C_BFU_LATENCY-2:0];
    end 

    always_ff @(posedge i_clk) begin : agu_raddr_twiddle_pipeline_processing 
        agu_raddr_twiddle_pipeline[C_BFU_LATENCY-1:1] <= agu_raddr_twiddle_pipeline[C_BFU_LATENCY-2:0];
    end 

    fft_twiddle_rom_wrapper #(
        .DATA_WIDTH(DATA_WIDTH),
        .DATA_DEPTH((NFFT/2)  )
    ) fft_twiddle_rom_wrapper_inst (
        .clk   (i_clk                        ),
        .i_addr(agu_raddr_twiddle_pipeline[3]),
        .o_tr  (twiddle_rom_dout_real        ),
        .o_ti  (twiddle_rom_dout_imag        )
    );


    fft_memory_bank_wrapper #(
        .DATA_WIDTH     (DATA_WIDTH  ),
        .DATA_DEPTH_LOG2($clog2(NFFT))
    ) fft_memory_bank_wrapper_inst (
        .i_clk             (i_clk                                            ),
        // Control
        .i_bank_select     (mem_select                                       ),
        .i_load_unload     (br_tvalid_pipeline[0]                            ),
        .i_addr_load       (br_taddr_normal                                  ),
        .i_addr_load_bitrev(br_taddr_reversed                                ),
        // Input/Output
        .i_re              (br_tdata_re                                      ),
        .i_im              (br_tdata_im                                      ),
        .o_re              (o_tdata_re                                       ),
        .o_im              (o_tdata_im                                       ),
        .o_index           (o_xk_index                                       ),
        // R/W
        .i_wren_1          (agu_wr_en_pipeline[C_BFU_LATENCY-1] & ~mem_select),
        .i_wr_addr_x       (agu_raddr_mem_a_pipeline[(C_BFU_LATENCY-1)]      ),
        .i_rd_addr_x       (agu_raddr_mem_a_pipeline[1]                      ),
        .i_wren_2          (agu_wr_en_pipeline[C_BFU_LATENCY-1] & mem_select ),
        .i_wr_addr_y       (agu_raddr_mem_b_pipeline[(C_BFU_LATENCY-1)]      ),
        .i_rd_addr_y       (agu_raddr_mem_b_pipeline[1]                      ),
        // BFU
        .i_xr              (calculated_xr                                    ),
        .i_xi              (calculated_xi                                    ),
        .i_yr              (calculated_yr                                    ),
        .i_yi              (calculated_yi                                    ),
        .o_xr              (stored_xr                                        ),
        .o_xi              (stored_xi                                        ),
        .o_yr              (stored_yr                                        ),
        .o_yi              (stored_yi                                        )
    );


    fft_radix_2 #(
        .DATA_WIDTH(DATA_WIDTH),
        .QFORMAT   (QFORMAT   )
    ) fft_radix_2_inst (
        .clk (i_clk                ),
        // Input A
        .i_ar(stored_xr            ),
        .i_ai(stored_xi            ),
        // Input B
        .i_br(stored_yr            ),
        .i_bi(stored_yi            ),
        // Input TW
        .i_tr(twiddle_rom_dout_real),
        .i_ti(twiddle_rom_dout_imag),
        // Output A
        .o_xr(calculated_xr        ),
        .o_xi(calculated_xi        ),
        // Output B
        .o_yr(calculated_yr        ),
        .o_yi(calculated_yi        )
    );




endmodule : fft_sv