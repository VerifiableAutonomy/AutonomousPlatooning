figure
subplot(2,1,1);

load LateralErrorAt50kph

time = Errors.time;
lateralError = Errors.signals(3).values;

tmin = 70;
tmax = 115;
idx = time > tmin & time < tmax;

time = time(idx) - tmin;
lateralError = lateralError(idx,:);

plot([0 max(time)], [0 0], 'k--')
hold on;
plot(time,lateralError);
title('Lateral control of a 10 vehicle platoon subject to a lane change disturbance at 50kph');
xlabel('Time [s]');
ylabel('Lateral Error [m]');
subplot(2,1,2);

load LateralErrorAt90kph

time = Errors.time;
lateralError = Errors.signals(3).values;

tmin = 240.75;
tmax = 285.75;
idx = time > tmin & time < tmax;

time = time(idx) - tmin;
lateralError = lateralError(idx,:);

plot([0 max(time)], [0 0], 'k--')
hold on;
plot(time,lateralError);
title('Lateral control of a 10 vehicle platoon subject to a lane change disturbance at 90kph');
xlabel('Time [s]');
ylabel('Lateral Error [m]');
subplot(2,1,2);

