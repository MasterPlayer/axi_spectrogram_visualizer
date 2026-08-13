


module fft_control (
    input logic i_clk, 
    input logic i_resetn,

    input logic i_tvalid, 
);


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
                        if (input_buffer_address < G_NFFT-1) begin 
                            current_state <= current_state;
                        end else begin 
                            current_state <= LOAD_UNLOAD_ST;
                        end 
                    end else begin 
                        current_state <= current_state;
                    end 

                LOAD_UNLOAD_ST : 
                    if (input_buffer_address == G_NFFT-1) begin 
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
                        if (input_buffer_address < G_NFFT-1) begin 
                            input_buffer_address <= input_buffer_address + 1;
                        end else begin 
                            input_buffer_address <= '{default:0};
                        end 
                    end else begin 
                        input_buffer_address <= input_buffer_address;
                    end 

                LOAD_UNLOAD_ST : 
                    if (input_buffer_address < G_NFFT-1) begin 
                        input_buffer_address <= input_buffer_address + 1;
                    end else begin 
                        input_buffer_address <= '{default:0};
                    end 

                default : 
                    input_buffer_address <= '{default:0};
            endcase // current_state

        end 
    end 

endmodule 