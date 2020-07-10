%% Import ground truth data from bag file
% Script for importing data from a bag file

%% Parameters, change these to match those used to record data
models = ["waffleADX","waffle3DM","waffleEG120","waffleEG1300"]; 
location = "house"; 
have_vis = true; 

for model = models
    %% Select topic from rosbag and import it as a timeseries 
    rosbag1 = rosbag(sprintf("/home/josh/catkin_ws/src/my_pkgs/outputs/%s_%s_out.bag",location,model));
    rosbag_gnd = select(rosbag1,'Topic','localization/gnd_truth'); 
    rosbag_vio = select(rosbag1,'Topic','localization/vio');
    rosbag_imu = select(rosbag1,'Topic','localization/imu');
    if have_vis    
        rosbag_vis = select(rosbag1,'Topic','localization/orbslam');
    end
        
    suffix = ["gnd","vio","imu","vis"]; 
    ts = struct; 
    
    ts.(suffix(1)) = timeseries(rosbag_gnd,'Pose.Pose.Position.X','Pose.Pose.Position.Y');  
    ts.(suffix(2)) = timeseries(rosbag_vio,'Pose.Pose.Position.X','Pose.Pose.Position.Y'); 
    ts.(suffix(3)) = timeseries(rosbag_imu,'Pose.Pose.Position.X','Pose.Pose.Position.Y'); 
    if have_vis
        ts.(suffix(4)) = timeseries(rosbag_vis,'Pose.Pose.Position.X','Pose.Pose.Position.Y');  
    else 
        ts.(suffix(4)) = timeseries(zeros(1,10),ones(1,10)*ts.(suffix(1)).Time(1)); 
    end
    
    %% Adjust time so it starts at 0
    start = ts.(suffix(1)).Time(1); 
    ts.(suffix(1)).Time = ts.(suffix(1)).Time-start;
    ts.(suffix(2)).Time = ts.(suffix(2)).Time-start;
    ts.(suffix(3)).Time = ts.(suffix(3)).Time-start; 
    ts.(suffix(4)).Time = ts.(suffix(4)).Time-start;  
    %% Clear temporary variables
    clearvars -except ts suffix model location have_vis

    %% Resample to get matching time vectors 
    for s = suffix(2:size(suffix,2))
        [ts.(sprintf('gnd_resample_%s',s)),ts.(sprintf('%s_resample',s))] ...
            = synchronize(ts.gnd, ts.(s),'Union');
    end

    %% Calculate RMSE 
    rmse = struct;  
    for s = suffix(2:size(suffix,2)) 
        [rmse.(sprintf('x_%s',s)),rmse.(sprintf('y_%s',s))] ... 
            = calc_rmse_xy(ts.(sprintf('%s_resample',s)), ts.(sprintf('gnd_resample_%s',s))); 
        [rmse.(sprintf('x_ts_%s',s)),rmse.(sprintf('y_ts_%s',s))] ... 
            = calc_rmse_ts_xy(ts.(sprintf('%s_resample',s)), ts.(sprintf('gnd_resample_%s',s))); 
    end 

    print_rmse(suffix,rmse); 
    %% Plot output 
    colors = ['g','m','b','r']; 

    close all;
    figure; 
    hold on; 
        for i = 1:size(suffix,2)
            scatter(ts.(suffix(i)).Data(:,1),ts.(suffix(i)).Data(:,2),colors(i)); 
        end   
        title('Position in World Frame'); 
        xlabel('X Position'); ylabel('Y Position'); 
        legend('Ground Truth','Visual+Inertial Fused','Inertial','Visual','Location','northwest'); 
    hold off; 

    figure; 
    hold on; 
        for i = 1:size(suffix,2)
            plot(ts.(suffix(i)).Time,ts.(suffix(i)).Data(:,1),colors(i),'LineWidth',5); 
        end  
        title('X Position vs Time'); 
        xlabel('Time (s)'); ylabel('X Position'); 
        legend('Ground Truth','Visual+Inertial Fused','Inertial','Visual','Location','northwest'); 
    hold off; 

    figure; 
    hold on;
        for i = 1:size(suffix,2)
            plot(ts.(suffix(i)).Time,ts.(suffix(i)).Data(:,2),colors(i),'LineWidth',5); 
        end 
        title('Y Position vs Time'); 
        xlabel('Time (s)'); ylabel('Y Position'); 
        legend('Ground Truth','Visual+Inertial Fused','Inertial','Visual','Location','northwest'); 
    hold off; 


    clearvars -except rmse ts model location have_vis
    save(sprintf("/home/josh/Matlab/Datasets/%s_%s.mat",location,model))
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

function print_rmse(suffix,rmse)
    fprintf('============================\n');
    fprintf('%7s%6s %6s %6s \n','',suffix(2),suffix(3),suffix(4));
    fprintf('----------------------------\n'); 
    fprintf('%7s ','X RMSE:'); 
    for s = suffix(2:size(suffix,2)) 
        fprintf('%1.3f  ',rmse.(sprintf('x_%s',s))); 
    end
    fprintf('\n%6s ','Y RMSE:'); 
    for s = suffix(2:size(suffix,2)) 
        fprintf('%1.3f  ',rmse.(sprintf('y_%s',s))); 
    end
    fprintf('\n');
    fprintf('============================\n');
end
