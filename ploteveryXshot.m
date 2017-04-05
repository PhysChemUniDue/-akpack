function ploteveryXshot(UVFrequency)
% PLOTEVERYXSHOT makes a plot from every 20/UVFrequency shot
%
% PLOTEVERYXSHOT(UVFrequency) plots every 20/UVFrequency shot. The raw
% spectrum has to be in itx format and can be selected via an open file
% dialog.

%import .itx-File
import akpack.itximport

[file,path] = uigetfile('*.itx','Select IGOR text file');
if file == 0
    % Return if no file was selected
    return
end
filename = [path file];

s = itximport(filename,'struct');

%import required data
SigOsc1 = s.SigOsc1;
WLOPG = s.WLOPG;


%Frequency(IR)/UVFrequency
repRate=20/UVFrequency;


numdataSignal=numel(SigOsc1);

%devide raw data into a Matrix: shotnumber vs Signal
Signal=reshape(SigOsc1,[repRate,numdataSignal/repRate]);

%devide raw data into a Matrix: shotnumber vs Wavelength
Wavelength=reshape(WLOPG,[repRate,numdataSignal/repRate]);

%get x-axis/stepsize
clearWavelength=unique(WLOPG);



for i=1:repRate
    
    iSignal=Signal(i,:);
    iWavelength=Wavelength(i,:);
    
    for j=1:numel(clearWavelength)
        
        
        SumSignal=iSignal(iWavelength==clearWavelength(j));
        
        meanSignal=mean(SumSignal);
       
        
        Matrix(i,j)=meanSignal;
        
    end
    
       
     figure()
     plot(clearWavelength,Matrix(i,:))
    
 
end
   

   
    
end
