function gaborPatch = makeGaborPatch(width,nGaussianSDs,contrastFraction,contrastNoise,gratingPeriod,gratingPeriodUnits,orientation,black,white)
% gaborPatch = makeGaborPatch(width,nGaussianSDs,contrastFraction,gratingPeriod,gratingPeriodUnits,orientation,black,white)
%
% Adopted from PTB's GratingDemo.m
% 
% Returns a matrix representing pixel values for a gabor patch.
% Use Screen('MakeTexture') and Screen('DrawTexture)to draw it on the PTB 
% screen.
%
%
% Explanation of input variables
% ------------------------------
%
% Default values are set for variables that are either not specified or are
% specified as the empty matrix [].
%
% width = width of the square containing the Gabor patch, in pixels
%
% nGaussianSDs = # of standard deviations of the Gaussian curve defining the patch
%       contained within the square.
%
%       Default = 6
%
% contrastFraction = contrast of the patch 
%       1 = maximal contrast b/t darker and lighter parts of the patch
%       0 = no contrast at all (all gray)
%       Intermediate values change the difference b/t darker and lighter
%       parts linearly.
%       
%       Default = 1
%
% gratindPeriod = the magnitude of the period of the Gabor patch's grating.
%       Period can be specified either in units of pixels or in units of
%       the standard deviation of the Gabor patch Gaussian.
%
%       Default: 1 grating period = 1 Gaussian SD.
%
% gratingPeriodUnits = type of units gratingPeriod is specified in.
%       'sd' = specified in units of the Gaussian SD.
%       any other value = specified in units of pixels.
%
% orientation = orientation of the grating
%       'vertical' = grating is oriented vertically
%       any other value = grating is oriented horizontally
%
%       To display gratings rotated between vertical and horizontal
%       orientation, use the Screen('DrawTexture') rotation functionality
%
% black = CLUT value for black on this computer (default = 0)
% white = CLUT value white on this computer (default = 255)


%% set parameter values if not specified
if ~exist('nGaussianSDs','var') || isempty(nGaussianSDs)
    nGaussianSDs = 6;
end

if ~exist('contrastFraction','var') || isempty(contrastFraction)
    contrastFraction = 1;
end

if ~exist('orientation','var') || isempty(orientation)
    orientation = 'horiztonal';
end

if ~exist('black','var') || isempty(black)
    black = 0;
end

if ~exist('white','var') || isempty(white)
    white = 255;
end


%% handle specification of the grating period

% if no grating period is specified, set it to 2/3s of the Gaussian SD
if ~exist('gratingPeriod','var') || isempty(gratingPeriod)
    gratingPeriodUnits = 'sd';
    gratingPeriod = 1;

% if grating period is given a value without a type specification,
% assume the grating period value is in pixels
elseif ~exist('gratingPeriodUnits','var') || isempty(gratingPeriodUnits)
    gratingPeriodUnits = 'pixels';
end

% compute the pixels per grating period
pixelsPerSD = width / nGaussianSDs;
switch gratingPeriodUnits
    case 'sd'
        nGaussianSDsPerGratingPeriod = gratingPeriod;
        pixelsPerGratingPeriod = nGaussianSDsPerGratingPeriod * pixelsPerSD;
    otherwise
        pixelsPerGratingPeriod = gratingPeriod;
end


spatialFrequency = 1 / pixelsPerGratingPeriod; % How many periods/cycles are there in a pixel?
radiansPerPixel = spatialFrequency * (2 * pi); % = (periods per pixel) * (2 pi radians per period)


%% adjust contrast

gray = (black + white) / 2;

% compute maximum luminance at this contrast
maxLuminance = (white-gray) * contrastFraction; 

% % adjust black and white according to the specified contrast
% black = gray - maxLuminance;
% white = gray + maxLuminance;


%% make the patch

halfWidthOfGrid = width / 2;
widthArray = (-halfWidthOfGrid) : halfWidthOfGrid;  % widthArray is used in creating the meshgrid.

% Creates a two-dimensional square grid.  For each element i = i(x0, y0) of
% the grid, x = x(x0, y0) corresponds to the x-coordinate of element "i"
% and y = y(x0, y0) corresponds to the y-coordinate of element "i"
[x y] = meshgrid(widthArray, widthArray);

% Creates a sinusoidal grating, where the period of the sinusoid is 
% approximately equal to "pixelsPerGratingPeriod" pixels.
% Note that each entry of gratingMatrix varies between minus one and
% one; -1 <= gratingMatrix(x0, y0)  <= 1

% the grating is oriented horizontally unless otherwise specified.
switch orientation
    case 'vertical'
        gratingMatrix = sin(radiansPerPixel .* x);
    otherwise
        gratingMatrix = sin(radiansPerPixel .* y);
end

%Create noise matrix
noiseMatrix = 2*(ceil(2*rand(width+1, width+1)))-3; %values from -1 to 1
noiseMatrix = noiseMatrix * contrastNoise;

gratingMatrix = gratingMatrix * contrastFraction;
gratingMatrix = gratingMatrix + noiseMatrix;

for i=1:size(gratingMatrix,1)
    for j=1:size(gratingMatrix,1)
        if gratingMatrix(i,j) > 1
            gratingMatrix(i,j) = 1;
        elseif gratingMatrix(i,j) < -1
            gratingMatrix(i,j) = -1;
        end
    end
end

% Creates a circular Gaussian mask centered at the origin.
%
% Note that since each entry of circularGaussianMaskMatrix is "e"
% raised to a negative exponent, each entry of
% circularGaussianMaskMatrix is one over "e" raised to a positive
% exponent, which is always between zero and one;
% 0 < circularGaussianMaskMatrix(x0, y0) <= 1
circularGaussianMaskMatrix = exp(-((x .^ 2) + (y .^ 2)) / (2 * pixelsPerSD ^ 2));

% Since each entry of gratingMatrix varies between minus one and one and each entry of
% circularGaussianMaskMatrix vary between zero and one, each entry of
% imageMatrix varies between minus one and one.
% -1 <= imageMatrix(x0, y0) <= 1
gaborMatrix = gratingMatrix .* circularGaussianMaskMatrix;

% Since each entry of gaborMatrix is a fraction between minus one and
% one, multiplying gaborMatrix by absoluteDifferenceBetweenWhiteAndGray
% and adding the gray CLUT color code baseline
% converts each entry of gaborMatrix into a shade of gray:
% if an entry of "m" is minus one, then the corresponding pixel is black;
% if an entry of "m" is zero, then the corresponding pixel is gray;
% if an entry of "m" is one, then the corresponding pixel is white.

% Taking the absolute value of the difference between white and gray will
% help keep the grating consistent regardless of whether the CLUT color
% code for white is less or greater than the CLUT color code for black.
absoluteDifferenceBetweenWhiteAndGray = abs(white - gray);

gaborPatch = gray + absoluteDifferenceBetweenWhiteAndGray * gaborMatrix;

