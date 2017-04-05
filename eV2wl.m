function y = eV2wl(E)
% Convert an energy in eV to the corresponding wavelength in nm.
%   E:  Energy in eV
%

% Speed of light in m/s
c = 299792458;
% Planck's constant in Js
h = 6.62606957e-34;

% Energy to Joule
EJoule = E*1.60217657e-19;
% Wavelength in m
lambda = h*c./EJoule;
% Wavelength in nm
y = lambda*1e9;

end % Main