classdef VarOptsInputs < matlab.io.internal.FunctionInterface ...
        & matlab.io.internal.shared.TreatAsMissingInput ...
        & matlab.io.internal.shared.CommonVarOpts
    %VARIABLEOPTIONSINPUTS Summary of this class goes here
    %   Detailed explanation goes here

%   Copyright 2018 The MathWorks, Inc.
    
    properties (Access = private)
        Name_ = '';
    end
    
    properties (Parameter, Dependent)
        %NAME
        %   Name of the variable to be imported. Must be a valid identifier.
        %
        % See also matlab.io.VariableImportOptions
        Name
    end
    
    properties (Parameter)
        %TYPE
        %   The input type of the variable when imported.
        %
        % See also matlab.io.VariableImportOptions
        Type
        
        %FILLVALUE
        %   Used as a replacement value when ErrorRule = 'fill' or
        %   MissingRule = 'fill'. The valid types depend on the value of TYPE.
        %
        % See also matlab.io.VariableImportOptions
        %   matlab.io.spreadsheet.SpreadsheetImportOptions/MissingRule
        %   matlab.io.spreadsheet.SpreadsheetImportOptions/ImportErrorRule
        %   matlab.io.VariableImportOptions/Type
        FillValue
    end
    % get/set functions
    methods    
        function obj = set.Name(obj,rhs)
        rhs = convertCharsToStrings(rhs);
        if ~(isstring(rhs) && isscalar(rhs))
            error(message('MATLAB:textio:textio:InvalidStringProperty','Name'));
        end
        if ~isvarname(rhs)
            error(message('MATLAB:table:VariableNameNotValidIdentifier',rhs));
        end
        obj.Name_ = char(rhs);
        end
        
        function val = get.Name(opts)
        val = opts.Name_;
        end
                
        function obj = set.Type(obj,val)
        obj.Type = setType(obj,val);
        end
        
        function val = get.Type(obj)
        val = getType(obj,obj.Type);
        end
        function obj = set.FillValue(obj,val)
        obj.FillValue = setFillValue(obj,val);
        end
        
        function val = get.FillValue(obj)
        % Converts to the correct type
        val = getFillValue(obj,obj.FillValue);
        end
    end
    
    methods (Hidden, Sealed)
        function opts = setNames(opts,names)
        % avoid validating names
        if ~isempty(names)
            ids = ~strcmp(names,{opts.Name_});
            [opts(ids).Name_] = names{ids};
        end
        end
        function names = getNames(opts)
        % avoid validating names
        names = {opts.Name_};
        end
    end
    
    methods (Abstract,Access = protected)
        type = setType(obj,val);
        type = getType(obj,val);
        val = setFillValue(obj,val);
        val = getFillValue(obj,val);
    end
    
    methods (Static)
        function validateFixedType(name,type,rhs)
        import matlab.io.internal.supportedTypeNames
        rhs = convertCharsToStrings(rhs);
        if ~isstring(rhs) || ~any(strcmp(supportedTypeNames,rhs))
            error(message('MATLAB:textio:io:NotDataType'));
        end
        newMsg = [getString(message('MATLAB:textio:io:StaticOptionsType',type)), ...
            '\n\n',getString(message('MATLAB:textio:io:Setdatatype')), '\n', ...
            getString(message('MATLAB:textio:io:SetvartypeSyntax',name,rhs))];
        throw(MException('MATLAB:textio:io:StaticOptionsType',newMsg));
        end
    end
end
