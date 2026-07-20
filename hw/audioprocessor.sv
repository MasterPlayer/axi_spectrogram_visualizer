`timescale 1ns / 1ps



module audioprocessor #(
    parameter integer AXIS_DATA_WIDTH = 20, 
    parameter integer FILTER_COUNT = 24
) (
    input logic                       i_clk        ,
    input logic                       i_resetn     ,
    //
    input logic [AXIS_DATA_WIDTH-1:0] s_axis_tdata ,
    input logic                       s_axis_tvalid
);

    parameter ADDRESS_WIDTH = 13                                ;
    parameter MEMORY_SIZE   = (2**ADDRESS_WIDTH)*AXIS_DATA_WIDTH;

    logic [  ADDRESS_WIDTH-1:0] addra;
    logic [AXIS_DATA_WIDTH-1:0] dina ;
    logic                       ena  ;
    logic                       wea  ;

    logic [  ADDRESS_WIDTH-1:0] addrb;
    logic [AXIS_DATA_WIDTH-1:0] doutb;
    logic                       enb  ;

    logic [ADDRESS_WIDTH-1:0] data_counter             ;
    logic                     has_data_counter_exceeded;

    logic [AXIS_DATA_WIDTH-1:0] memory_data ;
    logic                       memory_valid;

    logic [ADDRESS_WIDTH-1:0] memory_data_counter;

    logic [$clog2(FILTER_COUNT)-1:0] filter_cnt;

    logic [ 7:0] fir_coeff_addr   ;
    logic [31:0] fir_coeff_data   ;
    logic        fir_coeff_valid  ;
    logic [31:0] fir_s_axis_tdata ;
    logic        fir_s_axis_tvalid;
    logic        fir_s_axis_tready;
    logic [31:0] fir_m_axis_tdata ;
    logic        fir_m_axis_tvalid;
    logic        fir_m_axis_tready;

    typedef enum {
        IDLE_ST,
        LOAD_COEFFS_ST,
        PROCESS_DATA_ST,
        STUB_ST

    } fsm;

    fsm current_state = IDLE_ST;

    always_ff @(posedge i_clk, negedge i_resetn) begin : ena_processing 
        if (~i_resetn) begin 
            ena <= 1'b0;
        end else begin 
            ena <= 1'b1;
        end 
    end 

    always_ff @(posedge i_clk) begin : dina_processing
        dina <= s_axis_tdata;
    end 

    always_ff @(posedge i_clk, negedge i_resetn) begin : wea_processing
        if (~i_resetn) begin
            wea <= 1'b0;
        end else begin
            wea <= s_axis_tvalid;
        end
    end 

    always_ff @(posedge i_clk, negedge i_resetn) begin : addra_processing 
        if (~i_resetn) begin 
            addra <= '{default:0};
        end else begin 
            if (wea) begin 
                addra <= addra + 1;
            end else begin 
                addra <= addra;
            end 
        end 
    end

    always_ff @(posedge i_clk, negedge i_resetn) begin : data_counter_processing 
        if (~i_resetn) begin 
            data_counter <= '{default:0};
        end else begin 

            if (wea) begin 
                if (data_counter == 4095) begin 
                    data_counter <= '{default:0};
                end else begin 
                    data_counter <= data_counter + 1;
                end 
            end else begin 
                data_counter <= data_counter;
            end 

        end 
    end 

    always_ff @(posedge i_clk, negedge i_resetn) begin : has_data_counter_exceeded_processing 
        if (~i_resetn) begin
            has_data_counter_exceeded <= 1'b0;
        end else begin 
            if (wea) begin 
                if (data_counter == 4095) begin 
                    has_data_counter_exceeded <= 1'b1;
                end else begin 
                    has_data_counter_exceeded <= 1'b0;
                end 
            end else begin 
                has_data_counter_exceeded <= 1'b0;
            end 
        end 
    end 


    always_ff @(posedge i_clk, negedge i_resetn) begin : current_state_processing 
        if (~i_resetn) begin 
            current_state <= IDLE_ST;
        end else begin 
            case (current_state)
                IDLE_ST :   
                    if (has_data_counter_exceeded) begin 
                        current_state <= PROCESS_DATA_ST;
                    end else begin 
                        current_state <= current_state;
                    end 

                PROCESS_DATA_ST : 
                 // TODO : ADD condition
                    if (memory_data_counter == 4095) begin 
                        current_state <= STUB_ST;
                    end else begin 
                        current_state <= current_state;
                    end 

                default : 
                    current_state <= current_state;
            endcase // current_state
        end 
    end 


    xpm_memory_sdpram #(
        .ADDR_WIDTH_A           (ADDRESS_WIDTH  ),   // DECIMAL
        .ADDR_WIDTH_B           (ADDRESS_WIDTH  ),   // DECIMAL
        .AUTO_SLEEP_TIME        (0              ),   // DECIMAL
        .BYTE_WRITE_WIDTH_A     (AXIS_DATA_WIDTH),   // DECIMAL
        .CASCADE_HEIGHT         (0              ),   // DECIMAL
        .CLOCKING_MODE          ("common_clock" ),   // String
        .ECC_BIT_RANGE          ("7:0"          ),   // String
        .ECC_MODE               ("no_ecc"       ),   // String
        .ECC_TYPE               ("none"         ),   // String
        .IGNORE_INIT_SYNTH      (0              ),   // DECIMAL
        .MEMORY_INIT_FILE       ("none"         ),   // String
        .MEMORY_INIT_PARAM      ("0"            ),   // String
        .MEMORY_OPTIMIZATION    ("true"         ),   // String
        .MEMORY_PRIMITIVE       ("auto"         ),   // String
        .MEMORY_SIZE            (MEMORY_SIZE    ),   // DECIMAL
        .MESSAGE_CONTROL        (0              ),   // DECIMAL
        .RAM_DECOMP             ("auto"         ),   // String
        .READ_DATA_WIDTH_B      (AXIS_DATA_WIDTH),   // DECIMAL
        .READ_LATENCY_B         (1              ),   // DECIMAL
        .READ_RESET_VALUE_B     ("0"            ),   // String
        .RST_MODE_A             ("SYNC"         ),   // String
        .RST_MODE_B             ("SYNC"         ),   // String
        .SIM_ASSERT_CHK         (0              ),   // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
        .USE_EMBEDDED_CONSTRAINT(0              ),   // DECIMAL
        .USE_MEM_INIT           (1              ),   // DECIMAL
        .USE_MEM_INIT_MMI       (0              ),   // DECIMAL
        .WAKEUP_TIME            ("disable_sleep"),   // String
        .WRITE_DATA_WIDTH_A     (AXIS_DATA_WIDTH),   // DECIMAL
        .WRITE_MODE_B           ("no_change"    ),   // String
        .WRITE_PROTECT          (1              )    // DECIMAL
    ) xpm_memory_sdpram_inst (
        .clka          (i_clk    ),
        .addra         (addra    ),
        .dina          (dina     ),
        .ena           (ena      ),
        .wea           (wea      ),
        .clkb          (i_clk    ),
        .addrb         (addrb    ),
        .doutb         (doutb    ),
        .enb           (enb      ),
        .dbiterrb      (         ),
        .sbiterrb      (         ),
        .injectdbiterra(1'b0     ),
        .injectsbiterra(1'b0     ),
        .regceb        (1'b1     ),
        .rstb          (~i_resetn),
        .sleep         (1'b0     )
    );




    always_ff @(posedge i_clk, negedge i_resetn) begin : addrb_processing 
        if (~i_resetn) begin 
            addrb <= '{default:0};
        end else begin 
            case (current_state) 
                PROCESS_DATA_ST : 
                    if (fir_s_axis_tready & fir_s_axis_tvalid) begin 
                        addrb <= addrb + 1;
                    end else begin 
                        addrb <= addrb;
                    end 

                default : 
                    addrb <= '{default:0};

            endcase // current_state
        end 
    end 

    always_ff @(posedge i_clk, negedge i_resetn) begin : enb_processing 
        if (~i_resetn) begin 
            enb <= 1'b0;
        end else begin 
            case (current_state)
                PROCESS_DATA_ST : 
                    enb <= 1'b1;

                default : 
                    enb <= 1'b0;
            endcase // current_state
        end 
    end

    always_ff @(posedge i_clk, negedge i_resetn) begin : memory_valid_processing 
        if (~i_resetn) begin 
            memory_valid <= 1'b0;
        end else begin 

            case (current_state)
                PROCESS_DATA_ST : 
                    memory_valid <= 1'b1;

                default : 
                    memory_valid <= 1'b0;

            endcase // current_state
        end 
    end 

    always_comb memory_data = doutb;

    always_ff @(posedge i_clk, negedge i_resetn) begin : memory_data_counter_processing 
        case (current_state)
            PROCESS_DATA_ST : 
                // TODO : ADD condition
                if (fir_s_axis_tready & fir_s_axis_tvalid) begin 
                    memory_data_counter <= memory_data_counter + 1;
                end else begin 
                    memory_data_counter <= memory_data_counter;
                end 

            default : 
                memory_data_counter <= '{default:0};

        endcase // current_state
    end 

    always_comb fir_s_axis_tdata = memory_data;
    always_comb fir_s_axis_tvalid = memory_valid;


    axis_fir_filter #(
        .N_BYTES         (4),
        .COEFF_ADDR_WIDTH(8)
    ) axis_fir_filter_inst (
        .CLK          (i_clk            ),
        .RESET        (~i_resetn        ),
        .COEFF_ADDR   (fir_coeff_addr   ),
        .COEFF_DATA   (fir_coeff_data   ),
        .COEFF_VALID  (fir_coeff_valid  ),
        .S_AXIS_TDATA (fir_s_axis_tdata ),
        .S_AXIS_TVALID(fir_s_axis_tvalid),
        .S_AXIS_TREADY(fir_s_axis_tready),
        .M_AXIS_TDATA (fir_m_axis_tdata ),
        .M_AXIS_TVALID(fir_m_axis_tvalid),
        .M_AXIS_TREADY(fir_m_axis_tready)
    );

    always_ff @(posedge i_clk, negedge i_resetn) begin : fir_m_axis_tready_processing 
        if (~i_resetn) begin 
            fir_m_axis_tready <= 1'b0;
        end else begin 
            fir_m_axis_tready <= 1'b1;
        end 
    end 


endmodule
