function SW=fix_traveling_delays(SW)
for np=1:length(SW)
    temp=SW(np).Travelling_Delays;
    temp(isnan(temp))=0;
    SW(np).Travelling_Delays=temp;
end;