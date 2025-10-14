clear; clf; clc;

% define time
dt = 0.1;
t = [0:dt:3000];

% acceleration
acc = 0.1*sin(t/50) + 0.03*sin(t.^2);

subplot(3,1,1);
plot(t,acc);
ylabel('Acc m/s^2');

% calulate velocity
vel = cumtrapz(t,acc);
%[~,id] = find( vel < 0.01);
[~,id] = findpeaks(-vel);

subplot(3,1,2); hold on;
plot(t,vel);
plot(t(id),vel(id), 'or');
ylabel('vel m/s');

% calculate distance
pos = cumtrapz(t,vel);
subplot(3,1,3);
plot(t,pos);
ylabel('m/s');
