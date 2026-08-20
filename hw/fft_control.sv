



module fft_control #(
    parameter NFFT          = 256,
    parameter C_BFU_LATENCY = 13
) (
    input  logic                    i_clk               ,
    input  logic                    i_resetn            ,
    input  logic                    i_tvalid            ,
    input  logic                    agu_done            ,
    input  logic                    agu_wren           ,
    //
    output logic [$clog2(NFFT)-1:0] input_buffer_address,
    output logic                    input_buffer_tvalid ,
    output logic                    mem_select
);

    logic [4:0] hold_counter;

    typedef enum {
        IDLE_ST , 
        FILL_BUFFER_ST, 
        LOAD_UNLOAD_ST, 
        RUN_ST, 
        HOLD_ST
    } fsm;

    fsm current_state;

    logic d_agu_wren;

    always_ff @(posedge i_clk) begin : d_agu_wren_processing
        d_agu_wren <= agu_wren;
    end 


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
                if (~d_agu_wren & agu_wren) begin 
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


endmodule : fft_control