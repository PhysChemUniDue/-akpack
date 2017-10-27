% Pack spectra in working directory into a dataset called 'DataSet.mat' The
% data has to be in raw itx format.

import akpack.itximport
import akpack.sfgprocess

pathName = [pwd, '/*.itx'];
dirInfo = dir( pathName );

fprintf('Packing %g spectra...\n', numel(dirInfo))

DataSet = struct();

for i=1:numel(dirInfo)
    
    [~,DataSet(i).name,~] = fileparts(dirInfo(i).name);
    DataSet(i).date = dirInfo(i).date;
    
    % Import itx file
    fileName = [pwd, '/', dirInfo(i).name];
    itximport( fileName );
    
    S = sfgprocess(WLOPG, SigOsc1, SigDet1);
    fields = fieldnames(S);
    
    for f=1:numel(fields)
        DataSet(i).(fields{f}) = S.(fields{f});
    end
    
end

save( 'DataSet','DataSet' );
disp('Done.')