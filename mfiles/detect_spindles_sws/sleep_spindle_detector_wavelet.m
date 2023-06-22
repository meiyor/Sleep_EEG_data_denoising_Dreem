function [timespindles,durspindles,MINS,DENS,time_SS,dur_SS,dens_SS]=sleep_spindle_detector_wavelet(data,times,fs,nbchan,sel_plot,ch_sel_ind,time_c1,time_c2,center_freq)
%% data is must not be filtered it is filtered by the wavelet decomposition method
%% the input parameters set for this code are the following
%% data: an array composed between channels (in this case four- 4) x time and it is the fraction of EEG data you want to use to infer where are the sleep spindles.
%% time: this is an array of size time having the equivalences in time where the EEG data is defined. This array should be the same length as the size 2 of the EEG data, in this case the data input parameter.
%% fs: sampling frequency being 250Hz for this particular case
%% nbchan: four (4) for this particular case
%% sel_plot: 0 if you don't want to plot the spindles holded in your EEG data, and 1 if you want to plot the sleep spindles holded on your input data. 
%% ch_sel_in: the user must specify what channels the want to plot as numerical indeces [1, 2, 3 or 4], after the bipolar set is transformed to unipolar the indeces of the channels are {F7, F8, O1, O2}.
%% time_c1: time constrain 1 for the spindles detection suggested to define it in 0.3
%% time_c2: time constrain 2 for the spindles detection suggested to define it in 0.5
%% center_freq: define this center frequency between 11-13Hz define it following the convinience of the user
%% the output parameters set for this code are the following
%% timespindles: cell array with a size equal to number channels and for each channel we have a specific number of spindles detections. In this array we have the time where the spindles started in the time-domain vector.
%% durspindles: cell array with a size equal to number channels and for each channel we have a specific number of spindles detections. In this array we have the duration of spindles in seconds.
%% MINS: number of minutes that the data trial is taken in this analysis, this measure is taken for each channel.
%% DENS: Density of spindles detected per each minute across the trial, this measure is calculated for each channel.
%% time_SS: a sorted array grouping the spindles starting times detected for each channel. The array is sorted from low to high in seconds reporting the times where the spindles started.
%% dur_SS: a sorted array grouping the spindles duration times detected for each channel. The array is sorted from low to high in seconds reporting the spindles duration. The length of time_SS and dur_SS are equal.
%% dens_SS: a number representing the density of spindles detected per minute in the entire trial after grouping all the different spindles detected for each channel.
close all;
for ch=1:nbchan
    %% design the wavelet
    fc=center_freq;
    n=6;
    ss=n/(2*pi*fc);
    tp=2*ss^2;
    tStart = -4;
    tStop = 4;
    timeVector = linspace(tStart,tStop, (tStop-tStart)*fs );
    psiWavelet = (pi*tp)^(-0.5).*exp(2*1i*pi*fc.*timeVector).*exp(-timeVector.^2/tp);

    input = psiWavelet;
    Nfft = 10 * 2^nextpow2(length(input));
    psd = 20.*log10(fftshift(abs(fft(input,Nfft))));
    freqs = [0:Nfft - 1].*(fs/Nfft);
    freqs(freqs >= fs/2) = freqs(freqs >= fs/2) - fs;
    freqs = fftshift(freqs);

    tt=times;
    
    fsig=conv(data(ch,:),psiWavelet,'same');
    ssig=smooth(abs(real(fsig)),0.1*fs);
    baseline=mean(ssig);

    th=2*baseline;
    cores=ssig>th;

    %% detect consecutive ones between 0.3 and 3 s
    coress=num2str(cores)';
    pattern=num2str(ones(round(fs*time_c1),1));
    beg=strfind(coress,pattern'); %start points of each candidate core
    b1=[0;diff(beg')];
    beg(b1==1)=[];

    %% store duration of each core
    dur=zeros(size(beg));
    for jj=1:length(beg)
            k=1;
            while(cores(beg(jj)+k)==1 && length(cores)>beg(jj)+k)
                k=k+1;
            end;
            dur(jj)=k;
    end;
    beg(dur>3*fs)=[];
    dur(dur>3*fs)=[];

    %% now extend the spindles: at least 0.5 s above th2=2*baseline
    th2=1.5*baseline;
    candidates=ssig>th2;

    %% detect consecutive ones greater than 0.5 s
    candidatess=num2str(candidates)';
    pattern=num2str(ones(round(fs*time_c2),1));
    begc=strfind(candidatess,pattern'); %start points of each candidate core
    b1=[0;diff(begc')];
    begc(b1==1)=[];
    
    %% store duration of each extension
    durc=zeros(size(begc));
    for jj=1:length(begc)
            k=1;
            while(candidates(begc(jj)+k)==1 && length(candidates)>begc(jj)+k)
                k=k+1;
            end;
            durc(jj)=k;
    end;

    %% now combine the two classifications
    C=zeros(size(cores));
    for jj=1:length(beg)
        C(beg(jj):beg(jj)+dur(jj))=1;
    end
    
    E=zeros(size(cores));
    for jj=1:length(begc)
        E(begc(jj):begc(jj)+durc(jj))=1;
    end
    %% intersect
    EC=E&C;
    %% adjust duration
    b1=diff(EC');
    begec=find(b1==1);
    
    ind=zeros(size(begec));
    
    for jj=1:length(begec)
        truebeg=find(begc<=begec(jj));
        if ~isempty(truebeg)
        ind(jj)=truebeg(end);
        else ind(jj)=NaN;
        end
    end
    ind(isnan(ind))=[];
    BEG=begc(ind);
    DUR=durc(ind);
    
    EPTS=BEG+DUR;
    distance=-EPTS(1:end-1)+BEG(2:end);
    while (any(distance<fs))
        ind=find(distance<fs);
        ind=ind(1);
        if (DUR(ind)+distance(ind)+DUR(ind+1))<3*fs
            BEG(ind+1)=[];
            DUR(ind)=DUR(ind)+distance(ind)+DUR(ind+1);
            DUR(ind+1)=[];
            distance=BEG(2:end)-(BEG(1:end-1)+DUR(1:end-1)); %update distance
        else;
            distance(ind)=999; %do not merge
        end;
    end;

    beg=tt(BEG);
    DUR=DUR/fs;
    dur_res=[];
    mins=numel(data(ch,:))/60/fs;
    beg_res=unique(beg,'stable');
    for ic=1:length(beg_res)
         dur_res(ic)=DUR(max(find(beg==beg_res(ic))));
    end;
    dens=length(beg_res)/mins;
    timespindles{ch}=beg_res';
    durspindles{ch}=dur_res'+0.5;
    MINS(ch)=mins;
    DENS(ch)=dens;
end;
if sel_plot==1
    figure;
    plot(times,data(ch_sel_ind,:),'LineWidth',4);
    hold on;
    for ch_sel=1:4
       if ch_sel==1
           time_S=timespindles{ch_sel}';
           dur_S=durspindles{ch_sel}';
       else
          for cc=1:length(timespindles{ch_sel}) 
              val_ref=time_S-timespindles{ch_sel}(cc);
              if all( val_ref>3 | val_ref<-3 )
                  time_S=[time_S timespindles{ch_sel}(cc)];
                  dur_S=[dur_S durspindles{ch_sel}(cc)];
              end;
          end;
           
       end;
    %   plot(timespindles{ch_sel},zeros([1 length(timespindles{ch_sel})]),'ro','LineWidth',4);
    %   plot(timespindles{ch_sel}+durspindles{ch_sel},zeros([1 length(timespindles{ch_sel})]),'yo','LineWidth',4);
    end;
    time_SS=sort(time_S);
    for icont=1:length(time_SS)
        dur_SS(icont)=dur_S(find(time_S==time_SS(icont)));
    end;
    plot(time_SS,zeros([1 length(time_SS)]),'ro','LineWidth',4);
    plot(time_SS+dur_SS,zeros([1 length(time_SS)]),'yo','LineWidth',4);
    grid on;
    set(gca,'FontSize',17);
    xlabel('time [s]');
    ylabel('Amplitude [uV]');
    figure;
    for ch_ind = 1:4
        [Pxx{ch_ind},F{ch_ind}] = pwelch(data(ch_ind,:),700,100,1024,fs);
        plot(F{ch_ind},Pxx{ch_ind},'LineWidth',4);
        hold on;
    end;
    grid on;
    set(gca,'FontSize',17);
    xlabel('Frequency [Hz]');
    ylabel('Amplitude [uV^2/Hz]');
    legend({'F7','F8','O1','O2'});
    figure;
    for ch_ind = 1:4
        loglog(F{ch_ind},log(Pxx{ch_ind}),'LineWidth',4); %% use plot if this is necessary
        hold on;
    end;
    grid on;
    set(gca,'FontSize',17);
    xlabel('Frequency [Hz]');
    ylabel('Amplitude log[uV^2/Hz]');
    legend({'F7','F8','O1','O2'});
    %xlim([0,25]);
end;
%% dense calculation
dens_SS=length(time_SS)/mean(MINS);
