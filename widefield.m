function [widefield] = widefield
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
selpath = uigetdir;
cd(selpath)
name_components = strsplit(selpath,'\');
filename_mat=[name_components{1,5} '_' name_components{1,6} '_' name_components{1,7} '.mat'];
filename_fig=[name_components{1,5} '_' name_components{1,6} '_' name_components{1,7} '.fig'];
fig_title=[name_components{1,5} ' ' name_components{1,6} ' ' name_components{1,7}];

files = dir('*.tif');
out=size(files,1);

%at Brecht 2p: 8 sec recording, start of stim after 2 sec; 230 frames per
%recording at 29.9 hz. Start stim at 59,8 frames and end at 89,7 frames 

gauss=10;

for ii=1:out %fname = files'
    InfoImage=imfinfo(files(ii).name);
    mImage=InfoImage(1).Width;
    nImage=InfoImage(1).Height;
    NumberImages=length(InfoImage);
    
    normMatrix=zeros(nImage,mImage,10,'uint16');%image for normalization 
        for i=1:10
        normMatrix(:,:,i)=imread((files(ii).name),'Index',i);
        end 
        normImage= imgaussfilt(mean(normMatrix,3),gauss);
        
    BslMatrix=zeros(nImage,mImage,30,'uint16');%create Baseline
        for i=1:30
        k=i+10;
        temp1=imread((files(ii).name),'Index',k);
        temp1=double(imgaussfilt(temp1,gauss));
        temp1=temp1-normImage;
        BslMatrix(:,:,i)=temp1;
        end
        popBslMatrix(:,:,ii)=mean(BslMatrix,3);
        
        
    StimMatrix=zeros(nImage,mImage,30,'uint16');%create Stim
        for i=1:30
        k=i+60;%put in at which frame the stim starts 
        temp2=imread((files(ii).name),'Index',k);
        temp2=double(imgaussfilt(temp2,gauss));
        temp2=temp2-normImage;
        StimMatrix(:,:,i)=temp2;
        end
        popStimMatrix(:,:,ii)=mean(StimMatrix,3);
   
    BaseMatrix=zeros(nImage,mImage,230,'uint16');%create Baseimage of FOV
        for i=1:230
        BaseMatrix(:,:,i)=imread((files(ii).name),'Index',i);
        end
        popBaseMatrix(:,:,ii)=mean(BaseMatrix,3);
end

BslImage=(mean(popBslMatrix,3));
        
StimImage=(mean(popStimMatrix,3));

BaseImage=mean(popBaseMatrix,3);

%%make struct and save 
widefield.BslMatrix=popBslMatrix;
widefield.BslImage=BslImage;

widefield.StimMatrix=popStimMatrix;
widefield.StimImage=StimImage;

widefield.BaseMatrix=popBaseMatrix;
widefield.BaseImage=BaseImage;

save (filename_mat,'widefield')

%plot Widefield data 
limit=max(max(StimImage));%set colour range
figure('position', [100,100,650,200])
ax3=subplot(1,4,1); %create mean image
imagesc(widefield.BaseImage)
colormap (ax3,gray);
xlabel('Filed of View','Fontsize',12)

subplot(1,4,2)
imagesc(widefield.BslImage)
h1=colormap(jet);
xlabel('Baseline','Fontsize',12)
caxis([0 limit])

subplot(1,4,3)
imagesc(widefield.StimImage)
xlabel('Evoked','Fontsize',12)
caxis([0 limit])
%colorbar

subplot(1,4,4)
imagesc((widefield.StimImage-widefield.BslImage))
xlabel('Bsl-Evoked','Fontsize',12)
caxis([0 limit])
hold on
for i=1:4
    subplot(1,4,i)
    set(gca,'xtick',[]) 
    set(gca,'ytick',[]) 
    pbaspect([1 1 1])
end 
subplot(1,4,1)
title(fig_title)
subplot(1,4,4)
originalSize = get(gca, 'Position');
colorbar
set(gca, 'Position', originalSize);
savefig(filename_fig)
end

