[vidpath, vidscale] = track_turtlebot('/home/josh/turtlebotdrive.mp4'); 
vidpath.Data = (vidpath.Data - vidpath.Data(1,:))*0.1/vidscale; 

%%
rosbag1 = rosbag('/home/josh/turtlebotdrive.bag'); 
rosbag_odom = select(rosbag1,'Topic','localization/odom');
rosbag_vio = select(rosbag1,'Topic','localization/vio');
rosbag_imu = select(rosbag1,'Topic','localization/imu');
rosbag_vis = select(rosbag1,'Topic','localization/orbslam'); 

odompath = timeseries(rosbag_odom,'Pose.Pose.Position.X','Pose.Pose.Position.Y');  
viopath = timeseries(rosbag_vio,'Pose.Pose.Position.X','Pose.Pose.Position.Y');  
imupath = timeseries(rosbag_imu,'Pose.Pose.Position.X','Pose.Pose.Position.Y');  
vispath = timeseries(rosbag_vis,'Pose.Pose.Position.X','Pose.Pose.Position.Y');  

%%
close all; 
figure; 
plot(vidpath.Data(:,2),vidpath.Data(:,1)); 
hold on;  
plot(odompath.Data(:,1),odompath.Data(:,2)); 
hold on; 
plot(viopath.Data(:,1),viopath.Data(:,2)); 
hold on; 
plot(imupath.Data(:,1),imupath.Data(:,2)); 
hold on; 
plot(vispath.Data(:,1),vispath.Data(:,2)); 


legend("video","odometry","fused","imu","visual"); 