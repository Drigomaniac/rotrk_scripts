function [flag_ok, diff_bad ]  = rotrk_check_diffmetrics(TRKS_IN, varargin)
flag_ok=0;
diff_bad=0;

for ii=1:numel(TRKS_IN)
    for jj=1:numel(varargin)
        if ~strcmp(TRKS_IN{ii}.id,varargin{jj}{ii}.id)
            flag_ok=ii;
            diff_bad=jj;
        end
    end
end