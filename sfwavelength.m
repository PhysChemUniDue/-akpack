function sumWavelength = sfwavelength(wl1, wl2)
% Calculate the sum frequency wavelength from the generating wavelengths.
%
%   WSF = SFWAVELENGTH(WL1, WL2) calculates the sum frequency wavelength
%   from intial wavelengths WL1 and WL2

sumWavelength = 1./( 1./wl1 + 1./wl2 );

end