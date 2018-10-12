%analyse data with suite2p
%mag 5: diameter 35 and 100 components 
%mag 2: diameter 15 and 300 components 
%-> .proc file
%register suite2p analysis across days 

registers2p %gui 
%--> .reg file 

%load last day (857_p41) as dataset 1 and register other days to it as
%dataset 2. Save in file of dataset 2
%%
%create list of no. of baseline files 
db.raw_file = uigetdir;%chose which raw animal file should be analysed 
name_components = strsplit(db.raw_file,'\');
db.animal = name_components{1,(length(name_components))};
db.root=(db.raw_file) ;
cd(db.root) %put in the animal 
db.folder_list=dir ('*p*'); %list all files that start with 18 to avoid invisible files 
db.FOV='/2';

for i= 1:numel(db.folder_list)
    db.idx=strcat('/',db.folder_list(i).name);
    db.subf=strcat(db.root,db.idx,db.FOV);
    if exist (db.subf)
    cd (db.subf)
    file=dir('*_bsl_*.tif');
    db.bsl_files(i,1)=numel(file);
    else continue 
    end 
end 

%%
%%load dat files into data struct

db.results_file= uigetdir;
name_components = strsplit(db.results_file,'\');
%db.results_file='/Users/Johannasigl-glockner/Lab/SCNN1A/for holidays/';
db.animal = name_components{1,(length(name_components))};
db.root=db.results_file;
cd(db.root) %put in the animal 
db.folder_list=dir ('*p*'); %list all files that start with 18 to avoid invisible files 
db.FOV='2';
name=strcat(db.animal,'_',db.FOV,'_raw');
name2=strcat(db.animal,'_',db.FOV,'_db');

for i= 1:numel(db.folder_list)
    db.idx=strcat('/',db.folder_list(i).name);
    db.subf=strcat(db.root,db.idx,'/',db.FOV);
    if exist(db.subf)
    cd (db.subf)
    db.file=dir('*_proc.mat');
        if isempty(db.file)==0
        load (db.file.name);
        data(i).dat = dat;
        %some data prep: 
        data(i).dat.Fcell_npcorr= data(i).dat.Fcell{1,1}-(0.7* data(i).dat.FcellNeu{1,1});
        iscell=[data(i).dat.stat(1:end).iscell]';%gets the indices, if something is a cell (from new_main GUI selection) 
        data(i).dat.traces=data(i).dat.Fcell_npcorr((iscell==1),:);
        data(i).dat.ztraces = zscore(data(i).dat.traces);
        data(i).dat.icoord={data(i).dat.stat(iscell==1).ipix}';
        data(i).dat.xcoord={data(i).dat.stat(iscell==1).xpix}';
        data(i).dat.ycoord={data(i).dat.stat(iscell==1).ypix}';
        data(i).date = db.folder_list(i).name;
        data(i).bsl_files = db.bsl_files(i,1);
        db.file=dir('*plane1_reg.mat');
            if isempty(db.file)==0
            x=length(db.file)%put this in in case their are hidden copies 
            load (db.file(x).name);   
            data(i).reg = regi;
            else 
            end 
        else  
        end 
    else 
    end 
end 

%save data and db files in the results file for this animal 
%assignin('base',name,data);%this would rename the structure variable 
cd(db.root)
save(name,'data')
save(name2,'db')
clearvars -except data db

%% create anchor day 
k=2;%which one is the anchor day
x=(db.bsl_files(k,1)*4000)+1;
temp=data(k).dat.traces;
temp=data(k).dat.traces(:,x:end);
day=['day_' num2str(k,'%d')];

dims=size(temp);
idx=[1:230:dims(1,2)]; %make sure frame number is correct 
dims2=size(idx);
for n=1:dims(1,1)
    for i=1:dims2(1,2)
        idx1=idx(i);
        cells{n,k}(:,i)=(temp(n,idx(i):(idx(i)+229)));%make sure its the right number of frames 
    end 
end 
%create cell mask figure 
name3=strcat('m',db.animal,'_',db.FOV,'_cellmask.fig');
matrix(length(data(k).dat.ops.yrange),length(data(k).dat.ops.xrange))=NaN;
for i=1:dims(1,1)
    matrix(data(k).dat.icoord{i,1})=rand;
end 
imagesc(matrix)
hold on
for i=1:dims(1,1)
    text(data(k).dat.xcoord{i,1}(1,1),data(k).dat.ycoord{i,1}(1,1),num2str(i),'Color','red','FontSize',10);
end 
savefig(name3)
%save here cells already 
cd(db.root)
name4=strcat(db.animal,'_',db.FOV,'_idcells');
save(name4,'cells')

clearvars -except data db cells 
%% 
%add subseqeunt or prior days with matched cells 

for h=[3] % day that are added; 
    day=['day_' num2str(h,'%d')];
    temp=[];
    temp=data(h).dat.traces;
    x=(db.bsl_files(h,1)*4000)+1;
    temp=temp(:,x:end);

    dims=size(temp);
    idx=[1:230:dims(1,2)];
    dims2=size(idx);
    for n=1:dims(1,1)
        for i=1:dims2(1,2)
            idx1=idx(i);
            Temp{n,h}(:,i)=(temp(n,idx(i):(idx(i)+229)));
        end 
    end 

    cellidx=data(h).reg.rois.iscell_idcs;
    dims=size(cellidx);
    for k=1:dims(1,1)
        dest=cellidx(k,1);
        org=cellidx(k,2);
        mov_cell=Temp{org,h};
        cells{dest,h}=mov_cell; %put in label for struct 
    end 
end 

%save as cslls file in results and clear vars
cd(db.root)
name4=strcat('m',db.animal,'_',db.FOV,'_idcells');
save(name4,'cells')
%clearvars -except data db cells 





















