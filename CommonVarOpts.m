classdef CommonVarOpts < matlab.io.internal.FunctionInterface
    %COMMONVAROPTS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Parameter)
        %QUOTERULE
        %   How surrounding quotes in text should be treated.
        %
        %   'remove' - If converting from text, and the field begins with a double
        %              quotation mark ("), omit the leading quotation mark and its
        %              accompanying closing mark, which is the second instance of a
        %              lone double quotation mark. Replace escaped double quotation
        %              marks (for example, ""abc"") with lone double quotation
        %              marks ("abc"). Ignore any double quotation marks that appear
        %              after the closing double quotation mark.
        %
        %   'keep'   - retain all quote marks. NOTE: This may cause conversion to
        %              fail for some types.
        %
        %   'error'  - Report an error when converting data which begins with a
        %              double-quote character ("). Use this setting if the field
        %              should never be quoted.
        %
        % See also matlab.io.VariableImportOptions
        QuoteRule = 'remove';
        
        %PREFIXES
        %   A cell array of character vectors or a string vector containing
        %   the prefix characters that need to be removed from the
        %   variable on import.
        %
        % See also matlab.io.VariableImportOptions
        Prefixes = {};
        
        %SUFFIXES
        %   A cell array of character vectors or a string vector containing
        %   the suffix characters that need to be removed from the
        %   variable on import.
        %
        % See also matlab.io.VariableImportOptions
        Suffixes = {};
        
        %EMPTYFIELDRULE Procedure to manage empty variable fields
        %
        %   'missing' - treat empty fields as missing data and follow the
        %               procedure specified in the MissingRule property.
        %
        %   'error'   - treat empty fields as import errors and follow the
        %               procedure specified in the ImportErorrRule
        %               property.
        %
        %   'auto'    - convert empty fields to type-specific values.
        %               For example, when variable is of type:
        %
        %               text                 - import as zero length char
        %                                      or string
        %               numeric:
        %                  1) floating-point - import as NaN
        %                  2) integer        - import as 0
        %               duration             - import as NaN
        %               categorical          - import as <undefined>
        %               datetime             - import as NaT
        %               logical              - import as false
        %
        % See also matlab.io.VariableImportOptions
        %   matlab.io.spreadsheet.SpreadsheetImportOptions/ImportErrorRule
        %   matlab.io.VariableImportOptions/FillValue
        %   matlab.io.spreadsheet.SpreadsheetImportOptions/MissingRule
        EmptyFieldRule = 'missing';
    end
    
    methods
        function obj = set.QuoteRule(obj,rhs)
        obj.QuoteRule = validatestring(rhs,{'remove','keep','error'});
        end
        
        function obj = set.Prefixes(obj, val)
        obj.Prefixes = validateAndSortByLength(val,'MATLAB:textio:textio:InvalidPrefixes');
        end
        
        function obj = set.Suffixes(obj, val)
        obj.Suffixes = validateAndSortByLength(val,'MATLAB:textio:textio:InvalidSuffixes');
        end
        
        function obj = set.EmptyFieldRule(obj,rhs)
        obj.EmptyFieldRule = validatestring(rhs,{'missing','error','auto'});
        end
    end
end

function val = validateAndSortByLength(val,msgID)
val = convertCharsToStrings(val);
if ~isstring(val)
    error(message(msgID));
end
[~,idx] = sort(strlength(val),'descend');
val = cellstr(val(idx));
end