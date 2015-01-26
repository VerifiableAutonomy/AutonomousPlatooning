%% Straight figure
f = figure;
subplot(2,1,1);

load LateralErrorAt50kph

time = Errors.time;
lateralError = Errors.signals(3).values;

tmin = 90;
tmax = 150;
idx = time > tmin & time < tmax;

time = time(idx) - tmin;
lateralError = lateralError(idx,:);

peaks50 = max(lateralError);

plot([0 max(time)], [0 0], 'k--')
hold on;
plot(time,lateralError);
title({'Inter-vehicle lateral error for a 10 vehicle platoon' 'Subject to a lane change disturbance at t=0s' 'Speed: 50kph'});
xlabel('Time [s]');
ylabel('Lateral Error [m]');
axis([0 60 -0.4 1]);
subplot(2,1,2);

load LateralErrorAt90kph

time = Errors.time;
lateralError = Errors.signals(3).values;

tmin = 90;
tmax = 150;
idx = time > tmin & time < tmax;

time = time(idx) - tmin;
lateralError = lateralError(idx,:);

peaks90 = max(lateralError);


plot([0 max(time)], [0 0], 'k--')
hold on;
plot(time,lateralError);
title('Speed: 90kph');
xlabel('Time [s]');
ylabel('Lateral Error [m]');
axis([0 60 -0.4 1]);
f.Position(4) = f.Position(4)*1.5;
f.Position(2) = f.Position(2)/2;

%% Damping with speed

speeds = int32(50:5:90) ;

for i=1:length(speeds)
    load(['data/LateralControlAt' num2str(speeds(i)) 'kph.mat']);
    time = Errors.time;
    lateralError = Errors.signals(3).values;

    tmin = 120;
    tmax = 180;
    idx = time > tmin & time < tmax;
    lateralError = lateralError(idx,:);
    peaks = max(lateralError);
    peaksAll(i,:) = peaks;
    for j=2:length(peaks)
        peaksNormalised(i,j-1) = peaks(j)/peaks(j-1);
    end
end
figure
plot(peaksNormalised');



 %% Steady state turn
f = figure;
load LateralErrorAt50kph_SSTurn

time = Errors.time;
lateralError = Errors.signals(3).values;

tmin = 180;
tmax = 300;
idx = time > tmin & time < tmax;

time = time(idx) - tmin;
lateralError = lateralError(idx,:);

plot([0 max(time)], [0 0], 'k--')
hold on;
plot([60 60], [-0.6 0.6], 'k:')
plot(time,lateralError); %-repmat(lateralError(1,:),[length(lateralError), 1])
title({'Inter-vehicle lateral error for a 10 vehicle platoon' 'Subject to lane change disturbances during steady state cornering' 'Speed: 50kph'});
xlabel('Time [s]');
ylabel('Lateral Error [m]');
text(95,0.2,{'Manouver in' 'direction of corner'},'HorizontalAlignment','center');
text(35,-0.3,{'Manouver away from' 'direction of corner'},'HorizontalAlignment','center');
f.Position(3) = f.Position(3)*2;
