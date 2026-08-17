%% If needed generate data much than 16 bits - please fix output 
%% instead %c%c%c%c insert required char numbers
%% for example for 20 bits - insert %c%c%c%c%c
%% for example for 32 bits - insert %c%c%c%c%c%c%c%c 
clc;
clear all;
close all;

NFFT = 256;
DATA_WIDTH = 16;

limit = (2^(DATA_WIDTH-1))-1;

k = 0:1:(NFFT/2)-1;
twiddle_cos = int32(round(cos(2*pi*k/NFFT)*limit))';
twiddle_sin = int32(round(-sin(2*pi*k/NFFT)*limit))';

twiddle_cos_hex = dec2hex(twiddle_cos)';
twiddle_sin_hex = dec2hex(twiddle_sin)';

filename_real = strcat('../outputs/twiddle_real_hex_', int2str(NFFT), '.hex');
filename_imag = strcat('../outputs/twiddle_imag_hex_', int2str(NFFT), '.hex');

fileID = fopen(filename_real, 'w');
fprintf(fileID, '%c%c%c%c ', twiddle_cos_hex);
fclose(fileID);

fileID = fopen(filename_imag, 'w');
fprintf(fileID, '%c%c%c%c ', twiddle_sin_hex);
fclose(fileID);



