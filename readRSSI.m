function [rssi,utcDN,freqHz,raw] = readRSSI(fn,dataType,lc,doPlot)
% Michael Hirsch

%% user parameters
if nargin<2 || isempty(dataType), dataType = 'multifreq'; end 
if nargin<3 || isempty(lc), lc='b'; end 
if nargin<4 || isempty(doPlot), doPlot = true; end
%% open file
fid = fopen(fn,'r');
if fid<0, error(['Could not open file ',fn]), end
%% get headers
templ = '%s %s';
nHeaders = 5;
hdrs = textscan(fid,templ,nHeaders,...
                'Delimiter',',','MultipleDelimsAsOne',true);
            
FreqInd = ~cellfun(@isempty,regexp(hdrs{1},'Frequency.*','once'));
FreqHz = str2num(hdrs{2}{FreqInd});  %#ok<ST2NM>
            
AzElInd = ~cellfun(@isempty,regexp(hdrs{1},'Azimuth/Elevation.*','once'));
AzElDeg = str2num(hdrs{2}{AzElInd}); %#ok<ST2NM>

AttInd = ~cellfun(@isempty,regexp(hdrs{1},'Attenuation.*','once'));
AttDB = str2double(hdrs{2}{AttInd});

ModeInd = ~cellfun(@isempty,regexp(hdrs{1},'Mode/Bandwidth.*','once'));
Mode = hdrs{2}{ModeInd}; Mode = Mode(1:3);

%% purge blank lines in an Octave-compatible way (headerlines not handled well)
if isoctave
    junkLines = 3;
else %is matlab
    junkLines = 4;
end

for i = 1:junkLines
    tmp = fgetl(fid);
end
%% read data
templ = '%s%f%f';

raw = textscan(fid,templ,'Delimiter',' ','MultipleDelimsAsOne',true);

utcDN = datenum(raw{1},'yyyy-mm-ddTHH:MM:SS');
rssi = raw{3};
freqHz = raw{2};

fclose(fid);

%% plots
if doPlot
figure(1)
ax = gca;

switch lower(dataType)
    case 'singlefreq'
line(utcDN,rssi)
set(ax,'ylim',[-54 54])
datetick
title({[num2str(FreqHz/1e6,'%0.3f'),'MHz:  RSSI: ',datestr(utcDN(1),'yyyy-mmm-dd'),' to ',datestr(utcDN(end),'yyyy-mmm-dd')],...
       ['Az/El(Deg): ',num2str(AzElDeg,'%0.1f'),'  Att.(dB): ',num2str(AttDB),'  Mode: ',Mode]})
xlabel('Time (Local Boston)')
ylabel('RSSI (uncalibrated)')
grid on
    case 'multifreq'
        
if nargin<3, lc = 'b'; end

line(freqHz/1e6,rssi,'Color',lc)
set(ax,'ylim',[-54 54],'xtick',435:0.25:438)
xlabel('Freq (MHz)')
ylabel('RSSI (uncalibrated)')
    otherwise, warning(['plot type ',dataType,' unknown, unable to plot'])
end %switch
 
end % if doPlot

%%
if nargout==0, clear, end

end
