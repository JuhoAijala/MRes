% Base script for EEG experiment looking at ERPs to targets and distractors under verbal working memory load

% Juho Aijala & Daniel Pearson

%% set up some global variables that we will use across the different scripts
global black
global white

%% these calls clear the workspace
sca         % this closes any open Psychtoolbox windows
clear all   % this clears any MATLAB variables
clc         % this clears the command window

%% add all folders to the path
addpath(genpath(cd()));

%% Setup Psychtoolbox
screens = Screen('Screens');    % this counts the number of screens that we have
KbName('UnifyKeyNames');        % this is important for some reason to standardise keyboard input across platforms / OSs

if length(screens) > 2         % if using two monitors
    screenNum = 2;              % use the secondary monitor
else
    screenNum = 0;              % use the primary monitor
end

Screen('Preference', 'SkipSyncTests', 1);       % skip the Psychtoolbox calibrations - NEED TO CHANGE THIS WHEN RUNNING THE EXPT FOR REAL

% Get screen resolution, and find location of centre of screen
[scrWidth, scrHeight] = Screen('WindowSize',screenNum);
screenRes = [scrWidth scrHeight];
scr_centre = screenRes / 2;

%% Open the PTB Screen
[MainWindow, rect] = Screen(screenNum, 'OpenWindow', [0 0 0], [], 32);      % Open the Psychtoolbox window (just added the rect here to get it for the fixation cross JÃ„)
Screen('Preference', 'DefaultFontName', 'Segoe UI');                        % I like this font...
Screen('TextSize', MainWindow, 34);                                         % Set the text size
framerate = round(Screen(MainWindow, 'FrameRate'));                         % figure out the refresh rate of the monitor being used

white = [255 255 255];                                                      % get values for black and white
black = [0 0 0];

HideCursor;

Screen('BlendFunction', MainWindow, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');  % this is useful for using transparent stimuli

%% Set up stimulus colours
gray = [70 70 70];

red = [245,94,26]; % these values approximated from Gaspelin & Luck (2018 - JoCN)
green = [54,148,51];

stim_colours = [red; green];
%% Set and shuffle rng

rng('default')
rng('shuffle')
rand('state',sum(100*clock));                                               %Reset rng based on the clock

%% Set up stimulus sizes - we might want to change these values
stim_size = dva2pix(2);                                             %I had to change these: apparently my computers graphics dont
stim_line_width = dva2pix(0.2);                                     %Support im_size = dva2pix(3), im_line_width = dva2pix(0.3)
line_width = dva2pix(0.2);                                          %or ne_width = dva2pix(0.3);
line_size = dva2pix(1);


%% Generate stimuli to use in the visual search task
[diamonds, circles, target_lines, distractor_lines] = generate_search_stim(stim_size, stim_line_width, stim_colours, line_size, line_width, MainWindow);

% can draw shapes to the screen like this:
%Screen('DrawTexture', MainWindow, circles(1))
%Screen('DrawTexture', MainWindow, target_lines(2))
%Screen(MainWindow, 'Flip')

%KbWait([], 2);

%Screen('DrawTexture', MainWindow, diamonds(2))
%Screen('DrawTexture', MainWindow, target_lines(2))
%Screen(MainWindow, 'Flip')
%% Generate the Coordinates for the stimuli
%%(There's probably a better/simpler way of doing this?)                                              
radius = 300;                                                               %Radius of the circle along which the stimuli are presented. Just picked at random atm
[coordinatesX,coordinatesY] = GrtCircleCoor(radius);                        %Generates two vectors coordinatesX and coordinatesY, for a 1000 points along a circle with a specified radius centered in the centre of the screen
BaseRect = [ 0 0 stim_size stim_size];                                      %Defines the baserect for the stimuli
BaseRectLines = [ 0 0 line_size line_size];                                 %defines the baserect for the targetlines

%defining the locations we use for the targets and distractors. Picks 4
%points that are equally distributed along the circle. 1000/4 = 250

stimRects(1,:) = CenterRectOnPointd(BaseRect,coordinatesX(250),coordinatesY(250));  %250
stimRects(2,:) = CenterRectOnPointd(BaseRect,coordinatesX(500),coordinatesY(500));  %500
stimRects(3,:) = CenterRectOnPointd(BaseRect,coordinatesX(750),coordinatesY(750));  %750
stimRects(4,:) = CenterRectOnPointd(BaseRect,coordinatesX(1000),coordinatesY(1000));%1000

%Same for target lines to get the correct size
linecoor(1,:) = CenterRectOnPointd(BaseRectLines,coordinatesX(250),coordinatesY(250));
linecoor(2,:) = CenterRectOnPointd(BaseRectLines,coordinatesX(500),coordinatesY(500));
linecoor(3,:) = CenterRectOnPointd(BaseRectLines,coordinatesX(750),coordinatesY(750));
linecoor(4,:) = CenterRectOnPointd(BaseRectLines,coordinatesX(1000),coordinatesY(1000));

%% Generate the coordinates for the peripheral distractor stimuli:

arcLocs = 4;                                                                    % 4 different distractor locations (top, right, bottom, left)
arcLocshalf = arcLocs/2;                                                        % locations/2, used to balance the locations
arc_angle = 45;                                                                 % each distractor arc subtends 45 degrees
arc_start = [0-arc_angle/2, 90-arc_angle/2, 180-arc_angle/2, 270-arc_angle/2];  % this is the start point for each arc
arc_width = stim_size;                                                          % make the distractor arcs as wide as the stimuli
arc_radius = radius + 150 + stim_size/2;                                        % this is fairly random at the moment - basically the centre of the arc is 150 pixels further out than the centre of the shapes

% create a rect to set the outer limits of the arc shaped distractors
arcRect = [scr_centre(1) - arc_radius, scr_centre(2) - arc_radius, scr_centre(1) + arc_radius, scr_centre(2) + arc_radius];



%% Setting up basic info about the experiment
Con_number = 2;                                                             %This is two at the moment (target in the middle/distractor in the middle)
blocks = 6;                                                                 %Number of blocks in the experiment;
blocks_per_con = blocks/Con_number;                                         %amount of blocks per one condition
trials_per_con = 20  ;                                                       %No of trials for each condition, just randomly picked atm
sub_con = 4;                                                                %Target up/down/left/right
total_trials = trials_per_con*Con_number;                                   %No of total trials
con_trials = total_trials/Con_number;                                       %How many trials each condition has
sub_con_trials = total_trials/sub_con;                                      %How many trials every sub_con (target up/down or target left/right) has

%How often is the distractor aligned with the target?
%Creates a matrix lenght(total_trials) X trials_per_con matrix with each row
%containing a random permutation of numbers from 1 to total_percentage.
%Used to set the percentage at which the distractor aligns with the target.
%The rows correspond to the target locations, and the individual numbers in
%the rows to the trials. For any given trial we can check if
%does_align(x,i) < percentage. If < percentage, target and distractor do
%not align. Creates an equal amount of align/does not align -trials for
%each condition. Percentage can be specified 
replacement = false;
percentage = sub_con_trials*0.5;  
does_align = [];

for i = 1:sub_con                                                                                                                                          
alignment_random = repmat(1:sub_con_trials,1);
does_align(i,:) = randsample(alignment_random, sub_con_trials);
end

case_counter = [1 1 1 1];                                                      %Used to count the frequency of every target direction to balance whether 

%NOW ONLY BALANCE FOR THE WHOLE EXPERIMENT
%NEED TO BE BALANCED ACROSS CONDITIONS!!

                                  
%This creates a vector that has the lenght of total trials and consists of
%a random of arrangment of the experimental conditions with an 50/50 ratio of both of them. 

%WILL BE DONE WITH BLOCKS
%Randomises the conditions.
%1 = low WM load
%2 = high Wm load
condition_random = repmat(1:Con_number,1,trials_per_con);
con_list = randsample(condition_random, Con_number *con_trials);

%Randomises whether the target is left/right or up/down
sub_con_random = repmat(1:sub_con,1,sub_con_trials);
sub_con_list = randsample(sub_con_random, sub_con *sub_con_trials);

%When target middle/not middle, randomises whether distractor up/down
%1 = up/right, 2 = down/left
distract_random = repmat(1:arcLocs,1, sub_con_trials);
distract_random_list = randsample(distract_random, sub_con *sub_con_trials);

% %Is the distractor aligned with the target (eg. also in the middle when the
% %target is) or not (eg. left or right when target in the middle)
% distract_random = repmat(1:arcLogs/2, sub_con_trials);
% distract_random_list = randsample(distract_random, sub_con *sub_con_trials);


%% %Fixation cross adapted from Thaler, SchÃ¼tz, Goodale and Gegenfurtner (2013)
%(Thaler, L., SchÃ¼tz, A. C., Goodale, M. A., & Gegenfurtner, K. R. (2013).
%What is the best fixation target? The effect of target shape on stability of fixational eye movements. Vision Research, 76, 31-42.)

width = 37;                                                                 % horizontal dimension of display (cm)
dist = 60;                                                                  % viewing distance (cm)
colorOval = [255 255 255];                                                  % color of the two circles [R G B]
colorCross = [0 0 0];                                                       % color of the Cross [R G B]

sizecircle1 = 0.6;                                                          % diameter of outer circle (degrees)                     
sizecircle2 = 0.2;                                                          % diameter of inner circle (degrees)

ppd = pi * (rect(3)-rect(1)) / atan(width/ dist/2) / 360;                   % pixel per degree
[cx, cy] = RectCenter(rect);

%Size now set to normal


%% Instructions
test_matrix = [0 0
               0 0
               0 0
               0 0];
%%Something here

%% A for loop that goes through all the trials

for i = 1:length(con_list)
    %% Selects right positioning according to condition
    %Target is a green circle. Other items are green diamond s. Distractors
    %are red curves appearing in the periphery.
    
    switch sub_con_list(i)
        case 1                                                             %TARGET UP
%% This decides whether the target aligns with the distractor
            if does_align(1,case_counter(sub_con_list(i))) > percentage                                                            %in total 25% of times aligns with the target         
                if distract_random_list(i) <= length(distract_random_list)/2                           %Distractor is...
                    dist_location = 1;                                                                 %Up 12.5% of times                      
                else
                    dist_location = 3;                                                                 %Down 12.5% of times     
                end
                test_matrix (1,1) = test_matrix(1,1) + 1
            elseif does_align(1,case_counter(sub_con_list(i) )) <= percentage                                                        %in total 75% of times does not align with the target                   
                if distract_random_list(i) <= length(distract_random_list)/2                           %Distractor is...
                    dist_location = 2;                                                                  %left 37.5% of the time                                    
                else
                    dist_location = 4;                                                                  %right 37.5% of the time
                end
                test_matrix (1,2) = test_matrix(1,2) + 1
            end
case_counter(sub_con_list(i)) = case_counter(sub_con_list(i)) + 1;
%% This sets up target and neutral stimuli
            up_random = circles(2);                                        %TARGET
            down_random = diamonds(2);                                     %neutral
            right_random = diamonds(2);                                    %neutral
            left_random = diamonds(2);                                     %neutral
            
            
        case 2                                                             %TARGET DOWN
%% This decides whether the target aligns with the distractor          
     
            if does_align(2,case_counter(sub_con_list(i))) > percentage                               %in total 25% of times aligns with the target           
                if distract_random_list(i) == 1                            %Distractor is...
                    dist_location = 1;                                     %Up 12.5% of times                 
                else
                    dist_location = 3;                                     %Down 12.5% of times    
                end
                test_matrix (2,1) = test_matrix(2,1) + 1
            elseif does_align(2,case_counter(sub_con_list(i))) <= percentage                            %in total 75% of times does not align with the target             
                if distract_random_list(i) == 1                            %Distractor is...
                    dist_location = 2;                                     %left 37.5% of the time                                      
                else
                    dist_location = 4;                                     %right 37.5% of the time
                end
                test_matrix (2,2) = test_matrix(2,2) + 1
            end
case_counter(sub_con_list(i)) = case_counter(sub_con_list(i)) + 1;
%% This sets up target and neutral stimuli
            up_random = diamonds(2);                                       %neutral
            down_random = circles(2);                                      %TARGET
            right_random = diamonds(2);                                    %neutral
            left_random = diamonds(2);                                     %neutral
            
        case 3                                                             %TARGET RIGHT
%% This decides whether the target aligns with the distractor
            if does_align(3,case_counter(sub_con_list(i))) > percentage                               %in total 25% of times aligns with the target           
                if distract_random_list(i) == 1                            %Distractor is...
                    dist_location = 2;                                     %Left 12.5% of times                 
                else
                    dist_location = 4;                                     %Right 12.5% of times    
                end
                test_matrix (3,1) = test_matrix(3,1) + 1
            elseif does_align(3,case_counter(sub_con_list(i))) <= percentage                            %in total 75% of times does not align with the target             
                if distract_random_list(i) == 1                            %Distractor is...
                    dist_location = 1;                                     %Up 37.5% of the time                                      
                else
                    dist_location = 3;                                     %Down 37.5% of the time
                end
                test_matrix (3,2) = test_matrix(3,2) + 1
            end
case_counter(sub_con_list(i)) = case_counter(sub_con_list(i)) + 1;
%% This sets up target and neutral stimuli
            
            distract_leftright = distract_random_list(i);                  %distractor left or right
            up_random = diamonds(2);                                       %neutral                                   
            down_random = diamonds(2);                                     %neutral                                  
            right_random = circles(2);                                     %TARGET
            left_random = diamonds(2);                                     %neutral   
            
        case 4                                                             %TARGET LEFT     
%% This decides whether the target aligns with the distractor  

            if does_align(4,case_counter(sub_con_list(i))) > percentage                               %in total 25% of times aligns with the target           
                if distract_random_list(i) == 1                            %Distractor is...
                    dist_location = 2;                                     %Left 12.5% of times                 
                else
                    dist_location = 4;                                     %Right 12.5% of times    
                end
                test_matrix (4,1) = test_matrix(4,1) + 1
            elseif does_align(4,case_counter(sub_con_list(i))) <= percentage                            %in total 75% of times does not align with the target             
                if distract_random_list(i) == 1                            %Distractor is...
                    dist_location = 1;                                     %Up 37.5% of the time                                      
                else
                    dist_location = 3;                                     %Down 37.5% of the time
                end
                test_matrix (4,2) = test_matrix(4,2) + 1
            end
case_counter(sub_con_list(i)) = case_counter(sub_con_list(i)) + 1; 
%% This sets up target and neutral stimuli
            
            up_random = diamonds(2);
            down_random = diamonds(2);
            right_random = diamonds(2);
            left_random = circles(2);
            
    end
    
 
%%Orientations for targetlines. Just assigned at random atm.

% DP - keeping these random is fine
leftline = randi(2);
rightline = randi(2);
upline = randi(2);
downline = randi(2);


%
%% Draw the shapes according to conditions

    %and fixation cross in the middle
    Screen('FillOval', MainWindow, colorOval, [cx-sizecircle1/2 * ppd, cy-sizecircle1/2 * ppd, cx+sizecircle1/2 * ppd, cy+sizecircle1/2 * ppd], sizecircle1 * ppd);
    Screen('DrawLine', MainWindow, colorCross, cx-sizecircle1/2 * ppd, cy, cx+sizecircle1/2 * ppd, cy, sizecircle2 * ppd);
    Screen('DrawLine', MainWindow, colorCross, cx, cy-sizecircle1/2 * ppd, cx, cy+sizecircle1/2 * ppd, sizecircle2 * ppd);
    Screen('FillOval', MainWindow, colorOval, [cx-sizecircle2/2 * ppd, cy-sizecircle2/2 * ppd, cx+sizecircle2/2 * ppd, cy+sizecircle2/2 * ppd], sizecircle2 * ppd);
    %Left shape+line
    Screen('DrawTexture', MainWindow, left_random , [], stimRects(2,:) );
    Screen('DrawTexture', MainWindow, target_lines(leftline) , [], linecoor(2,:));
    %Right shape+line
    Screen('DrawTexture', MainWindow, right_random , [], stimRects(4,:));
    Screen('DrawTexture', MainWindow, target_lines(rightline) , [], linecoor(4,:));
    %Down shape+line
    Screen('DrawTexture', MainWindow, down_random , [], stimRects(1,:) );
    Screen('DrawTexture', MainWindow, target_lines(downline) , [], linecoor(1,:));
    %Up shape+line
    Screen('DrawTexture', MainWindow, up_random , [], stimRects(3 ,:));
    Screen('DrawTexture', MainWindow, target_lines(upline), [], linecoor(3,:));
    
    % The peripheral arc distractors:
    possible_arcLocs = 1:arcLocs;        %all the possible arc locations, should give: [1 2 3 4]
    coloured_arcLoc = dist_location;    %pick a location to be coloured at random. Will want to change this so that distractor is not 100% random on each trial. If you get stuck with this let me know.
    gray_arcLoc = possible_arcLocs(possible_arcLocs ~= coloured_arcLoc); % all other arc locations will be grey
    Screen('FrameArc', MainWindow, red, arcRect, arc_start(coloured_arcLoc), arc_angle, arc_width);  % this function draws the coloured arc. You can run 'Screen FrameArc?' for more info about it.
    
    for i = 1:length(gray_arcLoc) % for the other arc locations
        Screen('FrameArc', MainWindow, gray, arcRect, arc_start(gray_arcLoc(i)), arc_angle, arc_width); % draw a grey arc
    end

    %Keeping fixation cross visible
    Screen(MainWindow, 'Flip')
    KbWait([],2);
    Screen('FillOval', MainWindow, colorOval, [cx-sizecircle1/2 * ppd, cy-sizecircle1/2 * ppd, cx+sizecircle1/2 * ppd, cy+sizecircle1/2 * ppd], sizecircle1 * ppd);
    Screen('DrawLine', MainWindow, colorCross, cx-sizecircle1/2 * ppd, cy, cx+sizecircle1/2 * ppd, cy, sizecircle2 * ppd);
    Screen('DrawLine', MainWindow, colorCross, cx, cy-sizecircle1/2 * ppd, cx, cy+sizecircle1/2 * ppd, sizecircle2 * ppd);
    Screen('FillOval', MainWindow, colorOval, [cx-sizecircle2/2 * ppd, cy-sizecircle2/2 * ppd, cx+sizecircle2/2 * ppd, cy+sizecircle2/2 * ppd], sizecircle2 * ppd);
    Screen(MainWindow, 'Flip');

    pause(0.5);
end

%% Press any key to close experiment
KbWait([], 2);

sca
