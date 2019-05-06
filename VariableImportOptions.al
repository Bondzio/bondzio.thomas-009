classdef VariableImportOptions < matlab.io.internal.mixin.HasPropertiesAsNVPairs ...
        & matlab.mixin.CustomDisplay ...
        & matlab.mixin.Heterogeneous ...
        & matlab.io.internal.shared.VarOptsInputs
    %VARIABLEIMPORTOPTIONS Options for importing a variable from a file
    %
    %   VariableImportOptions Properties:
    %               Name - The name of the variable on import
    %               Type - The data type of the variable on import
    %          FillValue - A scalar value to fill missing or unconvertible data
    %     TreatAsMissing - Text which is used in a file to represent missing
    %                      data, e.g. 'NA'
    %     EmptyFieldRule - How to treat empty field data
    %          QuoteRule - How to treat quoted text.
    %           Prefixes - Prefix characters to be removed from variable on
    %                      import
    %           Suffixes - Suffix characters to be removed from variable on
    %                      import
    %
    % See also
    %   readtable, datastore, matlab.io.spreadsheet.SpreadsheetImportOptions
    %   matlab.io.TextVariableImportOptions
    %   matlab.io.NumericVariableImportOptions
    %   matlab.io.LogicalVariableImportOptions
    %   matlab.io.DatetimeVariableImportOptions
    %   matlab.io.DurationVariableImportOptions
    %   matlab.io.CategoricalVariableImportOptions
    
    % Copyright 2016-2018 The MathWorks, Inc.
    methods (Sealed)
        function tf = eq(a,b)
            tf = true;
            if ~strcmp(class(a),class(b))
                tf = false;
                return;
            end
            
            for i = 1:numel(b)
                equalVarOpts = strcmp(a.Type,b(i).Type)...
                    && all(strcmp(a.TreatAsMissing,b(i).TreatAsMissing))...
                    && strcmp(a.QuoteRule,b(i).QuoteRule)...
                    && all(strcmp(a.Prefixes,b(i).Prefixes))...
                    && all(strcmp(a.Suffixes,b(i).Suffixes))...
                    && strcmp(a.EmptyFieldRule,b(i).EmptyFieldRule)...
                    && compareVarProps(a,b(i));
                
                if ~equalVarOpts
                    tf = false;
                    return
                end
                
            end
        end
    end
    
    methods (Static, Sealed, Access = protected)
        function elem = getDefaultScalarElement()
            elem = matlab.io.TextVariableImportOptions();
        end
    end
    
    methods (Sealed, Access=?matlab.io.ImportOptions)
        function obj = overrideType(obj,idx,types)
            tf = ismember(types,matlab.io.internal.supportedTypeNames());
            
            if ~all(tf)
                error(message('MATLAB:textio:io:UnsupportedConversionType',types{find(~tf,1)}));
            end
            % Convert the selection to the requested types.
            for i = 1:numel(idx)
                obj(idx(i)) = convertOptsToType(obj(idx(i)),types{i});
            end
        end
    end
    % Custom Display Methods
    methods (Sealed, Access = protected)
        function propgrp = getPropertyGroups(obj)
            if ~isscalar(obj)
                propgrp = getPropertyGroups@matlab.mixin.CustomDisplay(obj);
            else
                props.Name            = obj.Name;
                props.Type            = obj.Type;
                props.FillValue       = obj.FillValue;
                props.TreatAsMissing  = obj.TreatAsMissing;
                props.QuoteRule       = obj.QuoteRule;
                props.Prefixes        = obj.Prefixes;
                props.Suffixes        = obj.Suffixes;
                props.EmptyFieldRule  = obj.EmptyFieldRule;
                
                propgrp(1) = matlab.mixin.util.PropertyGroup(props,'Variable Properties:');
                
                [type_specific,group_name] = obj.getTypedPropertyGroup();
                
                propgrp(2) = matlab.mixin.util.PropertyGroup(type_specific,group_name);
            end
        end
        
        function h = getHeader(obj)
            h = getHeader@matlab.mixin.CustomDisplay(obj);
        end
        
        function f = getFooter(obj)
            f = getFooter@matlab.mixin.CustomDisplay(obj);
        end
        
        function displayEmptyObject(obj)
            displayEmptyObject@matlab.mixin.CustomDisplay(obj);
        end
        
        function displayNonScalarObject(obj)
            
            try
                isdesktop = usejava('desktop') && desktop('-inuse');
            catch
                isdesktop = false;
            end
            
            if ~isrow(obj) || ~isdesktop
                displayNonScalarObject@matlab.mixin.CustomDisplay(obj);
                return;
            end
            
            if matlab.internal.display.isHot()
                name = '<a href="matlab:helpPopup matlab.io.VariableImportOptions" style="font-weight:bold">VariableImportOptions</a>';
            else
                name = 'VariableImportOptions';
            end
            
            propNames = {'Name';'Type';'FillValue';'TreatAsMissing';'EmptyFieldRule'; ...
                'QuoteRule';'Prefixes';'Suffixes'};
            s = struct(propNames{1},{obj.Name},propNames{2},{obj.Type},propNames{3},{obj.FillValue}, ...
                propNames{4},{obj.TreatAsMissing},propNames{5},{obj.EmptyFieldRule}, ...
                propNames{6},{obj.QuoteRule},propNames{7},{obj.Prefixes},propNames{8},{obj.Suffixes});
            displayVariableBody(obj,name,s);
            strHelpGetvaropts = '<a href="matlab:helpPopup getvaropts" style="font-weight:regular">getvaropts</a>';
            fprintf(['\n\t', getString(message('MATLAB:textio:io:GetvaroptsLink')), ' ',strHelpGetvaropts, '\n']);
        end
    end
    
    % For child class to do custom display
    methods (Abstract, Access = protected)
        [type_specific,group_name] = getTypedPropertyGroup(obj);
        tf = compareVarProps(a,b);
    end
    
    methods (Sealed, Hidden, Access = protected)
        function strs = handleQuotes(obj,strs)
            if strcmp(obj.QuoteRule,'keep')
                return
            end
            quoted = startsWith(strip(strs),'"');
            if any(quoted(:))
                if strcmp(obj.QuoteRule,'error')
                    error(message('MATLAB:textio:io:QuoteRuleErrorSpreadsheet',strs{find(quoted(:),1)}))
                else
                    strs(quoted) = regexprep(strs(quoted),'^(\s*)"(""|[^"])*"?','$1${strrep($2,''""'',''"'')}');
                end
            end
        end
    end
    
    methods (Sealed,Static,Hidden)
        function obj = getTypedOptionsByName(newType)
            switch newType
                case {'double','single','int8','uint8','int16','uint16','int32','uint32','int64','uint64'}
                    obj = matlab.io.NumericVariableImportOptions('Type',newType);
                case {'char','string'}
                    obj = matlab.io.TextVariableImportOptions('Type',newType);
                case 'datetime'
                    obj = matlab.io.DatetimeVariableImportOptions();
                case 'duration'
                    obj = matlab.io.DurationVariableImportOptions();
                case 'categorical'
                    obj = matlab.io.CategoricalVariableImportOptions();
                case 'logical'
                    obj = matlab.io.LogicalVariableImportOptions();
                otherwise
                    assert(false);
            end
        end
    end
    
    methods (Access = private)
        function obj = convertOptsToType(obj,type)
            % Set the shared properties
            persistent sharedProperties
            if isempty(sharedProperties)
                meta = ?matlab.io.VariableImportOptions;
                sharedProperties = setdiff({meta.PropertyList.Name},["Type","FillValue"]);
            end
            
            try
                obj.Type = type;
            catch
                oldobj = obj;
                % First get an object of the new type
                obj = matlab.io.VariableImportOptions.getTypedOptionsByName(type);
                % Assign old properties into new properties.
                for p = sharedProperties
                    obj.(p{:}) =  oldobj.(p{:});
                end
            end
        end
    end
    
end

function d = displayVariableBody(obj,name,s)
% using message catalog to display the variable options
d = "  1x";
fprintf('  %s\n\n   Variable Options:\n',getString(message('MATLAB:ObjectText:DISPLAY_AND_DETAILS_ARRAY_WITH_PROPS', d + numel(obj),name)));
fields = fieldnames(s);

C = permute(struct2cell(s),[1,3,2]);
% for cell variables, we want to keep the {}
classes = cellfun(@class,C,'UniformOutput',false);

% convert cell to string
isEmptyCell = cellfun(@isempty,C);
C(isEmptyCell) = {''};
% any cell of size > 1 needs to be converted to char array before
% converting to string
idx = cellfun(@iscellstr,C);
idx = find(idx == 1);
prodSymb = matlab.internal.display.getDimensionSpecifier;
singleCells = zeros(numel(idx),1);
for ii = 1 : numel(idx)
    [m,n] = size(C{idx(ii)});
    if m == 1 && n == 1
        singleCells(ii) = idx(ii);
        C{idx(ii)} = ['', C{idx(ii)}{1},''];
    else
        C{idx(ii)} = ['',num2str(m), prodSymb, num2str(n),' cell'];
    end
end
singleCells(singleCells == 0) = [];
C = string(C);

% truncate Names, FillValue scalar values, TreatAsMissing scalar
% values, Prefix scalar values, Suffix scalar values to 30 characters,
% and replace newline characters with their display equivalent
idx = [find(contains(C,{newline,char(13)})); find(strlength(C) > 30)];
for ii = 1 : numel(idx)
    C(idx(ii)) = matlab.internal.display.truncateLine(C(idx(ii)),30);
end

C(singleCells) = "'" + C(singleCells) + "'";
C(classes == "cell") = "{" + C(classes == "cell") + "}";
% replace <missing> with actual values
for ii = 1 : size(C,2)
    if isempty(s(ii).FillValue)
        C(3,ii) = "";
    else
        if isa(s(ii).FillValue,"string") && ismissing(s(ii).FillValue)
            C(3,ii) = sprintf("<missing>");
        else
            if isa(s(ii).FillValue,'logical') || isa(s(ii).FillValue,'double')
                C(3,ii) = sprintf("%u",s(ii).FillValue);
            else
                C(3,ii) = sprintf("%s",s(ii).FillValue);
            end
        end
    end
end
C(classes == "char") = "'" + C(classes == "char") + "'";
C(C == "") = "{}";
% construct the variable index headers (1),(2),(3), ...
C = [compose("(%d)",1:size(s,2));C];
for ii = 1 : size(C,2)
    C(:,ii) = pad(C(:,ii),max(strlength(C(:,ii))),"left");
end

% get the variable names (Name, Type, FillValue, etc.)
d = [""; string(fields) + ":"];
d = pad(d,max(strlength(d(:)))+2,"left");
fprintf("%s\n",join(d + " " + join(C," | ",2),newline));
end
