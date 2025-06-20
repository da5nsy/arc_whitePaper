% Process data into the format needed

%% Convert mat file to csv

clc, clear, close all

% Raw data not shared (privacy, and also it is 1.3TB)
% .mat file generated by: arc_ellipse/arc_ImageAnalysis/arc_extractGoProImageStatsV1.m
% TODO Still not sure whether we will share this 1.5GB .mat file

repoHomeDir = ['..',filesep,'..',filesep,'..'];
addpath(repoHomeDir);
addpath([repoHomeDir,filesep,'imageanalysis']);

paths = getLocalPaths;

load(paths.GoProProcessedData,'fileList');

% remove some fields which won't work nicely in a csv
fileList = rmfield(fileList,'FM_O');
fileList = rmfield(fileList,'FM_T');
fileList = rmfield(fileList,'MondStats');
fileList = rmfield(fileList,'DiscrStats');

writetable(struct2table(fileList),['..',filesep,'GoPro',filesep,'GoPro.csv']);

%% Convert that csv into a matrix that is easier for later plotting

clc, clear, close all

t = readtable(['..',filesep,'GoPro',filesep,'GoPro.csv']);

mat = NaN([6,size(t,1)]);

paths = getLocalPaths;
data.PP = load(paths.PPProcessedData,'resultsTable');
stdLLM = std([data.PP.resultsTable.MeanLLM],"omitnan");
stdSLM = std([data.PP.resultsTable.MeanSLM],"omitnan");

for i = 1:size(t,1)
    try

        mat(1,i) = t.meanMB_1(i);
        mat(2,i) = t.meanMB_2(i);
        mat(3,i) = t.meanMB_3(i);

                % seasonNames = {'Summer','Autumn','Winter','Spring'};
        if strcmp(t.season{i},'Summer')
            mat(4,i) = 1;
        elseif strcmp(t.season{i},'Autumn')
            mat(4,i) = 2;
        elseif strcmp(t.season{i},'Winter')
            mat(4,i) = 3;
        elseif strcmp(t.season{i},'Spring')
            mat(4,i) = 4;
        end

        % locationNames = {'Tromso','Oslo'};
        if strcmp(t.location{i},'Tromso')
            mat(5,i) = 0;
        elseif strcmp(t.location{i},'Oslo')
            mat(5,i) = 1;
        end

        if isnan(t.meanMB_1(i)) % TODO The more robust way of doing this would be to edit MacBtoCL to return NaN when given NaN (it currently returns 0)
            mat(6,i) = NaN;
        else
            mat(6,i) = MacBtoCL([t.meanMB_1(i);t.meanMB_2(i)],[stdLLM,stdSLM]);
        end

    catch
        % warning('data transformation issue') % this is commented out because we currently only process a subset of the data, so there's lots of NaN placeholders
    end
end

writematrix(mat,['..',filesep,'GoPro',filesep,'GoPro_sub.csv']);
