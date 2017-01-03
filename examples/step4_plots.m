% %%

%%
%Adding the xls values
disp('Adding xls_data to values from rotrk_2landmarks.m ...');
TRKS_FX_centerline_R = rotrk_add_xls(xls_DATA,TRKS_FX_centerline_R);
TRKS_FX_centerline_L = rotrk_add_xls(xls_DATA,TRKS_FX_centerline_L);
TRKS_FX_trimmed_L = rotrk_add_xls(xls_DATA,TRKS_FX_trimmed_L);
TRKS_FX_trimmed_R = rotrk_add_xls(xls_DATA,TRKS_FX_trimmed_R);

TRKS_FX_DOT=rotrk_add_xls(xls_DATA,TRKS_FX_DOT);
TRKS_FX_FIMBRIA_L=rotrk_add_xls(xls_DATA,TRKS_FX_FIMBRIA_L);
TRKS_FX_FIMBRIA_R=rotrk_add_xls(xls_DATA,TRKS_FX_FIMBRIA_R);
%%





% %Plotting default tracking parameters

%%
%First let's get the *.plot parameters to be passed
for tocomment=1:1
    for ii=1:numel(TRKS_FX_DOT)
        TRKS_FX_DOT{ii}.plot_params.color='bb';
        TRKS_FX_DOT{ii}.plot_params.orientation='fornix';
    end
    
    for ii=1:numel(TRKS_FX_FIMBRIA_R)
        TRKS_FX_FIMBRIA_R{ii}.plot_params.color='gg';
        TRKS_FX_FIMBRIA_R{ii}.plot_params.orientation='fornix';
        
        TRKS_FX_trimmed_R{ii}.plot_params.color='gg';
        TRKS_FX_trimmed_R{ii}.plot_params.orientation='fornix';
        
        TRKS_FX_centerline_R{ii}.plot_params.color='gg';
        TRKS_FX_centerline_R{ii}.plot_params.orientation='fornix';
    end
    
    for ii=1:numel(TRKS_FX_FIMBRIA_L)
        TRKS_FX_FIMBRIA_L{ii}.plot_params.color='rr';
        TRKS_FX_FIMBRIA_L{ii}.plot_params.orientation='fornix';
        
        TRKS_FX_trimmed_L{ii}.plot_params.color='rr';
        TRKS_FX_trimmed_L{ii}.plot_params.orientation='fornix';
        
        TRKS_FX_centerline_L{ii}.plot_params.color='rr';
        TRKS_FX_centerline_L{ii}.plot_params.orientation='fornix';
    end
end

%%
%
%All strlimes:
rotrk_plot(TRKS_FX_DOT,'','age','AD',TRKS_FX_FIMBRIA_R,TRKS_FX_FIMBRIA_L);
rotrk_plot(TRKS_FX_DOT,'','age','NC',TRKS_FX_FIMBRIA_R,TRKS_FX_FIMBRIA_L);


%Trimmed lines:
rotrk_plot(TRKS_FX_trimmed_R,'','age','AD',TRKS_FX_centerline_L)
rotrk_plot(TRKS_FX_trimmed_R,'','age','NC',TRKS_FX_centerline_L)

%Centerlines:
rotrk_plot(TRKS_FX_centerline_R,'','age','AD',TRKS_FX_centerline_L)
rotrk_plot(TRKS_FX_centelrine_R,'','age','NC',TRKS_FX_centerline_L)
