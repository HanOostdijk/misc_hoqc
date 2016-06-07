%% 
%% Introduction
% This document shows how to use the hoqc_LOG class.
% With this class the programmer can write messages to a 
% separate logfile or to standard output (the screen).
%% Features
% 
% * choice between separate logfile or standard output.
% * the logfile can be reset (emptied) before the first write if that is desired.
% * the logfile can be closed after every write if that is desired. Useful for long running jobs. 
% * a timestamp can be included in the message if that is desired.
% * various message types can be distinguished and (temporarily) shown or hidden.
% * the message can be formatted from a template with variable parts.
%
% These options are set when the log object is created (with the exception of the
% settings of the message types). 
%% Constructor arguments
% * Argument 1 
% of the constructor gives the name of the logfile. The default |''| 
% indicates the screen.
% * the |reset| (default |false|) argument indicates that the 
% logfile will be reset (emptied) before the first write. 
% * the |cl_aw| (default |false|) argument indicates that the 
% logfile will be closed after every write. Useful for long running jobs 
% * the |ts| (default |true|) argument indicates that a timestamp  
% will be included in the message 
%% Examples logging to screen
% In this section we will write log messages to the screen.
% Because we did not specify |ts| we will use its default (|true|)
% and therefore a timestamp is included.
% By default the standard types (|info|, |debug| and |error|) are shown, 
% but as an example we will now hide the |INFO| messages. 
% Because the |XXX| type 
% is non-standard it is by default not shown and therefore 
% only the |DEBUG| message is shown in this section:
mylog  = hoqc_LOG('') ;      
mylog.set_types('info',false);    
mylog.write('info', ...  
	'function %s called with input %7.3f','f1',exp(1));
mylog.write('xxx', ...   
	'function %s called with input %7.3f','f2',exp(2)); 
mylog.write('debug', ...  
	'function %s called with input %7.3f','f3',exp(3));
%%
% Only after using the |set_types| function for |INFO| and |XXX|
% messages of these types are show in the log:
mylog.set_types('info',true,'xxx',true);          
mylog.write('info', ...  
	'function %s called with input %7.3f','f4',exp(4)); 
mylog.write('xxx', ... 
	'function %s called with input %7.3f','f5',exp(5)); 
%%
% An example of logging without a timestamp and a preformatted message.
mylog  = hoqc_LOG('','ts',false) ; 
mymsg  = 'function xxx is not called';
mylog.write('info', mymsg);
%% Examples logging to external log file
% All possibilities of logging to screen are also available for logging to an external file.
% The only difference is that the first argument of the constructur should contain the name of a
% file that may or may not exist. In addition to the options already discussed there are two
% options only applicable for an external log file:
%%
% * |reset| : when set to |true| it indicates that the log file will be reset (emptied) before writing
% the first message. The default is |false| and in that case the messages will be written at the end of
% (appended to) the log file. 
% * |cl_aw| : when set to |true| it indicates that the log file will be closed after every write. 
% This is useful for long running jobs. The default is |false| and in that case the log file 
% has to be closed with the |closefile| function to be able to read the messages in the file.
% 
% In the first example we use the default options for an external log file by specifying only the filename. 
% Starting with an empty file and looking at the log file just before the 'second close' we will see 
% just 'line 1'. Just after the 'second close' we will see 'line 1' and 'line 2'.  
%
% Viewing the log file after the 'third close' we will see only 'line 3': because of the |reset| argument
% after opening the file it was reset (emptied) before writing 'line 3'. By opening the log file with the
% |cl_aw| argument the file is closed after each write and therefore we see 'line 4' (and 'line 3') 
% already before 'fourth close': the file was closed immediately after writing the message.
mylog1 = hoqc_LOG('log.txt') ;        
mylog1.write('info', ...        
  	'line 1'); 
mylog1.closefile() ; % first close  
mylog1 = hoqc_LOG('log.txt') ;        
mylog1.write('info', ...        
  	'line 2'); 
% view the log file first time: only 'line 1' visible
mylog1.closefile() ; % second close 
% view the log file second time: both 'line 1' and 'line 2' visible
mylog1 = hoqc_LOG('log.txt','reset',true) ;        
mylog1.write('info', ...        
  	'line 3'); 
mylog1.closefile() ; % third close  
% view the log file third time: only 'line 3' visible
mylog1 = hoqc_LOG('log.txt','cl_aw',true) ;        
mylog1.write('info', ...        
  	'line 4'); 
% view the log file fourth time: both 'line 3' and 'line 4' visible
mylog1.closefile() ; % fourth close  

%% Listings
%% 
% <latex>
% \lstinputlisting[caption=hoqc\_LOG.m]{../hoqc_LOG.m}
% </latex>
