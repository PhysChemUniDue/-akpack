function DataSet = processSR430( fileNames )
% Processes data from SRS SR430 Scaler/Discriminator
%
% D = PROCESSSR430(FILENAMES) import FILENAMES (can be a single string or a
% cell array of strings) and returns a dataset structure D.

% Set amplification level for flux
ampLevel = 1e15;

% Check if filesnames are stored in a cell array. If thats not the case
% (only one file selected) make a cell array out of it
if ~iscell( fileNames )
    fileNamesCell{1} = fileNames;
    fileNames = fileNamesCell;
end

DataSet = struct();
for i=1:numel( fileNames )
    
    % Import numeric data
    numericData = dlmread( fileNames{i}, '\t', 12, 0 );
    
    % Put in data set
    % Change the time data from nanoseconds to seconds
    DataSet(i).time = numericData(:,1)*1e-9;
    DataSet(i).counts = numericData(:,2:end);
    % Remove Background and Normalize Counts
    DataSet(i).normCounts = (DataSet(i).counts - mean(DataSet(i).counts(1:10))) ...
        ./ max(DataSet(i).counts);
    % Calculate flux and amplify it. Without amplification there are
    % problems with fitting the spectrum because of very low amplitudes
    DataSet(i).flux = DataSet(i).normCounts ./ DataSet(i).time * ampLevel;
    
    fileID = fopen( fileNames{i}, 'r' );
    
    dataArray = textscan(fileID, '%s', 10);
    % Store date as datetime
    DataSet(i).Date = datetime([dataArray{1}{9}, ' ', dataArray{1}{10}]);
    
    % Read other options
    formatSpec = '%s %f';
    dataArray = textscan( fileID, formatSpec, 8, ...
        'Delimiter', '\t', ...
        'ReturnOnError', false, ...
        'HeaderLines', 2);
    
    % Get names and values out of there
    OptionNames = dataArray{1};
    OptionValues = dataArray{2};
    
    % Replace '%' and ' ' in the Option Names
    for j=1:numel( OptionNames )
        OptionNames{j} = regexprep( OptionNames{j}, '%', '' );
        OptionNames{j} = regexprep( OptionNames{j}, ' ', '' );
        OptionNames{j} = regexprep( OptionNames{j}, '(ns', '' );
        OptionNames{j} = regexprep( OptionNames{j}, ')', '' );
        
        % Append values to data set
        DataSet(i).(OptionNames{j}) = OptionValues(j);
    end
    
    % Put the file name in the data set
    [~,DataSet(i).fileName,~] = fileparts(fileNames{i});
    
    % Search for temperature indication in the file name
    k = regexp(DataSet(i).fileName,'\d\d\dK');
    DataSet(i).Temperature = str2double(DataSet(i).fileName(k:k+2));
    
    % Search for repetition rate indication in the file name
    [k,j] = regexp(DataSet(i).fileName,'\dHz|\d\dHz');
    DataSet(i).RepRate = str2double(DataSet(i).fileName(k:j-2));
    
    % Search for attenuator levels indication in the file name
    [k,j] = regexp(DataSet(i).fileName, '(atn\d\d\d|_\d\d\d_)');
    str = DataSet(i).fileName(k:j);
    k = regexp(str, '\d\d\d');
    DataSet(i).AttnLevel = str2double(str(k:k+2));
    
    % Search for wavelength indication in the file name
    k = regexp(DataSet(i).fileName,'\d\d\dnm');
    DataSet(i).Wavelength = str2double(DataSet(i).fileName(k:k+2));
    
    % Search for distance indication in the file name
    [k,j] = regexp(DataSet(i).fileName,'\d\d\dmm_|\d\d\d.\d\dmm_');
    DataSet(i).externalDistance = ...
        str2double(DataSet(i).fileName(k:j-3));
    
    % Search for background pressure indication in the file name
    [k,j] = regexp(DataSet(i).fileName,'\d.\de-\dmbar|\d.\d\de-\dmbar|\de-\d\dmbar|\de-\dmbar|\d\de-\dmbar');
    DataSet(i).backgroundPressure = str2double(DataSet(i).fileName(k:j-4));
    
    % Close file
    fclose( fileID );
    
end


end