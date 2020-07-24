function data = load_real_data(filename)
    data = struct; 
    
    % parse info from filename 
    k = strfind(filename,".bag");
    data.trial = str2double(extractBetween(filename,k-1,k));
    
    % Get path from video 
    prefix = extractBetween(filename,1,k);
    vidfilename = sprintf("%smp4",prefix{1}); 
    [data.ts.gnd, vidscale] = track_turtlebot(vidfilename); 
    % make starting point 0,0 and scale to meters 
    data.ts.gnd.Data = (data.ts.gnd.Data - data.ts.gnd.Data(1,:))*0.1/vidscale; 
    temp = data.ts.gnd.Data(:,1); 
    data.ts.gnd.Data(:,1) = data.ts.gnd.Data(:,2); 
    data.ts.gnd.Data(:,2) = temp; 
    close all; 
    
    % select desired topics of rosbag 
    rosbag1 = rosbag(filename); 
    rosbag_imu_enc = select(rosbag1,'Topic','localization/imu_enc'); 
    rosbag_vio = select(rosbag1,'Topic','localization/vio');
    rosbag_vis = select(rosbag1,'Topic','localization/orbslam');
    % turn topics into timeseries with position data
    data.ts.imu_enc = timeseries(rosbag_imu_enc,'Pose.Pose.Position.X','Pose.Pose.Position.Y');  
    data.ts.vio = timeseries(rosbag_vio,'Pose.Pose.Position.X','Pose.Pose.Position.Y');  
    data.ts.vis = timeseries(rosbag_vis,'Pose.Pose.Position.X','Pose.Pose.Position.Y');  
    
    % process the data 
    suffixes = ["gnd","vio","imu_enc","vis"];
    
    interval = 1e-1; 
    % Synchronize vio and vis data with imu data so it is easier to line
    % them all up later
    [~,data.ts.vio] = synchronize(data.ts.imu_enc, data.ts.vio,'Uniform','Interval',interval);
    [~,data.ts.vis] = synchronize(data.ts.imu_enc, data.ts.vis,'Uniform','Interval',interval);
    % Synchronize time between video and imu_enc based on distance moved 
    [data.ts.gnd,~] = dist_sync(data.ts.gnd,0.01); 
    [data.ts.imu_enc, rosbag_start] = dist_sync(data.ts.imu_enc,0.01); 
    % Line up vio and vis data with imu_encoder start time (and video start)
    data.ts.vio = time_sync_rosbag(data.ts.vio,rosbag_start); 
    data.ts.vis = time_sync_rosbag(data.ts.vis,rosbag_start);
    
    [data.ts.gnd_imu_enc,data.ts.imu_enc] = synchronize(data.ts.gnd, data.ts.imu_enc,'Uniform','Interval',interval);
    [data.ts.gnd_vio,data.ts.vio] = synchronize(data.ts.gnd, data.ts.vio,'Uniform','Interval',interval);
    [data.ts.gnd_vis,data.ts.vis] = synchronize(data.ts.gnd, data.ts.vis,'Uniform','Interval',interval);
    
 
    
    
    % calculate RMSE 
    for s = suffixes(2:size(suffixes,2)) 
        [data.rmse.(sprintf('x_%s',s)),data.rmse.(sprintf('y_%s',s))] ... 
            = calc_rmse_xy(data.ts.(sprintf('%s',s)), data.ts.(sprintf('gnd_%s',s))); 
        [data.rmse.(sprintf('x_ts_%s',s)),data.rmse.(sprintf('y_ts_%s',s))] ... 
            = calc_rmse_ts_xy(data.ts.(sprintf('%s',s)),data.ts.(sprintf('gnd_%s',s))); 
    end 
end

%% Helper functions
function [rmse_ts_x, rmse_ts_y] = calc_rmse_ts_xy(est, gnd)
    rmse_ts_x = timeseries; 
    rmse_ts_y = timeseries; 
    for time = 1:size(est.Time) 
        rmse_ts_x = addsample(rmse_ts_x,'Data',calc_rmse(est.Data(1:time,1),gnd.Data(1:time,1)),'Time',est.Time(time));
        rmse_ts_y = addsample(rmse_ts_y,'Data',calc_rmse(est.Data(1:time,2),gnd.Data(1:time,2)),'Time',est.Time(time));
    end
end 

function [rmse_x, rmse_y] = calc_rmse_xy(est, gnd)
    rmse_x = calc_rmse(est.Data(1:end,1),gnd.Data(1:end,1));
    rmse_y = calc_rmse(est.Data(1:end,2),gnd.Data(1:end,2));
end

function rmse = calc_rmse(est,gnd)
    rmse = sqrt(mean((est-gnd).^2));
end

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