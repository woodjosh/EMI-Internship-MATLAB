models = ["waffleADX","waffle3DM","waffleEG120","waffleEG1300"]; 
location = "house"; 

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

x_ts_vio = [rmse.x_ts_vio];
y_ts_vio = [rmse.y_ts_vio];
x_ts_vis = [rmse.x_ts_vis];
y_ts_vis = [rmse.y_ts_vis];
x_ts_imu = [rmse.x_ts_imu];
y_ts_imu = [rmse.y_ts_imu];


close all; 

figure('Position',[500 600 1200 400]); 
tiledlayout(1,2) 

nexttile
    hold on; 
    scatter(x_axis,x_vio,'m'); 
    scatter(x_axis,x_imu,'b'); 
    scatter(x_axis,x_vis,'r');  
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
    scatter(x_axis,y_vis,'r'); 
    set(gca,'xtick',x_axis);
    set(gca,'xticklabel',x_labels,'fontsize',8)
    axis([1 4 0 5]); 
    legend('Visual+Inertial Fused','Inertial','Visual','Location','northwest'); 
    ylabel('Y RMSE'); 
    hold off; 
    
figure('Position',[0 50 2400 400]); 
tiledlayout(1,4) 

nexttile
    hold on; 
    plot(x_ts_vio(1),'m'); 
    plot(x_ts_imu(1),'b'); 
    plot(x_ts_vis(1),'r'); 
    axis([0 45 0 5]); 
    legend('Visual+Inertial Fused','Inertial','Visual','Location','northwest'); 
    ylabel('X RMSE'); xlabel('Time (s)'); 
    title(models(1)); 
    hold off; 
    
nexttile 
    hold on; 
    plot(x_ts_vio(2),'m'); 
    plot(x_ts_imu(2),'b'); 
    plot(x_ts_vis(2),'r'); 
    axis([0 45 0 5]); 
    legend('Visual+Inertial Fused','Inertial','Visual','Location','northwest'); 
    ylabel('X RMSE'); xlabel('Time (s)'); 
    title(models(2)); 
    hold off; 

nexttile    
    hold on; 
    plot(x_ts_vio(3),'m'); 
    plot(x_ts_imu(3),'b'); 
    plot(x_ts_vis(3),'r'); 
    axis([0 45 0 5]); 
    legend('Visual+Inertial Fused','Inertial','Visual','Location','northwest'); 
    ylabel('X RMSE'); xlabel('Time (s)'); 
    title(models(3)); 
    hold off; 
    
nexttile    
    hold on; 
    plot(x_ts_vio(4),'m'); 
    plot(x_ts_imu(4),'b'); 
    plot(x_ts_vis(4),'r'); 
    axis([0 45 0 5]); 
    legend('Visual+Inertial Fused','Inertial','Visual','Location','northwest'); 
    ylabel('X RMSE'); xlabel('Time (s)'); 
    title(models(4)); 
    hold off; 
figure('Position',[0 50 2400 400]); 
tiledlayout(1,4) 

 nexttile
    hold on; 
    plot(y_ts_vio(1),'m'); 
    plot(y_ts_imu(1),'b'); 
    plot(y_ts_vis(1),'r'); 
    axis([0 45 0 5]); 
    legend('Visual+Inertial Fused','Inertial','Visual','Location','northwest'); 
    ylabel('Y RMSE'); xlabel('Time (s)'); 
    title(models(1)); 
    hold off; 
    
nexttile 
    hold on; 
    plot(y_ts_vio(2),'m'); 
    plot(y_ts_imu(2),'b'); 
    plot(y_ts_vis(2),'r'); 
    axis([0 45 0 5]); 
    legend('Visual+Inertial Fused','Inertial','Visual','Location','northwest'); 
    ylabel('Y RMSE'); xlabel('Time (s)'); 
    title(models(2)); 
    hold off; 

nexttile    
    hold on; 
    plot(y_ts_vio(3),'m'); 
    plot(y_ts_imu(3),'b'); 
    plot(y_ts_vis(3),'r'); 
    axis([0 45 0 5]); 
    legend('Visual+Inertial Fused','Inertial','Visual','Location','northwest'); 
    ylabel('Y RMSE'); xlabel('Time (s)'); 
    title(models(3)); 
    hold off; 
    
nexttile    
    hold on; 
    plot(y_ts_vio(4),'m'); 
    plot(y_ts_imu(4),'b'); 
    plot(y_ts_vis(4),'r'); 
    axis([0 45 0 5]); 
    legend('Visual+Inertial Fused','Inertial','Visual','Location','northwest'); 
    ylabel('Y RMSE'); xlabel('Time (s)'); 
    title(models(4)); 
    hold off; 
    