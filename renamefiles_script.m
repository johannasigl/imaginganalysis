start_path=cd

%recording_data_files = arrayfun(@(nr) sprintf('W225_p25_bsl_', nr), 1:10, 'UniformOutput', false); %what are the names of the subfolders and how many are there?
%listOfFolderNames=recording_data_files';

names = arrayfun(@(nr) sprintf('W225_p25_bsl_%i.tif', nr), 1:11, 'UniformOutput', false); %what are the names that the traces should get?
files = dir('*.tif');
 

for k = 1 :length(files)
currentfile=files(k).name;
movefile(currentfile,names{k})%orig name of 
end