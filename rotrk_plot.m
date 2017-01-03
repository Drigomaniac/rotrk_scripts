function rotrk_plot(TRKS_IN, volume, sortedby, dx,  varargin )
%function rotrk_plot(header,tracts, volume, sortedby,limit_to, header2, tracts2, header3, tracts3 )
% Inputs:
%    TRKS_IN:
%       TRKS_IN.header          -> struct/cell file header (*make sure this is larger
%       TRKDS_IN.tracts         -> struct/cell file strlines
%
%    volume         --> volume to be overlaid (optional, use '' if not
%                       needed. <Still needed to implement>)
%    sortedby       --> sorted by this variable (e.g. header.data.age, so put 'age')
%                       Here, more implementation is needed to change
%                       variable to other than age.
%    dx             --> limit to a specific input to the chosen Dx
%                       (e.g. header.data.dx, so put 'AD' or 'NC')
%    varargin       --> pass other tracts (e.g. TRKS_IN2, TRKS_IN3, ...)
% Outputs:
%    The plot :P


if nargin < 2
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
        local_rotrk_goplot(TRKS_IN)
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
                local_rotrk_goplot(TRKS_IN{plot_idx})
                title([ '\color{red}' strrep(TRKS_IN{plot_idx}.id,'_','\_')], 'Interpreter', 'tex')
                hold off
                plot_idx=plot_idx+1;
            end
        end
    end
    
    
else
    
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
            local_rotrk_goplot(TRKS_IN{plot_idx})
            for kk=1:numel(varargin) %--->Check how many more TRKS_in are being passed)
                for mm=1:numel(varargin{kk})
                    if strcmp(varargin{kk}{mm}.id,TRKS_IN{plot_idx}.id)
                        local_rotrk_goplot(varargin{kk}{mm})
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



%STARTING LOCAL FUNCTION
% Plot streamlines
function local_rotrk_goplot(single_TRKS_IN)
for numtrks = 1:size(single_TRKS_IN.sstr,2)
    matrix = single_TRKS_IN.sstr(numtrks).matrix;
    [maxpts, maxidx ]  = max(arrayfun(@(x) size(x.matrix, 1), single_TRKS_IN.sstr));
    
    if ~isfield(single_TRKS_IN,'plot_params') %if no .plot_params field, initialize params
        plot_color='r';
        orientation='xy';
    else
        plot_color=single_TRKS_IN.plot_params.color;
        orientation=single_TRKS_IN.plot_params.orientation;
    end
    %Check if single_TRKS_IN.plotparams exists (if not go with defaults...)
    hold on
    switch plot_color
        case 'rainbow'
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
            plot3(matrix(1,1), matrix(1,2), matrix(1,3), 'g.')
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
        view(-80,24)
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
%Reverse x-orientation so it looks like right is right in the image!
set(gca,'xdir','reverse'); shg
