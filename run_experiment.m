% note: you must build the model meart_trace60 once before running this
% script!

if (exist('threshold') & exist('offset'))
    fprintf('\nUsing existing threshold and offset vectors')
else
    setthresh
end

%set 0 to mask noisy channel
channelmask = ones(1,60); % assume that all channels are good

synctimes = 0; %0 means disable, not relevant for this experiment

% stimulus combinations
I=eye(60);
stimcombs = [I; zeros(60)]; % each comb contains 1 electrode

%%

%which combinations to use
comb_stim_indexes=[1:60]; %all 
% comb_stim_indexes=[8];    %use just combination 8

N=1; % number of repeats per combination
Delta_T = .1; % time between repeats
hold_T=1;  %time between combinations

T_start=1*60;   %when to start stimulating (in sec)

map60_params.trigtrace_preframes = 0; % number of frames to save before stimulus
map60_params.trigtrace_postframes = 30 % " after stimulus

%compute params
dstimtimes=repmat([hold_T Delta_T*ones(1,N-1)],1,length(comb_stim_indexes));
stimtimes=(cumsum(dstimtimes)+T_start)*2000;

switchtimes=[];
switchtimes(1,:) = stimtimes - 100;
helpon=[];
for  i=1:length(comb_stim_indexes) % making sure the repeats will be for each comb one next to the other
    helpon= [helpon, repmat(comb_stim_indexes(i),1,N)];
end
switchtimes(2,:)=helpon;

% trig_labels = cellstr(num2str(helpon));
% Setting the stimulus intensity
stimulusintensity=[400 500 600 700 800] ;
switchtimes(3,:)=repmat(ones(1,N*length(comb_stim_indexes))*3,1,1); %use 3rd intensity for all combs

%%
if(N*length(comb_stim_indexes)*(map60_params.trigtrace_postframes +map60_params.trigtrace_preframes)>108000)
    error('Trigtrace data too large!!');
end

ibs_delaytimes = -1; % NOTE: -1 means disable, 0 means immediate stimulation!

target_model='meart_target_60';
host_model='meart_host_60';

rtwbuild(target_model)

%run host and target models:
open(host_model)


set_param([host_model,'/Data Packet Handler/Process Data/Iterate Frames/Triggered Store Trace/Delay'], 'Delay', num2str(8*map60_params.trigtrace_preframes))
set_param([host_model,'/Data Packet Handler/Process Data/Iterate Frames/Triggered Store Trace/Re-Triggerable Held Enable/Constant'], 'Value',num2str(map60_params.trigtrace_preframes+map60_params.trigtrace_postframes))
set_param([host_model,'/Data Packet Handler/Process Data/Iterate Frames/Triggered Store Trace/Select Syncs for Trigger'], 'Elements', '61')
set_param([host_model,'/Data Packet Handler/Process Data/Iterate Frames/Simulation Stopper'], 'maxtrigs', '10000')    

set_param(host_model, 'SimulationCommand', 'start')
pause(3)
start(tg)

pause(stimtimes(end)/2000+5);   %wait untill last stimulus

stop(tg)
set_param(host_model, 'SimulationCommand', 'stop')

%set it back to original
set_param([host_model,'/Data Packet Handler/Process Data/Iterate Frames/Triggered Store Trace/Delay'], 'Delay', 'presamples*8')
set_param([host_model,'/Data Packet Handler/Process Data/Iterate Frames/Triggered Store Trace/Re-Triggerable Held Enable/Constant'], 'Value', 'presamples + postsamples')
set_param([host_model,'/Data Packet Handler/Process Data/Iterate Frames/Triggered Store Trace/Select Syncs for Trigger'], 'Elements', 'triggerchannel')


