function opts = delimitedTextImportOptions(varargin)
%Create options for importing delimited text data
% opts = delimitedTextImportOptions('Prop1',val1,'Prop2',val2,...) creates
%        options for importing a delimited text file.
%
%   DelimitedTextImportOptions Properties:
%
%                     DataLines - The lines in the text file where the data is located.
%             VariableNamesLine - Where the variable names are located
%                RowNamesColumn - Where the row names are located
%             VariableUnitsLine - Where the variable units are located
%      VariableDescriptionsLine - Where the variable descriptions are located
%                 VariableNames - Names of the variables in the file
%         SelectedVariableNames - Names of the variables to be imported
%                 VariableTypes - The import types of the variables
%               VariableOptions - Advanced options for variable import
%               ImportErrorRule - Rules for interpreting nonconvertible or bad data
%                   MissingRule - Rules for interpreting missing or unavailable data
%              ExtraColumnsRule - what to do with extra columns of data that appear
%                                 after the expected variables
%     ConsecutiveDelimitersRule - what to do with consecutive
%                                 delimiters that appear in the file
%         LeadingDelimitersRule - what to do with delimiters at the beginning of a
%                                 line
%                 EmptyLineRule - what to do with empty lines in the file
%                    Delimiter  - Symbol(s) indicating the end of data fields in the
%                                 file
%                    Whitespace - characters to be treated as whitespace.
%                    LineEnding - Symbol(s) indicating the end of a line in the file
%                  CommentStyle - Symbol(s) designating text to ignore
%                      Encoding - Text encoding of the file to be imported
%                   NumVariables - The number of variables to import
%
% See Also
%   detectImportOptions, readtable,
%   matlab.io.text.DelimitedTextImportOptions

% Copyright 2018 MathWorks, Inc.

opts = matlab.io.text.DelimitedTextImportOptions(varargin{:});
end

