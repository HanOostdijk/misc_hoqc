addpath('D:/data/matlab/matlab_publish_latex/code')

%% example5: -> latex  
% same as example4 but now with a regular LaTeX contents 
% by setting 'maketableofcontents' to true
mycode = { ...                                          % example of code to execute (one line)  
            'demo_hoqc_LOG'   ...
            } ; 
pstruct = struct( ...                                   % publish options
    'format' , 'latex' , ...                            % output format latex using the new xsl file
    'call' , {mycode} , ...                             % code to execute (defined above)
    'newname' , 'demo_hoqc_LOG.tex' , ...             	% new name of output file  
    'first_preamble1','\renewcommand*{\familydefault}{\sfdefault}' , ...
    'last_preamble1','\definecolor{lightgray}{rgb}{0.1,0.2,1}' , ...
    'prettifier_options', 'framed,unnumbered', ...      % no numbering
    'pdftitle', 'Demo hoqc\_LOG', ...                    % pdf title
    'pdfauthor', 'han@hanoostdijk.nl' , ...         	% insert a pdf option    
    'orientation', 'landscape', ...                      % portrait or landscape 
    'title', 'Demo hoqc\_LOG', ...                       % title
    'author', 'Han Oostdijk (han@hanoostdijk.nl)', ... 	% auhor
    'maketitle', true , ...                             % create title
    'maketableofcontents', true , ...                   % create tableofcontents
    'makelstlistoflistings', true);                     % create lstlistoflistings
newname = publish_mpl('demo_hoqc_LOG', pstruct) ;     	% produce the output file (tex)    