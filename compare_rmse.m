models = ["waffleADX","waffle3DM","waffleEG120","waffleEG1300"]; 
location = "emptyroom"; 

gyro_data(1) = load(sprintf("/home/josh/Matlab/Datasets/%s_%s.mat",location,models(1))); 
gyro_data(2) = load(sprintf("/home/josh/Matlab/Datasets/%s_%s.mat",location,models(2))); 
gyro_data(3) = load(sprintf("/home/josh/Matlab/Datasets/%s_%s.mat",location,models(3))); 
gyro_data(4) = load(sprintf("/home/josh/Matlab/Datasets/%s_%s.mat",location,models(4)));  

x_labels = [gyro_data.model];
x_axis = 1:size(x_labels,2); 
rmse = [gyro_data.rmse];
x_vio = [rmse.x_vio]; 
y_vio = [rmse.y_vio]; 
x_vis = [rmse.x_vis]; 
y_vis = [rmse.y_vis];
x_imu = [rmse.x_imu]; 
y_imu = [rmse.y_imu];

close all; 

figure('Position',[500 500 1200 400]); 
tiledlayout(1,2) % Requires R2019b or later
title('House Environment'); 

nexttile
    hold on; 
    scatter(x_axis,x_vio,'m'); 
    scatter(x_axis,x_imu,'b'); 
    %scatter(x_axis,x_vis,'r');  
    set(gca,'xtick',x_axis);
    set(gca,'xticklabel',x_labels,'fontsize',8)
    axis([1 4 0 3]); 
    legend('Visual+Inertial Fused','Inertial','Visual','Location','northwest'); 
    ylabel('X RMSE'); 
    hold off; 
    
nexttile 
    hold on; 
    scatter(x_axis,y_vio,'m'); 
    scatter(x_axis,y_imu,'b'); 
    %scatter(x_axis,y_vis,'r'); 
    set(gca,'xtick',x_axis);
    set(gca,'xticklabel',x_labels,'fontsize',8)
    axis([1 4 0 3]); 
    legend('Visual+Inertial Fused','Inertial','Visual','Location','northwest'); 
    ylabel('Y RMSE'); 
    hold off; 

    