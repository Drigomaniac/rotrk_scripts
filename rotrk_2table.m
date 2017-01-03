%function [ myTable ] = rotrk_2table(hdr_trimmed1, str_trimmed1, hdr_trimmed2, str_trimmed2, hdr_centerline, str_centerline,  hdr_centerline2, str_centerline2, hdr_1,sstr_1,data_flag, hdr_other1, sstr_other1, name_other1, hdr_other2,sstr_other2, name_other2)
function [ myTable  vars_out] = rotrk_2table(TRKS_IN, varargin)
% Self explanatory, it generates a table based on the values given
% *!! The first hdrs or strs should be longer in size!!

%FIRST, GET THE NECESSARY VALUES FROM TRKS_IN:
[outTable, headerdata_field ] = local_getdemos_from_headerdata(TRKS_IN,'AD23NC23');
%~~END OF TRKS_IN adding to TABLE

%INITIALIZING VARIABLE
%So they have the same SIZE SO WE CAN CONVERT STRUCT TO TABLE
num_rows=numel(TRKS_IN);
var_fields.id=headerdata_field.id; %* --> This will be used to convert struct2table (as same index are needed);
for pp=1:numel(varargin) %on every TRKS passed
    %initializing the names we'll use for each varargin
    trk_name=strrep(varargin{pp}{1}.header.specific_name,'trk_','');
    numstr_varargin=strcat('numsstr_',trk_name);
    %Now on every value that makes up the vararing TRKS (e.g. n=42 for L or
    %45 for R)
    
    %number of streamlines passed:
    var_fields.(numstr_varargin)=nan(numel(TRKS_IN),1);
    for kk=1:size(varargin{pp}{1}.header.scalar_IDs,2)
        sc_name=cell2char(varargin{pp}{1}.header.scalar_IDs(kk));
        sc_ref=3+kk;
        mean_sc_name=strcat('mean',sc_name,'_',trk_name);
        var_fields.(mean_sc_name)=nan(numel(TRKS_IN),1);
        clear temp_avg
    end
end
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~END OF INIT~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%%
vars_out='';
%NOW WORKING ON VARARGIN
for ii=1:numel(var_fields.id)
    %NOW WORKING ON VARARGIN:
    for pp=1:numel(varargin) %on every TRKS passed
        %if ii==1 ; disp([ 'trk2table--> in ' varargin{pp}{1}.header.specific_name ' ...' ] ) ; end
        %initializing the names we'll use for each varargin
        trk_name=strrep(varargin{pp}{1}.header.specific_name,'trk_','');
        numstr_varargin=strcat('numsstr_',trk_name);
        %Now on every value that makes up the vararing TRKS (e.g. n=42 for L or
        %45 for R)
        for jj=1:numel(varargin{pp})
            %id from TRKS_in (initialize in var_fields.id to compare and
            %execute:
            if strcmp(var_fields.id{ii},varargin{pp}{jj}.header.data.id);
                %number of streamlines passed:
                var_fields.(numstr_varargin)(ii,1)=size(varargin{pp}{jj}.sstr,2);
                %Now look at every diffmetrics value
                %disp(['in pp: ' num2str(pp)]);
                for kk=1:size(varargin{pp}{jj}.header.scalar_IDs,2)
                    sc_name=cell2char(varargin{pp}{jj}.header.scalar_IDs(kk));
                    sc_ref=3+kk;
                    mean_sc_name=strcat('mean',sc_name,'_',trk_name);
                    for gg=1:size(varargin{pp}{jj}.sstr,2) %on every streamline...
                        temp_avg(gg)=mean(varargin{pp}{jj}.sstr(end).matrix(:,sc_ref));
                    end
                    var_fields.(mean_sc_name)(ii,1)=mean(temp_avg);
                    clear temp_avg
                end
            end
        end
    end
end
varTable=struct2table(var_fields);
myTable=join(outTable,varTable);
%%~~~~~~~~~~~~~~~~~~~~~~~~END OF IMPLEMENTATION~~~~~~~~~~~~~~~~~~~~~~~~~~%%

%%%%STARTING LOCAL FUNCTION/S%%%%%
function [outTable, spec_field ] = local_getdemos_from_headerdata(TRKS_IN,flag_project)
%EXTRACT variables values
for ii=1:numel(TRKS_IN)
    %char vars:
    spec_field.id{ii,1}=TRKS_IN{ii}.header.data.id;
    spec_field.sex{ii,1}=TRKS_IN{ii}.header.data.sex;
    spec_field.dx{ii,1}=TRKS_IN{ii}.header.data.dx;
    spec_field.dx_pse{ii,1}=TRKS_IN{ii}.header.data.dx_pse;
    
    %double type vars:
    spec_field.age(ii,1)=TRKS_IN{ii}.header.data.age;
    spec_field.diffmotion(ii,1)=TRKS_IN{ii}.header.data.diffmotion;
    spec_field.education(ii,1)=TRKS_IN{ii}.header.data.education;
    if strcmp(flag_project,'AD23NC23')
        
        spec_field.agematched_id(ii,1)=TRKS_IN{ii}.header.data.agematched;
        
        spec_field.T1_hippovol_L(ii,1)=TRKS_IN{ii}.header.data.T1_hippovol_L;
        spec_field.T1_hippovol_R(ii,1)=TRKS_IN{ii}.header.data.T1_hippovol_R;
        
        spec_field.vol_fimbriaDIL_L(ii,1)=TRKS_IN{ii}.header.data.fimbria_volDIL_L;
        spec_field.vol_fimbriaDIL_R(ii,1)=TRKS_IN{ii}.header.data.fimbria_volDIL_R;
        spec_field.vol_FX_DOT_bil(ii,1)=TRKS_IN{ii}.header.data.vol_FX_DOT_bil;
    end
    %number of strlines
    name_TRKS_IN=TRKS_IN{1}.header.specific_name;
    numstr=strcat('numsstr_',name_TRKS_IN);
end

%Making specific variables categorical:
spec_field.sex=nominal(spec_field.sex); %(done here so it passes the name when creating the table)
spec_field.dx=nominal(spec_field.dx);
spec_field.dx_pse=nominal(spec_field.dx_pse);
    
%Making a structure type variable to a table
outTable=struct2table(spec_field);

