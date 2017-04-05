function varargout = sfsReference(varargin)
% Apply a reference measurement to a SFG spectrum.
%
%   SFSREFERENCE() select reference and dataset from open file prompt.
%   D = SFSREFERENCE(DATASET, REFERENCE) apply REFERENCE to DATASET and
%   return a processed dataset D.
%   D = SFSREFERENCE(___, OPTION) apply options. Available options:
%
%   'plot'  -   Plot original, reference and processed spectra.

import akpack.itximport
import akpack.sfgprocess

if nargin == 0
    
    fprintf( 'Loading reference spectrum ...\n' )
    
    % Choose file
    [filenameRef, pathnameRef, ~] = uigetfile('*.itx','Choose GaAs Reference');
    referenceFile = [pathnameRef filenameRef];
    
    % Load spectra
    fprintf( 'Loading spectral data set ...\n' )
    [filename, pathname, ~] = uigetfile('*.mat','Choose Spectra Data Set');
    dataFile = [filename, pathname];

elseif nargin == 1
    
    disp('Bad number of input arguments')
    
elseif nargin >= 2
    
    dataFile = varargin{1};
    referenceFile = varargin{2};
    
end

% Import itx file
dataRef = itximport( referenceFile,'struct' );

% Process GaAs spectrum
[GaAsSig,GaAsWN,GaAsWL] = sfgprocess( dataRef.WLOPG, dataRef.SigOsc1 );

% Amplify Signal
GaAsSig = GaAsSig*1e10;

% Load data set
load( dataFile )

% Process Spectra
fprintf( 'Processing %g spectra ...\n', numel( DataSet ) )
for i=1:numel( DataSet )
    
    for j=1:numel( DataSet(i).wavelength )
        % Check if the GaAs spectrum contains all wavelengths of the actual SFG
        % spectrum
        isInReference = any( DataSet(i).wavelength(j) == GaAsWL );
        if ~isInReference
            fprintf( 'Stopped execution at %s because the reference does not contain a wavelength of %g nm\n', DataSet(i).name, DataSet(i).wavelength(j) ) 
            return
        else
            % Get index of current wavelength in GaAs reference
            idx = find( DataSet(i).wavelength(j) == GaAsWL );
            % Processing
            DataSet(i).signalR(j) = DataSet(i).signal(j)/GaAsSig(idx);
        end
    end
    
end

if nargin == 3    
    if strcmp(varargin{3},'plot')
        for i=1:numel(DataSet)            
            % Sample plot
            figure; hold on
            p1(i) = plot( DataSet(i).wavenumber, DataSet(i).signal./max( DataSet(i).signal ) );
            p2(i) = plot( GaAsWN,GaAsSig./max(GaAsSig) );
            p3(i) = plot( DataSet(i).wavenumber, DataSet(i).signalR./max( DataSet(i).signalR ) );
            p1(i).DisplayName = 'Original';
            p2(i).DisplayName = 'Reference';
            p3(i).DisplayName = 'Processed';
            title(sprintf('Dataset Index: %g', i))
            legend('show')
            hold off            
        end
    else
        fprintf('Unknown option "%s"\n', varargin{3})
    end
end

for i=1:numel( DataSet )
    DataSet(i).signal = DataSet(i).signalR;
end
DataSet = rmfield( DataSet,'signalR' );

if nargout == 0
    % Save Data Set
    fprintf( 'Saving data set ...\n' )
    [FileName,PathName,~] = uiputfile('*.mat','Save Processed Data Set as ...');
    save( [PathName FileName], 'DataSet' )
elseif nargout == 1
    varargout{1} = DataSet;
end

fprintf( 'Done.\n' )

end