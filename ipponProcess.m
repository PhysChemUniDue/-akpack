function ipponProcess(varargin)
% IPPONPROCESS processes experimental data fromt the IPPon experiment. Make
% sure there's an '*_expData_*.mat' in the name of the file you want to
% process.
%
%   IPPONPROCESS() processes the data from the current folder and saves it
%   as a .mat file with the name 'ProcessedData.mat'.
%   IPPONPROCESS(ARG) - if a folder is passed as an argument ARG the data
%   from this folder is processed and saved as 'ProcessedData.mat'. If ARG
%   is not a folder, data from the current folder is saved as 'ARG.mat'.
%   IPPONPROCESS(FOLDER, FILENAME) processes the data from folder FOLDER
%   and saves it as a .mat file with the name FILENAME.

% Set default file name for processed Data
defaultFileName = 'ProcessedData.mat';

% Identifiers in filenames for IPPon data
identifier = '*expData*.mat';

% Preallocate
D = struct();
dat = struct();

% If input argument is passed interpret it as a folder name or file name
if nargin==0
    folderName = pwd();
    fileName = defaultFileName;
elseif nargin==1
    if isdir(varargin{1})
        folderName = varargin{1};
        fileName = defaultFileName;
    else
        folderName = pwd();
        fileName = varargin{1};
    end
elseif nargin==2
    folderName = varargin{1};
    fileName = varargin{2};
else
    disp('Too many input arguments')
    return
end

% Start timing
tic

% Get directory info
dirInfo = dir([folderName, '/', identifier]);

if numel(dirInfo)==0
    % No files found
    disp('No files were found')
    return
end

fprintf( 'Processing %g Files...\t', numel(dirInfo) )

% Bin reduction: reduce bins to my_num_bins
my_num_bins = 1024;

% Maximal deviation of counts (ABW*standard deviation) from mean count
% value
ABW = 3;

names = {'Background', 'UV', 'UV+IR' };

for q=1:numel(dirInfo)
    
    fprintf( '#' )
    
    %% Loading    
    load( [folderName, '/', dirInfo(q).name], 'timeData', 'data', 'd', 'delayTimes' ) 
    
    if exist('delayTimes','var')
        D(q).delay = delayTimes(d);
    else
        D(q).delay = nan;
    end
    
    % Reshape if my_num_bins is smaller than the original one
    if my_num_bins < numel(timeData)
        % Set new time data array to account for reduced amount of bins
        timeData = linspace(timeData(end)/my_num_bins, timeData(end), my_num_bins);
        % To reduce bins we have to swap the first and second dimension first
        data = permute(data, [2, 1, 3]);
        % Preallocate a reshaped data array
        data_reshaped = zeros(size(data, 1), my_num_bins, 3);
        % Reduce number of bins shot for shot
        for i=1:size(data_reshaped, 1)
            data_reshaped(i,:,:) = sum(reshape(data(i,:,:), (size(data, 2)/my_num_bins), my_num_bins, 3));
        end
        % Swap the dimensions back
        data_reshaped = permute(data_reshaped, [2, 1, 3]);
        % Overwrite original data
        data = data_reshaped;
    end
    
    if exist('d', 'var')
        % Set the number of the measurement if there is any information
        % about it. If not it was most likely not a series but a single
        % measurement thus we can set it equal to 1.
        D(q).measurementNumber = d;
    else
        D(q).measurementNumber = 1;
    end
    
    counts = data(:,:,:);
    sumCounts = sum(counts,1);
    stdDev = std( sumCounts,0, 2 );
    highDev = abs( sumCounts - mean( sumCounts ) ) > ABW*stdDev;
    highDev = logical( sum( highDev, 3 ) );
    counts(:,highDev,:) = [];
    
    for i=1:3
        dat(i).name = [names{i},' - ', num2str(D(q).delay * 1e9),' ns'];
        dat(i).timeData = timeData*1e-3;
        dat(i).counts = counts(:,:,i);
        dat(i).sumCounts = sumCounts(1,:,i);
        dat(i).meanCounts = mean( dat(i).sumCounts );
        dat(i).stdDev = stdDev(i);
        dat(i).highDev = abs( sum(counts,1) - mean( sum(counts,1) ) ) > ABW*stdDev;
        dat(i).countsAccu = sum( dat(i).counts,2 );
        dat(i).tof = dat(i).countsAccu - dat(1).countsAccu;
        dat(i).flux = dat(i).tof./dat(i).timeData';
    end
    
    D(q).stdDev = stdDev;
    D(q).sumCounts = sumCounts;
    D(q).countsDifference = dat(3).tof - dat(2).tof;    
    D(q).data = dat(1:3);
    D(q).highDev = highDev;
    D(q).removed = sum( highDev );
    D(q).timeData = timeData*1e-3;
    
end

% Sort by measurement number
[~, ind]=sort(cell2mat({D.measurementNumber}));
D=D(ind);

fprintf( '\nSaving...\t' )
save(fileName, 'D')
fprintf('| Time: %.1f s\n', toc )