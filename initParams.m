sampleTimes.main = 0.02;      % Must match TORCS
sampleTimes.control = 0.02;   % Must be less than (and an integer multiple of) mainSampleTime
sampleTimes.sensor = 0.04;
sampleTimes.v2v = 0.1;

delays.v2v = 0.01;
delays.sensor = 0.2;

spacing = 6;