%% Updated Oct24
% extract OE data when auto saving. Add movement to file name from
% character21, see below. Select file line 40
% last used March2026

% Close all the figures, clear the workspace...
close all; clc; clear;

top_directory = 'C:\Users\mszmjp1\OneDrive - The University of Nottingham\Projects\Other projects\HD Arrays\OEphys pilot data\Javi_VL_VM_06.03.26';
dataset_id_number = 1;

% Scan folder
if dataset_id_number == 1
    folder_info = dir(top_directory);
    
    % Filter out non-directory items and '.' or '..'
    folder_info = folder_info([folder_info.isdir] & ~ismember({folder_info.name}, {'.', '..'}));
    
    % Initialize struct array
    emg_files = struct();
    
    % Loop through each folder and create the file paths and names
    for i = 1:length(folder_info)
        folder_name = folder_info(i).name;
        
        % Generate full file path for each folder
        emg_files(i).file_path = fullfile(top_directory, folder_name, 'Record Node 101', 'experiment1', 'recording1', 'structure.oebin');
        
        % Extract the name starting from the 21st character if possible
        if length(folder_name) >= 21
            emg_files(i).name = folder_name(21:end); % Extract from the 21st character onward
        else
            emg_files(i).name = folder_name; % If less than 21 characters, use the whole folder name
        end
    end
    
    array_name = 'javi25%'; % CHANGE to reflect file name
end

% Select folder to process, chrono order
selected_indices = [1];

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
    save_filename = fullfile(top_directory, [array_name '_' emg_files(idx).name '.mat']);
    disp(['Saving ' save_filename]);
    
    % Save the data
    save(save_filename, 'amplifier_data', 't_amplifier', '-v7.3');
end
