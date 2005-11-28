function handles = RGBMerge(handles)

% Help for the RGB Merge module:
% Category: Image Processing
%
% SHORT DESCRIPTION:
% Takes 1 to 3 images and assigns them to colors in a final, RGBimage.
% Each color's brightness can be adjusted independently.
% *************************************************************************
%
% Settings:
%
% Adjustment factors: Leaving the adjustment factors set to 1 will
% balance all three colors equally in the final image, and they will
% use the same range of intensities as each individual incoming image.
% Using factors less than 1 will decrease the intensity of that
% color in the final image, and values greater than 1 will increase
% it.  Setting the adjustment factor to zero will cause that color to
% be entirely blank.
%
% See also RGBSPLIT, RGBTOGRAY.

% CellProfiler is distributed under the GNU General Public License.
% See the accompanying file LICENSE for details.
%
% Developed by the Whitehead Institute for Biomedical Research.
% Copyright 2003,2004,2005.
%
% Authors:
%   Anne Carpenter
%   Thouis Jones
%   In Han Kang
%   Ola Friman
%   Steve Lowe
%   Joo Han Chang
%   Colin Clarke
%   Mike Lamprecht
%   Susan Ma
%   Wyman Li
%
% Website: http://www.cellprofiler.org
%
% $Revision$

%%%%%%%%%%%%%%%%%
%%% VARIABLES %%%
%%%%%%%%%%%%%%%%%
drawnow


[CurrentModule, CurrentModuleNum, ModuleName] = CPwhichmodule(handles);

%textVAR01 = What did you call the image to be colored blue?
%choiceVAR01 = Leave this black
%infotypeVAR01 = imagegroup
BlueImageName = char(handles.Settings.VariableValues{CurrentModuleNum,1});
%inputtypeVAR01 = popupmenu

%textVAR02 = What did you call the image to be colored green?
%choiceVAR02 = Leave this black
%infotypeVAR02 = imagegroup
GreenImageName = char(handles.Settings.VariableValues{CurrentModuleNum,2});
%inputtypeVAR02 = popupmenu

%textVAR03 = What did you call the image to be colored red?
%choiceVAR03 = Leave this black
%infotypeVAR03 = imagegroup
RedImageName = char(handles.Settings.VariableValues{CurrentModuleNum,3});
%inputtypeVAR03 = popupmenu

%textVAR04 = What do you want to call the resulting image?
%defaultVAR04 = RGBImage
%infotypeVAR04 = imagegroup indep
RGBImageName = char(handles.Settings.VariableValues{CurrentModuleNum,4});

%textVAR05 = Enter the adjustment factor for the blue image
%defaultVAR05 = 1
BlueAdjustmentFactor = char(handles.Settings.VariableValues{CurrentModuleNum,5});

%textVAR06 = Enter the adjustment factor for the green image
%defaultVAR06 = 1
GreenAdjustmentFactor = char(handles.Settings.VariableValues{CurrentModuleNum,6});

%textVAR07 = Enter the adjustment factor for the red image
%defaultVAR07 = 1
RedAdjustmentFactor = char(handles.Settings.VariableValues{CurrentModuleNum,7});

%%%VariableRevisionNumber = 1

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% PRELIMINARY CALCULATIONS & FILE HANDLING %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
drawnow

%%% Determines whether the user has specified an image to be loaded in
%%% blue.
if ~strcmp(BlueImageName, 'Leave this black')
    %%% Read (open) the images and assign them to variables.
    fieldname = BlueImageName;
    %%% Checks whether the image to be analyzed exists in the handles structure.
    if ~isfield(handles.Pipeline, fieldname)
        %%% If the image is not there, an error message is produced.  The error
        %%% is not displayed: The error function halts the current function and
        %%% returns control to the calling function (the analyze all images
        %%% button callback.)  That callback recognizes that an error was
        %%% produced because of its try/catch loop and breaks out of the image
        %%% analysis loop without attempting further modules.
        error(['Image processing was canceled in the ', ModuleName, ' module because it could not find the input image.  It was supposed to be named ',BlueImageName, ' but an image with that name does not exist.  Perhaps there is a typo in the name.'])
    end
    %%% Reads the image.
    BlueImage = handles.Pipeline.(fieldname);
    BlueImageExists = 1;
    if max(BlueImage(:)) > 1 || min(BlueImage(:)) < 0
        CPwarndlg(['The images you have loaded in the ', ModuleName, ' module are outside the 0-1 range, and you may be losing data.'],'Outside 0-1 Range','replace');
    end
else
    BlueImageExists = 0;
end

drawnow
%%% Repeat for Green and Red.
if ~strcmp(GreenImageName, 'Leave this black')
    if ~isfield(handles.Pipeline, GreenImageName)
        error(['Image processing was canceled in the ', ModuleName, ' module because it could not find the input image.  It was supposed to be named ', GreenImageName, ' but an image with that name does not exist.  Perhaps there is a typo in the name.'])
    end
    GreenImage = handles.Pipeline.(GreenImageName);
    GreenImageExists = 1;
    if max(GreenImage(:)) > 1 || min(GreenImage(:)) < 0
        CPwarndlg(['The images you have loaded in the ', ModuleName, ' module are outside the 0-1 range, and you may be losing data.'],'Outside 0-1 Range','replace');
    end
else GreenImageExists = 0;
end

if ~strcmp(RedImageName, 'Leave this black')
    if ~isfield(handles.Pipeline, RedImageName)
        error(['Image processing was canceled in the ', ModuleName, ' module because it could not find the input image.  It was supposed to be named ', RedImageName, ' but an image with that name does not exist.  Perhaps there is a typo in the name.'])
    end
    RedImage = handles.Pipeline.(RedImageName);
    RedImageExists = 1;
    if max(RedImage(:)) > 1 || min(RedImage(:)) < 0
        CPwarndlg(['The images you have loaded in the ', ModuleName, ' module are outside the 0-1 range, and you may be losing data.'],'Outside 0-1 Range','replace');
    end
else RedImageExists = 0;
end
drawnow

%%% If any of the colors are to be left black, creates the appropriate
%%% image.
if ~BlueImageExists && ~RedImageExists && ~GreenImageExists
    error(['Image processing was canceled in the ', ModuleName, ' module because you have not selected any images to be merged in the RGB Merge module.'])
end
if ~BlueImageExists && ~RedImageExists && GreenImageExists
    BlueImage = zeros(size(GreenImage));
    RedImage = zeros(size(GreenImage));
end
if ~BlueImageExists && RedImageExists && ~GreenImageExists
    BlueImage = zeros(size(RedImage));
    GreenImage = zeros(size(RedImage));
end
if BlueImageExists && ~RedImageExists && ~GreenImageExists
    RedImage = zeros(size(BlueImage));
    GreenImage = zeros(size(BlueImage));
end
if BlueImageExists && RedImageExists && ~GreenImageExists
    GreenImage = zeros(size(BlueImage));
end
if ~BlueImageExists && RedImageExists && GreenImageExists
    BlueImage = zeros(size(GreenImage));
end
if BlueImageExists && ~RedImageExists && GreenImageExists
    RedImage = zeros(size(BlueImage));
end

%%% Checks whether the three images are the same size.
try
    if size(BlueImage) ~= size(GreenImage)
        error(['Image processing was canceled in the ', ModuleName, ' module because the three images selected are not the same size.  The pixel dimensions must be identical.'])
    end
    if size(RedImage) ~= size(GreenImage)
        error(['Image processing was canceled in the ', ModuleName, ' module because the three images selected are not the same size.  The pixel dimensions must be identical.'])
    end
catch error(['Image processing was canceled in the ', ModuleName, ' module because there was a problem with one of three images selected. Most likely one of the images is not in the same format as the others - for example, one of the images might already be in RGB format.'])
end

%%%%%%%%%%%%%%%%%%%%%%
%%% IMAGE ANALYSIS %%%
%%%%%%%%%%%%%%%%%%%%%%
drawnow

%%% If any of the images are binary/logical format, they must be
%%% converted to a double first before immultiply.
RGBImage(:,:,1) = immultiply(double(RedImage),str2double(RedAdjustmentFactor));
RGBImage(:,:,2) = immultiply(double(GreenImage),str2double(GreenAdjustmentFactor));
RGBImage(:,:,3) = immultiply(double(BlueImage),str2double(BlueAdjustmentFactor));

%%%%%%%%%%%%%%%%%%%%%%%
%%% DISPLAY RESULTS %%%
%%%%%%%%%%%%%%%%%%%%%%%
drawnow

ThisModuleFigureNumber = handles.Current.(['FigureNumberForModule',CurrentModule]);
if any(findobj == ThisModuleFigureNumber);

    drawnow
    %%% Activates the appropriate figure window.
    CPfigure(handles,ThisModuleFigureNumber);
    %%% A subplot of the figure window is set to display the Merged RGB
    %%% image.  Using CPimagesc or image instead of imshow doesn't work when
    %%% some of the pixels are saturated.
    subplot(2,2,1); CPimagesc(RGBImage);
    title(['Merged Color Image, cycle # ',num2str(handles.Current.SetBeingAnalyzed)]);
    %%% A subplot of the figure window is set to display the blue image.
    subplot(2,2,2); CPimagesc(BlueImage); title('Blue Image');
    %%% A subplot of the figure window is set to display the green image.
    subplot(2,2,3); CPimagesc(GreenImage); title('Green Image');
    %%% A subplot of the figure window is set to display the red image.
    subplot(2,2,4); CPimagesc(RedImage); title('Red Image');
    CPFixAspectRatio(RGBImage);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% SAVE DATA TO HANDLES STRUCTURE %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
drawnow

%%% Saves the adjusted image to the handles structure so it can be used by
%%% subsequent modules.
handles.Pipeline.(RGBImageName) = RGBImage;