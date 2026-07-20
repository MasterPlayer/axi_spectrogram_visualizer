`timescale 1ps / 1ps



module tb_audioprocessor();

    parameter integer AXIS_DATA_WIDTH = 20;

    logic                       clk                         ;
    logic                       resetn                      ;
    logic [AXIS_DATA_WIDTH-1:0] s_axis_tdata  = '{default:0};
    logic                       s_axis_tvalid = 1'b0        ;

    integer index = 0;

    initial begin 
        clk = 1'b0;
        forever
        #2500 clk = ~clk;
    end 

    always_ff @(posedge clk) begin : index_processing 
        index <= index + 1;
    end 

    always_ff @(posedge clk) begin : resetn_processing 
        if (index < 100) begin 
            resetn <= 1'b0;
        end else begin 
            resetn <= 1'b1;
        end 
    end 

    logic        allow_work     = 1'b0        ;
    logic [31:0] data_index     = '{default:0};
    logic        has_new_sample = 1'b0        ;

    audioprocessor #(.AXIS_DATA_WIDTH(AXIS_DATA_WIDTH)) audioprocessor_inst (
        .i_clk        (clk          ),
        .i_resetn     (resetn       ),
        //
        .s_axis_tdata (s_axis_tdata ),
        .s_axis_tvalid(s_axis_tvalid)
    );

    always_ff @(posedge clk) begin : allow_work_processing 
        if (index == 1000) begin 
            allow_work <= 1'b1;
        end else begin 
            allow_work <= allow_work;
        end 
    end 

    always_ff @(posedge clk) begin : data_index_processing 
        if (allow_work) begin 
            if (data_index < 4175) begin 
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

    always_ff @(posedge clk) begin : s_axis_tdata_processing 
        if (has_new_sample) begin 
            s_axis_tdata <= s_axis_tdata + 1;
        end else begin 
            s_axis_tdata <= s_axis_tdata;
        end 
    end 

    always_comb s_axis_tvalid = has_new_sample;

   //  int fdr0;
   //  int fdw0;
   //  int fdr1;
   //  int fdw1;
   //  int fdr2;
   //  int fdw2;
   //  int fdr3;
   //  int fdw3;
   //  int fdr4;
   //  int fdw4;
   //  int fdr5;
   //  int fdw5;
   //  int fdr6;
   //  int fdw6;
   //  int fdr7;
   //  int fdw7;
   //  int fdr8;
   //  int fdw8;
   //  int fdr9;
   //  int fdw9;
   //  int fdr10;
   //  int fdw10;
   //  int fdr11;
   //  int fdw11;
   //  int fdr12;
   //  int fdw12;
   //  int fdr13;
   //  int fdw13;
   //  int fdr14;
   //  int fdw14;
   //  int fdr15;
   //  int fdw15;
   //  int fdr16;
   //  int fdw16;
   //  int fdr17;
   //  int fdw17;
   //  int fdr18;
   //  int fdw18;
   //  int fdr19;
   //  int fdw19;
   //  int fdr20;
   //  int fdw20;
   //  int fdr21;
   //  int fdw21;
   //  int fdr22;
   //  int fdw22;
   //  int fdr23;
   //  int fdw23;

   //  string line;

   //  initial begin
   //      // 1. Open the file in read mode ("r")
   //      fdr0 = $fopen("Z:/coeffs_fixed/0.txt", "r");
   //      fdw0 = $fopen("Z:/coeffs_fixed/0.hex", "w");

   //      fdr1 = $fopen("Z:/coeffs_fixed/1.txt", "r");
   //      fdw1 = $fopen("Z:/coeffs_fixed/1.hex", "w");

   //      fdr2 = $fopen("Z:/coeffs_fixed/2.txt", "r");
   //      fdw2 = $fopen("Z:/coeffs_fixed/2.hex", "w");

   //      fdr3 = $fopen("Z:/coeffs_fixed/3.txt", "r");
   //      fdw3 = $fopen("Z:/coeffs_fixed/3.hex", "w");

   //      fdr4 = $fopen("Z:/coeffs_fixed/4.txt", "r");
   //      fdw4 = $fopen("Z:/coeffs_fixed/4.hex", "w");

   //      fdr5 = $fopen("Z:/coeffs_fixed/5.txt", "r");
   //      fdw5 = $fopen("Z:/coeffs_fixed/5.hex", "w");

   //      fdr6 = $fopen("Z:/coeffs_fixed/6.txt", "r");
   //      fdw6 = $fopen("Z:/coeffs_fixed/6.hex", "w");

   //      fdr7 = $fopen("Z:/coeffs_fixed/7.txt", "r");
   //      fdw7 = $fopen("Z:/coeffs_fixed/7.hex", "w");

   //      fdr8 = $fopen("Z:/coeffs_fixed/8.txt", "r");
   //      fdw8 = $fopen("Z:/coeffs_fixed/8.hex", "w");

   //      fdr9 = $fopen("Z:/coeffs_fixed/9.txt", "r");
   //      fdw9 = $fopen("Z:/coeffs_fixed/9.hex", "w");

   //      fdr10 = $fopen("Z:/coeffs_fixed/10.txt", "r");
   //      fdw10 = $fopen("Z:/coeffs_fixed/10.hex", "w");

   //      fdr11 = $fopen("Z:/coeffs_fixed/11.txt", "r");
   //      fdw11 = $fopen("Z:/coeffs_fixed/11.hex", "w");

   //      fdr12 = $fopen("Z:/coeffs_fixed/12.txt", "r");
   //      fdw12 = $fopen("Z:/coeffs_fixed/12.hex", "w");

   //      fdr13 = $fopen("Z:/coeffs_fixed/13.txt", "r");
   //      fdw13 = $fopen("Z:/coeffs_fixed/13.hex", "w");

   //      fdr14 = $fopen("Z:/coeffs_fixed/14.txt", "r");
   //      fdw14 = $fopen("Z:/coeffs_fixed/14.hex", "w");

   //      fdr15 = $fopen("Z:/coeffs_fixed/15.txt", "r");
   //      fdw15 = $fopen("Z:/coeffs_fixed/15.hex", "w");

   //      fdr16 = $fopen("Z:/coeffs_fixed/16.txt", "r");
   //      fdw16 = $fopen("Z:/coeffs_fixed/16.hex", "w");

   //      fdr17 = $fopen("Z:/coeffs_fixed/17.txt", "r");
   //      fdw17 = $fopen("Z:/coeffs_fixed/17.hex", "w");

   //      fdr18 = $fopen("Z:/coeffs_fixed/18.txt", "r");
   //      fdw18 = $fopen("Z:/coeffs_fixed/18.hex", "w");

   //      fdr19 = $fopen("Z:/coeffs_fixed/19.txt", "r");
   //      fdw19 = $fopen("Z:/coeffs_fixed/19.hex", "w");

   //      fdr20 = $fopen("Z:/coeffs_fixed/20.txt", "r");
   //      fdw20 = $fopen("Z:/coeffs_fixed/20.hex", "w");

   //      fdr21 = $fopen("Z:/coeffs_fixed/21.txt", "r");
   //      fdw21 = $fopen("Z:/coeffs_fixed/21.hex", "w");

   //      fdr22 = $fopen("Z:/coeffs_fixed/22.txt", "r");
   //      fdw22 = $fopen("Z:/coeffs_fixed/22.hex", "w");

   //      fdr23 = $fopen("Z:/coeffs_fixed/23.txt", "r");
   //      fdw23 = $fopen("Z:/coeffs_fixed/23.hex", "w");

        
   //      // 2. Loop through the file line by line
   //      while (!$feof(fdr0)) begin
   //          // $fgets returns the number of characters read, or 0 on error/EOF
   //          if ($fgets(line, fdr0)) begin
   //              // Process the line (e.g., print it)

   //              // $displayh("%h", line.atoi());
   //              $fwrite(fdw0,"%h\n", line.atoi());
   //          end
   //      end

   //      while (!$feof(fdr1)) begin
   //          // $fgets returns the number of characters read, or 0 on error/EOF
   //          if ($fgets(line, fdr1)) begin
   //              // Process the line (e.g., print it)

   //              // $displayh("%h", line.atoi());
   //              $fwrite(fdw1,"%h\n", line.atoi());
   //          end
   //      end

   //      while (!$feof(fdr2)) begin
   //          // $fgets returns the number of characters read, or 0 on error/EOF
   //          if ($fgets(line, fdr2)) begin
   //              // Process the line (e.g., print it)

   //              // $displayh("%h", line.atoi());
   //              $fwrite(fdw2,"%h\n", line.atoi());
   //          end
   //      end
   //      while (!$feof(fdr3)) begin
   //          // $fgets returns the number of characters read, or 0 on error/EOF
   //          if ($fgets(line, fdr3)) begin
   //              // Process the line (e.g., print it)

   //              // $displayh("%h", line.atoi());
   //              $fwrite(fdw3,"%h\n", line.atoi());
   //          end
   //      end
   //      while (!$feof(fdr4)) begin
   //          // $fgets returns the number of characters read, or 0 on error/EOF
   //          if ($fgets(line, fdr4)) begin
   //              // Process the line (e.g., print it)

   //              // $displayh("%h", line.atoi());
   //              $fwrite(fdw4,"%h\n", line.atoi());
   //          end
   //      end
   //      while (!$feof(fdr5)) begin
   //          // $fgets returns the number of characters read, or 0 on error/EOF
   //          if ($fgets(line, fdr5)) begin
   //              // Process the line (e.g., print it)

   //              // $displayh("%h", line.atoi());
   //              $fwrite(fdw5,"%h\n", line.atoi());
   //          end
   //      end
   //      while (!$feof(fdr6)) begin
   //          // $fgets returns the number of characters read, or 0 on error/EOF
   //          if ($fgets(line, fdr6)) begin
   //              // Process the line (e.g., print it)

   //              // $displayh("%h", line.atoi());
   //              $fwrite(fdw6,"%h\n", line.atoi());
   //          end
   //      end
   //      while (!$feof(fdr7)) begin
   //          // $fgets returns the number of characters read, or 0 on error/EOF
   //          if ($fgets(line, fdr7)) begin
   //              // Process the line (e.g., print it)

   //              // $displayh("%h", line.atoi());
   //              $fwrite(fdw7,"%h\n", line.atoi());
   //          end
   //      end
   //      while (!$feof(fdr8)) begin
   //          // $fgets returns the number of characters read, or 0 on error/EOF
   //          if ($fgets(line, fdr8)) begin
   //              // Process the line (e.g., print it)

   //              // $displayh("%h", line.atoi());
   //              $fwrite(fdw8,"%h\n", line.atoi());
   //          end
   //      end
   //      while (!$feof(fdr9)) begin
   //          // $fgets returns the number of characters read, or 0 on error/EOF
   //          if ($fgets(line, fdr9)) begin
   //              // Process the line (e.g., print it)

   //              // $displayh("%h", line.atoi());
   //              $fwrite(fdw9,"%h\n", line.atoi());
   //          end
   //      end
   //      while (!$feof(fdr10)) begin
   //          // $fgets returns the number of characters read, or 0 on error/EOF
   //          if ($fgets(line, fdr10)) begin
   //              // Process the line (e.g., print it)

   //              // $displayh("%h", line.atoi());
   //              $fwrite(fdw10,"%h\n", line.atoi());
   //          end
   //      end
   //      while (!$feof(fdr11)) begin
   //          // $fgets returns the number of characters read, or 0 on error/EOF
   //          if ($fgets(line, fdr11)) begin
   //              // Process the line (e.g., print it)

   //              // $displayh("%h", line.atoi());
   //              $fwrite(fdw11,"%h\n", line.atoi());
   //          end
   //      end
   //      while (!$feof(fdr12)) begin
   //          // $fgets returns the number of characters read, or 0 on error/EOF
   //          if ($fgets(line, fdr12)) begin
   //              // Process the line (e.g., print it)

   //              // $displayh("%h", line.atoi());
   //              $fwrite(fdw12,"%h\n", line.atoi());
   //          end
   //      end
   //      while (!$feof(fdr13)) begin
   //          // $fgets returns the number of characters read, or 0 on error/EOF
   //          if ($fgets(line, fdr13)) begin
   //              // Process the line (e.g., print it)

   //              // $displayh("%h", line.atoi());
   //              $fwrite(fdw13,"%h\n", line.atoi());
   //          end
   //      end
   //      while (!$feof(fdr14)) begin
   //          // $fgets returns the number of characters read, or 0 on error/EOF
   //          if ($fgets(line, fdr14)) begin
   //              // Process the line (e.g., print it)

   //              // $displayh("%h", line.atoi());
   //              $fwrite(fdw14,"%h\n", line.atoi());
   //          end
   //      end
   //      while (!$feof(fdr15)) begin
   //          // $fgets returns the number of characters read, or 0 on error/EOF
   //          if ($fgets(line, fdr15)) begin
   //              // Process the line (e.g., print it)

   //              // $displayh("%h", line.atoi());
   //              $fwrite(fdw15,"%h\n", line.atoi());
   //          end
   //      end
   //      while (!$feof(fdr16)) begin
   //          // $fgets returns the number of characters read, or 0 on error/EOF
   //          if ($fgets(line, fdr16)) begin
   //              // Process the line (e.g., print it)

   //              // $displayh("%h", line.atoi());
   //              $fwrite(fdw16,"%h\n", line.atoi());
   //          end
   //      end
   //      while (!$feof(fdr17)) begin
   //          // $fgets returns the number of characters read, or 0 on error/EOF
   //          if ($fgets(line, fdr17)) begin
   //              // Process the line (e.g., print it)

   //              // $displayh("%h", line.atoi());
   //              $fwrite(fdw17,"%h\n", line.atoi());
   //          end
   //      end
   //      while (!$feof(fdr18)) begin
   //          // $fgets returns the number of characters read, or 0 on error/EOF
   //          if ($fgets(line, fdr18)) begin
   //              // Process the line (e.g., print it)

   //              // $displayh("%h", line.atoi());
   //              $fwrite(fdw18,"%h\n", line.atoi());
   //          end
   //      end
   //      while (!$feof(fdr19)) begin
   //          // $fgets returns the number of characters read, or 0 on error/EOF
   //          if ($fgets(line, fdr19)) begin
   //              // Process the line (e.g., print it)

   //              // $displayh("%h", line.atoi());
   //              $fwrite(fdw19,"%h\n", line.atoi());
   //          end
   //      end
   //      while (!$feof(fdr20)) begin
   //          // $fgets returns the number of characters read, or 0 on error/EOF
   //          if ($fgets(line, fdr20)) begin
   //              // Process the line (e.g., print it)

   //              // $displayh("%h", line.atoi());
   //              $fwrite(fdw20,"%h\n", line.atoi());
   //          end
   //      end
   //      while (!$feof(fdr21)) begin
   //          // $fgets returns the number of characters read, or 0 on error/EOF
   //          if ($fgets(line, fdr21)) begin
   //              // Process the line (e.g., print it)

   //              // $displayh("%h", line.atoi());
   //              $fwrite(fdw21,"%h\n", line.atoi());
   //          end
   //      end
   //      while (!$feof(fdr22)) begin
   //          // $fgets returns the number of characters read, or 0 on error/EOF
   //          if ($fgets(line, fdr22)) begin
   //              // Process the line (e.g., print it)

   //              // $displayh("%h", line.atoi());
   //              $fwrite(fdw22,"%h\n", line.atoi());
   //          end
   //      end
   //      while (!$feof(fdr23)) begin
   //          // $fgets returns the number of characters read, or 0 on error/EOF
   //          if ($fgets(line, fdr23)) begin
   //              // Process the line (e.g., print it)

   //              // $displayh("%h", line.atoi());
   //              $fwrite(fdw23,"%h\n", line.atoi());
   //          end
   //      end


   //      // 3. Close the file handle
   //      $fclose(fdr0);
   //      $fclose(fdr1);
   //      $fclose(fdr2);
   //      $fclose(fdr3);
   //      $fclose(fdr4);
   //      $fclose(fdr5);
   //      $fclose(fdr6);
   //      $fclose(fdr7);
   //      $fclose(fdr8);
   //      $fclose(fdr9);
   //      $fclose(fdr10);
   //      $fclose(fdr11);
   //      $fclose(fdr12);
   //      $fclose(fdr13);
   //      $fclose(fdr14);
   //      $fclose(fdr15);
   //      $fclose(fdr16);
   //      $fclose(fdr17);
   //      $fclose(fdr18);
   //      $fclose(fdr19);
   //      $fclose(fdr20);
   //      $fclose(fdr21);
   //      $fclose(fdr22);
   //      $fclose(fdr23);

   //      $fclose(fdw0);
   //      $fclose(fdw1);
   //      $fclose(fdw2);
   //      $fclose(fdw3);
   //      $fclose(fdw4);
   //      $fclose(fdw5);
   //      $fclose(fdw6);
   //      $fclose(fdw7);
   //      $fclose(fdw8);
   //      $fclose(fdw9);
   //      $fclose(fdw10);
   //      $fclose(fdw11);
   //      $fclose(fdw12);
   //      $fclose(fdw13);
   //      $fclose(fdw14);
   //      $fclose(fdw15);
   //      $fclose(fdw16);
   //      $fclose(fdw17);
   //      $fclose(fdw18);
   //      $fclose(fdw19);
   //      $fclose(fdw20);
   //      $fclose(fdw21);
   //      $fclose(fdw22);
   //      $fclose(fdw23);

   // end



endmodule
