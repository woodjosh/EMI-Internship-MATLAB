function [path, scale] = track_turtlebot(filename)

% Create System objects for reading and displaying video and for drawing a bounding 
% box of the object. 
close all; 
videoReader = VideoReader(filename);
videoPlayer = vision.VideoPlayer('Position',[100,100,680,520]);

% Read the first video frame, which contains the object, define the region.
objectFrame = readFrame(videoReader);

tryagain = true; 
nextFrame = true; 
% keep trying to get user input as long as user wants
figure('WindowState','fullscreen'); imshow(objectFrame);
while nextFrame
    imshow(objectFrame); 
    title("Press spacebar until desired start frame. Then press enter."); 
    waitforbuttonpress; 
    value = double(get(gcf,'CurrentCharacter'));
    
    if value == 32
        objectFrame = readFrame(videoReader); 
        nextFrame = true; 
    elseif value == 13 
        nextFrame = false; 
    end
end


while tryagain
    close all; 
    % Get user input to define region and scale
    figure('WindowState','fullscreen'); imshow(objectFrame);  
    title("Draw box around QR code"); 
    objectRegion=round(getPosition(imrect));
    close; 

    % Detect interest points in the object region.
    points = detectFASTFeatures(rgb2gray(objectFrame),'ROI',objectRegion);
        
    % Display the detected points.
    pointImage = insertMarker(objectFrame,points.Location,'+','Color','green');
    pos = mean(points.Location(:,:)); 
    pointImage = insertShape(pointImage,'FilledCircle',[pos 6],'Color','blue','Opacity',1); 

    figure('WindowState','fullscreen');imshow(pointImage);
    title('Detected interest points and robot center');
    
    % Ask user if the interest points are acceptable 
    f = figure;
    c = uicontrol;
    c.String = 'Yes';
    c.Callback = @yesButton;
    c.Position = [200 200 100 100];
    
    d = uicontrol; 
    d.String = 'No'; 
    d.Callback = @noButton; 
    d.Position = [300 200 100 100]; 
    
    annotation('textbox', [0.28 0.8 0 0], 'String', 'Is the center of the robot correct?', 'FitBoxToText', true);
    uiwait(f);  
 
end
% callback functions for button push 
        function yesButton(src,event)
            tryagain = false; 
            uiresume; 
            close all; 
        end
    
        function noButton(src,event)
            tryagain = true; 
            uiresume; 
        end

figure('WindowState','fullscreen'); imshow(objectFrame); 
title("Draw line across QR code for scale"); 
scale=round(getPosition(imline));
scale = pdist(scale); 
close; 

% Create a tracker object.
tracker = vision.PointTracker('MaxBidirectionalError',1);
 
% Initialize the tracker.
initialize(tracker,points.Location,objectFrame);

% Read, track, display points, and results in each video frame.
ts_raw = timeseries(pos,videoReader.currentTime); 
while hasFrame(videoReader)
      % read next frame, track points
      frame = readFrame(videoReader);
      [points,validity] = tracker(frame);
      
      % calculate centroid with means
      pos = mean(points(validity,:));
      
      if all(~isnan(pos)) && size(pos,2) == 2
          % display results 
          out = insertMarker(frame,points(validity, :),'+');
          out = insertShape(out,'FilledCircle',[pos 6],'Color','blue','Opacity',1); 
          videoPlayer(out);

          % add results to timeseries
          ts_raw = addsample(ts_raw,'Data',pos,'Time',videoReader.currentTime);
      end
end

% Release the video player.
release(videoPlayer);
path = ts_raw;
end