%THIS CODE GENERATES AN PSYCHoPHYSICAL EXPERIMENT INVESTIGATING THE EFFECTS
%OF MOVEMENT DIRECTION ON MOVEMENT DIRECTION DISCRIMINATION. (CARDINAL VS.
%DIAGONAL DIRECTIONS).

%THE PARTICIPANTS WILL SEE TWO MOVING GABORS, AND WILL HAVE TO INDICATE
%WHETHER THEY MOVE INTO THE SAME OR DIFFERENT DIRECTIONS. THERE ARE 4 MAIN
%MOVEMENT DIRECTIONS (MAIN CONDITIONS)

%1. UP (VERTICAL)
%2. TO THE RIGHT (HORIZONTAL)
%3. UPPER RIGHT (DIAGONAL)
%4. LOWER RIGHT (DIAGONAL)

%THE OTHER GABOR CAN DIFFER FROM THESE DIRECTIONS BY THE FOLLOWING ANGLES
%(SUB-CONDITIONS)
% 3, 6, 12, 18, 24

%THE PARTICIPANT WILL GO THROUGH ALL THE MAIN CONDITIONS (RANDOMISED),
%WHERE HALF OF THE TRIALS THE GABORS WILL MOVE INTO THE SAME DIRECTION ANND
%HALF OF THE TRIALS THEY WILL DIFFER BY THE SPECIFIED ANGLES (30 TRIALS FOR
%EACH ANGLE, ALL COMPLETELY RANDOMISED)

%THE PROGRAM WILL SAVE THE ACCURACY AND REACTION TIMES IN EACH
%SUB-CONDITION FOR ANALYSIS. THE DATA CAN BE USED FOR PLOTTING THE
%PSYCHOMETRIC FUNCTIONS OF THE PARTICIPANTS



%****************************************************************************
%EXPERIMENT SET-UP
%****************************************************************************

%SETS UP RANDOM-NUMBER GENERATOR
rng('default')
rng('shuffle')


%TAKES THE PARTICIPANT INFORMATION AS INPUT
subNo = input('Please enter subject number:');
age = input('Age:');
sex = input('Sex:');
va = input('Visual acuity:');


%%%%%%%%%%%%%%%%%%%%%%%%%
% PRELIMINART OPERATIONS
%%%%%%%%%%%%%%%%%%%%%%%%%

% CLEAR MATLAB WINDOW:
clc;

% CHECK FOR OPENGL-COMPABILITY
% AssertOpenGL;


% RESET RANDOM NUMBER GENERATOR
rand('state',sum(100*clock));


% INITIATE KEYBORD-RESPONSES
InCategory  = KbName('m'); % within category key 'm'
OutCategory = KbName('c'); % out of category via key 'c'

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% IMPORTANT VARIABLES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% presentation time of each image
GaborDuration   = 2;
% 0 = left horizontal, movement direction
GaborDirection = [0, 45, 90, 135, 180];                                    

% COLOR RGB VALUES FOR FEEDBACK (ON PRACTICE ONLY)
red = [200 20 50];
green = [50 250 50];

%GETS THE SCREEN NUMBER AND OPENS THE MAXIMUM INDEX (SCREEN NO. 1)
screens=Screen('Screens');
screenNumber=max(screens);

% HIDES THE MOUSE CURSOR:
HideCursor;


% DEFINES BLACK AND WHITE
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
grey = white / 2;
inc = white - grey;

%

%DEFINES THE WINDOW IN WHICH THE EXPERIMENT IS DISPLAYD
[w, wRect]=Screen('OpenWindow',screenNumber, grey, [ 0 0 1024 768]);

% SETS UP ALPHA-BLENDING TO GET ANTI-ALIASED LINES
Screen('BlendFunction', w, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');


%PARAMETERS FOR FIXATION CROSS AND TEXT SIZE
Screen('TextFont', w, 'Ariel');
Screen('TextSize', w, 36);

% CENTER COORDINATES
[xCenter, yCenter] = RectCenter(wRect);

% FIXATION CROSS ARM-SIZE
fixCrossDimPix = 20;

%FIXATION CROSS COORDINATES
CROSSCOORX = [-fixCrossDimPix fixCrossDimPix 0 0];
CROSSCOORY = [0 0 -fixCrossDimPix fixCrossDimPix];
allCoords = [CROSSCOORX; CROSSCOORY];

% LINEWIDTH(PIXELS
lineWidthPix = 4;

%DUMMY CALLS TO MAKE SURE THE FUNCTION ARE READY
KbCheck;
WaitSecs(0.1);
GetSecs;


%IFI = ESTIMATE OF THE FLIP INTERVAL OF THE SCREEN
ifi = Screen('GetFlipInterval', w);
% GABOR GRATING SIZE IN PIXELS
gratingSizePix = 600;

% GRATING FREQUENCY IN CYCLES PER PIXEL
%CONTROLS THE FREQUENCY OF THE SINE-WAVE/GRATING
freqCyclesPerPix = 0.01;

% DEFINES THE MOVEMENT SPEED OF THE GRATING (CYCLES PER SECOND)
cyclesPerSecond = 0.5;

% DEFINE HALF-SIZE OF THE GRATING
texsize = gratingSizePix / 2;

% CYCLES PER SECOND ROUNDED TO THE NEAREST PIXEL (SMALLEST UNIT, CANT BE
% SMALLER
% Ceil rounds each element of X to the nearest integer greater than 
% or equal to that element.
pixPerCycle = ceil(1 / freqCyclesPerPix);                                   


% FREQUENCY IN RADIANS
freqRad = freqCyclesPerPix * 2 * pi;

% VISIBLE SIZE OF THE GRATING
visibleSize = 2 * texsize + 1;

% DEFINES THE GRATING BY CREATING A SINEWAVE BASED ON THE VARIABLES
% SPECIFIED BEFORE
x = meshgrid(-texsize:texsize + pixPerCycle, 1);
grating = 50* sin(freqRad*x) + grey;

%********************************************
%THIS CAN BE USED TO ADD NOISE INTO THE GRATING IF UNCOMMENTED
%**********************************************
% %NOISE MASK
% mask = ones(1, numel(x), 2) * grey;
% contrast = 0.9;
% mask(:, :, 2)= grating .* contrast;
% noise = rand(round(visibleSize / 2)) .* grey;
% noiseTex = Screen('MakeTexture', w, noise);
%************************************************

%IMFILTERS
%USES A IN-BUILD MOTION FILTER TO MAKE THE GRATING BLURRIER
Filter = fspecial('motion', 100, 80);
FilteredGrating = imfilter(grating, Filter, 'replicate');


% MAKES THE DESTINATION RECTANGLE THAT IT USED TO SPECIFY THE LOCATION AND
% MOVEMENT OF THE GRATING
dstRect = [0 0 visibleSize visibleSize];
dstRect = CenterRect(dstRect, wRect);

% WAIT ONE FRAME FLIP BEFORE REDRAWING
waitframes = 1;

% WAITDURATION (WAIT-DURATION * TIME IT TAKES TO FLIP THE SCREEN)
waitDuration = waitframes * ifi;

% PIXPERCYCLE WITHOUT ROUNDING, OTHERWISE THERE WILL BE ROUNDING ERRORS
pixPerCycle = 1 / freqCyclesPerPix;

%USES PREVIOUSLY SPECIFIED SPEED-VARIABLES AND WAITDURATION TO GENERATE THE
%AMOUNT OF SHIFT PER FRAME
shiftPerFrame = cyclesPerSecond * pixPerCycle * waitDuration;

%SYNCS TO THE VERTICAL RETRACE (
vbl = Screen('Flip', w);

% SET FRAMECOUNTER TO ZERO FOR COUNTING THE FRAMES
frameCounter = 0;

%GENERATES THE GRATING TEXT
gratingTex = Screen('MakeTexture', w, FilteredGrating);

%A CIRCULAR GAUSSIAN MASK WITH BLURRED BORDERS (OTHERWISE 
%THE MOVING GRATING WILL BE A SQUARE)MASK PARAMETERS
gabor_size      = 40; % Gabor size in degrees of visual angle
aperture        = 1.5;% aperture  of gaussian window
pixelsPerDeg    = 27; % 27 pixels per degree of visual angle for 1024 x 768 res
EccTarget       = 0;  % in deg of visual angle
GAbgrey    = round((white+black)/2); %Grey
gaussSD         = pixelsPerDeg * aperture;

%Defines the mask based on the variables
parmss.gabor_dim = [round(pixelsPerDeg*gabor_size) round(pixelsPerDeg*gabor_size)]; 

%GENERATES THE MASK BASED ON THE SPECIFIED VARIABLES
Circlemask        = ones(parmss.gabor_dim(1)+1, parmss.gabor_dim(1)+1, 2) * GAbgrey;
[x,y]       = meshgrid(-parmss.gabor_dim(1)/2:parmss.gabor_dim(1)/2,-parmss.gabor_dim(1)/2:parmss.gabor_dim(1)/2);
Circlemask(:,:,2) = white * (1 - exp(-((x/gaussSD).^2)-((y/gaussSD).^2)));
masktex     = Screen('MakeTexture', w, Circlemask);


%COORDINATES FOR DRAWING THE MASK
gabor_tex_rect      = [0 0 parmss.gabor_dim];
gabor_center_rect   = CenterRect(gabor_tex_rect, wRect);
gabor_rect          = gabor_center_rect+[pixelsPerDeg*EccTarget,0,pixelsPerDeg*EccTarget,0];

%DEFINES THE CONDITIONS OF THE EXPERIMENT AND THE AMOUNT OF TRIALS PER
%CONDITIONS
CON = [90 135 180 225];
SecGabors = [3 6 12 18 24];
trials = 30;
totaltrials = length(SecGabors) * trials;


%INTERSTIMULUS INTERVAL
iti =0.5;

%AN EMPTY MATRIX FOR SAVING THE RESULTS IN
results=[];
% INSTRUCTION MESSAGE
message = ['Indicate whether the gratings are moving into the same direction.' ...
    '\n Press M for same direction, and C for different direction' ...
    '\n There will be a feedback following your response.\n Press the mouse button to begin...'];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EXPERIMENT BEGINS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%WRITES INSTRUCTION MESSAGE IN THE MIDDLE WITH WHITE COLOUR.
DrawFormattedText(w, message, 'center', 'center', WhiteIndex(w));
Screen('Flip', w);

% MOUSE CLICK TO STAR THE EXPERIMENT:
GetClicks(w);

% WAITS A SECOND BEFORE STARTING
WaitSecs(1.000);

%CREATES A A RANDOM ORDER FOR THE CONDITIONS, WITH THE SAME AMOUNT OF EACH
%CONDITION
randomGabor = randperm(length(CON));

% FOR-LOOP TO RUN THE EXPERIMENT
for Block = 1:length(CON)
    
    %SPECIFIES THE ORDER OF THE DIFFERING CONDITIONS (DIFFERING CONDITION = HOW
    %MUCH THE DIFFERING GABOR DIFFERS FROM THE MAIN ONE). THE ORDER IS RANDOM
    %FOR EACH CONDITION
    TargetGabor = CON(randomGabor(Block));
    TargetGaborRes = TargetGabor;
    
    randomSecGabor = [];
    while length(randomSecGabor) <  totaltrials
        randomlist = randperm(length(SecGabors));
        randomSecGabor =horzcat( randomSecGabor, randomlist);
    end
    
    %SPECIFIES THAT HALF OF THE TIME THE GABORS ARE GOING TO MOVE TO THE SAME
    %DIRECTION AND HALF OF THE TIME TO A DIFFERENT DIRECTION. THE ORDER IS
    %RANDOM FOR EACH CONDITION
    samediflist = [];
    while length(samediflist) < totaltrials
        randomlist = randperm(trials);
        balancelist = randomlist > trials / 2 ;
        anglelist = double(balancelist);
        samediflist =horzcat(samediflist, anglelist);
    end
    
    
    %FOR-LOOP THAT GOES TROUGH ONE OF THE MAIN CONDITIONS
    for AllGabors = 1: totaltrials
        
        %DEFINES THE ORDERS AND OF THE SUB-CONDITIONS AND SAME OR DIFFERENT
        %MOVING DIRECTION
        SecGabor = SecGabors(randomSecGabor(AllGabors));
        CompGabor = TargetGabor + SecGabor;
        samediff = samediflist(AllGabors);
        Order = randi(2);
        
        %WHETHER THE GABORS WILL MOVE INTO THE SAME OR DIFFERENT DIRECTION
        %WITHIN THIS TRIAL
        if samediff == 1
            
            TargetGabor = TargetGabor;
            CompGabor = CompGabor;
        else
            TargetGabor = TargetGabor;
            CompGabor = TargetGabor;
        end
        
        %IF THEY MOVE INTO DIFFEERENT DIRECTIONS, WHICH COMES FIRST.
        if Order == 1
            FirstGabor = TargetGabor;
            SecondGabor = CompGabor;
            
        else
            FirstGabor = CompGabor;
            SecondGabor = TargetGabor;
            
        end
        
        
        %DRAWS THE FIXATION CROSS
        Screen('DrawLines', w, allCoords,...
            lineWidthPix, black, [xCenter yCenter], 2);
        
        % SCREENFLIP
        Screen('Flip', w);
        
        WaitSecs(0.500);
        
        Screen('Flip', w); % clear screen to background color
        
        % initialize KbCheck and variables
        [KeyIsDown, endrt, KeyCode]= KbCheck;
        
        
        
        %THIS GENERATES A MOVING GABOR ACCORDING TO THE CONDITION
        while frameCounter < 120                                                 
            % 120 * ifi = 2004ms
            
            %CALCULATE THE XOFFSET FOR THE WINDOW TO SAMPLE THE GRATING 
            %(USED FOR CREATING THE MOVEMENT)
            
            %xoffset grows as the loop goes on
            %Mod returns the reminder of the division, so the remainder of
            %Framecounter * shiftPerFrame/PixPerCycle.
            xoffset = mod(frameCounter * shiftPerFrame, pixPerCycle) ;
            
            %xoffset grows as the loop goes on.
            %FRAMECOUNTER + 1
            frameCounter = frameCounter + 1;
            
            %DEFINES SOURCE RECTANGLE
            %SourceRect is defined again with the modified xoffset
            srcRect = [xoffset 0 xoffset + visibleSize visibleSize];               
            
            
            %DRAWS GRATING AND MASK WITH THE NEWLY DEFINED SRCRECT, CAUSING
            %MOVEMENT DUE TO THE GRATING SHIFTING EVERY ITERATION
            
            %The changing value of srcRect that is generated by xoofset 
            %is used to move the grating
            Screen('DrawTexture', w, gratingTex, srcRect, dstRect, FirstGabor );   
            Screen('DrawTexture', w, masktex, gabor_tex_rect, gabor_rect);
            
            % FLIP THE SCREEN ON THE NEXT VERTICAL RETRACE
            % Vertical retrace = the amount of time between the end of one
            %frame being drawn, and the beginning of the next frame.
            [VBLTimestamp]= Screen('Flip', w, vbl + (waitframes - 0.5) * ifi);     
            
        end
        
        %set framecounter back to zero
        frameCounter = 0;
        %clear screen to background color
        Screen('Flip', w);
        %GetSecs used for generating reaction times
        end_interval = GetSecs;                                                    
        
        
        %WAITS UNTIL ITI HAS ELAPSED
        while GetSecs - end_interval < iti
        end
        
        
        %HERE EXACTLY THE SAME SAME IS DONE AGAIN TO GENERATE A NEW GABOR THAT 
        %THE PARTICIPANT HAS TO COMPARE TO THE FIRST ONE. IT EITHER MOVES 
        %INTO THE SAME DIRECTION OR INTO A DIFFERENT ONE
        while frameCounter < 120
            xoffset = mod(frameCounter * shiftPerFrame, pixPerCycle);
            frameCounter = frameCounter + 1;
            srcRect = [xoffset 0 xoffset + visibleSize visibleSize];
            Screen('DrawTexture', w, gratingTex, srcRect, dstRect, SecondGabor);
            Screen('DrawTexture', w, masktex, gabor_tex_rect, gabor_rect);
            
            if frameCounter == 1
                [VBLTimestamp startrt]= Screen('Flip', w, vbl + (waitframes - 0.5) * ifi);
            else
                Screen('Flip', w, vbl + (waitframes - 0.5) * ifi);
            end
            
            %THE PARTICIPANT CAN RESPOND BEFORE STIMULUS TERMINATES
            [KeyIsDown, endrt, KeyCode]=KbCheck;
            if ( KeyCode(InCategory)==1 | KeyCode(OutCategory)==1 )
                break;
            end
            
            
            
        end
        
        %Framecounter to zero
        frameCounter = 0;
        % clear screen to background color
        Screen('Flip', w);                                                          
         
        
        
        %LOOP UNTIL VALID PARTICIPANT MAKES A RESPONSE
        while (KeyCode(InCategory)==0 & KeyCode(OutCategory)==0  )
            [KeyIsDown, endrt, KeyCode]=KbCheck;
        end
        
        % COMPUTES REACTION TIME (TIMES 1000 TO GET SECONDS)
        reactiontime = round(1000*(endrt-startrt));
        resp = find(KeyCode>0);
        
        
        % COMPUTES THE ACCURACY OF THE RESPONSE
        if ((KeyCode(InCategory)==1 & TargetGabor == CompGabor) | (KeyCode(OutCategory)==1 & TargetGabor ~= CompGabor) )
            accuracy =1;
        else
            accuracy = 0;
            
        end
        
        %FLIPS SCREEN
        Screen('Flip', w);
        
        %0.5 SEC BREAK BETWEEN TRIALS
        WaitSecs(0.500);
        
        %SAVES THE DATA FROM ONE TRIAL TO A THE RESULTS MATRIX
        resultsholder = [ subNo age sex va TargetGaborRes SecGabor samediff resp reactiontime accuracy ];
        results = vertcat(results, resultsholder);
        
        
    end
    
    %SUB-CONDITION OVER, TAKE A BREAK. RETURNS TO THE FIRST-LOOP
    DrawFormattedText(w, 'Please take a small break', 'center', 'center', WhiteIndex(w));
    Screen('Flip', w);
    GetClicks(w);
    
end



% SAVES THE RESULT-MATRIX AS A MAT-FILE.
Savename = num2str(subNo);
save(strcat('MovingGaborParticipant', Savename, '.mat'));

%EXPERIMENT OVER
DrawFormattedText(w, 'Thank you for participating', 'center', 'center', WhiteIndex(w));
Screen('Flip', w);
WaitSecs(3);

%CLOSES DOWN EVERYTHING
Screen('CloseAll');
ShowCursor;
fclose('all');
Priority(0);




