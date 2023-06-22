function [delta_ch,delta_av]=delta_rhytm_PSD(data,fs)
%% plot EEG data with 4 channels with fs=250Hz
close all
for ch_ind = 1:4
        [Pxx{ch_ind},F{ch_ind}] = pwelch(data(ch_ind,:),700,100,1024,fs);
        plot(F{ch_ind},Pxx{ch_ind},'LineWidth',4);
        hold on;
        delta_ch(ch_ind)=mean(Pxx{ch_ind}(F{ch_ind}>=1 | F{ch_ind}<=4));
end;
grid on;
set(gca,'FontSize',17);
xlabel('Frequency [Hz]');
ylabel('Amplitude [uV^2/Hz]');
legend({'F7','F8','O1','O2'});
xlim([0 25]);
delta_av=mean(delta_ch);
