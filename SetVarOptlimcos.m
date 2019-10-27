classdef SetVarOpts < matlab.io.internal.functions.AcceptsImportOptions ...
        & matlab.io.internal.shared.CategoricalVarOptsInputs ...
        & matlab.io.internal.shared.DatetimeVarOptsInputs ...
        & matlab.io.internal.shared.DurationVarOptsInputs ...
        & matlab.io.internal.shared.LogicalVarOptsInputs ...
        & matlab.io.internal.shared.NumericVarOptsInputs ...
        & matlab.io.internal.shared.TextVarOptsInputs ...
        & matlab.io.internal.shared.VarOptsInputs ...
        & matlab.io.internal.functions.ExecutableFunction
    %SETVAROPTS Executable setvaropts function
%

%   Copyright 2018 The MathWorks, Inc.

    properties (Required)
        Selection = false;
    end
    
    methods
        function func = set.Selection(func,rhs)
        rhs = convertCharsToStrings(rhs);
        if isempty(rhs) % select all
            func.Selection(1:numel(func.Options.VariableNames)) = true;
        elseif isstring(rhs) % a variable name
            if isscalar(rhs) && rhs == ":" % select all
                idx = 1:numel(func.Options.VariableNames);
            else
                % Pick only the variables which match, if any are unknown,
                % error
                [isElem,idx] = ismember(rhs,func.Options.VariableNames);
                if any(~isElem,'all')
                    error(message('MATLAB:textio:io:UnknownVarName',rhs{find(~isElem,1)}));
                end
            end
            func.Selection(idx(:)) = true;
        elseif isnumeric(rhs)
            n = numel(func.Options.VariableNames);
            if any(rhs > n,'all') || any(rhs < 1,'all')
                if n == 0 % The error is confusing if there aren't variables in the object
                    error(message('MATLAB:textio:io:NoVariablesAvailable'))
                else
                    error(message('MATLAB:textio:io:BadNumericSelection'))
                end
            end
            % change numbers to logical
            func.Selection(rhs(:)) = true;
        elseif islogical(rhs) && (numel(rhs) <= numel(func.Options.VariableNames))
            func.Selection = rhs(:)';
        else
            error(message('MATLAB:textio:io:BadSelectionInput'));
        end
        end
        
        function names = usingRequired(~)
        names = ["Options","Selection"];
        end
    end
    
    methods
        function opts = execute(func,supplied)
        if supplied.Name
            error(message('MATLAB:textio:io:SetVarOptsThroughProperty','Name','opts.VariableNames(...) = newnames'));
        end
        varopts = func.Options.VariableOptions(func.Selection);
        supplied = rmfield(supplied,func.RequiredNames);
        varopts = func.tryAssign(varopts,supplied);
        
        opts = func.Options;
        opts.VariableOptions(func.Selection) = varopts;
        end
        
        function [varargout] = validateAndExecute(func,varargin)
        [func, supplied] = validate(func,varargin{:});
        [varargout{1:nargout}] = func.execute(supplied);
        end
        
        function [func, supplied, additionalArgs] = validate(func,varargin)
        if mod(numel(varargin),2)~=0 % setvaropts(opts,nv-pairs...)
            % If the second arg was a valid selection, then either there
            % weren't enough values for the parameters, or one of the
            % parameter names is also a valid variable name. In the latter
            % case, we prefer to treat the input as a selection as the only
            % way to get the correct behavior is to specify a selection.
            func.Options = varargin{1};
            try
                % if there's an issue with the number or types of NV
                % pairs, catch that error here.
                func.Selection = varargin{2};
                hadSelection = true;
            catch
                hadSelection = false;
                varargin = {varargin{1},[],varargin{2:end}};
            end
            
            if hadSelection
                if isstring(convertCharsToStrings(varargin{end}))
                    error(message('MATLAB:textio:io:MissingOptionValue',varargin{end}));
                else
                    error(message('MATLAB:InputParser:ParamMustBeChar'));
                end
            end

        end
        matlab.io.internal.validators.validateNVPairs(varargin{3:end});
        [func, supplied, additionalArgs] = validate@matlab.io.internal.functions.ExecutableFunction(func,varargin{:});
        end
        
    end
    
    methods (Access = private)
        function varopts = tryAssign(func,varopts,supplied)
        names = string(fieldnames(supplied));
        try
            for n = names(:)'
                if supplied.(n)
                    [varopts.(n)] = deal(func.(n));
                end
            end
        catch ME
            switch ME.identifier % If the property doesn't exist for every variable, then error.
                case {'MATLAB:mustBeFieldName','MATLAB:noPublicFieldForClass'}
                    if n ~= names(1)
                        error(message('MATLAB:textio:io:NoValueForNamedOrNumbered',n))
                    else
                        error(message('MATLAB:textio:io:OptionNotAvailableForType',n));
                    end
            end
            rethrow(ME)
        end
        end
    end
    methods (Access = protected)
        function rhs = setInputFormat(~,rhs)
        end
        function val = getFillValue(~,val)
        end
        function val = setFillValue(~,val)
        end
        function val = setType(~,~) %#ok<STOUT>
        error(message('MATLAB:textio:io:SetVarOptsThroughProperty','Type','opts = setvartype(opts,...,type)'));
        end
        function val = getType(~,val)
        end
    end
end

