classdef TextInputs < matlab.io.internal.FunctionInterface &...
        matlab.io.internal.shared.EncodingInput
    
    % Copyright 2018 The MathWorks, Inc.
    properties (Parameter)
        %DATALINES the lines in the text file where the data is located.
        % DataLines must be a non-negative scalar integer or a Nx2 array of
        % non-negative integers.
        DataLines = [1, inf];
        
        %VARIABLENAMELINE the line in the file that contains the variable
        % names.
        % VariableNamesLine must be a non-negative scalar integer.
        VariableNamesLine = 0;
        
        %ROWNAMESCOLUMN the column that contains row names describing the
        % data.
        % RowNamesColumn must be a non-negative scalar integer.
        RowNamesColumn = 0;
        
        %VARIABLEUNITSLINE the line in the file that contains the variable
        % units.
        % VariableUnitsLine must be a non-negative scalar integer.
        VariableUnitsLine = 0;
        
        %VARIABLEDESCRIPTIONSLINE the line in the file that contains the
        % variable descriptions.
        % VariableDescriptionsLine must be a non-negative scalar integer.
        VariableDescriptionsLine = 0;
        
        %EXTRACOLUMNSRULE what to do with extra columns of data that appear
        % after the expected variables.
        %
        %   Possible values:
        %       addvars: Create a new variable in the resulting table
        %                containing the data from the extra columns. The
        %                new variables are named 'ExtraVar1', 'ExtraVar2',
        %                etc..
        %
        %        ignore: Ignore the extra columns of data.
        %
        %          wrap: Wrap the extra columns of data to new records.
        %                This does not change the number of variables.
        %
        %         error: Error during import and abort the operation.
        ExtraColumnsRule = 'addvars';
        
        %EMPTYLINERULE what to do with empty lines in the file.
        %
        %   Possible values:
        %          skip: Skip empty lines.
        %
        %          read: Read empty lines as you would non-empty lines.
        %
        %         error: Error during import and abort the operation.
        EmptyLineRule = 'skip';
    end
    
    properties (Parameter, Dependent)
        %WHITESPACE Characters to be treated as whitespace
        % See Also matlab.io.TextVariableImportOptions/WhitespaceRule
        Whitespace
        
        %LINEENDING Symbol(s) which indicate the end of a line.
        LineEnding
        
        %COMMENTSTYLE Symbol(s) designating text to ignore.
        % Specify a single string (such as '%') to ignore characters
        % following the string on the same line. Specify a cell array of
        % two strings (such as {'/*', '*/'}) to ignore characters between
        % the strings. Comments are only checked at the start of each
        % field, not within a field.
        CommentStyle
    end
    
    properties (Parameter, Dependent, Hidden)
        DataLine
    end
    
    properties (Access = private)
        % This contains interpreted characters, not the escape sequences
        whtspc_ = sprintf('\b\t ');
        eol_ = {newline,char(13),char([13 10])};
        comments_ = {};
    end

    % Getters and Setters
    methods
        function opts = set.DataLines(opts,rhs)
        if isscalar(rhs)
            try
                opts.DataLines = validateLineNumber(rhs);
            catch ME
                error(message('MATLAB:textio:io:InvalidDataLines'));
            end
        else
            if ~isnumeric(rhs)
                error(message('MATLAB:textio:io:InvalidDataLines'));
            end
            try
                opts.DataLines = matlab.io.internal.validators.validateLineIntervals(rhs,'DataLines');
            catch ME
                throwAsCaller(ME);
            end
        end
        end
        
        function opts = set.VariableNamesLine(opts,rhs)
        try
            opts.VariableNamesLine = validateLineNumber(rhs);
        catch ME
            throwAsCaller(ME);
        end
        end
        
        function opts = set.RowNamesColumn(opts,rhs)
        n = validateLineNumber(rhs);
        n = setRowNamesColumn(opts,n);
        opts.RowNamesColumn = n;
        end  
        
        function opts = set.VariableUnitsLine(opts,rhs)
        try
            opts.VariableUnitsLine = validateLineNumber(rhs);
        catch ME
            throwAsCaller(ME);
        end
        end
        
        function opts = set.VariableDescriptionsLine(opts,rhs)
        try
            opts.VariableDescriptionsLine = validateLineNumber(rhs);
        catch ME
            throwAsCaller(ME);
        end
        end
        
        function opts = set.ExtraColumnsRule(opts,rhs)
        try
            opts.ExtraColumnsRule = validatestring(rhs,{'addvars','ignore','wrap','error'});
        catch ME
            throwAsCaller(ME);
        end
        end
        
        function opts = set.EmptyLineRule(opts,rhs)
        try
            opts.EmptyLineRule = validatestring(rhs,{'skip','read','error'});
        catch ME
            throwAsCaller(ME)
        end
        end
        
        function opts = set.DataLine(opts,rhs)
        opts.DataLines = rhs;
        end
        
        function lhs = get.DataLine(opts)
        lhs = opts.DataLines;
        end
        function obj = set.Whitespace(obj,whitespace)
        whitespace = convertStringsToChars(whitespace);
        whitespace = matlab.io.internal.utility.validateAndEscapeStrings(whitespace,'Whitespace');
        obj.whtspc_ = unique(whitespace);
        end
        
        function whitespace = get.Whitespace(obj)
        % Array might be row or column, don't bother trying to
        % keep the state fixed as a column, but reorient it on return.
        % This will always produce a row.
        whitespace = matlab.io.internal.utility.unescape(obj.whtspc_(:)');
        end
        
        function opts = set.LineEnding(opts,rhs)
        rhs = convertStringsToChars(rhs);
        rhs = matlab.io.internal.utility.validateAndEscapeCellStrings(rhs,'LineEnding');
        opts.eol_ = unique(rhs);
        end
        
        function val = get.LineEnding(opts)
        val = matlab.io.internal.utility.unescape(opts.eol_(:))';
        end
        
        function opts = set.CommentStyle(opts,rhs)
            rhs = convertStringsToChars(rhs);
            rhs = matlab.io.internal.utility.validateAndEscapeCellStrings(rhs,'CommentStyle');
            if numel(rhs) > 2
                error(message('MATLAB:textscan:NonStringCellsInCommentStyle'))
            end
            opts.comments_ = rhs;
        end
        
        function val = get.CommentStyle(opts)
            val = matlab.io.internal.utility.unescape(opts.comments_);
        end
    end
end

function rhs = validateLineNumber(rhs)
if ~isnumeric(rhs) || ~isscalar(rhs) || floor(rhs) ~= rhs || rhs < 0 || isinf(rhs)
    error(message('MATLAB:textio:textio:ExpectedScalarInt'));
end
rhs = double(rhs);
end
