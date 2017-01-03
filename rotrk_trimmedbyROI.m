function [ TRKS_OUT ] = rotrk_trimmedbyROI(TRKS_IN, theROI, whatflag, theROI2)
%   function [ new_header, new_tracts ] = rotrk_trimmedbyROI(header, tracts, theROI, whatflag)
%   IN ->
%           TRKS_IN.tracts      : stream to be splitted (eg. *.matrix)
%           TRKS_IN.header      : midpoint where split occurs (e.g. '78')
%           theROI      : the ROI used for references
%           whatflag    : (e.g. 'above' --> move coordinates above the minimun eucledian distance
%                       : 'below' -> move coordinated above)
%   OUTPUT:
%               TRKS_OUT

%%%%%%%%SPLITTING THTE TRACTS_STRUCT FORM INTO TRACTS AND HEADER
tracts=TRKS_IN.sstr;
header=TRKS_IN.header;
TRKS_OUT.id=TRKS_IN.id;
TRKS_OUT.filename=TRKS_IN.filename;
%~~~

%Create a temporary eucledian distance between each point...
%For each streamline
strline_counter=1;
counter=1;
if strcmp(whatflag,'above') || strcmp(whatflag,'below')
    xyz_flag=rotrk_ROImean(theROI.filename);
else
    ROIxyz=rotrk_ROIxyz(theROI);
    xyz_flag=round(median(ROIxyz.value)); %/header.voxel_size(2));
    if nargin > 4
        ROIxyz2=rotrk_ROIxyz(theROI2);
        xyz_flag2=round(median(ROIxyz2.value)); %/header.voxel_size(2));
    end
end


for ii=1:numel(tracts)
    clear tmp_distance
    
    if strcmp(whatflag,'above') || strcmp(whatflag,'below')
        %Rounded median value of the xyz ROI dividing by the # of voxels
        %for compatibility with DSI_Studio
        %For each value within streamline
        for ij=1:size(tracts(ii).matrix,1)
            %Computing the eucledian distance
            tmp_distance(ij)=sqrt( (xyz_flag(1)-tracts(ii).matrix(ij,1))^2 + (xyz_flag(2)-tracts(ii).matrix(ij,2))^2  + (xyz_flag(3)-tracts(ii).matrix(ij,3))^2);
        end
        %What value index is closer??
        [minvalue minidx ] = min(tmp_distance);
    end
    %If flag is 'dot' then move all the values coordinates above the
    %eucledian distance..
    if strcmp(whatflag,'above')
        counter=1;
        for ik=minidx:size(tracts(ii).matrix,1)
            if minidx ~= size(tracts(ii).matrix,1)
                new_tracts(ii).matrix(counter,:)=tracts(ii).matrix(ik,:);
                counter=counter+1;
            end
        end
        new_tracts(ii).nPoints=counter-1;
        
        
        %If flag is 'fimbria' (and since values start next to dot fornix
        %then move all the values coordinates below the eucledian distance
    elseif strcmp(whatflag,'below')
        counter=1;
        if minidx > 2
            for ik=1:minidx
                %disp( ['ii is:' num2str(ii) ' and ik is:' num2str(ik) ' minidx:' num2str(minidx)] )
                new_tracts(strline_counter).matrix(counter,:)=tracts(ii).matrix(ik,:);
                counter=counter+1;
            end
            new_tracts(strline_counter).nPoints=counter-1;
            
            strline_counter=1+strline_counter; %This will remove strlines beyond the point. If we use the index ii, then we will have [] arrays
        end
        
        %Here we will be trimming based on what we did with the genu and splenium
        %Within streamlin
    elseif strcmp(whatflag,'genu') %Same will apply for the splenium but logical expression signs will be flipped!
        the_actual_str_counter=1;
        counter=1; %for the new_tracts
        flaggy_first_reach=0; %This flag will be changed to 1 when we reached the plane of interest
        cur_streamline=round(tracts(ii).matrix);
        %Now check all the values that go beyond the plane of interest
        %(in this case the y-plane so using index 2
        
        %Within each coordinate in the streamline
        for ik=1:size(cur_streamline,1)
            if flaggy_first_reach == 0 %wanting to reach the first plane and remove the others...
                if cur_streamline(ik,2) == xyz_flag(2)
                    flaggy_first_reach=1;
                    new_tracts(strline_counter).matrix(counter,:)=tracts(ii).matrix(ik,:);
                    new_tracts(strline_counter).nPoints=size(new_tracts(strline_counter).matrix,1);
                    counter=counter+1;
                end
            elseif flaggy_first_reach == 1
                new_tracts(strline_counter).matrix(counter,:)=tracts(ii).matrix(ik,:);
                new_tracts(strline_counter).nPoints=size(new_tracts(strline_counter).matrix,1);
                counter=counter+1;
                if cur_streamline(ik,2) == xyz_flag(2) && counter > 5
                    flaggy_first_reach=3;
                end
            end
        end
        strline_counter=1+strline_counter;
        
    %Same will apply for the splenium but logical expression signs will be flipped!    
    elseif strcmp(whatflag,'splenium') 
        the_actual_str_counter=1;
        counter=1; %for the new_tracts
        flaggy_first_reach=0; %This flag will be changed to 1 when we reached the plane of interest
        cur_streamline=round(tracts(ii).matrix);
        %Now check all the values that go beyond the plane of interest
        %(in this case the y-plane so using index 2
        
        %Within each coordinate in the streamline
        for ik=1:size(cur_streamline,1)
            if flaggy_first_reach == 0 %wanting to reach the first plane and remove the others...
                if cur_streamline(ik,2) == xyz_flag(2)
                    flaggy_first_reach=1;
                    new_tracts(strline_counter).matrix(counter,:)=tracts(ii).matrix(ik,:);
                    new_tracts(strline_counter).nPoints=size(new_tracts(strline_counter).matrix,1);
                    counter=counter+1;
                end
            elseif flaggy_first_reach == 1
                new_tracts(strline_counter).matrix(counter,:)=tracts(ii).matrix(ik,:);
                new_tracts(strline_counter).nPoints=size(new_tracts(strline_counter).matrix,1);
                counter=counter+1;
                if cur_streamline(ik,2) == xyz_flag(2) && counter > 5
                    flaggy_first_reach=3;
                end
            end
        end
        strline_counter=1+strline_counter;
    elseif strcmp(whatflag,'withinROI')
        if ~isempty(tracts(ii).matrix)
            cur_streamline=tracts(ii).matrix;
            tt=round(tracts(ii).matrix(1,1)); %Implemented for the X-axis for now...
            if tt < round(max(ROIxyz.value(:,1)))+2 && tt >  round(min(ROIxyz.value(:,1)))
                %Making sure if ends closer to the 2ndROI...
                if round(tracts(ii).matrix(end,1)) < round(max(ROIxyz2.value(:,1)))
                    new_tracts(counter).matrix=tracts(ii).matrix;
                    new_tracts(counter).nPoints=size(new_tracts(counter).matrix,1);
                    counter=counter+1;
                end
            end
        end
    end
   
end


%Check if a tract has size 1, if so then remove it (so parfor in the
%interpolation method does not fail!).

TRKS_OUT.sstr=new_tracts;
TRKS_OUT.header=TRKS_IN.header;
TRKS_OUT.header.n_count=size(new_tracts,2);
TRKS_OUT.header.specific_name=strcat(TRKS_IN.header.specific_name,'_trimmed'); %and adding it againg
%Removing naming convetion if trimmed was applied twice
TRKS_OUT.header.specific_name=strrep(TRKS_OUT.header.specific_name,'_trimmed_trimmed','_trimmedx2');

