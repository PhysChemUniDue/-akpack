% Make a table of the IPPon data in the current directory.
%
%   The data has to be stored in 'ProcessedData.mat'

load( 'ProcessedData.mat' )

for i=1:numel(D)
    T(i).DelayTime = D(i).delay;
    T(i).StdDevBG = D(i).data(1).stdDev;
    T(i).MeanBG = mean( D(i).data(1).sumCounts );
    T(i).StdDevUV = D(i).data(2).stdDev;
    T(i).MeanUV = mean( D(i).data(2).sumCounts );
    T(i).StdDevIR = D(i).data(3).stdDev;
    T(i).MeanIR = mean( D(i).data(3).sumCounts );
    T(i).NumberRemoved = sum(D(i).highDev);
end

T = struct2table(T);
disp(T)

fprintf( ...
    'Mean BG: %.1f +/- %.1f counts\n', mean( T.MeanBG ), std( T.StdDevBG ) )
fprintf( ...
    'Mean UV: %.1f +/- %.1f counts\n', mean( T.MeanUV ), std( T.StdDevUV ) )
fprintf( ...
    'Mean IR: %.1f +/- %.1f counts\n', mean( T.MeanIR ), std( T.StdDevIR ) )