tg = xpc;
tg.load('meart_trace60');
tg.StopTime = 2.0;
start(tg);
pause(3);
data = reshape(permute(reshape(tg.OutputLog,[],8,60),[2 1 3]),[],60);
offset = mean(data);
threshold = -10*std(data);
figure, plotchans(data, 10000)