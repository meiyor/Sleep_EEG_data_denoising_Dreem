function [SString_Total,data_after_ADJUST,data_unipolar_t]=remove_artifact_sleep_inv(name_of_the_file,thr_time,read_file,SString_Total,time_follow,data_unipolar_t)
%% name_of_the_file, string with the name of the file you want to process include the .edf with the absolute address of the file.
%% thr_time, vector of two positions setting up the beginning and the end of the time to process on each iteration. 
%% read_file, selector in 1 to read the bipolar file and transform it to unipolar representation, if 0 the bipolar representation will be mantained and the resulting representation of the results will be returned recurrently.
%% SString_Total, representation of the current output, this will be returned recurrently. 
%% time_follow, time offset to start in a desired beginning, you can process the signal from this point in time as you desire.
%% data_unipolar_t, representation of the unipolar data that is returned recurrently.
rng(1);
close all;

%% define the hypnogram for a particular subject
names=strsplit(name_of_the_file,'.');
load([names{1} '_hypnogram.mat']);
pos=max(find(time_s<=time_follow));

label_stage=label_vec(pos);
if label_stage==-1
    return;
end;
%% reduces artifacts per window 3-4 seconds this is for setting the thr_time
%rng(1);
if read_file == 1
    [data_unipolar,SString_L]=transform_bipolar_to_unipolar(name_of_the_file);
    %SString_L = pop_eegfiltnew(SString_L,1,120,8250);
else
    SString_L=SString_Total;
    data_unipolar=data_unipolar_t;
end;
ica_size=4;
SString_Total=SString_L;
data_unipolar_t=data_unipolar;
ccount=0;
sample_beg=round(thr_time(1)*SString_L.srate);
sample_end=round(thr_time(2)*SString_L.srate);
SString_L.data=data_unipolar(:,sample_beg:sample_end);
SString_L.times=SString_L.times(sample_beg:sample_end);
%% accelerometer signal not included in this analysis 
SString_L.xmax=sample_end-sample_beg+1;
SString_L.nbchan=4;
%SString_L.chanlocs=SString_L.chanlocs(2:6);
SString_L.pnts=SString_L.xmax;
while ica_size>1 %% && any(max(SString_L.data')>=100) %% don't use any amplitude criteria for now
    SString_L.chanlocs=readlocs('pos_unipolar_dreem.loc');
    SString_L=pop_cleanline(SString_L,'LineFrequencies',[50,60]);

    %% don't average across the channels they are so few and they are already references to Fp1
    %SString_L=pop_reref(SString_L,[]);
    
    %% clean raw process
    data_clean_raw=clean_rawdata(SString_L,5,[0.25 0.75],0.85,-1,-1,-1);
   
    %% avoid channel removal
    if size(data_clean_raw.data,1)~=4
        data_clean_raw=SString_L;
    end;
    
    %rmpath(genpath('/media/jmm/One_Touch/eeglab14_1_1b'))
    %% don't use the bssemg for having the artifacts detected by the ICA process
    %data_clean_raw=pop_autobssemg(data_clean_raw,1,0.85,'bsscca',{'eigratio',1e6},'emg_psd',{'ratio',10,'fs',250,'range',[1 10]});
    

    [data_clean_raw.icaweights,data_clean_raw.icasphere]=runica(data_clean_raw.data(:,:),'sphering','on','lrate',3e-6,'maxsteps',100,'reset_randomseed','off');
    
    data_clean_raw.icawinv=inv(data_clean_raw.icaweights*data_clean_raw.icasphere);
    data_clean_raw.data= repmat(data_clean_raw.data(:,:),1,1,100);
    data_clean_raw.trials=100;
    data_clean_raw.icachansind=[1 2 3 4];
    delete('report_sleep.txt');
    [art_channels]=ADJUST(data_clean_raw,'report_sleep.txt');
    
    if ccount>=20
        %data_after_ADJUST=pop_subcomp(data_clean_raw,[1,2,3,4,5]);
        mvmax=max(art_adjust);
        posmax=max(find(art_adjust==mvmax));
        data_after_ADJUST=data_ADJUST{posmax};
        data_after_ADJUST.data=mean(data_after_ADJUST.data(:,:,:),3);
        data_after_ADJUST.trials=1;
        break;
    end;

    data_after_ADJUST=pop_subcomp(data_clean_raw,art_channels);
    art_adjust(ccount+1)=length(art_channels);
    art_A{ccount+1}=art_channels;
    data_after_ADJUST.data=mean(data_after_ADJUST.data(:,:,:),3);
    data_after_ADJUST.trials=1;
    
    if  label_stage==2
        filter_p='db2';
    else
        filter_p='coif1';
    end;
    
    for ch=1:4
       [data_res{ch},l{ch}]=wavedec(real(data_after_ADJUST.data(ch,:)),3,filter_p);
       approx{ch} = appcoef(data_res{ch},l{ch},filter_p);
       [cd1{ch},cd2{ch},cd3{ch}] = detcoef(data_res{ch},l{ch},[1 2 3]);
       %% remove the octave functions if this necessary from the EEGlab path in functions->octavefunc
       if label_stage==3
            data_after_ADJUST.data(ch,:)=(resample(double(cd1{ch}),size(data_after_ADJUST.data,2),length(cd1{ch}))+resample(double(cd2{ch}),size(data_after_ADJUST.data,2),length(cd2{ch}))+resample(double(cd3{ch}),size(data_after_ADJUST.data,2),length(cd3{ch}))+resample(double(approx{ch}),size(data_after_ADJUST.data,2),length(approx{ch})))/4;
       else
            data_after_ADJUST.data(ch,:)=(resample(double(cd1{ch}),size(data_after_ADJUST.data,2),length(cd1{ch}))+resample(double(cd2{ch}),size(data_after_ADJUST.data,2),length(cd2{ch}))+resample(double(cd3{ch}),size(data_after_ADJUST.data,2),length(cd3{ch})))/3;
       end;
       %%data_clean_raw.data(ch,:)=(resample(double(cd1{ch}),size(data_clean_raw.data,2),length(cd1{ch}))+resample(double(cd2{ch}),size(data_clean_raw.data,2),length(cd2{ch}))+resample(double(cd3{ch}),size(data_clean_raw.data,2),length(cd3{ch})))/3;
    end;
        
    data_ADJUST{ccount+1}=data_after_ADJUST;
    
    ica_size=size(data_after_ADJUST.icawinv,2); 
    ccount=ccount+1;
    SString_L=SString_Total;
    sample_beg=round(thr_time(1)*SString_L.srate);
    sample_end=round(thr_time(2)*SString_L.srate);
    SString_L.data=data_unipolar(:,sample_beg:sample_end);
    SString_L.times=SString_L.times(sample_beg:sample_end);
    SString_L.xmax=sample_end-sample_beg+1;
    SString_L.nbchan=4;
    SString_L.chanlocs=SString_L.chanlocs;
    SString_L.pnts=SString_L.xmax;
  
end;
if ccount==0
    data_after_ADJUST=SString_L;   
end;
if ccount<20
    A=1;
end;
%% adjust amplitude 
if label_stage==3
    data_after_ADJUST.data=data_after_ADJUST.data*5;
 else
    for ch=1:4
         mmax(ch)=max(data_after_ADJUST.data(ch,:));
         mmin(ch)=min(data_after_ADJUST.data(ch,:));
         mdef(ch)=max(mmax(ch),abs(mmin(ch)));
         if mdef(ch)>=50
            data_after_ADJUST.data(ch,:)=(data_after_ADJUST.data(ch,:)./mdef(ch))*50;
         end;
    end;
end;
%if label_stage==0 || label_stage==1
%         data_after_ADJUST = pop_eegfiltnew(data_after_ADJUST,1,120,8250);
%end
A=1;
  