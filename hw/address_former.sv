

module address_former (
    input  logic        i_clk          ,
    input  logic        i_resetn       ,
    input  logic [31:0] i_s_axis_tdata ,
    input  logic        i_s_axis_tvalid,
    output logic [ 7:0] o_data         ,
    output logic [ 8:0] o_addr         ,
    output logic        o_valid
);

    typedef enum {
        IDLE_ST, 
        ADDRESS_FORMING_ST
    } fsm;

    fsm current_state = IDLE_ST;


    always_ff @(posedge i_clk, negedge i_resetn) begin 
        if (~i_resetn) begin 
            current_state <= IDLE_ST;
        end else begin 

            case (current_state)
                IDLE_ST : 
                    if (i_s_axis_tvalid) begin 
                        current_state <= ADDRESS_FORMING_ST;
                    end else begin 
                        current_state <= current_state;
                    end 

                ADDRESS_FORMING_ST : 
                    if (o_addr == 9'h1FF) begin 
                        current_state <= IDLE_ST;
                    end else begin 
                        current_state <= current_state;
                    end 

            endcase // current_state
        end 
    end 


    logic [6:0] address_lo; 
    logic [1:0] address_hi;


    always_ff @(posedge i_clk, negedge i_resetn) begin 
        if (~i_resetn) begin 
            address_hi <= '{default:0};
        end else begin 

            case (current_state)
                IDLE_ST : 
                    if (i_s_axis_tvalid) begin 
                        address_hi <= address_hi + 1;
                    end else begin 
                        address_hi <= '{default:0};
                    end 

                default : 
                    address_hi <= address_hi + 1;

            endcase // current_state
        end 
    end 


    always_ff @(posedge i_clk, negedge i_resetn) begin 
        if (~i_resetn) begin 
            address_lo <= '{default:0};
        end else begin 
            if (address_hi == 2'b11) begin 
                address_lo <= address_lo + 1;
            end else begin 
                address_lo <= address_lo;
            end 
        end 
    end 


    always_ff @(posedge i_clk) begin  
        o_addr <= {address_hi, address_lo};
    end


    always_ff @(posedge i_clk, negedge i_resetn) begin : o_data_processing
        if (~i_resetn) begin 
            o_data <= '{default:0};
        end else begin 

            case (current_state)
                ADDRESS_FORMING_ST : 
                    case (address_hi)
                        2'b00 : o_data <= i_s_axis_tdata[31:24];
                        2'b01 : o_data <= i_s_axis_tdata[23:16];
                        2'b10 : o_data <= i_s_axis_tdata[15: 8];
                        2'b11 : o_data <= i_s_axis_tdata[ 7: 0];
                        default : o_data <= o_data;
                    endcase // o_addr
                
                default : 
                    o_data <= '{default:0};

            endcase // current_state

        end 
    end 


    always_comb o_valid = (current_state == ADDRESS_FORMING_ST);

endmodule : address_former