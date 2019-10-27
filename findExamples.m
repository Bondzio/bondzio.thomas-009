function examples = findExamples(supportingFile)
    examples = struct([]);
    docConfig = com.mathworks.mlwidgets.help.DocCenterDocConfig.getInstance;
    searchConfig = docConfig.getSearchConfig;
    docSet = docConfig.getDocumentationSet;
    
    registry = com.mathworks.helpsearch.examples.ExampleSupportingFileRegistry(searchConfig, docSet);
    try
        pages = registry.getExamplesForSupportingFile(supportingFile);
        if ~pages.isEmpty
            index = 1;
            iterator = pages.iterator;
            while iterator.hasNext
                examplePage = iterator.next;
                title = char(examplePage.getTitle);
                uniqueId = char(examplePage.getUniqueId);
                exampleId = strrep(uniqueId, '.', '/');
                if ~isExecutableSupportingFile(exampleId, supportingFile) 
                    continue
                end
                examples(index).exampleTitle = char(org.apache.commons.lang.StringEscapeUtils.unescapeHtml(title));
                examples(index).exampleId = exampleId;
                index = index + 1;
            end
            [~,ind] = unique({examples.exampleId});
            examples = examples(ind);
        end
    catch
    end 
end

function isExecutable = isExecutableSupportingFile(exampleId, supportingFile)
    isExecutable = false;
    metadata = findExample(exampleId);
    [~, supportingFileName, supportingFileExt] = fileparts(supportingFile);
    if strcmp(supportingFileName, metadata.main)
        isExecutable = true;
        return;
    end
    
    for iFiles = 1:numel(metadata.files)
        f = metadata.files{iFiles};
        [~, name, ext] = fileparts(f.filename);
        if strcmp(supportingFileName, name)
            if strcmp(ext, '.m') || strcmp(ext, '.mlx') || strcmp(ext, '.slx')
                isExecutable = true;
                break;
            end
        end
    end
end

