function DataSet = processSR430( fileNames )
% Processes data from SRS SR430 Scaler/Discriminator
%
% D = PROCESSSR430(FILENAMES) import FILENAMES (can be a single string or a
% cell array of strings) and returns a dataset structure D.


% Check if filesnames are stored in a cell array. If thats not the case
% (only one file selected) make a cell array out of it
if ~iscell( fileNames )
    fileNamesCell{1} = fileNames;
    fileNames = fileNamesCell;
end

for i=1:numel( fileNames )
    
    % Import numeric data
    numericData = dlmread( fileNames{i}, '\t', 12, 0 );
    
    % Put in data set
    % Change the time data from nanoseconds to milliseconds
    DataSet(i).time = numericData(:,1)*1e6;
    DataSet(i).counts = numericData(:,2:end);
    
    % Import date
    formatSpec = '%*s%{dd-MMM-yyyy HH:mm:ss}D%[^\n\r]';
    
    fileID = fopen( fileNames{i}, 'r' );
    
    % This scans the file two times in order to read the datetime properly.
    % No idea why
    dataArray = textscan(fileID, formatSpec, 2, ...
        'Delimiter', '\t', ...
        'ReturnOnError', false, ...
        'DateLocale','de_DE');
    
    % Store datetime
    DataSet(i).Date = dataArray{1}(2);
    
    % Read other options
    formatSpec = '%s %f';
    dataArray = textscan( fileID, formatSpec, 9, ...
        'Delimiter', '\t', ...
        'ReturnOnError', false );
    
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
    k = regexp(DataSet(i).fileName,'\dHz');
    DataSet(i).RepRate = str2double(DataSet(i).fileName(k));
    
    % Search for attenuator levels indication in the file name
    [k,j] = regexp(DataSet(i).fileName, '(atn\d\d\d|_\d\d\d_)');
    str = DataSet(i).fileName(k:j);
    k = regexp(str, '\d\d\d');
    DataSet(i).AttnLevel = str2double(str(k:k+2));
    
    % Search for wavelength indication in the file name
    k = regexp(DataSet(i).fileName,'\d\d\dnm');
    DataSet(i).Wavelength = str2double(DataSet(i).fileName(k:k+2));
    
    % Close file
    fclose( fileID );
    
end


end