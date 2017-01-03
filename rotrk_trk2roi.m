function  drigo_trk2roi(header, tracts, vol_input,roi_name,split,tolerance, ROI_for_mid )
% [ new_ROIROI ] = drigo_trk2roi(header, tracts, vol_input,tolerance)
% Reads in a tract (in *.trk NOT *.trk.gz!) and exports an ROI in NIFTII
% format
%
%   Dependencies:
%                   trk_read
%  If 3 arguments are passed:
%   IN ->
%     header:       (header) in struct format
%     tracts:       (tracts) in *.trk struct format
%     vol_input:   (volume)  in *.nii format NOT *.nii.gz!
%     roi_name:     Filename to save (optional. default name: new_ROIROI.nii)
%     split:        *optional: if 'splitx'
%                              then it will look at the 'end' and 'beg'
%                              coordinates in x-pos and split it if it goes
%                              beyond:
%                                       x-coord +- <tolerance>  or
%                                       mx+b (if ROI_for_mid is passed)
%                    unilateral
%                   If any coordiante goes beyond
%     tolerance:    *optional for splitx: tolerance on how to do splitting
%                    (Default: +-2 points in the coordinate system)
%     ROI_for_mid   *optional for splitx: if passed, it will calculate the
%                   mean value of the specific ROI_for mid
%
%                   *Also, for future implementation: a mid region equating
%                   'y=mx+b' using center from header.dim and center
%                    from ROI_for_mid      
%                       
%  If 2 arguments are passed:
%     header:   (*.trk) file
%     tracts:   (volume) in nii format

%   OUT ->
%     new_ROIROI:  in *.nii format


%%CHECKING VARIABLE INITIALIZING...
if nargin < 4
    roi_name='new_ROI.nii' ;
    warning('No name passed as an input. Using new_ROI.nii as the name output...')
    split='';
end

if nargin < 5
    split='no_split';
end

if nargin < 6
    tolerance=2;
end

if nargin < 7
    ROI_for_mid='';
end
%~~~~~~~~~~end of checking variables initialization~~~~~~~~


%CHECKING STRUCTURE TYPE FOR vol_input
if isstruct(vol_input)
    if iscell(vol_input.filename)
        H_vol= spm_vol(cell2char(vol_input.filename));
    else
        H_vol= spm_vol(vol_input.filename);
    end
elseif iscell(vol_input)
    H_vol= spm_vol(cell2char(vol_input));
else
    H_vol= spm_vol(vol_input);
end
V_vol=spm_read_vols(H_vol);
%~~~~~~~~~~end of checking structure type~~~~~~~~


if strcmp(split,'no_split') 
    new_ROI=zeros(size(V_vol));
else
    disp('split activated. Applying unilateral split...')
    new_ROI_R=zeros(size(V_vol));
    new_ROI_L=zeros(size(V_vol));
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%STARTING MAIN IMPLEMENTATION HERE:
for ii = 1:numel(tracts)
    % Translate continuous vertex coordinates into discrete voxel coordinates
    %pos = round(tracts(ii).matrix(:,1:3) ./ repmat(header.voxel_size, tracts(ii).nPoints,1))
    pos = ceil(tracts(ii).matrix(:,1:3) ./ repmat(header.voxel_size, tracts(ii).nPoints,1));
    %disp([ 'in ii: ' num2str(ii)]); 
    switch split
        case 'no_split'  %No unilateral split...
            [ ind_bil , ~ , split_value ]  = local_calc_idx(header,pos);
            new_ROI(ind_bil)=1;
            
        case 'splitx'
            cut_label=1; % 1 for x-axis, 2 for y-axis, 3 for z-axis
            %Calculating index
            [ ind_L, ind_R, split_value ] =local_calc_idx(header,pos,cut_label, tolerance, ...
                ROI_for_mid); % 1 signifies 'x-coordinate'
            
            if ~(any(isnan(ind_L))) ; new_ROI_L(ind_L)=1; end 
            if ~(any(isnan(ind_R))) ; new_ROI_R(ind_R)=1; end
    end
end


%Writing into a file (all of the streamlines, that's why this if statements
%are outside the for loop...
if strcmp(split,'no_split')
    local_write_filename(H_vol,new_ROI,0,roi_name);
else
    local_write_filename(H_vol,new_ROI_L, 1, roi_name,'.nii','_L.nii');
    local_write_filename(H_vol,new_ROI_R, 1,roi_name,'.nii','_R.nii');
end
display(' ');

%%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



%%!!!!
%%%%%%%%%%%%%%%%%%%%%%LOCAL FUNCTION calc_idx%%%%%%%%%%%%%%%%%%%%%%%%
function [ind_bil_or_L , ind_R, split_value ] = local_calc_idx(header,pos,cut_label,~,ROI_for_mid)
if nargin < 3  %Simple calculation, no need to split it
    ind_bil_or_L = sub2ind(header.dim, pos(:,1), pos(:,2), pos(:,3));
    ind_R = '';
else    %Else apply some sort of splitting...
    %~~> Split value implementation either half of header dim:
    if isempty(ROI_for_mid) %apply header.dim(cutlabel)/2
        split_value=header.dim(cut_label)/2;
    else
        mean_ROI_here=rotrk_ROImean(ROI_for_mid);
        split_value=mean_ROI_here(cut_label)/header.voxel_size(cut_label);
        
      %~~> Another POSSIBILITYor calculate a liner fit (y=mx+b) to assigned the mid of
        %the brain based on the ROI_for_mid
        %split_value='Toimplement';
    end
        
    %Initializing ind_L/R
    ind_R=nan;
    ind_bil_or_L=nan;
    flag_notR=0;
    flag_notL=0;
    
    %Initial split
    if (pos(end,cut_label) > split_value )
        ind_bil_or_L = sub2ind(header.dim, pos(:,1), pos(:,2), pos(:,3));
    else
        ind_R= sub2ind(header.dim, pos(:,1), pos(:,2), pos(:,3));
    end

    
    %     if (pos(1,cut_label) >= split_value ) || (pos(end,cut_label) >= split_value )
%         for jj=1:size(pos,1)
%             if  ~(pos(jj,cut_label) > split_value )
%                 flag_notR=1;
%             end
%         end
%     end
%     if flag_notR ~= 1
%         ind_bil_or_L = sub2ind(header.dim, pos(:,1), pos(:,2), pos(:,3));
%     else
%         ind_R= sub2ind(header.dim, pos(:,1), pos(:,2), pos(:,3));
%     end
    %**
    % **For some reason, pos (X Y Z coordinates) are +1 indexed (eg. in
    %   FSLView the value at 88 80 30 will make pos to have coordinates 89 81 31
    %   (now in function rotrk_ROIxyz.m, where we get the exact coordinates (and others),
    %   we get rid of this indexing problem (by -1-ing all coordinates) to get the
    %   correct coordinates. Here pos values don't matter as we only save the
    %   values at exact positions. Though, it has been checked that values with function
    %   rotrk_add_sc.m as it has the same problem with pos but denote the output needed.
    %   ***Most likely this is a problem with indexing either starting at 0
    %   or 1
    %**
end
%~~~~~~~~~~~~~~~~~~~~~END OF FUNCTION calc_idx~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

%%%%%%%%%%%%%%%%%%%%%%LOCAL FUNCTION write_filename%%%%%%%%%%%%%%%%%%%%%%%%
function local_write_filename(H_vol,newROI_vol,is_split, roi_name,old_str,replaced_with)
if ~is_split
    H_vol.fname = roi_name;  %new_ROIROIname;
else
    H_vol.fname = strrep(roi_name,old_str,replaced_with);  %new_ROIROIname;
end



try
    system([ 'mkdir -p ' fileparts(H_vol.fname) ] );
    spm_write_vol(H_vol,newROI_vol);
    display(['The nii: ' H_vol.fname ' was successfully generated ' ]);
catch
    error('Cannot save the file. *Make sure *.nii is added as the roi_name! Is SPM installed?')
end
%~~~~~~~~~~~~~~~~~~~~~~END OF FUNCTION
%write_filename~~~~~~~~~~~~~~~~~~~~~~