%% Get path from video 
[vidpath, vidscale] = track_turtlebot('/home/josh/turtlebotdrive2.mp4'); 
% make starting point 0,0 and scale to meters 
vidpath.Data = (vidpath.Data - vidpath.Data(1,:))*0.1/vidscale; 

%% Get path from rosbag
rosbag1 = rosbag('/home/josh/turtlebotdrive2.bag'); 
rosbag_imu_enc = select(rosbag1,'Topic','localization/imu_enc');
rosbag_vio = select(rosbag1,'Topic','localization/vio');
rosbag_vis = select(rosbag1,'Topic','localization/orbslam'); 

imupath = timeseries(rosbag_imu_enc,'Pose.Pose.Position.X','Pose.Pose.Position.Y');  
viopath = timeseries(rosbag_vio,'Pose.Pose.Position.X','Pose.Pose.Position.Y');   
vispath = timeseries(rosbag_vis,'Pose.Pose.Position.X','Pose.Pose.Position.Y');  

%% Synchronize time between video and rosbag based on distance moved 
[synced_vid,~] = dist_sync(vidpath,0.01); 
[synced_imu, rosbag_start] = dist_sync(imupath,0.01); 

[synced_vid, synced_imu] = synchronize(synced_vid, synced_imu,'Uniform','Interval',1e-1);
[~,synced_vio] = synchronize(imupath, viopath,'Uniform','Interval',1e-2);
[~,synced_vis] = synchronize(imupath, vispath,'Uniform','Interval',1e-2);

synced_vio = time_sync_rosbag(synced_vio,rosbag_start); 
synced_vis = time_sync_rosbag(synced_vis,rosbag_start); 

close all; 
figure; 
% set axes based on ground truth 
axis([min(synced_vid.Data(:,2))-0.2 max(synced_vid.Data(:,2))+0.2 ...
      min(synced_vid.Data(:,1))-0.2 max(synced_vid.Data(:,1))+0.2]); 
for time = synced_vid.Time'
   hold on; 
   plot(synced_vid.Data(synced_vid.Time < time,2),synced_vid.Data(synced_vid.Time < time,1),'g'); 
   plot(synced_imu.Data(synced_imu.Time < time,1),synced_imu.Data(synced_imu.Time < time,2),'b');
   plot(synced_vio.Data(synced_vio.Time < time,1),synced_vio.Data(synced_vio.Time < time,2),'m');
   plot(synced_vis.Data(synced_vis.Time < time,1),synced_vis.Data(synced_vis.Time < time,2),'r');
   pause(0.001); 
end

%% Helper functions
function [syncedts, time_start] = dist_sync(ts,sync_dist)
    i = 1; 
    % find when the robot has traveled sync_dist
    sync_dist_travelled = false; 
    while ~sync_dist_travelled
        dist = pdist([ts.Data(i,:); 0 0]);
        if dist > sync_dist
            sync_dist_travelled = true; 
        end
        i = i+1; 
    end
    % make the timeseries start when the robot has traveled 0.1 m
    time_start = ts.Time(i); 
    syncedts = timeseries(ts.Data(i:end,:),ts.Time(i:end)); 
    syncedts.Time = syncedts.Time - syncedts.Time(1); 
end

function syncedts = time_sync_rosbag(ts,rosbag_start)
    data = ts.Time > rosbag_start;
    syncedts = timeseries(ts.Data(data,:),ts.Time(data)); 
    syncedts.Time = syncedts.Time - rosbag_start; 
end