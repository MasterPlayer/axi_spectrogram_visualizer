

module fft_address_generator #(parameter NFFT = 5) (
    input  logic                      i_clk          ,
    input  logic                      i_resetn       ,
    // Control
    input  logic                      i_start        ,
    output logic                      o_done         ,
    // Memory Control
    output logic                      o_wr_en        ,
    // Output Address
    output logic [($clog2(NFFT)-1):0] o_raddr_mem_a  ,
    output logic [($clog2(NFFT)-1):0] o_raddr_mem_b  ,
    output logic [($clog2(NFFT)-2):0] o_raddr_twiddle
);

    parameter NFFT_CLOG2 = $clog2(NFFT);
    parameter HOLD_COUNT = 9;

    typedef enum {
        IDLE_ST , 
        CLEAR_ST, 
        RUN_ST, 
        DONE_ST
    } fsm;

    fsm current_state;

    logic [1:0] clear_shreg;

    logic [(NFFT_CLOG2-1):0] addr; 
    logic [(NFFT_CLOG2-1):0] d_addr; 

    logic [(NFFT_CLOG2-1):0] addr_x2   ;
    logic [(NFFT_CLOG2-1):0] addr_x2_p1;

    logic [(NFFT_CLOG2-1):0] level;

    logic clear; 
    logic hold;

    logic clear_reg; 
    logic hold_reg;

    logic [$clog2(HOLD_COUNT)+1:0] hold_counter;

    logic [NFFT_CLOG2-1:0] tw_bitmask;
    
    always_ff @(posedge i_clk, negedge i_resetn) begin : current_state_processing 
        if (~i_resetn) begin 
            current_state <= IDLE_ST;
        end else begin 

            case (current_state)
                IDLE_ST :
                    if (i_start) begin 
                        current_state <= CLEAR_ST;
                    end else begin 
                        current_state <= current_state;
                    end 

                CLEAR_ST :
                    if (clear_shreg[1]) begin 
                        current_state <= RUN_ST;
                    end else begin 
                        current_state <= current_state;
                    end 

                RUN_ST : 
                    if ((addr[NFFT_CLOG2-1]) & (level == (NFFT_CLOG2-1))) begin 
                        current_state <= DONE_ST;
                    end else begin 
                        current_state <= current_state;
                    end 

                DONE_ST : 
                    if (i_start) begin 
                        current_state <= CLEAR_ST;
                    end else begin 
                        current_state <= current_state;
                    end 

                default : 
                    current_state <= current_state;

            endcase // current_state
        end 
    end 


    always_ff @(posedge i_clk, negedge i_resetn) begin : clear_shreg_processing 
        if (~i_resetn) begin 
            clear_shreg <= '{default:0};
        end else begin 
            case (current_state)
                CLEAR_ST : 
                    if (clear_shreg[1]) begin 
                        clear_shreg <= '{default:0};
                    end else begin 
                        clear_shreg <= {clear_shreg[0], 1'b1};
                    end 

                default : 
                    clear_shreg <= '{default:0};

            endcase // current_state
        end 
    end 


    always_comb clear = (current_state == RUN_ST) ? 1'b0 : 1'b1;


    always_ff @(posedge i_clk) begin : clear_reg_processing 
        clear_reg <= clear;
    end 


    always_ff @(posedge i_clk, negedge i_resetn) begin : addr_processing 
        if (~i_resetn) begin 
            addr <= '{default:0};
        end else begin 
            if (clear | hold) begin 
                addr <= '{default:0};
            end else begin 
                if (addr[NFFT_CLOG2-1]) begin 
                    addr <= '{default:0};
                end else begin 
                    addr <= addr + 1;
                end 
            end 
        end 
    end 


    always_ff @(posedge i_clk, negedge i_resetn) begin : d_addr_processing 
        if (~i_resetn) begin 
            d_addr <= '{default:0};
        end else begin 
            d_addr <= addr;
        end 
    end  


    always_ff @(posedge i_clk, negedge i_resetn) begin : level_processing 
        if (~i_resetn) begin 
            level <= '{default:0};
        end else begin 
            if (clear) begin 
                level <= '{default:0};
            end else begin 
                if (addr[NFFT_CLOG2-1]) begin 
                    if (level < (NFFT_CLOG2-1)) begin 
                        level <= level + 1;
                    end else begin 
                        level <= '{default:0};
                    end 
                end else begin 
                    level <= level;
                end 
            end 
        end 
    end 


    always_ff @(posedge i_clk, negedge i_resetn) begin : hold_counter_processing 
        if (~i_resetn) begin 
            hold_counter <= '{default:0};
        end else begin 
            if (addr[NFFT_CLOG2-1]) begin 
                hold_counter <= HOLD_COUNT;
            end else begin  
                if (~hold_counter[$clog2(HOLD_COUNT)+1]) begin 
                    hold_counter <= hold_counter - 1;
                end else begin 
                    hold_counter <= hold_counter;
                end 
            end 
        end 
    end 


    always_comb hold = ~hold_counter[$clog2(HOLD_COUNT)+1];


    always_ff @(posedge i_clk) begin : hold_reg_processing 
        hold_reg <= hold;
    end 


    always_ff @(posedge i_clk, negedge i_resetn) begin : o_wr_en_processing 
        if (~i_resetn) begin 
            o_wr_en <= 1'b0;
        end else begin 
            o_wr_en <= (~(hold_reg | clear_reg)) & (~(hold | clear));
        end 
    end 


    always_ff @(posedge i_clk, negedge i_resetn) begin : addr_x2_processing 
        if (~i_resetn) begin 
            addr_x2 <= '{default:0};
        end else begin 
            addr_x2 <= {addr[NFFT_CLOG2-1:0], 1'b0};
        end 
    end 


    always_ff @(posedge i_clk, negedge i_resetn) begin : addr_x2_p1_processing 
        if (~i_resetn) begin 
            addr_x2_p1 <= '{default:0};
        end else begin 
            addr_x2_p1 <= {addr[NFFT_CLOG2-1:0], 1'b0} + 1;
        end 
    end 


    always_ff @(posedge i_clk, negedge i_resetn) begin : o_raddr_mem_a_processing 
        if (~i_resetn) begin 
            o_raddr_mem_a <= '{default:0};
        end else begin 
            if (clear) begin 
                o_raddr_mem_a <= '{default:0};
            end else begin 
                o_raddr_mem_a <= (addr_x2 << level) | (addr_x2 >> ((NFFT_CLOG2)-level));
            end 
        end 
    end 

    always_ff @(posedge i_clk, negedge i_resetn) begin : o_raddr_mem_b_processing 
        if (~i_resetn) begin 
            o_raddr_mem_b <= '{default:0};
        end else begin 
            if (clear) begin 
                o_raddr_mem_b <= '{default:0};
            end else begin 
                o_raddr_mem_b <= (addr_x2_p1 << level) | (addr_x2_p1 >> ((NFFT_CLOG2)-level));
            end 
        end 
    end 

    always_ff @(posedge i_clk, negedge i_resetn) begin : tw_bitmask_processing 
        if (~i_resetn) begin 
            tw_bitmask <= '{default:0};
        end else begin 
            if (clear) begin 
                tw_bitmask <= '{default:0};
            end else begin 
                tw_bitmask[(NFFT_CLOG2-1)-level] <= 1'b1;
            end 
        end 
    end

    always_ff @(posedge i_clk, negedge i_resetn) begin : o_raddr_twiddle_processing 
        if (~i_resetn) begin 
            o_raddr_twiddle <= '{default:0};
        end else begin 
            if (clear) begin 
                o_raddr_twiddle <= '{default:0};
            end else begin 
                o_raddr_twiddle <= tw_bitmask & d_addr;
            end 
        end 
    end 


    always_ff @(posedge i_clk, negedge i_resetn) begin : o_done_processing 
        if (~i_resetn) begin 
            o_done <= 1'b0;
        end else begin 

            case (current_state)
                RUN_ST : 
                    if ((addr[NFFT_CLOG2-1]) & (level == (NFFT_CLOG2-1))) begin 
                        o_done <= 1'b1;
                    end else begin 
                        o_done <= 1'b0;
                    end 

                default : 
                    o_done <= 1'b0;

            endcase // current_state
        end 
    end


endmodule