
classdef  hoqc_LOG < handle
    
    %{
    examples of use:  
    mylog = hoqc_LOG('logje.txt','reset',true) ;        % log to file, reset, close after each write
    mylog.set_types('info',false);                      % do not show INFO messages
    mylog.write('info', ...                             % message will not be shown (see prev. line)
        'function %s called input %7.3f','f1',exp(1));
    mylog.write('xxx', ...                              % message will not be shown (unknown type:
        'function %s called input %7.3f','f2',exp(2));  % i.e not one of INFO, DEBUG or ERROR 
    mylog.write('debug', ...                            % message will be shown (default for 
        'function %s called input %7.3f','f3',exp(3));  % INFO, DEBUG and ERROR is true) 
    mylog.set_types('info',true,'xxx',true);            % show INFO and XXX messages
    mylog.write('info', ...                             % message will now be shown     
        'function %s called input %7.3f','f4',exp(4));  
    mylog.write('xxx', ...                              % message will now be shown     
        'function %s called input %7.3f','f5',exp(5));
    mylog.closefile()                                   % close logfile
    %}
    
    properties (GetAccess = private, Constant = true)
        version = '0.1' ;
    end
    
    properties (GetAccess = private)
        logfile     = '' ;                              % name logfile (set by constructor)
        logopen     = 0 ;                               % file handle logfile (set by constructor)
        cl_aw       = false ;                           % close after write? (set by constructor)
        ts          = true ;                            % timestamp to insert? (set by constructor)
        msg_types   = {} ;                              % message types (set by set_types)
        msg_tf      = true ;                            % display types? (set by set_types)
    end
    
    methods (Access = public)
        
        function obj = hoqc_LOG(varargin)               % constructor
            p = inputParser;
            addRequired(p,'logfile',@ischar);           % name logfile
            addParameter(p,'reset',false,@islogical) ;  % reset logfile ?
            addParameter(p,'cl_aw',false,@islogical) ;  % close after write?
            addParameter(p,'ts',true,@islogical) ;      % timestamp to insert?
            parse(p,varargin{:})                        % parse inputs
            obj.logfile     = p.Results.logfile ;       % name logfile
            obj.logopen     = 0 ;                       % file handle 0 (not open yet)
            reset           = p.Results.reset ;         % reset logfile ?
            obj.cl_aw       = p.Results.cl_aw ;         % close after write?
            obj.ts          = p.Results.ts ;            % timestamp to insert?
            obj.msg_types   = {'info','debug','error'}; % message types
            obj.msg_tf      = {true, true, true};       % display types ?
            if reset && numel(obj.logfile) > 0
                writefile(obj,'',reset)                 % reset (empty) logfile
            end
        end
        function version = getversion(obj)
            version = obj.version;
        end
        function logfile = getlogfile(obj)
            logfile = obj.logfile;
        end
        function set_types(obj,varargin)                % indicate which types will be printed
            types   = varargin ;
            ntypes  = numel(types);
            if ntypes == 0, return, end
            if mod(numel(types),2) == 1
                error('hoqc_LOG.set_types: not enough arguments')
            end
            for i=1:numel(types)/2
                set_type(obj, ...                       % set set type to false or true
                    types{2*i-1},types{2*i});
            end
        end        
        function tf = get_type(obj,type)                % inquire if type will be printed
            type    = lower(type);                      % argument to lower case
            [~,ix]  = ismember(type,obj.msg_types) ;    % lookup
            if ix == 0
                tf  = false ;                           % not found: not to print
            else
                tf  = obj.msg_tf{ix} ;                  % found: return boolean
            end
        end
        function write(obj,type,msg,varargin)           % write message (if type fits)
            if get_type(obj,type) == false
                return;
            end
            if obj.ts == true
                dt  = datestr(now, ...                  % formatted current time
                    'yyyy-mm-dd HH:MM:SS.FFF');
            else
                dt  = '' ;                              % no date_time included in message
            end
            msg_out = sprintf('%-7s%s - %s', ...        % combine type, timestamp and message
                upper(type),dt,msg) ;
            if numel(varargin) ~= sum(msg_out=='%')     % arguments correspond with message?
                error(['hoqc_LOG.write: ', ...          % display error if not
                    'incorrect number of arguments'])
            else
                msg_out=sprintf(msg_out,varargin{:}) ;  % insert arguments in message
            end
            if numel(obj.logfile) == 0
                fprintf('%s\n',msg_out);
            else
                writefile(obj,msg_out) ;
            end
        end        
        function closefile(obj)
            if obj.logopen > 0
                fclose(obj.logopen);
            end
            obj.logopen = 0;
        end
        
    end
    
    methods (Access = private)
        
        function set_type(obj,type1,tf1)                % indicate which types will be printed
            [~,ix] = ismember(type1,obj.msg_types) ;
            if ix > 0
                obj.msg_tf{ix} = tf1;                   % type1 found: change boolean
            else
                obj.msg_types = [obj.msg_types, type1]; % add type1 to array
                obj.msg_tf    = [obj.msg_tf, tf1];      % with corresponding boolean
            end
        end
        function writefile(obj,msg,varargin)
            defoptArgs      =  {false} ;                % default values for reset
            optArgs         =  ...                      % merge specified and default values
                hoqc_LOG.setOptArgs(varargin,defoptArgs) ;
            reset           = optArgs{1} ;              % reset file (t) or append (f)
            if reset
                oparm       = 'wt' ;                    % reset
            else
                oparm       = 'at' ;                    % append
            end
            if obj.logopen == 0
                obj.logopen = fopen(obj.logfile,oparm);
                if obj.logopen == 0
                    error(['hoqc_LOG.write: ', ...      % display error if file could not be opened
                        'file %s could not be opened'], ...
                        obj.logfile)
                end
            end
            if reset == false
                fprintf(obj.logopen,'%s\n',msg);
            end
            if reset || (obj.cl_aw == true)
                closefile(obj);
            end
        end
        
    end
    
    methods (Static, Access = private)
        
        function defArgs = setOptArgs(a,defArgs)
            % set non-specified optional parameters to default values
            % idea from Omid Khanmohamadi on matlabcentral
            
            % a         : arguments passed with varargin
            % defArgs   : on input default arguments
            %             on output default argument overwritten by the specified ones (if not empty)
            
            empty_a = cellfun(@(x)isequal(x,[]),a);     % indicate a that are not specified (empty)
            [defArgs{~empty_a}] = a{~empty_a};          % replace defaults by non-empty one
        end
        
    end
    
end
