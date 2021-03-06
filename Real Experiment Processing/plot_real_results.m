%% Load Dataset
load("/home/josh/TurtlebotTrials/04-Aug-2020/1m_circle.mat"); 
close all; 
% get unique models from experiment dataset
trials = unique([experiments.trial]);

% plot 
plot_all_paths(experiments,trials); 
% 
plot_all_RMSE_time(experiments,trials); 
% 
%plot_vs_time(experiments,1); 
%% Helper Functions
function plot_all_RMSE_time(experiments,trials) 
    figure; 
    tiledlayout(size(trials,2),2);
    for r = trials 
        for c = ["x","y"]
            nexttile
            plot_RMSE_time(experiments,r,c); 
        end
    end

end

function plot_vs_time(experiments,trial)
    figure; 
    gnd = experiments(trial).ts.gnd; 
    imu_enc = experiments(trial).ts.imu_enc; 
    vis = experiments(trial).ts.vis; 
    vio = experiments(trial).ts.vio; 
    axis([min(gnd.Data(:,1))-0.3, max(gnd.Data(:,1))+0.3, min(gnd.Data(:,2))-0.3, max(gnd.Data(:,2))+0.3]);
    for time = experiments(trial).ts.gnd.Time'
       hold on; 
       plot(gnd.Data(gnd.Time < time,1),gnd.Data(gnd.Time < time,2),'g'); 
       plot(imu_enc.Data(imu_enc.Time < time,1),imu_enc.Data(imu_enc.Time < time,2),'b');
       plot(vio.Data(vio.Time < time,1),vio.Data(vio.Time < time,2),'m');
       plot(vis.Data(vis.Time < time,1),vis.Data(vis.Time < time,2),'r');
       pause(0.001); 
  end
end

function plot_RMSE_time(experiments,trial,dir)
    linewidth = 1; 
    subset = [experiments(find([experiments.trial] == trial)).rmse]; 
    imu_enc = [subset.(sprintf("%s_ts_imu_enc",dir))];
    vis = [subset.(sprintf("%s_ts_vis",dir))];
    vio = [subset.(sprintf("%s_ts_vio",dir))];
    imu_enc.Name = sprintf("Trial %d",trial); 
    plot(imu_enc,'b','LineWidth',linewidth);
    hold on; 
    plot(vis,'r','LineWidth',linewidth); 
    hold on; 
    plot(vio,'m','LineWidth',linewidth); 
    ylabel(sprintf("%s RMSE", dir)); 
end

% experiments = struct exported from process experiments 
function plot_all_paths(experiments,trials)
    figure; 
    numTrials = size(trials,2);
    tiledlayout(numTrials,1); 
    linewidth = 1; 
    % rearrange to match the order you want to see the models in
    for n = 1:numTrials
    nexttile    
        plot(experiments(n).ts.gnd.Data(:,1),experiments(n).ts.gnd.Data(:,2),'g','LineWidth',linewidth)
        hold on 
        plot(experiments(n).ts.imu_enc.Data(:,1),experiments(n).ts.imu_enc.Data(:,2),'b','LineWidth',linewidth)
        hold on 
        plot(experiments(n).ts.vis.Data(:,1),experiments(n).ts.vis.Data(:,2),'r','LineWidth',linewidth)
        hold on 
        plot(experiments(n).ts.vio.Data(:,1),experiments(n).ts.vio.Data(:,2),'m','LineWidth',linewidth)
        title(sprintf("Trial %d",experiments(n).trial)); 
        axis([-0.2 1.2 -1 1]);
    end 
end