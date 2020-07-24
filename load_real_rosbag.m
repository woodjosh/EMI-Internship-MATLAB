function data = load_sim_rosbag(filename)
    data = struct; 
    %% get the data 
    % parse info from filename 
    j = strfind(filename,"/");
    file_info = extractBetween(filename,j(end)+1,strlength(filename));
    k = strfind(file_info,"_");
    data.location = extractBetween(file_info,1,k{1}(1)-1);
    data.model    = extractBetween(file_info,k{1}(1)+1,k{1}(2)-1);
    data.trial    = str2double(extractBetween(file_info,k{1}(2)+1,k{1}(3)-1));
    
    % select desired topics of rosbag 
    rosbag1 = rosbag(filename); 
    rosbag_gnd = select(rosbag1,'Topic','localization/gnd_truth'); 
    rosbag_vio = select(rosbag1,'Topic','localization/vio');
    rosbag_imu = select(rosbag1,'Topic','localization/imu');
    rosbag_vis = select(rosbag1,'Topic','localization/orbslam');
    % turn topics into timeseries with position data
    data.ts.gnd = timeseries(rosbag_gnd,'Pose.Pose.Position.X','Pose.Pose.Position.Y');  
    data.ts.vio = timeseries(rosbag_vio,'Pose.Pose.Position.X','Pose.Pose.Position.Y');  
    data.ts.imu = timeseries(rosbag_imu,'Pose.Pose.Position.X','Pose.Pose.Position.Y');  
    data.ts.vis = timeseries(rosbag_vis,'Pose.Pose.Position.X','Pose.Pose.Position.Y');  
    %% process the data 
    suffixes = ["gnd","vio","imu","vis"]; 
    % adjust time so it starts at 0 
    start = data.ts.gnd.Time(1);
    for s = suffixes 
        data.ts.(s).Time = data.ts.(s).Time-start;
    end
    
    % resample to get matching time vectors 
    for s = suffixes(2:size(suffixes,2))
        [data.ts.(sprintf('gnd_%s',s)),data.ts.(sprintf('%s',s))] ...
            = synchronize(data.ts.gnd, data.ts.(s),'Union');
    end
     
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