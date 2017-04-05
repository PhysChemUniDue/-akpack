% Pack spectra in working directory into a dataset called 'DataSet.mat' The
% data has to be in raw itx format.

import akpack.itximport
import akpack.sfgprocess

pathName = [pwd, '/*.itx'];
fileStruct = dir( pathName );

fprintf('Packing %g spectra...\n', numel(fileStruct))

for i=1:numel(fileStruct)
    
    DataSet(i).name = fileStruct(i).name;
    
    % Import itx file
    fileName = [pwd, '/', fileStruct(i).name];
    itximport( fileName );
    
    [signal,wavenumber,wavelength] = sfgprocess( WLOPG,SigOsc1 );
    
    DataSet(i).signal = signal*10e10;
    DataSet(i).wavenumber = wavenumber;
    DataSet(i).wavelength = wavelength;
    
end

save( 'DataSet','DataSet' );
disp('Done.')