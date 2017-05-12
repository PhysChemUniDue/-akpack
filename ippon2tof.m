function dataSet = ippon2tof(filename)

load([pwd, '/', filename])

ampLevel = 1e15;

for i = 1:numel(D)*2
    
    j = ceil(i/2);
    k = rem(i,2) + 2;
    
    dataSet(i).time = D(j).timeData' * 1e-6;
    dataSet(i).fileName = D(j).data(k).name;
    dataSet(i).flux = D(j).data(k).flux * ampLevel;
    dataSet(i).counts = D(j).data(k).tof;
    dataSet(i).delay = D(j).delay;
    
end

newFileName = [filename, '_tof_ds.mat'];
save(newFileName, 'dataSet')

fprintf('Saved "dataSet" as %s.\n', newFileName)

end