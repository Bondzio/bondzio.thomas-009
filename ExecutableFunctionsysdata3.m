classdef ExecutableFunction <  matlab.io.internal.FunctionInterface & matlab.mixin.CustomDisplay
    %EXECUTABLEFUNCTION A mixin which defines an executable function
 
    % Copyright 2018 MathWorks, Inc.
    properties (SetAccess = private, GetAccess = protected, Transient)
        SuppliedStruct
        ParameterNames
        RequiredNames
        Aliases = struct();
        Parser
    end
    
    properties (SetAccess = immutable, GetAccess = protected, Dependent)
        NumRequired
    end
    
    methods 
        %%
        function func = ExecutableFunction()
        % inspect the meta class of this instance for required and
        % parameter inputs
        me = metaclass(func);
        isParam = [me.PropertyList.Parameter];
        isRequired = [me.PropertyList.Required];

        names = string({me.PropertyList.Name});
        allArguments = names(isParam|isRequired);
        
        % assign the default fields of the supplied struct.
        suppliedStruct = struct;
        for i = 1:numel(allArguments)
            suppliedStruct.(allArguments(i)) = false;
        end
        func.SuppliedStruct = suppliedStruct;
        
        % required parameters must be supplied.
        requiredNames = names(isRequired);
        for n = requiredNames
            suppliedStruct.(n) = true;
        end
        func.RequiredNames = requiredNames;
        
        % create the NV pair parser.
        parameterNames = names(isParam);
        
        func.Parser = matlab.io.internal.validators.ArgumentParser(parameterNames,func.getAliases());
        func.ParameterNames = parameterNames;
        end
        
        %% 
        function [func, supplied, additionalArgs, results] = validateArguments(func,varargin)
        %validate input arguments
        parser = func.Parser;
        supplied = func.SuppliedStruct;
        
        % Process Required Names in order
        numReq = func.NumRequired;
        reqNames = func.usingRequired();
        for i = 1:numReq
            name = reqNames(i);
            func.(name) = varargin{i};
            supplied.(name) = true;
        end
        
        % get only the NV pairs
        params = varargin(numReq+1:end);
        if ~isempty(params)
            [params{1:2:end}] = convertStringsToChars(params{1:2:end});
            % resolve partial matches
            results = parser.canonicalizeNames(params(1:2:end));
            params(1:2:end) = cellstr(results.CanonicalNames);
            % get the argument struct
        else
            results = parser.canonicalizeNames({});
        end
        [paramStruct,additionalArgs] = parser.extractArgs(params{:});
        
        % assign parameter values to object
        paramnames = fieldnames(paramStruct);
        for i = 1:numel(paramnames)
            name = paramnames{i};
            func.(name) = paramStruct.(name); % validate by object setter
            supplied.(name) = true;
        end
        end
        
        function names = usingRequired(func)
        names = func.RequiredNames;
        end
    end
    
    methods 
        %%
        function [varargout] = validateAndExecute(func,varargin)
        % Do standard validation, and then execute.
        matlab.io.internal.validators.validateNVPairs(varargin{func.NumRequired+1:end});
        [func, supplied, additionalArgs] = func.validate(varargin{:});
        [varargout{1:nargout}] = func.execute(supplied,additionalArgs{:});
        end
        
        %%
        function [func, supplied, additionalArgs] = validate(func,varargin)
        [func, supplied, additionalArgs, results] = func.validateArguments(varargin{:});

        if ~isempty(results.AmbiguousMatch)
            error(message('MATLAB:table:parseArgs:AmbiguousParamName',varargin{func.NumRequired+2*results.AmbiguousMatch(1).idx - 1}))
        end
        if ~isempty(additionalArgs)
            error(message('MATLAB:textio:textio:UnknownParameter',additionalArgs{1}))
        end
        end
        
        function val = get.NumRequired(func)
            val = numel(func.usingRequired());
        end
        
        function v = getAliases(~)
        v = {};
        end
    end
    methods (Access=protected)
        function header = getHeader(obj)
        if ~isscalar(obj)
            header = getHeader@matlab.mixin.CustomDisplay(obj);
        else
            header = matlab.mixin.CustomDisplay.getClassNameForHeader(obj);
            header = ['  ExecutableFunction: ' header newline];
        end
        end
        
        function groups = getPropertyGroups(obj)
        if ~isscalar(obj)
            groups = getPropertyGroups@matlab.mixin.CustomDisplay(obj);
        else
            % Get Required
            groups = matlab.mixin.util.PropertyGroup.empty();
            groups = getPropGroupFromNames('Required Inputs:',groups,obj,obj.RequiredNames);
            % Get Parameters
            groups = getPropGroupFromNames('Parameter (Name-Value Pair) Inputs:',groups,obj,obj.ParameterNames);
            % Get Non-Inputs
            n = setdiff(properties(obj),[obj.RequiredNames, obj.ParameterNames, fieldnames(obj.Aliases)']);
            groups= getPropGroupFromNames('Non-Input Properties:',groups,obj,n);
        end
        end
    end
    methods (Abstract)
        [varargout] = execute(func,supplied,varargin);
    end
    methods (Access=protected)
        function s = obj2struct(func,supplied)
        s = struct();
        for n = fieldnames(supplied)'
            if supplied.(n{1})
                s.(n{1}) = func.(n{1});
            end
        end
        end
    end
end

function groups = getPropGroupFromNames(title,groups,func,names)
if numel(names) > 0
    s = struct();
    for i = 1:numel(names)
        s.(names{i}) = func.(names{i});
    end
    groups(end+1) = matlab.mixin.util.PropertyGroup(s,title);
end
end
