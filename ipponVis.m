function ipponVis(varargin)
%IPPONVIS Plot data from the IPPon experiment.
%   IPPONVIS(TYPE) plots the data from the file 'ProcessedData.mat'. The
%   kind of the plot is specified by TYPE.
%   IPPONVIS(FILE, TYPE) plots the data from file FILE in the form
%   specified by TYPE.
%   IPPONVIS(FILE, TYPE, N) plots the data from file FILE in the form
%   specified by TYPE. N is an array and specifies the indexes of the 
%   measurements that shall be plotted. Available options are:
%
%   'counts_vs_delay'   -   Plot number of counts of a whole measurement vs
%                           the delay time and the number of counts vs the
%                           number of the measurement.
%   'counts_vs_delay_n' -   Same as 'counts_vs_delay' but normalized to the
%                           mean background counts
%   'density'           -   Plot density spectra
%   'density_comparison'-   Plot the counts of the IR pumped spectrum minus
%                           the counts of the non-pumped spectrum.
%   'density_sum'       -   Plot the summation of of the density spectra
%   'comparison_sum'    -   Plot summation of tof comparisons

%% Check input arguments

if nargin == 1
    load ProcessedData.mat
    type = varargin{1};
    % Indexes
    N = 1:numel(D);
elseif nargin == 2
    load(varargin{1});
    type = varargin{2};
    % Indexes
    N = 1:numel(D);
elseif nargin == 3
    load(varargin{1});
    type = varargin{2};
    % Indexes
    N = varargin{3};
else
    disp('Wrong number of input arguments')
end

%% Calculate stuff thats important for multiple plots

names = {'Background', 'UV only', 'IR+UV'};

delay = zeros( 1,numel(D) );
measurementNumber = zeros(1,numel(D));
meanCounts = zeros( 3,numel(D) );
stdMeanCounts = zeros( 3,numel(D) );

for i=1:numel(D)
    delay(i) = D(i).delay;
    measurementNumber(i) = D(i).measurementNumber;
    for j=1:3
        meanCounts(j,i) = mean( D(i).data(j).sumCounts );
        stdMeanCounts(j,i) = std( D(i).data(j).sumCounts );
    end
end

%% Plots

if strcmp(type,'counts_vs_delay')
    
    % Counts vs delay time
    figure()
    hold on
    for i=1:3
        errorbar( delay, meanCounts(i,:), stdMeanCounts(i,:), ...
            'o', ...
            'DisplayName', names{i} )
    end
    legend('show')
    xlabel('Delay Time [$\mu$s]')
    ylabel('Mean Counts')
    title('Mean Counts per Mode at Different Delays')
    
    % Couts vs. Measurement number
    figure()
    hold on
    for i=1:3
        errorbar( measurementNumber, meanCounts(i,:), stdMeanCounts(i,:), ...
            'o-', ...
            'DisplayName', names{i} )
    end
    legend('show')
    xlabel('Measurement Number')
    ylabel('Mean Counts')
    title('Mean Counts per Mode vs Measurement Number')
    
elseif strcmp(type,'counts_vs_delay_n')
    
    % Counts vs delay time NORMALIZED
    figure()
    hold on
    for i=2:3
        errorbar( delay, meanCounts(i,:)./meanCounts(1,:), stdMeanCounts(i,:)./meanCounts(1,:), ...
            'o', ...
            'DisplayName', names{i} )
    end
    legend('show')
    xlabel('Delay Time [$\mu$s]')
    ylabel('Mean Counts/Background')
    title('Mean Counts per Mode at Different Delays (Normalized)')
    
    % Couts vs. Measurement number NORMALIZED
    figure()
    hold on
    for i=2:3
        errorbar( measurementNumber, meanCounts(i,:)./meanCounts(1,:), stdMeanCounts(i,:)./meanCounts(1,:), ...
            'o-', ...
            'DisplayName', names{i} )
    end
    legend('show')
    xlabel('Measurement Number')
    ylabel('Mean Counts/Background')
    title('Mean Counts per Mode vs Measurement Number (Normalized)')
    
elseif strcmp(type,'density')
    
    for i=N
        figure()
        hold on
        for j=2:3
            stairs( D(i).timeData, D(i).data(j).tof, ...
                'DisplayName', names{j} )
        end
        xlabel( 'Time [$\mu$s]')
        ylabel( 'Counts' )
        title( sprintf('Density Spectra - Delay: %g ns', D(i).delay) )
        legend( 'show' )
        
        for j=2:3
            figure()
            stairs( D(i).timeData, D(i).data(j).tof, ...
                'DisplayName', names{j} )
            xlabel( 'Time [$\mu$s]')
            ylabel( 'Counts' )
            title( sprintf('Density Spectrum - %s - Delay: %g ns', names{j}, D(i).delay ) )
            legend('show')
        end
    end
    
elseif strcmp(type,'density_comparison')
    
    for i=N
        figure()
        hold on
        stairs( D(i).timeData, D(i).data(3).tof-D(i).data(2).tof, ...
            'DisplayName', 'Data')
        plot( D(i).timeData, smooth( D(i).data(3).tof-D(i).data(2).tof,round(numel( D(i).timeData )/10 ),'loess' ), ...
            'DisplayName', 'Smoothed Data')
        xlabel( 'Time [$\mu$s]')
        ylabel( 'Counts' )
        title( sprintf( 'Density Spectra Comparison (IR-UV) - Delay: %g ns', D(i).delay ) )
        legend('show')
    end
    
elseif strcmp(type,'density_sum')
    
    
    tofSum = zeros(numel(D(1).data(1).tof),3);
    for i=N
        for j=1:3            
            tofSum(:,j) = tofSum(:,j) + D(i).data(j).tof;
        end
    end
    
    figure()
    hold on
    for j=2:3
        stairs( D(1).timeData, tofSum(:,j), ...
            'DisplayName', names{j} )
    end
    xlabel( 'Time [$\mu$s]')
    ylabel( 'Counts' )
    title( sprintf('Density Spectra - SUM') )
    legend( 'show' )
    
    for j=2:3
        figure()
        stairs( D(i).timeData, tofSum(:,j), ...
            'DisplayName', names{j} )
        xlabel( 'Time [$\mu$s]')
        ylabel( 'Counts' )
        title( sprintf('Density Spectrum - %s - SUM', names{j}) )
        legend('show')
    end
    
elseif strcmp(type,'comparison_sum')
    
    tofSum = zeros(numel(D(1).data(1).tof),3);
    for i=N
        for j=1:3
            tofSum(:,j) = tofSum(:,j) + D(i).data(j).tof;
        end
    end
    
    figure
    hold on
    stairs( D(1).timeData, tofSum(:,3)-tofSum(:,2), ...
        'DisplayName', 'Data' )
    plot( D(1).timeData, smooth( tofSum(:,3)-tofSum(:,2),round(numel( D(i).timeData )/10 ),'loess' ), ...
        'DisplayName', 'Smoothed Data')
    xlabel( 'Time [$\mu$s]')
    ylabel( 'Counts' )
    title( sprintf( 'Density Spectra Comparison (IR-UV) - SUM' ) )
    legend('show')
    
else
    
    fprintf('Type "%s" is not specified\n', type)
    
end

end