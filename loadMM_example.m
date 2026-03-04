mypath = "C:\Users\masgh\data\";

dataset = "Mat_VL_oct_4_2024_2024-10-04_17-46-07 50%RAMP 2.mat";

thisfile = load(fullfile(mypath,dataset));

%%
close all

figure
t = thisfile.t_amplifier;
data = thisfile.amplifier_data; % [27 x 927932]

% Offset each channel for visibility
offset = max(range(data, 2)) * 1.5; % auto-scale spacing

hold on;
for ch = 1:27
    plot(t, data(ch,:) + (ch-1)*offset, 'k', 'LineWidth', 0.5);
end

yticks((0:26)*offset);
yticklabels(arrayfun(@(x) sprintf('Ch %d', x), 1:27, 'UniformOutput', false));
xlabel('Time (s)');
title('All 27 Channels');

%% just ch14
fs = 1 / mean(diff(thisfile.t_amplifier));  % auto-detect sample rate
t  = thisfile.t_amplifier;
ch = thisfile.amplifier_data(14, :);

% Low-pass Butterworth filter at 20 Hz
fc  = 20;          % cutoff (Hz)
ord = 4;           % filter order
[b, a] = butter(ord, fc / (fs/2), 'low');
ch_filt = filtfilt(b, a, ch);

% 
% % Plot
% figure;
% plot(t, ch, 'Color', [0.7 0.7 0.7]); hold on;
% plot(t, ch_filt, 'b', 'LineWidth', 1.5);
% xlabel('Time (s)'); ylabel('Amplitude');
% title('Ch 14 — Raw vs Filtered (20 Hz LP)');
% legend('Raw', 'Filtered');

%% --- Raw vs Filtered ---
close all
clc
figure;
plot(t, ch, 'Color', [0.7 0.7 0.7]); hold on;
plot(t, ch_filt, 'b', 'LineWidth', 1.5);
xlabel('Time (s)'); ylabel('Amplitude');
title('Ch 14 — Raw vs Filtered (20 Hz LP)');
legend('Raw', 'Filtered');

% --- FFT / Power Spectrum ---
N    = length(ch);
f    = (0:N-1) * (fs/N);
half = 1:floor(N/2);

raw_fft  = abs(fft(ch));
filt_fft = abs(fft(ch_filt));

figure;
semilogy(f(half), raw_fft(half),  'Color', [0.7 0.7 0.7]); hold on;
semilogy(f(half), filt_fft(half), 'b', 'LineWidth', 1.5);
xline(20, 'r--', '20 Hz cutoff', 'LineWidth', 1.2);
xlabel('Frequency (Hz)'); ylabel('Power (log scale)');
title('Power Spectrum — Raw vs Filtered');
legend('Raw', 'Filtered');
xlim([0 fs/2]);

%--- Rectify, Envelope, RMS ---
% Rectify
ch_rect = abs(ch_filt);

% Envelope via low-pass on rectified signal (10 Hz)
[b2, a2]  = butter(4, 10/(fs/2), 'low');
ch_env    = filtfilt(b2, a2, ch_rect);

% RMS in sliding window
win_ms  = 200;                        % window size in ms
win_smp = round(win_ms * fs / 1000);  % convert to samples
ch_rms  = movmean(ch_rect.^2, win_smp).^0.5;

figure;
subplot(3,1,1);
plot(t, ch_rect, 'Color', [0.7 0.7 0.7]);
ylabel('Amplitude'); title('Rectified');

subplot(3,1,2);
plot(t, ch_rect, 'Color', [0.85 0.85 0.85]); hold on;
plot(t, ch_env, 'b', 'LineWidth', 1.5);
ylabel('Amplitude'); title('Envelope (10 Hz LP)');
legend('Rectified', 'Envelope');

subplot(3,1,3);
plot(t, ch_rms, 'r', 'LineWidth', 1.5);
ylabel('RMS'); xlabel('Time (s)');
title(sprintf('RMS (%d ms window)', win_ms));

% spit out mvc
mvc_rms = 800;  % 
ch_rms_norm = (ch_rms / mvc_rms) * 100;  % now in % MVC


rms_mean = mean(ch_rms_norm);
rms_std  = std(ch_rms_norm);
rms_cv   = (rms_std / rms_mean) * 100;  % coefficient of variation (%)
rms_max  = max(ch_rms_norm);

disp(table(rms_mean, rms_std, rms_cv, rms_max))