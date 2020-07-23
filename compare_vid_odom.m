%% Get path from video 
[vidpath, vidscale] = track_turtlebot('/home/josh/turtlebotdrive.mp4'); 
% make starting point 0,0 and scale to meters 
vidpath.Data = (vidpath.Data - vidpath.Data(1,:))*0.1/vidscale; 

%% Get path from rosbag
rosbag1 = rosbag('/home/josh/turtlebotdrive.bag'); 
rosbag_odom = select(rosbag1,'Topic','localization/odom');
rosbag_vio = select(rosbag1,'Topic','localization/vio');
rosbag_imu = select(rosbag1,'Topic','localization/imu');
rosbag_vis = select(rosbag1,'Topic','localization/orbslam'); 

odompath = timeseries(rosbag_odom,'Pose.Pose.Position.X','Pose.Pose.Position.Y');  
viopath = timeseries(rosbag_vio,'Pose.Pose.Position.X','Pose.Pose.Position.Y');  
imupath = timeseries(rosbag_imu,'Pose.Pose.Position.X','Pose.Pose.Position.Y');  
vispath = timeseries(rosbag_vis,'Pose.Pose.Position.X','Pose.Pose.Position.Y');  

%% Synchronize time between video and rosbag based on distance moved 
[synced_vid,~] = dist_sync(vidpath,0.01); 
[synced_odom, rosbag_start] = dist_sync(odompath,0.01); 

[synced_vid, synced_odom] = synchronize(synced_vid, synced_odom,'Uniform','Interval',1e-1);
[~,synced_vio] = synchronize(odompath, viopath,'Uniform','Interval',1e-1);
[~,synced_imu] = synchronize(odompath, imupath,'Uniform','Interval',1e-1);
[~,synced_vis] = synchronize(odompath, vispath,'Uniform','Interval',1e-1);

synced_vio = time_sync_rosbag(synced_vio,rosbag_start); 
synced_imu = time_sync_rosbag(synced_imu ,rosbag_start); 
synced_vis = time_sync_rosbag(synced_vis,rosbag_start); 

close all; 
% hold on; 
% plot(synced_vid.Time,synced_vid.Data(:,2)); 
% plot(synced_odom.Time,synced_odom.Data(:,1));
% plot(synced_vio.Time,synced_vio.Data(:,1));
% plot(synced_vis.Time,synced_vis.Data(:,1));
% hold off; 

% figure; 
% hold on; 
% plot(synced_vid.Time,synced_vid.Data(:,1)); 
% plot(synced_odom.Time,synced_odom.Data(:,2));
% plot(synced_vio.Time,synced_vio.Data(:,2));
% plot(synced_vis.Time,synced_vis.Data(:,2));
% hold off; 

figure; 
for time = synced_vid.Time'
   hold on; 
   plot(synced_vid.Data(synced_vid.Time < time,2),synced_vid.Data(synced_vid.Time < time,1),'g'); 
   plot(synced_odom.Data(synced_odom.Time < time,1),synced_odom.Data(synced_odom.Time < time,2),'b');
   plot(synced_vis.Data(synced_vis.Time < time,1),synced_vis.Data(synced_vis.Time < time,2),'r');
   pause(0.001); 
end

% 
% figure; 
% plot(vidpath.Data(:,2),vidpath.Data(:,1)); 
% hold on;  
% plot(odompath.Data(:,1),odompath.Data(:,2)); 
% hold on; 
% plot(viopath.Data(:,1),viopath.Data(:,2)); 
% hold on; 
% plot(imupath.Data(:,1),imupath.Data(:,2)); 
% hold on; 
% plot(vispath.Data(:,1),vispath.Data(:,2)); 
% legend("video","odometry","fused","imu","visual"); 
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