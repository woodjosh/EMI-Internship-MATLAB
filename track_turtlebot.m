function [path, scale] = track_turtlebot(filename)

% Create System objects for reading and displaying video and for drawing a bounding 
% box of the object. 
close all; 
videoReader = VideoReader(filename);
videoPlayer = vision.VideoPlayer('Position',[100,100,680,520]);

% Read the first video frame, which contains the object, define the region.
objectFrame = readFrame(videoReader);

% Get user input to define region and scale
figure('WindowState','fullscreen'); imshow(objectFrame);  
title("Draw box around object to track"); 
objectRegion=round(getPosition(imrect));
close; 
figure('WindowState','fullscreen'); imshow(objectFrame); 
title("Draw line across white circle"); 
scale=round(getPosition(imline));
fprintf("%3.1f pixels = .1 m\n",pdist(scale)); 
scale = pdist(scale); 
close; 
% Show initial frame with a red bounding box.
objectImage = insertShape(objectFrame,'Rectangle',objectRegion,'Color','red'); 
figure;

imshow(objectImage);
title('Red box shows object region');

% Detect interest points in the object region.
points = detectMinEigenFeatures(rgb2gray(objectFrame),'ROI',objectRegion);

% Display the detected points.
pointImage = insertMarker(objectFrame,points.Location,'+','Color','white');
pos = mean(points.Location(:,:)); 
pointImage = insertMarker(pointImage,pos,'x','Color','blue','Size',5); 
figure;
imshow(pointImage);
title('Detected interest points');
 
% Create a tracker object.
tracker = vision.PointTracker('MaxBidirectionalError',1);
 
% Initialize the tracker.
initialize(tracker,points.Location,objectFrame);

% Read, track, display points, and results in each video frame.
ts_raw = timeseries(pos,videoReader.currentTime); 
i = 2; 
while hasFrame(videoReader)
      % read next frame, track points
      frame = readFrame(videoReader);
      [points,validity] = tracker(frame);
      
      % calculate centroid with means
      pos = mean(points(validity,:)); 
      
      % display results 
      out = insertMarker(frame,points(validity, :),'+');
      out = insertMarker(out,pos,'x','Color','blue','Size',5); 
      videoPlayer(out);
      
      % add results to timeseries
      ts_raw = addsample(ts_raw,'Data',pos,'Time',videoReader.currentTime);
end

% Release the video player.
release(videoPlayer);
path = ts_raw;
end