%%
%INITIALIZE DIFFMETRICS TO BE PASSED
DIFFMETRICS=[ GFA ;NQA0; NQA1; NQA2; QA0; QA1; QA2; ISO; RDI1L; NMD; NRD; FA; RD; MD; AxD];


%%
%FLIP ALL TARGETS SO COORDINATES START AT THE ROI
%AND ADDING SPECIFIC SCALARS
%TRKS_FX_DOT:
disp('Flipping and adding scalars to closest ROI for TRKS_FX_DOT...')
for ii=1:numel(TRKS_FX_DOT)
    %disp(['In ii: ' num2str(ii) ] );
    for jj=1:numel(ROI_FX_DOT)
        if strcmp(TRKS_FX_DOT{ii}.id,ROI_FX_DOT{jj}.id)
            TRKS_FX_DOT{ii}=rotrk_flip(TRKS_FX_DOT{ii}, [ rotrk_ROImean(ROI_FX_DOT{jj})] );
            %!!
            %COMMENTED BELOW AS NUMBER OF *.trk AND *.nii coordinates MAY be replciated!!
            
%             %We only check one DIFFMETRICS as previous ids have been already checked (in step 1_init_variables.m)
%             for kk=1:size(DIFFMETRICS,2) 
%                 if strcmp(TRKS_FX_DOT{ii}.id,DIFFMETRICS{1,kk}.id)
%                     TRKS_FX_DOT{ii} = rotrk_add_sc(TRKS_FX_DOT{ii}, DIFFMETRICS(:,kk));
%                 end
%             end
%           !!
        end
    end
   
end

%TRKS_FX_FIMBRIA_L:
disp('Flipping and adding scalars to closest ROI for TRKS_FX_FIMBRIA_L...')
for ii=1:numel(TRKS_FX_FIMBRIA_L)
    %disp(['In ii: ' num2str(ii) ] );
    for jj=1:numel(ROI_FX_FIMBRIA_L)
        if strcmp(TRKS_FX_FIMBRIA_L{ii}.id,ROI_FX_FIMBRIA_L{jj}.id)
            TRKS_FX_FIMBRIA_L{ii}=rotrk_flip(TRKS_FX_FIMBRIA_L{ii}, [ rotrk_ROImean(ROI_FX_FIMBRIA_L{jj})] );
%             %Now adding scalars...
%             for kk=1:size(DIFFMETRICS,2) %We only check one DIFFMETRICS as previous ids have been already checked (in step 1_init_variables.m)
%                 if strcmp(TRKS_FX_FIMBRIA_L{ii}.id,DIFFMETRICS{1,kk}.id)
%                     TRKS_FX_FIMBRIA_L{ii} = rotrk_add_sc(TRKS_FX_FIMBRIA_L{ii}, DIFFMETRICS(:,kk));
%                 end
%             end
        end
    end
end

%TRKS_FX_FIMBRIA_R:
disp('Flipping and adding scalars to closest ROI for TRKS_FX_FIMBRIA_R...')
for ii=1:numel(TRKS_FX_FIMBRIA_R)
    %disp(['In ii: ' num2str(ii) ] );
    for jj=1:numel(ROI_FX_FIMBRIA_R)
        if strcmp(TRKS_FX_FIMBRIA_R{ii}.id,ROI_FX_FIMBRIA_R{jj}.id)
            TRKS_FX_FIMBRIA_R{ii}=rotrk_flip(TRKS_FX_FIMBRIA_R{ii}, [ rotrk_ROImean(ROI_FX_FIMBRIA_R{jj})] );
%             for kk=1:size(DIFFMETRICS,2) %We only check one DIFFMETRICS as previous ids have been already checked (in step 1_init_variables.m)
%                 if strcmp(TRKS_FX_FIMBRIA_R{ii}.id,DIFFMETRICS{1,kk}.id)
%                     TRKS_FX_FIMBRIA_R{ii} = rotrk_add_sc(TRKS_FX_FIMBRIA_R{ii}, DIFFMETRICS(:,kk));
%                 end
%             end
        end
       
    end
end



%%
%Creating the 2landmarks for each TRKS...
%it will return the trimmed header and strlines and the centerline heade
%and strlines
%Left Fimbria
disp('Applying rotrk_2landmarks using high_sc to selected the centerline (Left side): ')
[TRKS_FX_trimmed_L, TRKS_FX_centerline_L, TRKS_FX_trimmed_nointerp_L ] = ... 
    rotrk_2landmarks(TRKS_FX_DOTFIMBRIA_L, ROI_FX_DOT, ROI_FX_FIMBRIA_L,40, ...
    'high_sc',DIFFMETRICS, 'GFA');

disp('Applying rotrk_2landmarks using high_sc to selected the centerline (Right side): ')
%Right Fimbria
[TRKS_FX_trimmed_R, TRKS_FX_centerline_R, TRKS_FX_trimmed_nointerp_R ] = ...  
    rotrk_2landmarks(TRKS_FX_DOTFIMBRIA_R, ROI_FX_DOT, ROI_FX_FIMBRIA_R,40, ...
    'high_sc',DIFFMETRICS, 'GFA');
