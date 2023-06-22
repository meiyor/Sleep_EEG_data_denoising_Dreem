function [Sal_filtered,Sal,Result]=windowing_sleep_EEG(name_of_the_file,time_window,overlap_sec,time_ini,fs)
    %% name_of_the_file, string with the name of the file or the absolute path with .edf extension.
    %% time_window, time window in seconds that this application will iterate across the entire "per participant" data file.
    %% overlap_sec, size of overlap in seconds of each window, use 4 second window and 2 second overlap to process the file in the better way.
    %% time_ini, time offset in seconds to process the file, you can select any time depending on your desire to start processing the file.
    %% fs, sample frequency for these sleep files it is always 250Hz.
   [SBack,result,data_unipolar_b]=remove_artifact_sleep_inv(name_of_the_file,[time_ini+1 time_ini+time_window+1],1,[],time_ini,[]);
   Result=result.data;
   length_data=size(SBack.data,2);
   for win=1:round(length_data/(time_window-overlap_sec))
       time_beg=win*(time_window)-overlap_sec*win+time_ini;
       time_end=win*(time_window)-overlap_sec*win+time_window+time_ini;
       [SBack,result,data_unipolar_b]=remove_artifact_sleep_inv(name_of_the_file,[time_beg time_end],0,SBack,time_beg,data_unipolar_b);
       Result(:,end-overlap_sec*fs:end)=(Result(:,end-overlap_sec*fs:end)+real(result.data(:,1:overlap_sec*fs+1)))/2;
       Result=[Result real(result.data(:,overlap_sec*fs+1:(time_window)*fs+1))];
   end;
   ttime=linspace(0,length(Result)/fs,length(Result));
   Sal=eeg_emptyset();
   Sal.data=Result;
   Sal.times=ttime;
   Sal.srate=fs;
   Sal.nbchan=4;
   Sal.xmin=ttime(1);
   Sal.xmax=ttime(end);
   Sal.chanlocs=readlocs('pos_unipolar_dreem.loc');
   Sal.pnts=length(Sal.data);
   Sal.trials=1;
   %% filter it to detect spindles using Ferrareli et. al algorithm subsequently and the algorithms in Armand Mansen et. al for SWA
   Sal_filtered=pop_eegfiltnew(Sal,12,15,8250);
   A=1;