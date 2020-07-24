%% Load Dataset
load("/home/josh/Matlab/Datasets/07.14.mat"); 
close all; 
% get unique models from experiment dataset
models = unique([experiments.model]);
% rearrange to match the order you want to see the models in
models = models([2 1 3 4]); 

% plot 
plot_all_paths(experiments,models); 

plot_all_RMSE(experiments,models); 

plot_all_RMSE_time(experiments,models); 



%% Helper Functions
function plot_all_RMSE_time(experiments,models) 
    figure; 
    tiledlayout(size(models,2),2);
    for r = models 
        for c = ["x","y"]
            nexttile
            plot_RMSE_time_mean(experiments,r,c); 
        end
    end

end

function plot_RMSE_time(experiments,model,dir)
    subset = [experiments(find([experiments.model] == string(model))).rmse]; 
    imu = [subset.(sprintf("%s_ts_imu",dir))];
    vis = [subset.(sprintf("%s_ts_vis",dir))];
    vio = [subset.(sprintf("%s_ts_vio",dir))];
    for i = 1:size(imu,2); 
       plot(imu(i),'b');
       hold on; 
       plot(vis(i),'r'); 
       hold on; 
       plot(vio(i),'m'); 
    end
    title(model); 
    ylabel(sprintf("%s RMSE", dir)); 
end

function plot_RMSE_time_mean(experiments,model,dir)
    subset = [experiments(find([experiments.model] == string(model))).rmse]; 
    imu = [subset.(sprintf("%s_ts_imu",dir))];
    vis = [subset.(sprintf("%s_ts_vis",dir))];
    vio = [subset.(sprintf("%s_ts_vio",dir))];

    plot(avg_ts(imu),'b','LineWidth',3);
    hold on; 
    plot(avg_ts(vis),'r','LineWidth',3); 
    hold on; 
    plot(avg_ts(vio),'m','LineWidth',3); 
    
    axis([0 60 0 5]);
    title(model); 
    ylabel(sprintf("%s RMSE", dir)); 
end

function avged = avg_ts(mult_ts)
    %find shortest one
    min = intmax; 
    for ts = mult_ts 
       if size(ts.Data,1) < min 
           min = size(ts.Data,1); 
       end
    end

    total = timeseries(mult_ts(1).Data(1:min),mult_ts(1).Time(1:min));
    
    for ts = mult_ts(2:end)
        total.Data = total.Data + ts.Data(1:min);
    end
    
    avged = total./ size(mult_ts,2);     
end

% experiments = struct exported from process experiments 
function plot_all_RMSE(experiments,models)
    figure; 
    tiledlayout(3,2); 
    
    for r = ["imu","vis","vio"]
        for c = ["x","y"]
            nexttile
            boxplot_RMSE(experiments,models,c,r); 
            ylim([-1 6]); 
        end
    end
end

% experiments = struct exported from process experiments 
% dir         = dir we are interested in (x or y)
% source      = source (imu, visual, visual-inertial)
function boxplot_RMSE(experiments,models,dir,source)
    i =1;
    x = zeros(size(experiments,2)/size(models,2),size(models,2)); 
    for m = models
        subset = [experiments(find([experiments.model] == string(m))).rmse]; 
        x(:,i)=([subset.(sprintf("%s_%s",dir,source))]); 
        i= i+1; 
    end

    boxplot(x);
    ylabel(sprintf("%s RMSE (m)",dir)); 
    set(gca,'XTickLabel',models); 
    title(sprintf("%s navigation",source)); 
end

% experiments = struct exported from process experiments 
function plot_all_paths(experiments,models)
    figure; 
    numModels = size(models,2);
    tiledlayout(numModels,size(experiments,2)/numModels); 
    % rearrange to match the order you want to see the models in
    order = [11:15,16:20,6:10,1:5]; 
    for n = order
    nexttile    
        plot(experiments(n).ts.gnd.Data(:,1),experiments(n).ts.gnd.Data(:,2),'g','LineWidth',3)
        hold on 
        plot(experiments(n).ts.imu.Data(:,1),experiments(n).ts.imu.Data(:,2),'b','LineWidth',3)
        hold on 
        plot(experiments(n).ts.vis.Data(:,1),experiments(n).ts.vis.Data(:,2),'r','LineWidth',3)
        hold on 
        plot(experiments(n).ts.vio.Data(:,1),experiments(n).ts.vio.Data(:,2),'m','LineWidth',3)
        title(experiments(n).model); 
        axis([-2 6 -5 5]);
    end 
end
