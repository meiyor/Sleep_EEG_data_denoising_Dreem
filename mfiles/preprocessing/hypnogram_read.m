function hypnogram_read(path)
file_hypnogram=fopen(path);
for k_header=1:18
    s_header{k_header}=fgets(file_hypnogram);
end;
time_s(1)=0;
counter_30sec=1;
while (~feof(file_hypnogram))
    data_hypnogram{counter_30sec}=strsplit(fgets(file_hypnogram),'\t');
    time_s(counter_30sec+1)=time_s(counter_30sec)+str2num(data_hypnogram{counter_30sec}{4}(1:2));
    %% selection of different labels
    if length('SLEEP-S0')==length(data_hypnogram{counter_30sec}{3}) && strcmp('SLEEP-S0',data_hypnogram{counter_30sec}{3})
       label_value=0; 
    end;
    if length('SLEEP-S1')==length(data_hypnogram{counter_30sec}{3}) && strcmp('SLEEP-S1',data_hypnogram{counter_30sec}{3})
       label_value=1; 
    end;
     if length('SLEEP-S2')==length(data_hypnogram{counter_30sec}{3}) && strcmp('SLEEP-S2',data_hypnogram{counter_30sec}{3})
       label_value=2; 
    end;
    if length('SLEEP-S3')==length(data_hypnogram{counter_30sec}{3}) && strcmp('SLEEP-S3',data_hypnogram{counter_30sec}{3})
       label_value=3; 
    end;
    if length('SLEEP-REM')==length(data_hypnogram{counter_30sec}{3}) && strcmp('SLEEP-REM',data_hypnogram{counter_30sec}{3})
       label_value=4; 
    end;
    if length('SLEEP-MT')==length(data_hypnogram{counter_30sec}{3}) && strcmp('SLEEP-MT',data_hypnogram{counter_30sec}{3})
       label_value=-1; 
    end;
    label_vec(counter_30sec)=label_value;
    label_vec(counter_30sec+1)=label_value;
    counter_30sec=counter_30sec+1;
end;
plot(time_s,label_vec,'LineWidth',4)
xlabel('Time [s]');
set(gca,'FontSize',17);
grid on;