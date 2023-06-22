function [SW,incidence]=detect_sws(data,times,fs,sel_plot)
%% the input parameters set for this code are the following
%% data: an array composed between channels (in this case four- 4) x time and it is the fraction of EEG data you want to use to infer where are the sleep spindles.
%% time: this is an array of size time having the equivalences in time where the EEG data is defined. This array should be the same length as the size 2 of the EEG data, in this case the data input parameter.
%% fs: sampling frequency being 250Hz for this particular case
%% sel_plot: 0 if you don't want to plot the SWS holded in your EEG data, and 1 if you want to plot the SWS holded on your input data.
close all;
ttime=linspace(times(1),times(end),length(times));
Sal=eeg_emptyset();
Sal.data=data;
Sal.times=ttime;
Sal.srate=fs;
Sal.nbchan=4;
Sal.xmin=ttime(1);
Sal.xmax=ttime(end);
Sal.chanlocs=readlocs('pos_unipolar_dreem.loc');
Sal.pnts=length(Sal.data);
Sal.trials=1;
pop_saveset(Sal,'filename','sws.set')

[Data, Info] = swa_convertFromEEGLAB('sws.set');
Info = swa_getInfoDefaults(Info,'SW','envelope');

[Data.SWRef,Info]  = swa_CalculateReference(Data.Raw,Info);
[Data, Info,SW]    = swa_FindSWRef(Data,Info);
[Data, Info,SW]    = swa_FindSWChannels(Data, Info, SW);
[Info,SW]          = swa_FindSWTravelling(Info, SW);
SW=fix_traveling_delays(SW);

dur_total=(max(times)-min(times))/60;
incidence=length(SW)/dur_total;


if sel_plot==1
    figure;
    plot(times,Data.SWRef,'LineWidth',4);
    hold on;
    plot(times([SW.Ref_DownInd]),Data.SWRef([SW.Ref_DownInd]),'o','LineWidth',4);
    plot(times([SW.Ref_PeakInd]),Data.SWRef([SW.Ref_PeakInd]),'o','LineWidth',4);
    plot(times([SW.Ref_UpInd]),Data.SWRef([SW.Ref_UpInd]),'o','LineWidth',4);
    grid on;
    set(gca,'FontSize',17);
    ylabel('Amplitude [uV]');
    xlabel('time [s]');
    
    figure;
    [Pxx,F] = pwelch(Data.SWRef,700,100,1024,fs);
    plot(F,Pxx,'LineWidth',4);
    grid on;
    set(gca,'FontSize',17);
    xlabel('Frequency [Hz]');
    ylabel('Amplitude [uV^2/Hz]');
    
    figure;
    loglog(F,log(Pxx),'LineWidth',4);
    grid on;
    set(gca,'FontSize',17);
    xlabel('Frequency [Hz]');
    ylabel('Amplitude log[uV^2/Hz]');
end;
