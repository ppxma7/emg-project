clear variables
close all
clc

mypath  = 'C:\Users\masgh\data\nikki\';
dataset = {
    'BOOT_01NB_TA_R_PREBOOT_WALKING.mat',...
    'BOOT_01NB_TA_R_POSTBOOT_WALKING_WITHHEEL.mat',...
    'BOOT_01NB_TA_R_POSTBOOT_WALKING.mat',...
    'BOOT_01NB_GM_R_PREBOOT_WALKING.mat',...
    'BOOT_01NB_GM_R_POSTBOOT_WALKING_WITHHEEL.mat',...
    'BOOT_01NB_GM_R_POSTBOOT_WALKING.mat'
    };

%dataset = {'BOOT_01NB_GM_R_POSTBOOT_WALKING_WITHHEEL.mat'};

fs = 2000;
ord = 5;
win_smp = 200;

% --- Filter design (done once outside loop) ---
% Bandpass 20-500 Hz, 5th-order Butterworth
[b_bp, a_bp] = butter(ord, [20 500]/(fs/2), 'bandpass');

% Notch at 50 Hz and harmonics up to Nyquist
notch_freqs = 50:50:floor(fs/2 - 1);
wo = notch_freqs / (fs/2);
bw = wo / 35;  % Q ~35

thisMean = zeros(1, numel(dataset));
thisMax = zeros(1, numel(dataset));

for ii = 1:numel(dataset)
    close all

    thisfile = load(fullfile(mypath, dataset{ii}));
    data = double(thisfile.Data{1});  % [samples x channels]
    t = thisfile.Time{1};

    % bandpass
    emg_filt = filtfilt(b_bp, a_bp, data);

    % notch 50hz steps
    for i = 1:length(notch_freqs)
        [b_n, a_n] = iirnotch(wo(i), bw(i));
        emg_filt = filtfilt(b_n, a_n, emg_filt);
    end

    % remove bottom 5% 
    n_chan   = size(emg_filt, 2);
    n_reject = max(1, round(0.05 * n_chan));
    
    psd_snr = zeros(n_chan, 1);
    baseline_rms = zeros(n_chan, 1);

    for ch = 1:n_chan
        [pxx, f] = pwelch(emg_filt(:,ch), [], [], [], fs); % power spectral density
        psd_snr(ch) = mean(pxx(f >= 20 & f <= 500)) / mean(pxx(f < 20 | f > 500));
        baseline_rms(ch) = rms(emg_filt(1:round(0.1*fs), ch));  % first 100ms
    end

    % High SNR + low baseline = good channel
    score        = zscore(psd_snr) - zscore(baseline_rms);
    [~, idx]     = sort(score);
    bad_chans    = idx(1:n_reject);
    good_chans   = idx(n_reject+1:end);
    emg_clean    = emg_filt(:, good_chans);

    % more channel removal (>5x median RMS)
    chan_rms  = rms(emg_clean);  % RMS per channel
    med_rms   = median(chan_rms);
    outlier   = chan_rms > 5 * med_rms;
    emg_clean(:, outlier) = [];
    fprintf('Outlier removal: removed %d additional channels\n', sum(outlier));

    fprintf('File %d: removed %d / %d channels\n', ii, n_reject, n_chan);

    % rms envelope
    n_ch    = size(emg_clean, 2);
    rms_all = zeros(size(emg_clean));

    for ch = 1:n_ch
        rms_all(:,ch) = movmean(emg_clean(:,ch).^2, win_smp).^0.5;
    end

    rms_mean = mean(rms_all, 2);
    rms_max = max(rms_all,[],2);
    thisMean(ii) = mean(rms_mean);
    thisMax(ii) = mean(rms_max);

    % --- Plot ---
    h = figure;
    tiledlayout(2,1);

    nexttile
    plot(t, rms_all, 'LineWidth', 1);
    xlabel('Time (s)'); ylabel('RMS'); title('Per-channel RMS');

    nexttile
    plot(t, rms_mean, 'LineWidth', 1.5);
    xlabel('Time (s)'); ylabel('RMS'); title('Mean RMS');

    filename = fullfile(mypath, [extractBefore(dataset{ii}, '.') '_plot']);
    print(h, filename, '-dpng', '-r300');
end

% Summary
T = table(dataset', thisMean',thisMax', 'VariableNames', {'Condition', 'MeanRMS', 'MaxRMS'});
disp(T);
writetable(T, fullfile(mypath,'rms_summary.csv'));