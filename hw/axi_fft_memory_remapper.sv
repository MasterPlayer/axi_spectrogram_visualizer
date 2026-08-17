`timescale 1ns / 1ps



module axi_fft_memory_remapper #(
    parameter S_AXI_UCODE_ID_WIDTH   = 4 ,
    parameter S_AXI_UCODE_ADDR_WIDTH = 32,
    parameter S_AXI_UCODE_DATA_WIDTH = 32
) (
    input  logic                                  i_clk          ,
    input  logic                                  i_resetn       ,
    //
    input  logic [                          31:0] s_axis_tdata ,
    input  logic                                  s_axis_tvalid,
    //
    output logic [      S_AXI_UCODE_ID_WIDTH-1:0] M_AXI_AWID     ,
    output logic [    S_AXI_UCODE_ADDR_WIDTH-1:0] M_AXI_AWADDR   ,
    output logic [                           7:0] M_AXI_AWLEN    ,
    output logic [                           2:0] M_AXI_AWSIZE   ,
    output logic [                           1:0] M_AXI_AWBURST  ,
    output logic                                  M_AXI_AWLOCK   ,
    output logic [                           3:0] M_AXI_AWCACHE  ,
    output logic [                           2:0] M_AXI_AWPROT   ,
    output logic [                           3:0] M_AXI_AWQOS    ,
    output logic [                           3:0] M_AXI_AWREGION ,
    output logic                                  M_AXI_AWVALID  ,
    input  logic                                  M_AXI_AWREADY  ,
    output logic [    S_AXI_UCODE_DATA_WIDTH-1:0] M_AXI_WDATA    ,
    output logic [(S_AXI_UCODE_DATA_WIDTH/8)-1:0] M_AXI_WSTRB    ,
    output logic                                  M_AXI_WLAST    ,
    output logic                                  M_AXI_WVALID   ,
    input  logic                                  M_AXI_WREADY   ,
    input  logic [      S_AXI_UCODE_ID_WIDTH-1:0] M_AXI_BID      ,
    input  logic [                           1:0] M_AXI_BRESP    ,
    input  logic                                  M_AXI_BVALID   ,
    output logic                                  M_AXI_BREADY
);


    logic [6:0] addra;

    always_ff @(posedge i_clk, negedge i_resetn) begin 
        if (~i_resetn) begin 
            addra <= '{default:0};
        end else begin 
            if (s_axis_tvalid) begin 
                addra <= addra + 1;
            end else begin 
                addra <= addra;
            end 
        end 
    end


    logic [31:0] doutb_0;
    logic [31:0] doutb_1;
    logic [31:0] doutb_2;
    logic [31:0] doutb_3;

    logic [ 4:0] addrb;

    xpm_memory_tdpram #(
        .ADDR_WIDTH_A           (7              ),
        .ADDR_WIDTH_B           (5              ),
        .AUTO_SLEEP_TIME        (0              ),
        .BYTE_WRITE_WIDTH_A     (8              ),
        .BYTE_WRITE_WIDTH_B     (8              ),
        .CASCADE_HEIGHT         (0              ),
        .CLOCKING_MODE          ("common_clock" ),
        .ECC_BIT_RANGE          ("7:0"          ),
        .ECC_MODE               ("no_ecc"       ),
        .ECC_TYPE               ("none"         ),
        .IGNORE_INIT_SYNTH      (0              ),
        .MEMORY_INIT_FILE       ("none"         ),
        .MEMORY_INIT_PARAM      ("0"            ),
        .MEMORY_OPTIMIZATION    ("true"         ),
        .MEMORY_PRIMITIVE       ("auto"         ),
        .MEMORY_SIZE            (1024           ),
        .MESSAGE_CONTROL        (0              ),
        .RAM_DECOMP             ("auto"         ),
        .READ_DATA_WIDTH_A      (8              ),
        .READ_DATA_WIDTH_B      (32             ),
        .READ_LATENCY_A         (1              ),
        .READ_LATENCY_B         (1              ),
        .READ_RESET_VALUE_A     ("0"            ),
        .READ_RESET_VALUE_B     ("0"            ),
        .RST_MODE_A             ("SYNC"         ),
        .RST_MODE_B             ("SYNC"         ),
        .SIM_ASSERT_CHK         (0              ),
        .USE_EMBEDDED_CONSTRAINT(0              ),
        .USE_MEM_INIT           (1              ),
        .USE_MEM_INIT_MMI       (0              ),
        .WAKEUP_TIME            ("disable_sleep"),
        .WRITE_DATA_WIDTH_A     (8              ),
        .WRITE_DATA_WIDTH_B     (32             ),
        .WRITE_MODE_A           ("no_change"    ),
        .WRITE_MODE_B           ("no_change"    ),
        .WRITE_PROTECT          (1              )
    ) xpm_memory_tdpram_0_inst (
        .clka          (i_clk              ),
        .rsta          (~i_resetn          ),
        .addra         (addra              ),
        .dina          (s_axis_tdata[31:24]),
        .wea           (s_axis_tvalid      ),
        .douta         (                   ),
        .clkb          (i_clk              ),
        .rstb          (~i_resetn          ),
        .addrb         (addrb              ),
        .doutb         (doutb_0            ),
        .dinb          (32'h00000000       ),
        .dbiterra      (                   ),
        .dbiterrb      (                   ),
        .sbiterra      (                   ),
        .sbiterrb      (                   ),
        .ena           (1'b1               ),
        .enb           (1'b1               ),
        .injectdbiterra(1'b0               ),
        .injectdbiterrb(1'b0               ),
        .injectsbiterra(1'b0               ),
        .injectsbiterrb(1'b0               ),
        .regcea        (1'b1               ),
        .regceb        (1'b1               ),
        .sleep         (1'b0               ),
        .web           (4'h0               )
    );

    xpm_memory_tdpram #(
        .ADDR_WIDTH_A           (7              ),
        .ADDR_WIDTH_B           (5              ),
        .AUTO_SLEEP_TIME        (0              ),
        .BYTE_WRITE_WIDTH_A     (8              ),
        .BYTE_WRITE_WIDTH_B     (8              ),
        .CASCADE_HEIGHT         (0              ),
        .CLOCKING_MODE          ("common_clock" ),
        .ECC_BIT_RANGE          ("7:0"          ),
        .ECC_MODE               ("no_ecc"       ),
        .ECC_TYPE               ("none"         ),
        .IGNORE_INIT_SYNTH      (0              ),
        .MEMORY_INIT_FILE       ("none"         ),
        .MEMORY_INIT_PARAM      ("0"            ),
        .MEMORY_OPTIMIZATION    ("true"         ),
        .MEMORY_PRIMITIVE       ("auto"         ),
        .MEMORY_SIZE            (1024           ),
        .MESSAGE_CONTROL        (0              ),
        .RAM_DECOMP             ("auto"         ),
        .READ_DATA_WIDTH_A      (8              ),
        .READ_DATA_WIDTH_B      (32             ),
        .READ_LATENCY_A         (1              ),
        .READ_LATENCY_B         (1              ),
        .READ_RESET_VALUE_A     ("0"            ),
        .READ_RESET_VALUE_B     ("0"            ),
        .RST_MODE_A             ("SYNC"         ),
        .RST_MODE_B             ("SYNC"         ),
        .SIM_ASSERT_CHK         (0              ),
        .USE_EMBEDDED_CONSTRAINT(0              ),
        .USE_MEM_INIT           (1              ),
        .USE_MEM_INIT_MMI       (0              ),
        .WAKEUP_TIME            ("disable_sleep"),
        .WRITE_DATA_WIDTH_A     (8              ),
        .WRITE_DATA_WIDTH_B     (32             ),
        .WRITE_MODE_A           ("no_change"    ),
        .WRITE_MODE_B           ("no_change"    ),
        .WRITE_PROTECT          (1              )
    ) xpm_memory_tdpram_1_inst (
        .clka          (i_clk              ),
        .rsta          (~i_resetn          ),
        .addra         (addra              ),
        .dina          (s_axis_tdata[23:16]),
        .wea           (s_axis_tvalid      ),
        .douta         (                   ),
        .clkb          (i_clk              ),
        .rstb          (~i_resetn          ),
        .addrb         (addrb              ),
        .doutb         (doutb_1            ),
        .dinb          (32'h00000000       ),
        .dbiterra      (                   ),
        .dbiterrb      (                   ),
        .sbiterra      (                   ),
        .sbiterrb      (                   ),
        .ena           (1'b1               ),
        .enb           (1'b1               ),
        .injectdbiterra(1'b0               ),
        .injectdbiterrb(1'b0               ),
        .injectsbiterra(1'b0               ),
        .injectsbiterrb(1'b0               ),
        .regcea        (1'b1               ),
        .regceb        (1'b1               ),
        .sleep         (1'b0               ),
        .web           (4'h0               )
    );

    xpm_memory_tdpram #(
        .ADDR_WIDTH_A           (7              ),
        .ADDR_WIDTH_B           (5              ),
        .AUTO_SLEEP_TIME        (0              ),
        .BYTE_WRITE_WIDTH_A     (8              ),
        .BYTE_WRITE_WIDTH_B     (8              ),
        .CASCADE_HEIGHT         (0              ),
        .CLOCKING_MODE          ("common_clock" ),
        .ECC_BIT_RANGE          ("7:0"          ),
        .ECC_MODE               ("no_ecc"       ),
        .ECC_TYPE               ("none"         ),
        .IGNORE_INIT_SYNTH      (0              ),
        .MEMORY_INIT_FILE       ("none"         ),
        .MEMORY_INIT_PARAM      ("0"            ),
        .MEMORY_OPTIMIZATION    ("true"         ),
        .MEMORY_PRIMITIVE       ("auto"         ),
        .MEMORY_SIZE            (1024           ),
        .MESSAGE_CONTROL        (0              ),
        .RAM_DECOMP             ("auto"         ),
        .READ_DATA_WIDTH_A      (8              ),
        .READ_DATA_WIDTH_B      (32             ),
        .READ_LATENCY_A         (1              ),
        .READ_LATENCY_B         (1              ),
        .READ_RESET_VALUE_A     ("0"            ),
        .READ_RESET_VALUE_B     ("0"            ),
        .RST_MODE_A             ("SYNC"         ),
        .RST_MODE_B             ("SYNC"         ),
        .SIM_ASSERT_CHK         (0              ),
        .USE_EMBEDDED_CONSTRAINT(0              ),
        .USE_MEM_INIT           (1              ),
        .USE_MEM_INIT_MMI       (0              ),
        .WAKEUP_TIME            ("disable_sleep"),
        .WRITE_DATA_WIDTH_A     (8              ),
        .WRITE_DATA_WIDTH_B     (32             ),
        .WRITE_MODE_A           ("no_change"    ),
        .WRITE_MODE_B           ("no_change"    ),
        .WRITE_PROTECT          (1              )
    ) xpm_memory_tdpram_2_inst (
        .clka          (i_clk             ),
        .rsta          (~i_resetn         ),
        .addra         (addra             ),
        .dina          (s_axis_tdata[15:8]),
        .wea           (s_axis_tvalid     ),
        .douta         (                  ),
        .clkb          (i_clk             ),
        .rstb          (~i_resetn         ),
        .addrb         (addrb             ),
        .doutb         (doutb_2           ),
        .dinb          (32'h00000000      ),
        .dbiterra      (                  ),
        .dbiterrb      (                  ),
        .sbiterra      (                  ),
        .sbiterrb      (                  ),
        .ena           (1'b1              ),
        .enb           (1'b1              ),
        .injectdbiterra(1'b0              ),
        .injectdbiterrb(1'b0              ),
        .injectsbiterra(1'b0              ),
        .injectsbiterrb(1'b0              ),
        .regcea        (1'b1              ),
        .regceb        (1'b1              ),
        .sleep         (1'b0              ),
        .web           (4'h0              )
    );

    xpm_memory_tdpram #(
        .ADDR_WIDTH_A           (7              ),
        .ADDR_WIDTH_B           (5              ),
        .AUTO_SLEEP_TIME        (0              ),
        .BYTE_WRITE_WIDTH_A     (8              ),
        .BYTE_WRITE_WIDTH_B     (8              ),
        .CASCADE_HEIGHT         (0              ),
        .CLOCKING_MODE          ("common_clock" ),
        .ECC_BIT_RANGE          ("7:0"          ),
        .ECC_MODE               ("no_ecc"       ),
        .ECC_TYPE               ("none"         ),
        .IGNORE_INIT_SYNTH      (0              ),
        .MEMORY_INIT_FILE       ("none"         ),
        .MEMORY_INIT_PARAM      ("0"            ),
        .MEMORY_OPTIMIZATION    ("true"         ),
        .MEMORY_PRIMITIVE       ("auto"         ),
        .MEMORY_SIZE            (1024           ),
        .MESSAGE_CONTROL        (0              ),
        .RAM_DECOMP             ("auto"         ),
        .READ_DATA_WIDTH_A      (8              ),
        .READ_DATA_WIDTH_B      (32             ),
        .READ_LATENCY_A         (1              ),
        .READ_LATENCY_B         (1              ),
        .READ_RESET_VALUE_A     ("0"            ),
        .READ_RESET_VALUE_B     ("0"            ),
        .RST_MODE_A             ("SYNC"         ),
        .RST_MODE_B             ("SYNC"         ),
        .SIM_ASSERT_CHK         (0              ),
        .USE_EMBEDDED_CONSTRAINT(0              ),
        .USE_MEM_INIT           (1              ),
        .USE_MEM_INIT_MMI       (0              ),
        .WAKEUP_TIME            ("disable_sleep"),
        .WRITE_DATA_WIDTH_A     (8              ),
        .WRITE_DATA_WIDTH_B     (32             ),
        .WRITE_MODE_A           ("no_change"    ),
        .WRITE_MODE_B           ("no_change"    ),
        .WRITE_PROTECT          (1              )
    ) xpm_memory_tdpram_3_inst (
        .clka          (i_clk            ),
        .rsta          (~i_resetn        ),
        .addra         (addra            ),
        .dina          (s_axis_tdata[7:0]),
        .wea           (s_axis_tvalid    ),
        .douta         (                 ),
        .clkb          (i_clk            ),
        .rstb          (~i_resetn        ),
        .addrb         (addrb            ),
        .doutb         (doutb_3          ),
        .dinb          (32'h00000000     ),
        .dbiterra      (                 ),
        .dbiterrb      (                 ),
        .sbiterra      (                 ),
        .sbiterrb      (                 ),
        .ena           (1'b1             ),
        .enb           (1'b1             ),
        .injectdbiterra(1'b0             ),
        .injectdbiterrb(1'b0             ),
        .injectsbiterra(1'b0             ),
        .injectsbiterrb(1'b0             ),
        .regcea        (1'b1             ),
        .regceb        (1'b1             ),
        .sleep         (1'b0             ),
        .web           (4'h0             )
    );

    logic need_update;

    typedef enum {
        AWAIT_DATA_ST, 
        ESTABLISH_ADDRESS_ST,
        AXI_TX_DATA_ST, 
        AXI_TX_RESPONSE_ST
    } axi_fsm;

    axi_fsm axi_current_state = AWAIT_DATA_ST; 

    logic [1:0] segment_address;

    always_ff @(posedge i_clk, negedge i_resetn) begin 
        if (~i_resetn) begin 
            need_update <= 1'b0;
        end else begin 
            case (axi_current_state)
                AWAIT_DATA_ST : 
                    if (s_axis_tvalid) begin 
                        if (addra == 7'h7F) begin 
                            need_update <= 1'b1;
                        end else begin 
                            need_update <= 1'b0;
                        end 
                    end else begin 
                        need_update <= 1'b0;
                    end 

                default : 
                    need_update <= 1'b0;
            endcase // axi_current_state
        end 
    end

    always_ff @(posedge i_clk, negedge i_resetn) begin : addrb_processing 
        if (~i_resetn) begin 
            addrb <= '{default:0};
        end else begin 

            case (axi_current_state) 
                ESTABLISH_ADDRESS_ST : 
                    if (M_AXI_AWVALID & M_AXI_AWREADY) begin 
                        addrb <= addrb + 1;
                    end else begin 
                        addrb <= addrb;
                    end 

                AXI_TX_DATA_ST : 
                    addrb <= addrb + 1;

                default : 
                    addrb <= '{default:0};

            endcase // axi_current_state
        end 
    end
 
    always_ff @(posedge i_clk, negedge i_resetn) begin : segment_address_processing 
        if (~i_resetn) begin 
            segment_address <= '{default:0};
        end else begin 
            case (axi_current_state) 
                
                AXI_TX_RESPONSE_ST : 
                    if (M_AXI_BVALID & M_AXI_BREADY) begin 
                        segment_address <= segment_address + 1;
                    end else begin 
                        segment_address <= segment_address;
                    end 

                default : 
                    segment_address <= segment_address;

            endcase // axi_current_state
        end 
    end 

    always_ff @(posedge i_clk, negedge i_resetn) begin : axi_current_state_processing
        if (~i_resetn) begin 
            axi_current_state <= AWAIT_DATA_ST;
        end else begin 

            case (axi_current_state)
                AWAIT_DATA_ST : 
                    if (need_update) begin 
                        axi_current_state <= ESTABLISH_ADDRESS_ST; 
                    end else begin 
                        axi_current_state <= axi_current_state;
                    end 

                ESTABLISH_ADDRESS_ST : 
                    if (M_AXI_AWVALID & M_AXI_AWREADY) begin 
                        axi_current_state <= AXI_TX_DATA_ST;
                    end else begin 
                        axi_current_state <= axi_current_state;
                    end 

                AXI_TX_DATA_ST : 
                    if (M_AXI_WVALID & M_AXI_WREADY & M_AXI_WLAST) begin 
                        axi_current_state <= AXI_TX_RESPONSE_ST;
                    end else begin 
                        axi_current_state <= axi_current_state;
                    end  

                AXI_TX_RESPONSE_ST : 
                    if (M_AXI_BVALID & M_AXI_BREADY) begin 
                        if (segment_address == 2'b11) begin 
                            axi_current_state <= AWAIT_DATA_ST;
                        end else begin
                            axi_current_state <= ESTABLISH_ADDRESS_ST;
                        end 
                    end else begin 
                        axi_current_state <= axi_current_state;
                    end 

                default : 
                    axi_current_state <= axi_current_state;

            endcase // current_state
        end 
    end


    always_ff @(posedge i_clk, negedge i_resetn) begin : M_AXI_AWADDR_processing 
        if (~i_resetn) begin 
            M_AXI_AWADDR <= '{default:0};
        end else begin
            case (axi_current_state)
                AWAIT_DATA_ST : 
                    M_AXI_AWADDR <= 32'h40000000;

                AXI_TX_RESPONSE_ST : 
                    if (M_AXI_BVALID & M_AXI_BREADY) begin 
                        M_AXI_AWADDR <= M_AXI_AWADDR + 32'h00000080;
                    end else begin 
                        M_AXI_AWADDR <= M_AXI_AWADDR;
                    end 

                default : 
                    M_AXI_AWADDR <= M_AXI_AWADDR;

            endcase // axi_current_state
        end 
    end


    always_ff @(posedge i_clk, negedge i_resetn) begin : M_AXI_AWID_processing 
        if (~i_resetn) begin 
            M_AXI_AWID <= '{default:0};
        end else begin 

            case (axi_current_state) 
                AXI_TX_RESPONSE_ST : 
                    if (M_AXI_BVALID & M_AXI_BREADY) begin 
                        M_AXI_AWID <= M_AXI_AWID + 1;
                    end else begin 
                        M_AXI_AWID <= M_AXI_AWID;
                    end 

                default : 
                    M_AXI_AWID <= M_AXI_AWID;
            endcase

        end 
    end 

    always_comb M_AXI_AWSIZE   = 3'b010;
    always_comb M_AXI_AWLEN    = 8'h1F;
    always_comb M_AXI_AWBURST  = 2'b01;
    always_comb M_AXI_AWLOCK   = 1'b0;
    always_comb M_AXI_AWCACHE  = 4'h0;
    always_comb M_AXI_AWPROT   = 3'b000;
    always_comb M_AXI_AWQOS    = 4'h0;
    always_comb M_AXI_AWREGION = 4'h0;

    always_ff @(posedge i_clk, negedge i_resetn) begin : M_AXI_AWVALID_processing
        if (~i_resetn) begin
            M_AXI_AWVALID <= 1'b0;
        end else begin

            case (axi_current_state)

                ESTABLISH_ADDRESS_ST :
                    if (M_AXI_AWVALID & M_AXI_AWREADY) begin
                        M_AXI_AWVALID <= 1'b0;
                    end else begin
                        M_AXI_AWVALID <= 1'b1;
                    end

                default : M_AXI_AWVALID <= 1'b0;
            endcase // axi_current_state

        end
    end 

    always_ff @(posedge i_clk, negedge i_resetn) begin : M_AXI_WLAST_processing
        if (~i_resetn) begin 
            M_AXI_WLAST <= 1'b0;
        end else begin 

            case (axi_current_state)
                AXI_TX_DATA_ST : 
                    if (addrb == 5'h1f) begin 
                        M_AXI_WLAST <= 1'b1;
                    end else begin 
                        M_AXI_WLAST <= 1'b0;
                    end 
                

                default : 
                    M_AXI_WLAST <= 1'b0;

            endcase // axi_current_state
        end 
    end 


    always_comb M_AXI_WDATA = (segment_address == 2'b00) ? doutb_0 : 
                              (segment_address == 2'b01) ? doutb_1 : 
                              (segment_address == 2'b10) ? doutb_2 : 
                                                           doutb_3;

    always_comb M_AXI_WVALID = (axi_current_state == AXI_TX_DATA_ST | M_AXI_AWVALID) ? 1'b1 : 1'b0;
    always_comb M_AXI_WSTRB = 4'hF;
    always_comb M_AXI_BREADY = 1'b1;//(axi_current_state == AXI_TX_RESPONSE_ST) ? 1'b1 : 1'b0;

endmodule
