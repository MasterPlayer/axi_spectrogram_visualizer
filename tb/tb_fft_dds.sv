`timescale 1ps / 1ps


module tb_fft_dds();


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

    logic        i_start;
    logic [31:0] i_phase;

    always_ff @(posedge clk) begin 
        if (index > 1000) begin 
            i_start <= 1'b1;
        end else begin 
            i_start <= 1'b0;
        end 
    end  

    // always_comb i_phase = 32'h10000000;

    // axis_dds_x16 axis_dds_x16_inst (
    //     .i_clk        (clk         ),
    //     .i_start      (i_start     ),
    //     .i_phase      (i_phase     ),
    //     .i_pause      (32'h00000000),
    //     .m_axis_tdata (i_tdata_re  ),
    //     .m_axis_tvalid(i_tvalid    )
    // );

    always_ff @(posedge clk) begin 
        case (index) 
            1000 : begin i_tdata_re <= 16'h0000; i_tvalid <= 1'b1; end 
            1001 : begin i_tdata_re <= 16'h0001; i_tvalid <= 1'b1; end 
            1002 : begin i_tdata_re <= 16'h0002; i_tvalid <= 1'b1; end 
            1003 : begin i_tdata_re <= 16'h0003; i_tvalid <= 1'b1; end 
            1004 : begin i_tdata_re <= 16'h0004; i_tvalid <= 1'b1; end 
            1005 : begin i_tdata_re <= 16'h0005; i_tvalid <= 1'b1; end 
            1006 : begin i_tdata_re <= 16'h0006; i_tvalid <= 1'b1; end 
            1007 : begin i_tdata_re <= 16'h0007; i_tvalid <= 1'b1; end 
            1008 : begin i_tdata_re <= 16'h0008; i_tvalid <= 1'b1; end 
            1009 : begin i_tdata_re <= 16'h0009; i_tvalid <= 1'b1; end 
            1010 : begin i_tdata_re <= 16'h000a; i_tvalid <= 1'b1; end 
            1011 : begin i_tdata_re <= 16'h000b; i_tvalid <= 1'b1; end 
            1012 : begin i_tdata_re <= 16'h000c; i_tvalid <= 1'b1; end 
            1013 : begin i_tdata_re <= 16'h000d; i_tvalid <= 1'b1; end 
            1014 : begin i_tdata_re <= 16'h000e; i_tvalid <= 1'b1; end 
            1015 : begin i_tdata_re <= 16'h000f; i_tvalid <= 1'b1; end 
            1016 : begin i_tdata_re <= 16'h0010; i_tvalid <= 1'b1; end 
            1017 : begin i_tdata_re <= 16'h0011; i_tvalid <= 1'b1; end 
            1018 : begin i_tdata_re <= 16'h0012; i_tvalid <= 1'b1; end 
            1019 : begin i_tdata_re <= 16'h0013; i_tvalid <= 1'b1; end 
            1020 : begin i_tdata_re <= 16'h0014; i_tvalid <= 1'b1; end 
            1021 : begin i_tdata_re <= 16'h0015; i_tvalid <= 1'b1; end 
            1022 : begin i_tdata_re <= 16'h0016; i_tvalid <= 1'b1; end 
            1023 : begin i_tdata_re <= 16'h0017; i_tvalid <= 1'b1; end 
            1024 : begin i_tdata_re <= 16'h0018; i_tvalid <= 1'b1; end 
            1025 : begin i_tdata_re <= 16'h0019; i_tvalid <= 1'b1; end 
            1026 : begin i_tdata_re <= 16'h001a; i_tvalid <= 1'b1; end 
            1027 : begin i_tdata_re <= 16'h001b; i_tvalid <= 1'b1; end 
            1028 : begin i_tdata_re <= 16'h001c; i_tvalid <= 1'b1; end 
            1029 : begin i_tdata_re <= 16'h001d; i_tvalid <= 1'b1; end 
            1030 : begin i_tdata_re <= 16'h001e; i_tvalid <= 1'b1; end 
            1031 : begin i_tdata_re <= 16'h001f; i_tvalid <= 1'b1; end 
            1032 : begin i_tdata_re <= 16'h0020; i_tvalid <= 1'b1; end 
            1033 : begin i_tdata_re <= 16'h0021; i_tvalid <= 1'b1; end 
            1034 : begin i_tdata_re <= 16'h0022; i_tvalid <= 1'b1; end 
            1035 : begin i_tdata_re <= 16'h0023; i_tvalid <= 1'b1; end 
            1036 : begin i_tdata_re <= 16'h0024; i_tvalid <= 1'b1; end 
            1037 : begin i_tdata_re <= 16'h0025; i_tvalid <= 1'b1; end 
            1038 : begin i_tdata_re <= 16'h0026; i_tvalid <= 1'b1; end 
            1039 : begin i_tdata_re <= 16'h0027; i_tvalid <= 1'b1; end 
            1040 : begin i_tdata_re <= 16'h0028; i_tvalid <= 1'b1; end 
            1041 : begin i_tdata_re <= 16'h0029; i_tvalid <= 1'b1; end 
            1042 : begin i_tdata_re <= 16'h002a; i_tvalid <= 1'b1; end 
            1043 : begin i_tdata_re <= 16'h002b; i_tvalid <= 1'b1; end 
            1044 : begin i_tdata_re <= 16'h002c; i_tvalid <= 1'b1; end 
            1045 : begin i_tdata_re <= 16'h002d; i_tvalid <= 1'b1; end 
            1046 : begin i_tdata_re <= 16'h002e; i_tvalid <= 1'b1; end 
            1047 : begin i_tdata_re <= 16'h002f; i_tvalid <= 1'b1; end 
            1048 : begin i_tdata_re <= 16'h0030; i_tvalid <= 1'b1; end 
            1049 : begin i_tdata_re <= 16'h0031; i_tvalid <= 1'b1; end 
            1050 : begin i_tdata_re <= 16'h0032; i_tvalid <= 1'b1; end 
            1051 : begin i_tdata_re <= 16'h0033; i_tvalid <= 1'b1; end 
            1052 : begin i_tdata_re <= 16'h0034; i_tvalid <= 1'b1; end 
            1053 : begin i_tdata_re <= 16'h0035; i_tvalid <= 1'b1; end 
            1054 : begin i_tdata_re <= 16'h0036; i_tvalid <= 1'b1; end 
            1055 : begin i_tdata_re <= 16'h0037; i_tvalid <= 1'b1; end 
            1056 : begin i_tdata_re <= 16'h0038; i_tvalid <= 1'b1; end 
            1057 : begin i_tdata_re <= 16'h0039; i_tvalid <= 1'b1; end 
            1058 : begin i_tdata_re <= 16'h003a; i_tvalid <= 1'b1; end 
            1059 : begin i_tdata_re <= 16'h003b; i_tvalid <= 1'b1; end 
            1060 : begin i_tdata_re <= 16'h003c; i_tvalid <= 1'b1; end 
            1061 : begin i_tdata_re <= 16'h003d; i_tvalid <= 1'b1; end 
            1062 : begin i_tdata_re <= 16'h003e; i_tvalid <= 1'b1; end 
            1063 : begin i_tdata_re <= 16'h003f; i_tvalid <= 1'b1; end 
            1064 : begin i_tdata_re <= 16'h0040; i_tvalid <= 1'b1; end 
            1065 : begin i_tdata_re <= 16'h0041; i_tvalid <= 1'b1; end 
            1066 : begin i_tdata_re <= 16'h0042; i_tvalid <= 1'b1; end 
            1067 : begin i_tdata_re <= 16'h0043; i_tvalid <= 1'b1; end 
            1068 : begin i_tdata_re <= 16'h0044; i_tvalid <= 1'b1; end 
            1069 : begin i_tdata_re <= 16'h0045; i_tvalid <= 1'b1; end 
            1070 : begin i_tdata_re <= 16'h0046; i_tvalid <= 1'b1; end 
            1071 : begin i_tdata_re <= 16'h0047; i_tvalid <= 1'b1; end 
            1072 : begin i_tdata_re <= 16'h0048; i_tvalid <= 1'b1; end 
            1073 : begin i_tdata_re <= 16'h0049; i_tvalid <= 1'b1; end 
            1074 : begin i_tdata_re <= 16'h004a; i_tvalid <= 1'b1; end 
            1075 : begin i_tdata_re <= 16'h004b; i_tvalid <= 1'b1; end 
            1076 : begin i_tdata_re <= 16'h004c; i_tvalid <= 1'b1; end 
            1077 : begin i_tdata_re <= 16'h004d; i_tvalid <= 1'b1; end 
            1078 : begin i_tdata_re <= 16'h004e; i_tvalid <= 1'b1; end 
            1079 : begin i_tdata_re <= 16'h004f; i_tvalid <= 1'b1; end 
            1080 : begin i_tdata_re <= 16'h0050; i_tvalid <= 1'b1; end 
            1081 : begin i_tdata_re <= 16'h0051; i_tvalid <= 1'b1; end 
            1082 : begin i_tdata_re <= 16'h0052; i_tvalid <= 1'b1; end 
            1083 : begin i_tdata_re <= 16'h0053; i_tvalid <= 1'b1; end 
            1084 : begin i_tdata_re <= 16'h0054; i_tvalid <= 1'b1; end 
            1085 : begin i_tdata_re <= 16'h0055; i_tvalid <= 1'b1; end 
            1086 : begin i_tdata_re <= 16'h0056; i_tvalid <= 1'b1; end 
            1087 : begin i_tdata_re <= 16'h0057; i_tvalid <= 1'b1; end 
            1088 : begin i_tdata_re <= 16'h0058; i_tvalid <= 1'b1; end 
            1089 : begin i_tdata_re <= 16'h0059; i_tvalid <= 1'b1; end 
            1090 : begin i_tdata_re <= 16'h005a; i_tvalid <= 1'b1; end 
            1091 : begin i_tdata_re <= 16'h005b; i_tvalid <= 1'b1; end 
            1092 : begin i_tdata_re <= 16'h005c; i_tvalid <= 1'b1; end 
            1093 : begin i_tdata_re <= 16'h005d; i_tvalid <= 1'b1; end 
            1094 : begin i_tdata_re <= 16'h005e; i_tvalid <= 1'b1; end 
            1095 : begin i_tdata_re <= 16'h005f; i_tvalid <= 1'b1; end 
            1096 : begin i_tdata_re <= 16'h0060; i_tvalid <= 1'b1; end 
            1097 : begin i_tdata_re <= 16'h0061; i_tvalid <= 1'b1; end 
            1098 : begin i_tdata_re <= 16'h0062; i_tvalid <= 1'b1; end 
            1099 : begin i_tdata_re <= 16'h0063; i_tvalid <= 1'b1; end 
            1100 : begin i_tdata_re <= 16'h0064; i_tvalid <= 1'b1; end 
            1101 : begin i_tdata_re <= 16'h0065; i_tvalid <= 1'b1; end 
            1102 : begin i_tdata_re <= 16'h0066; i_tvalid <= 1'b1; end 
            1103 : begin i_tdata_re <= 16'h0067; i_tvalid <= 1'b1; end 
            1104 : begin i_tdata_re <= 16'h0068; i_tvalid <= 1'b1; end 
            1105 : begin i_tdata_re <= 16'h0069; i_tvalid <= 1'b1; end 
            1106 : begin i_tdata_re <= 16'h006a; i_tvalid <= 1'b1; end 
            1107 : begin i_tdata_re <= 16'h006b; i_tvalid <= 1'b1; end 
            1108 : begin i_tdata_re <= 16'h006c; i_tvalid <= 1'b1; end 
            1109 : begin i_tdata_re <= 16'h006d; i_tvalid <= 1'b1; end 
            1110 : begin i_tdata_re <= 16'h006e; i_tvalid <= 1'b1; end 
            1111 : begin i_tdata_re <= 16'h006f; i_tvalid <= 1'b1; end 
            1112 : begin i_tdata_re <= 16'h0070; i_tvalid <= 1'b1; end 
            1113 : begin i_tdata_re <= 16'h0071; i_tvalid <= 1'b1; end 
            1114 : begin i_tdata_re <= 16'h0072; i_tvalid <= 1'b1; end 
            1115 : begin i_tdata_re <= 16'h0073; i_tvalid <= 1'b1; end 
            1116 : begin i_tdata_re <= 16'h0074; i_tvalid <= 1'b1; end 
            1117 : begin i_tdata_re <= 16'h0075; i_tvalid <= 1'b1; end 
            1118 : begin i_tdata_re <= 16'h0076; i_tvalid <= 1'b1; end 
            1119 : begin i_tdata_re <= 16'h0077; i_tvalid <= 1'b1; end 
            1120 : begin i_tdata_re <= 16'h0078; i_tvalid <= 1'b1; end 
            1121 : begin i_tdata_re <= 16'h0079; i_tvalid <= 1'b1; end 
            1122 : begin i_tdata_re <= 16'h007a; i_tvalid <= 1'b1; end 
            1123 : begin i_tdata_re <= 16'h007b; i_tvalid <= 1'b1; end 
            1124 : begin i_tdata_re <= 16'h007c; i_tvalid <= 1'b1; end 
            1125 : begin i_tdata_re <= 16'h007d; i_tvalid <= 1'b1; end 
            1126 : begin i_tdata_re <= 16'h007e; i_tvalid <= 1'b1; end 
            1127 : begin i_tdata_re <= 16'h007f; i_tvalid <= 1'b1; end 
            1128 : begin i_tdata_re <= 16'h0080; i_tvalid <= 1'b1; end 
            1129 : begin i_tdata_re <= 16'h0081; i_tvalid <= 1'b1; end 
            1130 : begin i_tdata_re <= 16'h0082; i_tvalid <= 1'b1; end 
            1131 : begin i_tdata_re <= 16'h0083; i_tvalid <= 1'b1; end 
            1132 : begin i_tdata_re <= 16'h0084; i_tvalid <= 1'b1; end 
            1133 : begin i_tdata_re <= 16'h0085; i_tvalid <= 1'b1; end 
            1134 : begin i_tdata_re <= 16'h0086; i_tvalid <= 1'b1; end 
            1135 : begin i_tdata_re <= 16'h0087; i_tvalid <= 1'b1; end 
            1136 : begin i_tdata_re <= 16'h0088; i_tvalid <= 1'b1; end 
            1137 : begin i_tdata_re <= 16'h0089; i_tvalid <= 1'b1; end 
            1138 : begin i_tdata_re <= 16'h008a; i_tvalid <= 1'b1; end 
            1139 : begin i_tdata_re <= 16'h008b; i_tvalid <= 1'b1; end 
            1140 : begin i_tdata_re <= 16'h008c; i_tvalid <= 1'b1; end 
            1141 : begin i_tdata_re <= 16'h008d; i_tvalid <= 1'b1; end 
            1142 : begin i_tdata_re <= 16'h008e; i_tvalid <= 1'b1; end 
            1143 : begin i_tdata_re <= 16'h008f; i_tvalid <= 1'b1; end 
            1144 : begin i_tdata_re <= 16'h0090; i_tvalid <= 1'b1; end 
            1145 : begin i_tdata_re <= 16'h0091; i_tvalid <= 1'b1; end 
            1146 : begin i_tdata_re <= 16'h0092; i_tvalid <= 1'b1; end 
            1147 : begin i_tdata_re <= 16'h0093; i_tvalid <= 1'b1; end 
            1148 : begin i_tdata_re <= 16'h0094; i_tvalid <= 1'b1; end 
            1149 : begin i_tdata_re <= 16'h0095; i_tvalid <= 1'b1; end 
            1150 : begin i_tdata_re <= 16'h0096; i_tvalid <= 1'b1; end 
            1151 : begin i_tdata_re <= 16'h0097; i_tvalid <= 1'b1; end 
            1152 : begin i_tdata_re <= 16'h0098; i_tvalid <= 1'b1; end 
            1153 : begin i_tdata_re <= 16'h0099; i_tvalid <= 1'b1; end 
            1154 : begin i_tdata_re <= 16'h009a; i_tvalid <= 1'b1; end 
            1155 : begin i_tdata_re <= 16'h009b; i_tvalid <= 1'b1; end 
            1156 : begin i_tdata_re <= 16'h009c; i_tvalid <= 1'b1; end 
            1157 : begin i_tdata_re <= 16'h009d; i_tvalid <= 1'b1; end 
            1158 : begin i_tdata_re <= 16'h009e; i_tvalid <= 1'b1; end 
            1159 : begin i_tdata_re <= 16'h009f; i_tvalid <= 1'b1; end 
            1160 : begin i_tdata_re <= 16'h00a0; i_tvalid <= 1'b1; end 
            1161 : begin i_tdata_re <= 16'h00a1; i_tvalid <= 1'b1; end 
            1162 : begin i_tdata_re <= 16'h00a2; i_tvalid <= 1'b1; end 
            1163 : begin i_tdata_re <= 16'h00a3; i_tvalid <= 1'b1; end 
            1164 : begin i_tdata_re <= 16'h00a4; i_tvalid <= 1'b1; end 
            1165 : begin i_tdata_re <= 16'h00a5; i_tvalid <= 1'b1; end 
            1166 : begin i_tdata_re <= 16'h00a6; i_tvalid <= 1'b1; end 
            1167 : begin i_tdata_re <= 16'h00a7; i_tvalid <= 1'b1; end 
            1168 : begin i_tdata_re <= 16'h00a8; i_tvalid <= 1'b1; end 
            1169 : begin i_tdata_re <= 16'h00a9; i_tvalid <= 1'b1; end 
            1170 : begin i_tdata_re <= 16'h00aa; i_tvalid <= 1'b1; end 
            1171 : begin i_tdata_re <= 16'h00ab; i_tvalid <= 1'b1; end 
            1172 : begin i_tdata_re <= 16'h00ac; i_tvalid <= 1'b1; end 
            1173 : begin i_tdata_re <= 16'h00ad; i_tvalid <= 1'b1; end 
            1174 : begin i_tdata_re <= 16'h00ae; i_tvalid <= 1'b1; end 
            1175 : begin i_tdata_re <= 16'h00af; i_tvalid <= 1'b1; end 
            1176 : begin i_tdata_re <= 16'h00b0; i_tvalid <= 1'b1; end 
            1177 : begin i_tdata_re <= 16'h00b1; i_tvalid <= 1'b1; end 
            1178 : begin i_tdata_re <= 16'h00b2; i_tvalid <= 1'b1; end 
            1179 : begin i_tdata_re <= 16'h00b3; i_tvalid <= 1'b1; end 
            1180 : begin i_tdata_re <= 16'h00b4; i_tvalid <= 1'b1; end 
            1181 : begin i_tdata_re <= 16'h00b5; i_tvalid <= 1'b1; end 
            1182 : begin i_tdata_re <= 16'h00b6; i_tvalid <= 1'b1; end 
            1183 : begin i_tdata_re <= 16'h00b7; i_tvalid <= 1'b1; end 
            1184 : begin i_tdata_re <= 16'h00b8; i_tvalid <= 1'b1; end 
            1185 : begin i_tdata_re <= 16'h00b9; i_tvalid <= 1'b1; end 
            1186 : begin i_tdata_re <= 16'h00ba; i_tvalid <= 1'b1; end 
            1187 : begin i_tdata_re <= 16'h00bb; i_tvalid <= 1'b1; end 
            1188 : begin i_tdata_re <= 16'h00bc; i_tvalid <= 1'b1; end 
            1189 : begin i_tdata_re <= 16'h00bd; i_tvalid <= 1'b1; end 
            1190 : begin i_tdata_re <= 16'h00be; i_tvalid <= 1'b1; end 
            1191 : begin i_tdata_re <= 16'h00bf; i_tvalid <= 1'b1; end 
            1192 : begin i_tdata_re <= 16'h00c0; i_tvalid <= 1'b1; end 
            1193 : begin i_tdata_re <= 16'h00c1; i_tvalid <= 1'b1; end 
            1194 : begin i_tdata_re <= 16'h00c2; i_tvalid <= 1'b1; end 
            1195 : begin i_tdata_re <= 16'h00c3; i_tvalid <= 1'b1; end 
            1196 : begin i_tdata_re <= 16'h00c4; i_tvalid <= 1'b1; end 
            1197 : begin i_tdata_re <= 16'h00c5; i_tvalid <= 1'b1; end 
            1198 : begin i_tdata_re <= 16'h00c6; i_tvalid <= 1'b1; end 
            1199 : begin i_tdata_re <= 16'h00c7; i_tvalid <= 1'b1; end 
            1200 : begin i_tdata_re <= 16'h00c8; i_tvalid <= 1'b1; end 
            1201 : begin i_tdata_re <= 16'h00c9; i_tvalid <= 1'b1; end 
            1202 : begin i_tdata_re <= 16'h00ca; i_tvalid <= 1'b1; end 
            1203 : begin i_tdata_re <= 16'h00cb; i_tvalid <= 1'b1; end 
            1204 : begin i_tdata_re <= 16'h00cc; i_tvalid <= 1'b1; end 
            1205 : begin i_tdata_re <= 16'h00cd; i_tvalid <= 1'b1; end 
            1206 : begin i_tdata_re <= 16'h00ce; i_tvalid <= 1'b1; end 
            1207 : begin i_tdata_re <= 16'h00cf; i_tvalid <= 1'b1; end 
            1208 : begin i_tdata_re <= 16'h00d0; i_tvalid <= 1'b1; end 
            1209 : begin i_tdata_re <= 16'h00d1; i_tvalid <= 1'b1; end 
            1210 : begin i_tdata_re <= 16'h00d2; i_tvalid <= 1'b1; end 
            1211 : begin i_tdata_re <= 16'h00d3; i_tvalid <= 1'b1; end 
            1212 : begin i_tdata_re <= 16'h00d4; i_tvalid <= 1'b1; end 
            1213 : begin i_tdata_re <= 16'h00d5; i_tvalid <= 1'b1; end 
            1214 : begin i_tdata_re <= 16'h00d6; i_tvalid <= 1'b1; end 
            1215 : begin i_tdata_re <= 16'h00d7; i_tvalid <= 1'b1; end 
            1216 : begin i_tdata_re <= 16'h00d8; i_tvalid <= 1'b1; end 
            1217 : begin i_tdata_re <= 16'h00d9; i_tvalid <= 1'b1; end 
            1218 : begin i_tdata_re <= 16'h00da; i_tvalid <= 1'b1; end 
            1219 : begin i_tdata_re <= 16'h00db; i_tvalid <= 1'b1; end 
            1220 : begin i_tdata_re <= 16'h00dc; i_tvalid <= 1'b1; end 
            1221 : begin i_tdata_re <= 16'h00dd; i_tvalid <= 1'b1; end 
            1222 : begin i_tdata_re <= 16'h00de; i_tvalid <= 1'b1; end 
            1223 : begin i_tdata_re <= 16'h00df; i_tvalid <= 1'b1; end 
            1224 : begin i_tdata_re <= 16'h00e0; i_tvalid <= 1'b1; end 
            1225 : begin i_tdata_re <= 16'h00e1; i_tvalid <= 1'b1; end 
            1226 : begin i_tdata_re <= 16'h00e2; i_tvalid <= 1'b1; end 
            1227 : begin i_tdata_re <= 16'h00e3; i_tvalid <= 1'b1; end 
            1228 : begin i_tdata_re <= 16'h00e4; i_tvalid <= 1'b1; end 
            1229 : begin i_tdata_re <= 16'h00e5; i_tvalid <= 1'b1; end 
            1230 : begin i_tdata_re <= 16'h00e6; i_tvalid <= 1'b1; end 
            1231 : begin i_tdata_re <= 16'h00e7; i_tvalid <= 1'b1; end 
            1232 : begin i_tdata_re <= 16'h00e8; i_tvalid <= 1'b1; end 
            1233 : begin i_tdata_re <= 16'h00e9; i_tvalid <= 1'b1; end 
            1234 : begin i_tdata_re <= 16'h00ea; i_tvalid <= 1'b1; end 
            1235 : begin i_tdata_re <= 16'h00eb; i_tvalid <= 1'b1; end 
            1236 : begin i_tdata_re <= 16'h00ec; i_tvalid <= 1'b1; end 
            1237 : begin i_tdata_re <= 16'h00ed; i_tvalid <= 1'b1; end 
            1238 : begin i_tdata_re <= 16'h00ee; i_tvalid <= 1'b1; end 
            1239 : begin i_tdata_re <= 16'h00ef; i_tvalid <= 1'b1; end 
            1240 : begin i_tdata_re <= 16'h00f0; i_tvalid <= 1'b1; end 
            1241 : begin i_tdata_re <= 16'h00f1; i_tvalid <= 1'b1; end 
            1242 : begin i_tdata_re <= 16'h00f2; i_tvalid <= 1'b1; end 
            1243 : begin i_tdata_re <= 16'h00f3; i_tvalid <= 1'b1; end 
            1244 : begin i_tdata_re <= 16'h00f4; i_tvalid <= 1'b1; end 
            1245 : begin i_tdata_re <= 16'h00f5; i_tvalid <= 1'b1; end 
            1246 : begin i_tdata_re <= 16'h00f6; i_tvalid <= 1'b1; end 
            1247 : begin i_tdata_re <= 16'h00f7; i_tvalid <= 1'b1; end 
            1248 : begin i_tdata_re <= 16'h00f8; i_tvalid <= 1'b1; end 
            1249 : begin i_tdata_re <= 16'h00f9; i_tvalid <= 1'b1; end 
            1250 : begin i_tdata_re <= 16'h00fa; i_tvalid <= 1'b1; end 
            1251 : begin i_tdata_re <= 16'h00fb; i_tvalid <= 1'b1; end 
            1252 : begin i_tdata_re <= 16'h00fc; i_tvalid <= 1'b1; end 
            1253 : begin i_tdata_re <= 16'h00fd; i_tvalid <= 1'b1; end 
            1254 : begin i_tdata_re <= 16'h00fe; i_tvalid <= 1'b1; end 
            1255 : begin i_tdata_re <= 16'h00ff; i_tvalid <= 1'b1; end 
            default : begin i_tdata_re <= 16'h0000; i_tvalid <= 1'b0; end 

        endcase // index
    end 

    fft_sv fft_sv_inst (
        .i_clk     (clk       ),
        .i_resetn  (~reset    ),
        .i_tdata_re(i_tdata_re),
        .i_tdata_im(16'h0000  ),
        .i_tvalid  (i_tvalid  ),
        .o_tready  (          ),
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
