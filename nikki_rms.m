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

%dataset = {'BOOT_01NB_GM_R_POSTBOOT_WALKING_WITHHEEL.mat'}

fs      = 2000;
fc      = 20;
ord     = 4;
win_smp = round(200 * fs / 1000);

[b, a] = butter(ord, fc/(fs/2), 'low');

thisMean = zeros(1, numel(dataset));

for ii = 1:numel(dataset)
    close all

    thisfile = load(fullfile(mypath, dataset{ii}));
    data = thisfile.Data{1};
    t    = thisfile.Time{1};
    
    % quick QA check
    rms_per_ch = sqrt(mean(double(data).^2));          % RMS of each channel
    med_rms = median(rms_per_ch);
    bad_ch = rms_per_ch > 10 * med_rms; % flag channels >5x median
    %data2 = data;
    data(:, bad_ch) = [];
    n_ch = size(data, 2);
    fprintf('Removed %d bad channels\n', sum(bad_ch));

    rms_all     = zeros(size(data));
    ch_rect_all = zeros(size(data));

    for ch = 1:n_ch
        ch_filt = filtfilt(b, a, double(data(:, ch)));
        ch_rect_all(:,ch) = abs(ch_filt);
        rms_all(:,ch) = movmean(ch_rect_all(:,ch).^2, win_smp).^0.5;
    end

    ch_rect_mean = mean(ch_rect_all, 2);
    rms_mean = mean(rms_all, 2);

    % Plot
    h = figure;
    tiledlayout(2,1);

    nexttile
    plot(t, rms_all, 'LineWidth', 1.5);
    xlabel('Time (s)'); ylabel('RMS'); title('Per-channel RMS');

    nexttile
    plot(t, ch_rect_mean, 'DisplayName', 'Rectified mean'); hold on;
    plot(t, rms_mean, 'DisplayName', 'RMS mean');
    xlabel('Time (s)'); legend;
    
    filename = fullfile(mypath,[extractBefore(dataset{ii},'.') '_plot']);
    print(h,filename, '-dpng', '-r300');

    thisMean(ii) = mean(rms_mean);

    % % Waterfall plot
    % data_norm = data ./ (2 * sqrt(mean(data.^2)) + eps);
    % offsets   = (n_ch:-1:1);
    % data_plot = data_norm + offsets;
    % figure('Color','k');
    % plot(t, data_plot, 'Color', [0.3 0.8 0.5 0.4], 'LineWidth', 0.3);
    % yticks(1:n_ch); yticklabels(fliplr(1:n_ch));
    % xlabel('Time (s)'); xlim([t(1) t(end)]); ylim([0 n_ch+1]);
    % set(gca,'Color','k','XColor','w','YColor','w'); box off;
end

% Table + one-way ANOVA
% T = table(dataset', thisMean', 'VariableNames', {'Condition','MeanRMS'});
% disp(T);
% [p, tbl, stats] = anova1(thisMean);


% %%
% data_norm = data ./ (2 * sqrt(mean(data.^2)) + eps);
% offsets   = (n_ch:-1:1);
% data_plot = data_norm + offsets;
% figure('Color','k');
% plot(t, data_plot, 'Color', [0.3 0.8 0.5 0.4], 'LineWidth', 0.3);
% yticks(1:n_ch); yticklabels(fliplr(1:n_ch));
% xlabel('Time (s)'); xlim([t(1) t(end)]); ylim([0 n_ch+1]);
% set(gca,'Color','k','XColor','w','YColor','w'); box off;