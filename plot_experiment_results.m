%% Load Dataset
load("/home/josh/Matlab/Datasets/07.14.mat"); 
close all; 

plot_all_paths(experiments); 

plot_all_RMSE(experiments); 


function plot_all_RMSE(experiments)
    figure; 
    tiledlayout(3,2); 
    
    for r = ["imu","vis","vio"]
        for c = ["x","y"]
            nexttile
            boxplot_RMSE(experiments,c,r); 
            ylim([-1 6]); 
        end
    end
end

% experiments = struct exported from process experiments 
% axis        = axis we are interested in (x or y)
% source      = source (imu, visual, visual-inertial)
function boxplot_RMSE(experiments,axis,source)
    models = unique([experiments.model]);
    % rearrange to match the order you want to see the models in
    models = models([2 1 3 4]); 
    i =1;
    x = zeros(5,4); 
    for m = models
        subset = [experiments(find([experiments.model] == string(m))).rmse]; 
        x(:,i)=([subset.(sprintf("%s_%s",axis,source))]); 
        i= i+1; 
    end

    boxplot(x);
    ylabel(sprintf("%s RMSE (m)",axis)); 
    set(gca,'XTickLabel',models); 
    title(sprintf("%s navigation",source)); 
end
    
function plot_all_paths(experiments)
    figure; 
    tiledlayout(4,5); 

    for n = 1:20
    nexttile    
        plot(experiments(n).ts.gnd.Data(:,1),experiments(n).ts.gnd.Data(:,2),'g')
        hold on 
        plot(experiments(n).ts.imu.Data(:,1),experiments(n).ts.imu.Data(:,2),'b')
        hold on 
        plot(experiments(n).ts.vis.Data(:,1),experiments(n).ts.vis.Data(:,2),'r')
        hold on 
        plot(experiments(n).ts.vio.Data(:,1),experiments(n).ts.vio.Data(:,2),'m')
        title(experiments(n).model); 
        axis([-2 6 -5 5]);
    end
end
