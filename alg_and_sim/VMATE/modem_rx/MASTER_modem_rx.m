function out = MASTER_modem_rx(in,filename)

% This function models the entire receive path of the modem from the 
% pressure received by the transducer to the message for the host PC.

% Inputs:
% in: vector containing pressure data from propagation model
% filename: filename of text file containing modem rx parameters

% Outputs:
% out: received message with received timestamp added to front
%% Analog Model

% To be done later
in = modem_analog_rx(in);

%% Firmware Model

% Read in firmware parameters 
fp = fopen(filename,'r');
fs = str2double(strtok(fgets(fp),' '));
hpf_path = strtok(fgets(fp),' ');
ft_a = str2double(strtok(fgets(fp),' '));
N_a = str2double(strtok(fgets(fp),' '));
ft_b = str2double(strtok(fgets(fp),' '));
N_b = str2double(strtok(fgets(fp),' '));
thresh_a = str2double(strtok(fgets(fp),' '));
thresh_b = str2double(strtok(fgets(fp),' '));
ts_bits = str2double(strtok(fgets(fp),' '));
fclose(fp);

% Execute Firmware
hpf_out = modem_dsp_hpf(in,hpf_path);
assignin('base','hpf_out',hpf_out)
goertzel_out_a = modem_dsp_goertzel(hpf_out,fs,ft_a,N_a);
assignin('base','goertzel_out_a',goertzel_out_a)
goertzel_out_b = modem_dsp_goertzel(hpf_out,fs,ft_b,N_b);
assignin('base','goertzel_out_b',goertzel_out_b)
decision = modem_dsp_decision_circuit(goertzel_out_a,thresh_a,goertzel_out_b,thresh_b);
assignin('base','decision',decision)
out = modem_ctrl_rx(decision, ts_bits);

end