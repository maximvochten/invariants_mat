function plot_FS_frames_contour_tab(invariant_frame, object_invariant, pose, trial, viewpoint, referencepoint, datatype, parameterization, application, tab1, wrenchtype, path_to_data_folder)

axes(tab1);
set(groot,'defaultAxesTickLabelInterpreter','latex');
view(38,15)

% number identifying the location and orientation of the force sensor {lc} and motion tracker {tr} on the tool
sensor_id = configurations();

if strcmp(application,'contour')
    R_visual = rot_x(-135); % only for better visualization
elseif strcmp(application,'peg')
    R_visual = rot_x(90);
end

nb_rigid_bodies = 3;

% Colors
tracker_color = [30 30 30]/255; sensor_color = [0 0 205]/255; part1_color = [60 60 60]/255;
part2_color = [80 80 80]/255; part3_color = [100 100 100]/255; part4_color = [120 120 120]/255;
bearings_color = [0 0 0]/255; contour_color = [200 200 200]/255;

% FS axis
view_fig = [-50,10];
N = size(invariant_frame,3);

if strcmp(viewpoint,'world')
    
    % Fetch data to approximate the pose of the contour and tool
    if ~strcmp(trial,'ref') % not the reference case
        [~,~,position_tcp,rotation_tcp,~,~,~,~,~,~,~,~,~,~] = contour_preprocess_data(N,viewpoint,parameterization,'tool_point',trial,trial,application,wrenchtype,path_to_data_folder);
        [rotation_tcp,position_tcp] = reverse_artificial_variations(rotation_tcp,position_tcp,trial);
    else
        [~,~,~,~,~,~,~,~,~,position_tcp,rotation_tcp,~,~,~] = contour_preprocess_data(N,viewpoint,parameterization,'tool_point',1,1,application,wrenchtype,path_to_data_folder);
    end
    
    % Choose some samples to plot by stl files
    k_1 = 1;
    for j = round(linspace(1,N,nb_rigid_bodies))
        rotation_tcp_k(:,:,k_1) = rotation_tcp(:,:,j);
        position_tcp_k(k_1,:)   = position_tcp(j,:);
        k_1                     = k_1+1;
    end
    
    if strcmp(application,'contour')
        % Estimate the pose of the contour
        load('data/stl/contour/contour_edge');
        contour_edge = contour_edge/1000; % convert mm to m
        average_contour_edge = mean(contour_edge,1);
        delta_contour_edge = contour_edge - average_contour_edge;
        average_position_tcp = mean(position_tcp,1);
        delta_position_tcp = position_tcp - average_position_tcp;
        % Calculate the spatial alignment
        S = delta_contour_edge'*delta_position_tcp;
        [U,~,V] = svd(S);
        ROTATION = V*U';
        if det(ROTATION) < 0
            ROTATION = V*[1,0,0;0,1,0;0,0,-1]*U';
        end
        TRANSLATION = (average_position_tcp' - ROTATION*average_contour_edge')';
        
        % Plot the contour
        plot_stl('data/stl/contour/contour.STL',ROTATION,TRANSLATION,0.001,contour_color,0.5);
        load('data/stl/contour/contour_edge_o')
        load('data/stl/contour/contour_edge_y')
        load('data/stl/contour/contour_edge_z')
        for j = 1 : N
            p_o_orig(j,:) = ROTATION*p_o_orig(j,:)'+TRANSLATION';
            p_y_orig(j,:) = ROTATION*p_y_orig(j,:)'+TRANSLATION';
            p_z_orig(j,:) = ROTATION*p_z_orig(j,:)'+TRANSLATION';
        end
        plot3(p_o_orig(:,1),p_o_orig(:,2),p_o_orig(:,3),'k','linewidth',1.5)
        plot3(p_y_orig(:,1),p_y_orig(:,2),p_y_orig(:,3),'k','linewidth',1.5)
        plot3(p_z_orig(:,1),p_z_orig(:,2),p_z_orig(:,3),'k','linewidth',1.5)
        plot3([p_o_orig(1,1),p_y_orig(1,1)],[p_o_orig(1,2),p_y_orig(1,2)],[p_o_orig(1,3),p_y_orig(1,3)],'k','linewidth',1.5)
        plot3([p_o_orig(1,1),p_z_orig(1,1)],[p_o_orig(1,2),p_z_orig(1,2)],[p_o_orig(1,3),p_z_orig(1,3)],'k','linewidth',1.5)
        plot3([p_o_orig(end,1),p_y_orig(end,1)],[p_o_orig(end,2),p_y_orig(end,2)],[p_o_orig(end,3),p_y_orig(end,3)],'k','linewidth',1.5)
        plot3([p_o_orig(end,1),p_z_orig(end,1)],[p_o_orig(end,2),p_z_orig(end,2)],[p_o_orig(end,3),p_z_orig(end,3)],'k','linewidth',1.5)
        plot3([p_y_orig(1,1),p_z_orig(1,1)],[p_y_orig(1,2),p_z_orig(1,2)],[p_y_orig(1,3),p_z_orig(1,3)],'k','linewidth',1.5)
        plot3([p_y_orig(end,1),p_z_orig(end,1)],[p_y_orig(end,2),p_z_orig(end,2)],[p_y_orig(end,3),p_z_orig(end,3)],'k','linewidth',1.5)
        transf_contour_edge = (ROTATION*contour_edge'+TRANSLATION')'; % ToDo: do we remove it?
        
        %     figure()
        %     plot3(transf_contour_edge(:,1),transf_contour_edge(:,2),transf_contour_edge(:,3),'r')
        %     hold on
        %     plot3(position_tcp(:,1),position_tcp(:,2),position_tcp(:,3),'b')
        %     legend('CAD','trial')
        %     axis equal
        
        % Plot stl files in correct position and orientation
        if ~strcmp(trial,'ref') % not the reference case
            for j = 1 : k_1-1
                plot_stl(['data/stl/contour/configuration-',sensor_id(trial),'/tool-',sensor_id(trial),'-bearings.STL'],rotation_tcp_k(:,:,j),position_tcp_k(j,:),0.001,bearings_color,1);
                plot_stl(['data/stl/contour/configuration-',sensor_id(trial),'/tool-',sensor_id(trial),'-print4.STL'],rotation_tcp_k(:,:,j),position_tcp_k(j,:),0.001,part4_color,1);
                plot_stl(['data/stl/contour/configuration-',sensor_id(trial),'/tool-',sensor_id(trial),'-print1.STL'],rotation_tcp_k(:,:,j),position_tcp_k(j,:),0.001,part1_color,1);
                plot_stl(['data/stl/contour/configuration-',sensor_id(trial),'/tool-',sensor_id(trial),'-print2.STL'],rotation_tcp_k(:,:,j),position_tcp_k(j,:),0.001,part2_color,1);
                plot_stl(['data/stl/contour/configuration-',sensor_id(trial),'/tool-',sensor_id(trial),'-print3.STL'],rotation_tcp_k(:,:,j),position_tcp_k(j,:),0.001,part3_color,1);
                plot_stl(['data/stl/contour/configuration-',sensor_id(trial),'/tool-',sensor_id(trial),'-sensor.STL'],rotation_tcp_k(:,:,j),position_tcp_k(j,:),0.001,sensor_color,1);
                plot_stl(['data/stl/contour/configuration-',sensor_id(trial),'/tool-',sensor_id(trial),'-tracker.STL'],rotation_tcp_k(:,:,j),position_tcp_k(j,:),0.001,tracker_color,1);
            end
        end
    elseif strcmp(application,'peg')
        ROTATION = position_tcp(end,:);
        TRANSLATION = eye(3);
        plot_stl(['data/stl/peg/hole.STL'],TRANSLATION,ROTATION,0.001,part2_color,0.2);
        for j = 1 : k_1-1
            plot_stl(['data/stl/peg/coupling.STL'],rotation_tcp_k(:,:,j),position_tcp_k(j,:),0.001,bearings_color,0.6);
            plot_stl(['data/stl/peg/peg.STL'],rotation_tcp_k(:,:,j),position_tcp_k(j,:),0.001,part4_color,0.6);
            plot_stl(['data/stl/peg/handle.STL'],rotation_tcp_k(:,:,j),position_tcp_k(j,:),0.001,part2_color,0.6);
            plot_stl(['data/stl/peg/tracker.STL'],rotation_tcp_k(:,:,j),position_tcp_k(j,:),0.001,tracker_color,0.6);
            plot_stl(['data/stl/peg/sensor.STL'],rotation_tcp_k(:,:,j),position_tcp_k(j,:),0.001,sensor_color,0.6);
       end
    end
    
    darkred = [0.6350 0.0780 0.1840];
    red = [0.8500 0.3250 0.0980];
    green = [0.4660 0.6740 0.1880];
    blue = [0 0.4470 0.7410];
    grey = [0.8  0.8 0.8];
    
    if (strcmp(referencepoint,'tracker') || strcmp(referencepoint,'tool_point'))
        if ~strcmp(trial,'ref')
            [invariant_frame,~] = reverse_artificial_variations(invariant_frame,zeros(N,3),trial);
            [~,pos] = reverse_artificial_variations(pose(1:3,1:3,:),squeeze(pose(1:3,4,:))',trial);
        else
            pos = squeeze(pose(1:3,4,:))';
        end
    elseif strcmp(referencepoint,'force_sensor')
        if ~strcmp(trial,'ref')
            [invariant_frame,~] = reverse_artificial_variations(invariant_frame,zeros(N,3),trial);
            [~,pos] = reverse_artificial_variations(pose(1:3,1:3,:),squeeze(pose(1:3,4,:))',trial);
        else
            pos = squeeze(pose(1:3,4,:))';
        end
    end
    
    e_x = squeeze(invariant_frame(1:3,1,:))';
    e_y = squeeze(invariant_frame(1:3,2,:))';
    e_z = squeeze(invariant_frame(1:3,3,:))';
    
    arrow_width_FS = 0.0015;
    for i=1:5:N
        % Scale the FS-frames
        if strcmp(datatype,'moment')
            arrow_length_FS = 0.02+0.1*object_invariant(i)/5;
            arrow_width_FS = 0.001+0.0015*object_invariant(i)/5;
        else
            arrow_length_FS = 0.1;
        end
        mArrow3(pos(i,:),pos(i,:)+arrow_length_FS*e_x(i,:),'color',darkred,'stemWidth',arrow_width_FS);
        mArrow3(pos(i,:),pos(i,:)+arrow_length_FS*e_y(i,:)*0.5,'color',green,'stemWidth',arrow_width_FS*0.5);
        mArrow3(pos(i,:),pos(i,:)+arrow_length_FS*e_z(i,:)*0.5,'color',blue,'stemWidth',arrow_width_FS*0.5);
    end
    
    axis_font_size = 12;
    label_font_size = 18;
    set(gcf,'units','normalized','outerposition',[0 0.04 0.7 0.74]);
    set(gca,'FontSize',axis_font_size)
    hold on; axis equal; view(view_fig); grid on; box on;
    xlabel('$x\ [\mathrm{m}]$','Interpreter','LaTex','FontSize',label_font_size)
    ylabel('$y\ [\mathrm{m}]$','Interpreter','LaTex','FontSize',label_font_size)
    zlabel('$z\ [\mathrm{m}]$','Interpreter','LaTex','FontSize',label_font_size)
end

%% FS of force in {tool}
if strcmp(viewpoint,'body')
    
    if strcmp(application,'contour')
        % Plot stl files in correct position and orientation
        if strcmp(trial,'ref') % the reference case
            plot_stl(['data/stl/contour/configuration-',sensor_id(1),'/tool-',sensor_id(1),'-bearings.STL'],R_visual,zeros(1,3),0.001,bearings_color,0.4);
            plot_stl(['data/stl/contour/configuration-',sensor_id(1),'/tool-',sensor_id(1),'-print4.STL'],R_visual,zeros(1,3),0.001,part4_color,0.4);
        elseif ~strcmp(trial,'ref') % not the reference case
            plot_stl(['data/stl/contour/configuration-',sensor_id(trial),'/tool-',sensor_id(trial),'-bearings.STL'],R_visual,zeros(1,3),0.001,bearings_color,0.4);
            plot_stl(['data/stl/contour/configuration-',sensor_id(trial),'/tool-',sensor_id(trial),'-print4.STL'],R_visual,zeros(1,3),0.001,part4_color,0.4);
            plot_stl(['data/stl/contour/configuration-',sensor_id(trial),'/tool-',sensor_id(trial),'-print1.STL'],R_visual,zeros(1,3),0.001,part1_color,0.4);
            plot_stl(['data/stl/contour/configuration-',sensor_id(trial),'/tool-',sensor_id(trial),'-print2.STL'],R_visual,zeros(1,3),0.001,part2_color,0.4);
            plot_stl(['data/stl/contour/configuration-',sensor_id(trial),'/tool-',sensor_id(trial),'-print3.STL'],R_visual,zeros(1,3),0.001,part3_color,0.4);
            plot_stl(['data/stl/contour/configuration-',sensor_id(trial),'/tool-',sensor_id(trial),'-sensor.STL'],R_visual,zeros(1,3),0.001,sensor_color,0.4);
            plot_stl(['data/stl/contour/configuration-',sensor_id(trial),'/tool-',sensor_id(trial),'-tracker.STL'],R_visual,zeros(1,3),0.001,tracker_color,0.4);
        end
    elseif strcmp(application,'peg')
        plot_stl('data/stl/peg/coupling.STL',R_visual,zeros(1,3),0.001,bearings_color,0.7);
        plot_stl('data/stl/peg/peg.STL',R_visual,zeros(1,3),0.001,part4_color,0.7);
        plot_stl(['data/stl/peg/handle.STL'],R_visual,zeros(1,3),0.001,part1_color,0.7);
        plot_stl(['data/stl/peg/tracker.STL'],R_visual,zeros(1,3),0.001,tracker_color,0.7);
        plot_stl(['data/stl/peg/sensor.STL'],R_visual,zeros(1,3),0.001,sensor_color,0.7);
    end
    
    darkred = [0.6350 0.0780 0.1840];
    red = [0.8500 0.3250 0.0980];
    green = [0.4660 0.6740 0.1880];
    blue = [0 0.4470 0.7410];
    grey = [0.8  0.8 0.8];
    
    N = 101;
    if strcmp(referencepoint,'tool_point')
        pos = zeros(N,3);
    elseif strcmp(referencepoint,'tracker')
        if strcmp(trial,'ref')
            T_tr_tcp = eye(4);
        else
            if strcmp(application,'contour')
                [T_tcp_tr,~,~,~] = configuration_properties_contour(sensor_id(trial));
            elseif strcmp(application,'peg')
                [T_tcp_tr,~,~,~] = configuration_properties_peg();
            end
            T_tr_tcp = inverse_pose(T_tcp_tr);
            for k = 1:N
                invariant_frame(:,:,k) = T_tr_tcp(1:3,1:3)*invariant_frame(:,:,k);
            end
        end
        pos = zeros(N,3);
        for k = 1:N
            pos(k,:) = T_tr_tcp(1:3,4)'*R_visual';
        end
    elseif strcmp(referencepoint,'middle_contour')
        pos = squeeze(pose(1:3,4,:))'*R_visual';
    end
    
    e_x = squeeze(invariant_frame(1:3,1,:))'*R_visual';
    e_y = squeeze(invariant_frame(1:3,2,:))'*R_visual';
    e_z = squeeze(invariant_frame(1:3,3,:))'*R_visual';
    
    arrow_width_FS = 0.001;
    for i=1:5:N
        % Scale the FS-frames
        if strcmp(datatype,'moment')
            arrow_length_FS = 0.02+0.1*object_invariant(i)/5;
        else
            arrow_length_FS = 0.1;
        end
        mArrow3(pos(i,:),pos(i,:)+arrow_length_FS*e_x(i,:),'color',darkred,'stemWidth',arrow_width_FS);
        mArrow3(pos(i,:),pos(i,:)+arrow_length_FS*e_y(i,:)*0.5,'color',green,'stemWidth',arrow_width_FS*0.5);
        mArrow3(pos(i,:),pos(i,:)+arrow_length_FS*e_z(i,:)*0.5,'color',blue,'stemWidth',arrow_width_FS*0.5);
    end
    
    axis_font_size = 12;
    label_font_size = 18;
    set(gcf,'units','normalized','outerposition',[0 0.04 0.7 0.74]);
    set(gca,'FontSize',axis_font_size)
    hold on; axis equal; view(view_fig); grid on; box on;
    xlabel('$x\ [\mathrm{m}]$','Interpreter','LaTex','FontSize',label_font_size)
    ylabel('$y\ [\mathrm{m}]$','Interpreter','LaTex','FontSize',label_font_size)
    zlabel('$z\ [\mathrm{m}]$','Interpreter','LaTex','FontSize',label_font_size)
end

