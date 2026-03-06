%% Updated Oct24
% extract OE data when auto saving. Add movement to file name from
% character21, see below. Select file line 40
% last used March2026

% Close all the figures, clear the workspace...
close all; clc; clear;

trialName = 'MMtrial_06032026';

top_directory = fullfile('C:\Users\masgh\data\',trialName);
dataset_id_number = 1;

%prepend = 'javi';

% Scan folder
if dataset_id_number == 1
    %folder_info = fullfile(top_directory,thisFolder);
    folder_info = dir(top_directory);
    % Filter out non-directory items and '.' or '..'
    folder_info = folder_info([folder_info.isdir] & ~ismember({folder_info.name}, {'.', '..'}));

    names = {folder_info.name};
    % condensed version of the for loop
    % just renaming really and putting full file path in
    emg_files = struct(...
        'file_path', cellfun(@(n) fullfile(top_directory, n, 'Record Node 101', 'experiment1', 'recording1', 'structure.oebin'), names, 'UniformOutput', false), ...
        'name', cellfun(@(n) regexprep(n, '^javi_\d{2}_\d{2}_\d{2}_', ''), names, 'UniformOutput', false) ...
        );
    
end

% Select folder to process, chrono order
selected_indices = [4];

% Loop through the selected indices
for idx = selected_indices
    % Ensure the selected index is within bounds
    if idx > length(emg_files)
        warning('Index %d is out of bounds for emg_files.', idx);
        continue;
    end
    
    % Load EMG data from the selected file
    EMG = load_open_ephys_binary(emg_files(idx).file_path, 'continuous', 1);
    sampling_rate = round(1/diff(EMG.Timestamps(1:2)));
    
    % Select the portion of the data to save (adjust as needed)
    save_id = 1:length(EMG.Data); % Example: save the whole data range
    
    % Process and adjust timestamps
    t_amplifier = EMG.Timestamps(save_id);
    t_amplifier = t_amplifier - t_amplifier(1); % Set first time sample to 0
    disp('Making first time sample = 0');
    
    % Extract the amplifier data
    amplifier_data = EMG.Data(:, save_id);

   % Create the save file name with the full path
    save_filename = fullfile(top_directory, [trialName '_' emg_files(idx).name '.mat']);
    disp(['Saving ' save_filename]);
    
    % Save the data
    save(save_filename, 'amplifier_data', 't_amplifier', '-v7.3');
end
