function RunSweepRSSI(dataDir)

filelist = dir([dataDir,filesep,'FreqSweep_*.RSSIlog']);
filelist = {filelist.name}; %extract only name field

nFile = length(filelist);
%% user param
nFreq = 301; %a priori
xticks = 435:0.25:438; %a priori
ylims = [-55 55]; % a priori
%% preallocation
figure(1),clf(1)
axRaw=axes;
xlabel('Freq [MHz]'), ylabel('RSSI (uncalibrated)')
rssi = nan(nFreq,nFile);
display(['Plotting ',int2str(nFile),' files.'])
%% read data
for iFile = 1:nFile
    currFN = [dataDir,filesep,filelist{iFile}];
     [rssi(:,iFile),utcDN,freqHz] = readRSSI(currFN,'multifreq',[],false);
    
     line(freqHz/1e6,rssi(:,iFile),'Color',rand(1,3))
     
end %for
set(axRaw,'ylim',ylims,'xtick',xticks)
grid on

%% other plots
figure(2),clf(2)
axM = axes('parent',2);
maxrssi = max(rssi,[],2);
line(freqHz/1e6,maxrssi,'color','r','parent',axM,'displayname','Max');
xlabel('Freq [MHz]')
ylabel('RSSI (uncalibrated)')
grid on
set(axM,'ylim',ylims,'xtick',xticks)

meanrssi = mean(rssi,2);
line(freqHz/1e6,meanrssi,'color','k','parent',axM,'displayname','Mean');

medianrssi = median(rssi,2);
line(freqHz/1e6,medianrssi,'color','g','parent',axM,'displayname','Median');

minrssi = min(rssi,[],2);
line(freqHz/1e6,minrssi,'color','b','parent',axM,'displayname','Min');

rssi90 = prctile(rssi,90,2);
line(freqHz/1e6,rssi90,'color','r','linestyle','-.','parent',axM,'displayname','90th %');

rssi10 = prctile(rssi,10,2);
line(freqHz/1e6,rssi10,'color','b','linestyle','-.','parent',axM,'displayname','10th %');

drawnow
legend('show','location','south')


%{
figure(4),clf(4)
axStdDev = axes('parent',4);
stddevRssi = std(rssi,0,2);
plot(freqHz/1e6,stddevRssi);
xlabel('Freq [MHz]'), ylabel('stddev(RSSI) (uncalibrated)')
grid on
set(axStdDev,'xtick',xticks)
%}

end %function