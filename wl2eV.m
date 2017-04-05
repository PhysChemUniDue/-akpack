function y = wl2eV(lambda)
% Convert an a wavelength in nm to the corresponding energy in eV.
%   lambda: wavelength in nm
%

% Speed of light in m/s
c = 299792458;
% Planck's constant in Js
h = 6.62606957e-34;

% Wavelength to energy
Ejoule = h*c./lambda/1e-9;
% Engergy from Joule to eV
y = Ejoule/1.60217657e-19;

end % Main