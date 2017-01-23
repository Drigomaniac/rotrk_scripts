function rotrk_plot(TRKS_IN, plot_color, sortedby, dx,  varargin )
%function rotrk_plot(header,tracts, volume, sortedby,limit_to, header2, tracts2, header3, tracts3 )
% Inputs:
%   TRKS_IN:
%       TRKS_IN.header          -> struct/cell file header (*make sure this is larger
%       TRKDS_IN.tracts         -> struct/cell file strlines

%   plot_color      --> color of the plot (e.g. 'rainbow' 'r' 'rr' 'r.' 'b' 'bb' 'c' 'cc' 'g' 'k' 'kk' 'kline'  )       
%                       *will replace TRKS_IN.plot_params.color!!
%    sortedby       --> sorted by this variable (e.g. header.data.age, so put 'age')
%    dx             --> limit to a specific input to the chosen Dx
%                       (e.g. header.data.dx, so put 'AD' or 'NC')
%
%   ***
%   varargin       --> pass other tracts (e.g. TRKS_IN2, TRKS_IN3, ...)
%   varargin       --> or the following parameters:
%                   ('remove' 'limits' ) --> remove xyz axis
%                   ('add' 'sex' ) 
%                   ('add' 'age' )
%                   ('add' 'motion' ) --> add these values to the plot
%
%   ***
%   THESE PARAMETERS BELOW WILL BE READ FROM TRKS_IN.plot.params: 
%   TRKS_IN.plot_params.color
%   TRKS_IN.plot_params.orientation
%   TRKS_IN.plot_params.xlim
%   TRKS_IN.plot_params.ylim
%   TRKS_IN.plot_params.zlim
% OUTPUT:
%    The plot :P~~~! 


if nargin <2 ; plot_color=''; end
if nargin <3 ; sortedby=''; end
if nargin <4 ; dx=''; end

if nargin < 3  %ONLY A SINGLE PLOT CONFIGURATION
    n_plots=numel(TRKS_IN);
    n_subplots=ceil(n_plots/9); %e.g. for 23 values, we need at least 3 subplots (9x9x5)
    %~~~end of checking # of plots needed.
    
    %STARTING THE PLOT IMPLEMENTATION
    % number of subplots needed
    plot_idx=1;
    plot_counter=1;
    plot_idx=1;
    if numel(TRKS_IN)==1
        disp(['In: ' TRKS_IN.id '... '])
        local_rotrk_goplot(TRKS_IN, plot_color,'1st',varargin)
    else
        for ii=1:n_subplots % 1 through 3
            figure, hold on
            %if in the last subplot, check how many plots using mod)
            if (ii==n_subplots), subplot_idx=mod(n_plots,9)-1;
            else %subplot 9 subplots per figure...
                subplot_idx=9;
            end
            for jj=1:subplot_idx
                subplot(3,3,jj)
                disp(['In: ' TRKS_IN{plot_idx}.id '... '])
                local_rotrk_goplot(TRKS_IN{plot_idx},plot_color,'1st',varargin)
                title([ '\color{red}' strrep(TRKS_IN{plot_idx}.id,'_','\_')], 'Interpreter', 'tex')
                hold off
                plot_idx=plot_idx+1;
            end
        end
    end
    
    
else %NOW WE DEAL WITH A CELL ARRAY THAT CONTAIN MANY PLOTS
    
    %INITIALIZE CHECKING...
    if isempty(sortedby) ; warning('No sortedby argument passed. Plotting w/o sorting...'); end
    if isempty(dx) ; warning('No dx (e.g. AD) argument passed. Plotting everything...'); end
    
    %Check to see if the field 'sorted_by exists'
    for jj=1:numel(TRKS_IN)
        check_sorted(jj)= isfield(TRKS_IN{jj}.header.data,sortedby);
    end
    if ~all(check_sorted) %if all contain the sorted value, then continue, else error
        error(['TRKS_IN has an element that does not contain the sorted value:'...
            '''' sortedby ''''  ' in ith element:' num2str(find(check_sorted~=1))  ' . Please check!' ])
    end
    %Checking if the Dx field exists under the header...
    for jj=1:numel(TRKS_IN)
        check_dx(jj)= isfield(TRKS_IN{1}.header.data,'dx');
    end
    if ~all(check_dx) %if all contain the sorted value, then continue, else error
        error(['TRKS_IN has an element that does not contain the dx field ('...
            num2str(find(check_dx~=1)) ' element). Please check!' ])
    end
    %%~~~~~~end init checking~~~~~~~~~<<
    
    %SORTING THE VARIABLES BASED ON TRKS_IN:
    %Adding the value to a specific flag (age_val) to be used as a temporal
    %sorted array
    for ii=1:numel(TRKS_IN)
        age_val(ii)=TRKS_IN{ii}.header.data.age;
    end
    %Sorting idx from 'sortedby' argument (e.g. age)
    [ sorted_value, sorted_idx ] = sort(age_val);
    
    %Now sorting the cell...
    sorted_TRKS_IN{numel(TRKS_IN)}='';
    for ii=1:numel(TRKS_IN)
        sorted_TRKS_IN{ii}=TRKS_IN{sorted_idx(ii)};
    end
    %~~end of SORTING VARIABLES
    
    %IMPLEMENTING BASED ON DX
    %First check how many plots will be outputted based on the 'Dx' argument...
    n_plots=1;
    for ii=1:numel(sorted_TRKS_IN)
        if strcmp(sorted_TRKS_IN{ii}.header.data.dx,dx)
            TRKS_IN_toplot{n_plots}=sorted_TRKS_IN{ii};
            n_plots=n_plots+1;
        end
    end
    n_subplots=ceil(n_plots/9); %e.g. for 23 values, we need at least 3 subplots (9x9x5)
    %~~~end of checking # of plots needed.
    
    %STARTING THE PLOT IMPLEMENTATION
    % number of subplots needed
    plot_idx=1;
    plot_counter=1;
    for ii=1:n_subplots % 1 through 3
        figure, hold on
        %if in the last subplot, check how many plots using mod)
        if (ii==n_subplots), subplot_idx=mod(n_plots,9)-1;
        else %subplot 9 subplots per figure...
            subplot_idx=9;
        end
        for jj=1:subplot_idx
            subplot(3,3,jj)
            disp(['In: ' TRKS_IN_toplot{plot_idx}.id '... ']);
            local_rotrk_goplot(TRKS_IN{plot_idx},plot_color,'1st',varargin)
            for kk=1:numel(varargin) %--->Check how many more TRKS_in are being passed)
                if iscell(varargin{kk}) %if it's not cell, its 'remove' or the 'add' flag and its folow up arguments
                    for mm=1:numel(varargin{kk})
                        if strcmp(varargin{kk}{mm}.id,TRKS_IN{plot_idx}.id)
                            local_rotrk_goplot(varargin{kk}{mm},plot_color,'','')
                        end
                    end
                end
            end
            
            %TITLE AND COLOR:
            if strcmp(dx,'AD')
                title([ '\color{red}' strrep(TRKS_IN_toplot{plot_idx}.id,'_','\_')], 'Interpreter', 'tex')
                %title([ '\color{red}' 'AD\_' num2str(plot_counter) ], 'Interpreter', 'tex')
                plot_counter=plot_counter+1;
            else
                title([ '\color{blue}' strrep(TRKS_IN_toplot{plot_idx}.id,'_','\_')], 'Interpreter', 'tex')
                %title([ '\color{blue}' dx ' \_' num2str(plot_counter) ], 'Interpreter', 'tex')
                plot_counter=plot_counter+1;
            end
            plot_idx=plot_idx+1;
        end
        hold off
    end
end
%END OF FILE ~~~


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%STARTING LOCAL FUNCTION
% Plot streamlines
function local_rotrk_goplot(single_TRKS_IN,plot_color,what_plot,varargin)


%FIRST TAKING CARE OF THE COLOR!
%Setting up the values for the 1st plot only!
if nargin < 2
    what_plot='';
end

%COLOR INIT FOR STREAMLINE FIRST:
color=plot_color;
%CHECKING COLOR PARAMETER
if isfield(single_TRKS_IN,'plot_params')
    %COLOR
    if strcmp(plot_color,'')
        if isfield(single_TRKS_IN.plot_params, 'color')
            color=single_TRKS_IN.plot_params.color;
        else
            color='r';
        end
    end
end
if strcmp(color,''); color='k'; end
%%END OF COLOR INIT



%FOR LOOP TO ITERATE BETWEEN STREAMLINS WITHIN A TRACT
for numtrks = 1:size(single_TRKS_IN.sstr,2)
    %READING THE MATRIX:
    matrix = single_TRKS_IN.sstr(numtrks).matrix;
    
    %Check if single_TRKS_IN.plotparams exists (if not go with defaults...)
    hold on
    switch color
        case 'rainbow'
            [maxpts, maxidx ]  = max(arrayfun(@(x) size(x.matrix, 1), single_TRKS_IN.sstr));
            cline(matrix(:,1), matrix(:,2), matrix(:,3), (0:(size(matrix, 1)-1))/(maxpts))
        case 'myrainbow_4'
            if size(matrix,2) < 4
                error([ 'Error: diffusion metric not found.' ...
                    ' Make sure your data has at least a 4th column. Exiting...']);
            else
                cline(matrix(:,1), matrix(:,2), matrix(:,3), matrix(:,4))
            end
        case 'r'
            plot3(matrix(:,1), matrix(:,2), matrix(:,3),'r')
            plot3(matrix(1,1), matrix(1,2), matrix(1,3), 'b.','markersize',30)
        case 'rr'
            plot3(matrix(:,1), matrix(:,2), matrix(:,3),'r')
        case 'r.'
            plot3(matrix(1,1), matrix(1,2), matrix(1,3), 'r.')
        case 'b'
            plot3(matrix(:,1), matrix(:,2), matrix(:,3),'b')
            plot3(matrix(1,1), matrix(1,2), matrix(1,3), 'r.','markersize',30)
        case 'bb'
            plot3(matrix(:,1), matrix(:,2), matrix(:,3),'b')
        case 'c'
            plot3(matrix(:,1), matrix(:,2), matrix(:,3),'c')
            plot3(matrix(1,1), matrix(1,2), matrix(1,3), 'c.')
        case 'cc'
            plot3(matrix(:,1), matrix(:,2), matrix(:,3),'c')
        case 'g'
            plot3(matrix(:,1), matrix(:,2), matrix(:,3),'g')
            plot3(matrix(1,1), matrix(1,2), matrix(1,3), 'b.')
        case 'gg'
            plot3(matrix(:,1), matrix(:,2), matrix(:,3),'g')
        case 'k'
            plot3(matrix(:,1), matrix(:,2), matrix(:,3),'k')
            plot3(matrix(1,1), matrix(1,2), matrix(1,3), 'k.')
        case 'kk'
            plot3(matrix(:,1), matrix(:,2), matrix(:,3),'k')
        case 'kline'
            plot3(matrix(:,1), matrix(:,2), matrix(:,3),'k.','markersize',30)
            plot3(matrix(1,1), matrix(1,2), matrix(1,3), 'r.')
        otherwise
            plot3(matrix(:,1), matrix(:,2), matrix(:,3),'b-')
            plot3(matrix(1,1), matrix(1,2), matrix(1,3), 'r.','markersize',20)
            hold on
    end
end
%Reverse x-orientation so it looks like right is right in the image!
set(gca,'xdir','reverse'); shg

%%~~~~~~CHECKING PARAMETERS ONLY FOR FIRST TRKS_IN (in case of varargin)!!
if strcmp(what_plot,'1st')
 %Setting up the values for the 1st plot only!
    %CHECKING PARAMETERS
    %the plot parameters:
    if isfield(single_TRKS_IN,'plot_params')
        %COLOR
        if strcmp(plot_color,'')
            if isfield(single_TRKS_IN.plot_params, 'color')
                color=single_TRKS_IN.plot_params.color;
            else
                color='r';
            end
        end
        %ORIENTATION
        if isfield(single_TRKS_IN.plot_params, 'orientation')
            orientation=single_TRKS_IN.plot_params.orientation;
        else
            orientation='xy';
        end
        %XYZ-LIMITS
        if isfield(single_TRKS_IN.plot_params, 'xlim')
            xlim( single_TRKS_IN.plot_params.xlim);
        end
        if isfield(single_TRKS_IN.plot_params, 'ylim')
            ylim( single_TRKS_IN.plot_params.ylim);
        end
        if isfield(single_TRKS_IN.plot_params, 'zlim')
            zlim( single_TRKS_IN.plot_params.zlim);
        end
    end
    
    %other parameters that may have been passed as inputs:
    for ii=1:size(varargin{1},2)
        %disp(['numtrks: ' num2str(numtrks) ' and ii is: ' num2str(ii)])
        if strcmp(varargin{1}{ii},'add')
            try
                %the follow up argument will tell you what to add...
                if strcmp(varargin{1}{ii+1},'sex')
                    text(35,100,25 ,[ 'Sex: ' single_TRKS_IN.header.data.sex] );
                end
                if strcmp(varargin{1}{ii+1},'age')
                    text(35,100,30 ,[ 'Age:' num2str(single_TRKS_IN.header.data.age) ]);
                end
                if strcmp(varargin{1}{ii+1},',motion')
                    text(35,100,15 ,[ 'Motion:' num2str(single_TRKS_IN.header.data.diffmotion) ])
                end
            catch
                error('error when adding the add option. Have you added a 2nd argument?');
            end
        end
        if strcmp(varargin{1}{ii},'remove')
            try
                %the follow up argument will tell you what to add...
                if strcmp(varargin{1}{ii+1},'limits')
                    set(gca,'xcolor',get(gcf,'color'));
                    set(gca,'xtick',[]);
                    
                    set(gca,'ycolor',get(gcf,'color'));
                    set(gca,'ytick',[]);
                    
                    set(gca,'zcolor',get(gcf,'color'));
                    set(gca,'ztick',[]);
                    
                end
            catch
                error('error when adding the remove option. Hve you added a 2nd argument?');
            end
        end
    end
    
    xlabel('x'), ylabel('y'), zlabel('z', 'Rotation', 0)
    box off
    axis image
    axis ij
    
    switch orientation
        case 'xy'
            view(-90,0);
        case 'yz'
            view(-90,0);
        case 'xz'
            view(0,0)
        case '-3d'
            view(37.5,-30)
        case 'fornix'
            %view(229,0)
            %view(-80,24)
            %view(65,20)
            view(76,14 )  %so compatible with age and sex displaying coordinates
        case 'fornix2'
            view(124,-10)
        case 'fornix3'
            view(180,0)
        case 'fornix4'
            %view(-125,-8)
            view(-107,6)
        case 'cingL'
            %view(229,0)
            view(131,10)
        case 'crus'
            %view(229,0)
            view(-42,39)
        case 'ori1'
            %view(229,0)
            view(120,0)
        case 'ori2'
            %view(229,0)
            view(-180,90)
        otherwise
            view(3)
    end
end

