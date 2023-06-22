function [EEG,SString_L]=transform_bipolar_to_unipolar(path_file)
SString_L=pop_readedf(path_file);
%% matrix used to create the unipolar representation
M=[1 0 -1 0 ; 0 1 0 -1 ; -1 1 0 0 ; 0 1 -1 0; 1 0 0 -1];
data_exp=SString_L.data(2:6,:);
EEG=(pinv(M))*data_exp;