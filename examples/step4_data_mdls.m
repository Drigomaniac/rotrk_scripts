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


%%
%Adding additional tracts for the table
%!~~
%TO CHANGE STRUCTURE ISSUE AND RE-IMPLEMET:
%addition_splenium_genu
%~~!

%%
%Generate the major table
disp('Generating the table');
%Adding the necessary values to a table:
[unclean_Table, vars_out] = rotrk_2table(TRKS_FX_DOT, TRKS_FX_trimmed_L, TRKS_FX_trimmed_R, TRKS_FX_centerline_L, TRKS_FX_centerline_R);
%Remove nans and the matched pair:
clean_Table=rotrk_re_pair_nans(unclean_Table,'agematched_id',9);
theTable=clean_Table;
%%
%THE STATS! 
%IN CENTERLINES:
clc
%mdl_dot_length_L=fitlm(theTable, 'dotlength_Left~dx+diffmotion+vol_fimbriaDIL_L')
%mdl_dot_length_R=fitlm(theTable, 'dotlength_Right~dx+diffmotion+vol_fimbriaDIL_R')

%mdl_vol_joinedL=fitlm(theTable, 'vol_fornix_joinedL_mm3~dx+diffmotion+vol_fimbriaDIL_L')
%mdl_vol_joinedR=fitlm(theTable, 'vol_fornix_joinedR_mm3~dx+diffmotion+vol_fimbriaDIL_R')

mdl_GFA_L=fitlm(theTable, 'meanGFA_fx_dotfimbriaL_centerline~dx+diffmotion+0')
mdl_GFA_R=fitlm(theTable, 'meanGFA_fx_dotfimbriaR_centerline~dx+diffmotion+vol_fimbriaDIL_R')

mdl_NQA0_L=fitlm(theTable, 'meanNQA0_fx_dotfimbriaL_centerline~dx+diffmotion+vol_fimbriaDIL_L')
mdl_NQA0_R=fitlm(theTable, 'meanNQA0_fx_dotfimbriaR_centerline~dx+diffmotion+vol_fimbriaDIL_R')


%Other Interesting Metrics
mdl_NMD_L=fitlm(theTable, 'meanNMD_fx_dotfimbriaL_centerline~dx+diffmotion+vol_fimbriaDIL_L')
mdl_NMD_R=fitlm(theTable, 'meanNMD_fx_dotfimbriaR_centerline~dx+diffmotion+vol_fimbriaDIL_R')

mdl_NRD_L=fitlm(theTable, 'meanNRD_fx_dotfimbriaL_centerline~dx+diffmotion+vol_fimbriaDIL_L')
mdl_NRD_R=fitlm(theTable, 'meanNRD_fx_dotfimbriaR_centerline~dx+diffmotion+vol_fimbriaDIL_R')

mdl_FA_L=fitlm(theTable, 'meanFA_fx_dotfimbriaL_centerline~dx+diffmotion+vol_fimbriaDIL_L')
mdl_FA_R=fitlm(theTable, 'meanFA_fx_dotfimbriaR_centerline~dx+diffmotion+vol_fimbriaDIL_R')

mdl_RD_L=fitlm(theTable, 'meanRD_fx_dotfimbriaL_centerline~dx+diffmotion+vol_fimbriaDIL_L')
mdl_RD_R=fitlm(theTable, 'meanRD_fx_dotfimbriaR_centerline~dx+diffmotion+vol_fimbriaDIL_R')

mdl_AxD_L=fitlm(theTable, 'meanAxD_fx_dotfimbriaL_centerline~dx+diffmotion+vol_fimbriaDIL_L')
mdl_AxD_R=fitlm(theTable, 'meanAxD_fx_dotfimbriaR_centerline~dx+diffmotion+vol_fimbriaDIL_R')

mdl_MD_L=fitlm(theTable, 'meanMD_fx_dotfimbriaL_centerline~dx+diffmotion+vol_fimbriaDIL_L')
mdl_MD_R=fitlm(theTable, 'meanMD_fx_dotfimbriaR_centerline~dx+diffmotion+vol_fimbriaDIL_R')



%%
%IN TRIMMED TRKS

mdl_GFA_L=fitlm(theTable, 'meanGFA_fx_dotfimbriaL_trimmedx2~dx+diffmotion+numsstr_fx_dotfimbriaL_trimmedx2')
mdl_GFA_R=fitlm(theTable, 'meanGFA_fx_dotfimbriaR_trimmedx2~dx+diffmotion+numsstr_fx_dotfimbriaR_trimmedx2')

mdl_NQA0_L=fitlm(theTable, 'meanNQA0_fx_dotfimbriaL_trimmedx2~dx+diffmotion+numsstr_fx_dotfimbriaL_trimmedx2')
mdl_NQA0_R=fitlm(theTable, 'meanNQA0_fx_dotfimbriaR_trimmedx2~dx+diffmotion+numsstr_fx_dotfimbriaR_trimmedx2')


%Other Interesting Metrics
mdl_NMD_L=fitlm(theTable, 'meanNMD_fx_dotfimbriaL_trimmedx2~dx+diffmotion+numsstr_fx_dotfimbriaL_trimmedx2')
mdl_NMD_R=fitlm(theTable, 'meanNMD_fx_dotfimbriaR_trimmedx2~dx+diffmotion+numsstr_fx_dotfimbriaR_trimmedx2')

mdl_NRD_L=fitlm(theTable, 'meanNRD_fx_dotfimbriaL_trimmedx2~dx+diffmotion+numsstr_fx_dotfimbriaL_trimmedx2')
mdl_NRD_R=fitlm(theTable, 'meanNRD_fx_dotfimbriaR_trimmedx2~dx+diffmotion+numsstr_fx_dotfimbriaR_trimmedx2')

mdl_FA_L=fitlm(theTable, 'meanFA_fx_dotfimbriaL_trimmedx2~dx+diffmotion+numsstr_fx_dotfimbriaL_trimmedx2')
mdl_FA_R=fitlm(theTable, 'meanFA_fx_dotfimbriaR_trimmedx2~dx+diffmotion+numsstr_fx_dotfimbriaR_trimmedx2')

mdl_RD_L=fitlm(theTable, 'meanRD_fx_dotfimbriaL_trimmedx2~dx+diffmotion+numsstr_fx_dotfimbriaL_trimmedx2')
mdl_RD_R=fitlm(theTable, 'meanRD_fx_dotfimbriaR_trimmedx2~dx+diffmotion+numsstr_fx_dotfimbriaR_trimmedx2')

mdl_AxD_L=fitlm(theTable, 'meanAxD_fx_dotfimbriaL_trimmedx2~dx+diffmotion+numsstr_fx_dotfimbriaL_trimmedx2')
mdl_AxD_R=fitlm(theTable, 'meanAxD_fx_dotfimbriaR_trimmedx2~dx+diffmotion+numsstr_fx_dotfimbriaR_trimmedx2')

mdl_MD_L=fitlm(theTable, 'meanMD_fx_dotfimbriaL_trimmedx2~dx+diffmotion+numsstr_fx_dotfimbriaL_trimmedx2')
mdl_MD_R=fitlm(theTable, 'meanMD_fx_dotfimbriaR_trimmedx2~dx+diffmotion+numsstr_fx_dotfimbriaR_trimmedx2')


%%
%Getting a filtered table...
dx_means=theTable(:,{'dx','meanNQA0_fx_dotfimbriaL_centerline','meanNQA0_fx_dotfimbriaR_centerline' , ...
      'meanNQA1_fx_dotfimbriaL_centerline','meanNQA1_fx_dotfimbriaR_centerline' , ...
      'meanNQA2_fx_dotfimbriaL_centerline','meanNQA2_fx_dotfimbriaR_centerline' , ...
        'meanQA0_fx_dotfimbriaL_centerline','meanQA0_fx_dotfimbriaR_centerline' , ...
    'meanQA1_fx_dotfimbriaL_centerline','meanQA1_fx_dotfimbriaR_centerline' , ...
    'meanQA2_fx_dotfimbriaL_centerline','meanQA2_fx_dotfimbriaR_centerline' , ...
    'meanISO_fx_dotfimbriaL_centerline','meanISO_fx_dotfimbriaR_centerline' , ...
    'meanRDI1L_fx_dotfimbriaL_centerline','meanRDI1L_fx_dotfimbriaR_centerline' , ...
    });

AA=grpstats(dx_means,'dx',{'mean','std'})



