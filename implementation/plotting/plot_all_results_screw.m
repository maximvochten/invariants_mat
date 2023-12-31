function plot_all_results_screw(datatype,bool_reference_invariants,bool_visualize_trials,bool_visualize_reconstruction_errors,bool_visualize_summary,bool_paper_plots,...
    progress_ref,invars_data_ref,T_isa_data_ref,data_ref,viewpoint,referencepoint,parameterization,application,...
    recons_data_ref,nb_trials,progress,invars_data,T_isa_data,data,trial_0,recons_data,pose,pose_ref,trajectory_type,wrenchtype,path_to_data_folder)

%%
if bool_reference_invariants
    % Plot screw invariants of reference motion
    fig_data_inv = figure('Name',['screw invariants of ',datatype],'Color',[1 1 1],'NumberTitle','off');
    tabgroup_data_inv = uitabgroup; thistab = uitab(tabgroup_data_inv,'Title','reference');
    plot_screw_invariants(progress_ref,invars_data_ref,datatype,parameterization,thistab);
    % Plot ISA frames of reference motion
    fig_data_ISA = figure('Name',['ISA frames of ',datatype],'Color',[1 1 1],'NumberTitle','off');
    tabgroup_data_ISA = uitabgroup; thistab = uitab(tabgroup_data_ISA,'Title','reference');
    plot_ISA_frames_contour_tab(T_isa_data_ref,pose_ref,'ref',viewpoint,referencepoint,datatype,parameterization,application,thistab,wrenchtype,path_to_data_folder)
end

% Plot reference and reconstructed data
if bool_reference_invariants && bool_visualize_reconstruction_errors
    fig_data_recons = figure('Name',['measured vs. reconstructed ',datatype],'Color',[1 1 1],'NumberTitle','off');
    tabgroup_data_recons = uitabgroup; thistab = uitab(tabgroup_data_recons,'Title','reference'); axes(thistab);
    if strcmp(datatype,'pose')
        plot_trajectory_coordinates(progress_ref,[rotm2eul(data_ref(1:3,1:3,:),'zyx'),squeeze(data_ref(1:3,4,:))'],datatype,'measured vs. reconstructed pose',parameterization)
        plot_trajectory_coordinates(progress_ref,[rotm2eul(recons_data_ref(1:3,1:3,:),'zyx'),squeeze(recons_data_ref(1:3,4,:))'],datatype,'measured vs. reconstructed pose',parameterization)
    else
        plot_trajectory_coordinates(progress_ref,data_ref,datatype,'measured vs. reconstructed wrench',parameterization)
        plot_trajectory_coordinates(progress_ref,recons_data_ref,datatype,'measured vs. reconstructed wrench',parameterization)
    end
end

% Plot screw invariants of demonstrated data
if bool_visualize_trials
    for trial=1:nb_trials
        if ~bool_reference_invariants
            if trial == 1
                fig_data_inv = figure('Name',['screw invariants of ',datatype],'Color',[1 1 1],'NumberTitle','off');
                tabgroup_data_inv = uitabgroup; thistab = uitab(tabgroup_data_inv,'Title',['trial = ',num2str(trial+trial_0-1)]);
            else
                figure(fig_data_inv); thistab = uitab(tabgroup_data_inv,'Title',['trial = ',num2str(trial+trial_0-1)]);
            end
        elseif bool_reference_invariants
            figure(fig_data_inv); thistab = uitab(tabgroup_data_inv,'Title',['trial = ',num2str(trial+trial_0-1)]);
        end
        plot_screw_invariants(progress(:,trial),invars_data(:,:,trial),datatype,parameterization,thistab);
    end
end

% Plot ISA frames of demonstrated data
if bool_visualize_trials
    for trial=1:nb_trials
        if ~bool_reference_invariants
            if trial == 1
                fig_data_ISA = figure('Name',['ISA frames of ',datatype],'Color',[1 1 1],'NumberTitle','off');
                tabgroup_data_ISA = uitabgroup; thistab = uitab(tabgroup_data_ISA,'Title',['trial = ',num2str(trial+trial_0-1)]);
            else
                figure(fig_data_ISA); thistab = uitab(tabgroup_data_ISA,'Title',['trial = ',num2str(trial+trial_0-1)]);
            end
        elseif bool_reference_invariants
            figure(fig_data_ISA); thistab = uitab(tabgroup_data_ISA,'Title',['trial = ',num2str(trial+trial_0-1)]);
        end
        plot_ISA_frames_contour_tab(T_isa_data(:,:,:,trial),pose(:,:,:,trial),trial+trial_0-1,viewpoint,referencepoint,'motion',parameterization,application,thistab,wrenchtype,path_to_data_folder)
    end
end

% Plot measured and reconstructed data
if bool_visualize_reconstruction_errors
    for trial=1:nb_trials
        if ~bool_reference_invariants
            if trial == 1
                fig_data_recons = figure('Name',['measured vs. reconstructed ',datatype],'Color',[1 1 1],'NumberTitle','off');
                tabgroup_data_recons = uitabgroup; thistab = uitab(tabgroup_data_recons,'Title',['trial = ',num2str(trial+trial_0-1)]); axes(thistab);
            else
                figure(fig_data_recons); thistab = uitab(tabgroup_data_recons,'Title',['trial = ',num2str(trial+trial_0-1)]); axes(thistab);
            end
        elseif bool_reference_invariants
            figure(fig_data_recons); thistab = uitab(tabgroup_data_recons,'Title',['trial = ',num2str(trial+trial_0-1)]); axes(thistab);
        end
        if strcmp(datatype,'pose')
            plot_trajectory_coordinates(progress(:,trial),[rotm2eul(data(1:3,1:3,:,trial),'zyx'),squeeze(data(1:3,4,:,trial))'],datatype,'measured vs. reconstructed pose',parameterization)
            plot_trajectory_coordinates(progress(:,trial),[rotm2eul(recons_data(1:3,1:3,:,trial),'zyx'),squeeze(recons_data(1:3,4,:,trial))'],datatype,'measured vs. reconstructed pose',parameterization)
        else
            plot_trajectory_coordinates(progress(:,trial),data(:,:,trial),datatype,'measured vs. reconstructed wrench',parameterization)
            plot_trajectory_coordinates(progress(:,trial),recons_data(:,:,trial),datatype,'measured vs. reconstructed wrench',parameterization)
        end
    end
end

% Plot reference and demonstrated invariants
if bool_visualize_summary && strcmp(wrenchtype,'real')
    plot_screw_invariants_contour(bool_reference_invariants,progress_ref,invars_data_ref,progress,invars_data,datatype,parameterization);
    if strcmp(datatype,'wrench') && strcmp(viewpoint,'body')
        subplot(2,3,5); ylim([-0.2,0.2]); subplot(2,3,6); ylim([-0.1,0.1]);
    end
    exportgraphics(gcf,['figures/screw_invariants_',datatype,'_',viewpoint,'_',referencepoint,'.pdf'],'ContentType','vector');
elseif bool_visualize_summary && strcmp(wrenchtype,'synthetic')
    plot_screw_invariants_contour(bool_reference_invariants,progress_ref,invars_data_ref,progress,invars_data,datatype,parameterization);
    subplot(2,3,1); ylim([-1,35]); subplot(2,3,2); ylim([-5,5]); %subplot(2,3,3); ylim([-5,5])
    exportgraphics(gcf,['figures/screw_invariants_',datatype,'_',viewpoint,'_',referencepoint,'_',wrenchtype,'.pdf'],'ContentType','vector');
end

%% Special figures for the paper
if bool_paper_plots
    % Figure 10a
    if strcmp(application,'contour') && strcmp(trajectory_type,'motion') && strcmp(viewpoint,'world') && strcmp(referencepoint,'tracker') && trial_0 == 1 && nb_trials == 12
        trial = 5;
        view_fig = [175,16];
        axis_font_size = 24;
        label_font_size = 29;
        step_size = 2;
        plot_ISA_frames_contour(T_isa_data(:,:,:,trial),pose(:,:,:,trial),trial+trial_0-1,viewpoint,referencepoint,'motion (Fig. 9a)',parameterization,application,view_fig,axis_font_size,label_font_size,step_size,wrenchtype)
%         % Create ellipse
%         annotation('ellipse',...
%             [0.606927710843375 0.46458923512748 0.0692771084337349 0.240793201133146],...
%             'Color',[0 0.447058823529412 0.741176470588235],...
%             'LineWidth',3);
%         % Create ellipse
%         annotation('ellipse',...
%             [0.364457831325301 0.447592067988669 0.0692771084337349 0.240793201133146],...
%             'Color',[0 0.447058823529412 0.741176470588235],...
%             'LineWidth',3);
%         % Create arrow
%         annotation('arrow',[0.474397590361446 0.429969879518073],...
%             [0.764872521246459 0.671388101983004],...
%             'Color',[0 0.447058823529412 0.741176470588235],...
%             'LineWidth',3,...
%             'HeadStyle','plain');
%         % Create arrow
%         annotation('arrow',[0.557981927710843 0.604668674698796],...
%             [0.759206798866856 0.677053824362607],...
%             'Color',[0 0.447058823529412 0.741176470588235],...
%             'LineWidth',3,...
%             'HeadStyle','plain');
        exportgraphics(gcf,['figures/ISA_frames_',datatype,'_',viewpoint,'_',referencepoint,'_trial_',num2str(trial+trial_0-1),'.pdf'],'ContentType','vector');
    end
    
    % Figure 10d
    if strcmp(application,'contour') && strcmp(trajectory_type,'wrench') && strcmp(viewpoint,'world') && strcmp(referencepoint,'force_sensor') && trial_0 == 1 && nb_trials == 12
        trial = 5;
        view_fig = [170,22];
        axis_font_size = 34;
        label_font_size = 40;
        step_size = 3;
        plot_ISA_frames_contour(T_isa_data(:,:,:,trial),pose(:,:,:,trial),trial+trial_0-1,viewpoint,referencepoint,'wrench (Fig. 9b)',parameterization,application,view_fig,axis_font_size,label_font_size,step_size,wrenchtype)
        axis equal;
        exportgraphics(gcf,['figures/ISA_frames_',datatype,'_',viewpoint,'_',referencepoint,'_trial_',num2str(trial+trial_0-1),'.pdf'],'ContentType','vector');
    end
    
    % Figure 10b
    if strcmp(application,'contour') && strcmp(trajectory_type,'wrench') && strcmp(viewpoint,'body') && strcmp(referencepoint,'tracker') && trial_0 == 1 && nb_trials == 12
        trial = 5;
        view_fig = [-110,10];
        axis_font_size = 17;
        label_font_size = 22;
        step_size = 10;
        plot_ISA_frames_contour(T_isa_data(:,:,:,trial),pose(:,:,:,trial),trial+trial_0-1,viewpoint,referencepoint,'wrench (Fig. 9c)',parameterization,application,view_fig,axis_font_size,label_font_size,step_size,wrenchtype)
        exportgraphics(gcf,['figures/ISA_frames_',datatype,'_',viewpoint,'_',referencepoint,'_trial_',num2str(trial+trial_0-1),'.pdf'],'ContentType','vector');
    end
    
    % Figure 14a
    if strcmp(application,'peg') && strcmp(trajectory_type,'motion') && strcmp(viewpoint,'world') && strcmp(referencepoint,'tracker') && trial_0 == 1 && nb_trials == 12
%         trial = 12;
%         view_fig = [-50,10];
%         axis_font_size = 22;
%         label_font_size = 27;
%         step_size = 10;
%         plot_ISA_frames_contour(T_isa_data(:,:,:,trial),pose(:,:,:,trial),trial+trial_0-1,viewpoint,referencepoint,'motion (Fig. 9a)',parameterization,application,view_fig,axis_font_size,label_font_size,step_size,wrenchtype)
%         exportgraphics(gcf,['figures/ISA_frames_',datatype,'_',viewpoint,'_',referencepoint,'_trial_',num2str(trial+trial_0-1),'_peg.pdf'],'ContentType','vector');
         
        trial = 1;
        view_angles = [-100,20];
        plot_figure14(T_isa_data(:,:,:,trial), pose(:,:,:,trial), trial, referencepoint,view_angles)
        exportgraphics(gcf,['figures/ISA_frames_',datatype,'_',viewpoint,'_',referencepoint,'_trial_',num2str(trial),'_peg.pdf'],'ContentType','vector');

    end
    
    % Figure 14b
    if strcmp(application,'peg') && strcmp(trajectory_type,'wrench') && strcmp(viewpoint,'world') && strcmp(referencepoint,'force_sensor') && trial_0 == 1 && nb_trials == 12
%         trial = 12;
%         view_fig = [-50,10];
%         axis_font_size = 22;
%         label_font_size = 27;
%         step_size = 10;
%         plot_ISA_frames_contour(T_isa_data(:,:,:,trial),pose(:,:,:,trial),trial+trial_0-1,viewpoint,referencepoint,'motion (Fig. 9a)',parameterization,application,view_fig,axis_font_size,label_font_size,step_size,wrenchtype)
%         exportgraphics(gcf,['figures/ISA_frames_',datatype,'_',viewpoint,'_',referencepoint,'_trial_',num2str(trial+trial_0-1),'_peg.pdf'],'ContentType','vector');

        trial = 1;
        view_angles = [-100,20];
        plot_figure14(T_isa_data(:,:,:,trial), pose(:,:,:,trial), trial, referencepoint,view_angles)
        exportgraphics(gcf,['figures/ISA_frames_',datatype,'_',viewpoint,'_',referencepoint,'_trial_',num2str(trial),'_peg.pdf'],'ContentType','vector');

        trial = 12;
        view_angles = [166,20];
        plot_figure14(T_isa_data(:,:,:,trial), pose(:,:,:,trial), trial, referencepoint,view_angles)
        exportgraphics(gcf,['figures/ISA_frames_',datatype,'_',viewpoint,'_',referencepoint,'_trial_',num2str(trial),'_peg.pdf'],'ContentType','vector');

        
    end
    
end















