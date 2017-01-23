function [ roi_xyz ] = rotrk_ROIxyz(roi_input)
%   function [ roixyz ] = rotrk_ROIxyz(header, tracts, roi
%
%   IN ->
%           roi_input     : roi niftii file with the needed information
%           (either in rotrk format or just the filename)
%           header        : header info for (tmp_xyz*mat2) transformation
%   OUTPUT:
%               roixyz  : output with a 3xn matrix of xyz coordinates in
%               trk space


%mat2=header.vox_to_ras;

%If roi_input is in structure form (e.g. roi_input.id and
%roi_input.filename)
if isstruct(roi_input)
    H_vol=spm_vol(cell2char(roi_input.filename));
    mat2=H_vol.mat;
    roi_xyz.id=roi_input.id;
elseif iscell(roi_input)
    H_vol=spm_vol(cell2char(roi_input));
    mat2=H_vol.mat;
    roi_xyz.id='No ID, since filename was passed!';
else
    H_vol=spm_vol(roi_input);
    mat2=H_vol.mat;
    roi_xyz.id='No ID, since filename was passed!';
end

V_vol=spm_read_vols(H_vol);

ind=find(V_vol>0);
[ x y z ]  = ind2sub(size(V_vol),ind);
tmp_xyz = [ x-1 y-1 z-1 ones(numel(x),1) ] ;

roi_xyz.value =abs(tmp_xyz*mat2);
%roi_xyz.value =tmp_xyz;

roi_xyz.value=roi_xyz.value(:,1:3);