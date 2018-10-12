%prep zscored traces

for i=1:length(dend)
    dend(i).ztrace=zscore(dend(i).normtrace);
    dend(i).ztrace_st=dend(i).ztrace(:);
end 
%filename='p36_mag8_newcell_trace';
%save(filename,'dend');
%%
%%raw traces for all cells
f=figure (6);
f.Position=[1,1,1000,1000];

axis = (1:180);
n= 3;%number of rows 
m= 6;%number of columns
x((1:6),1)=91;
y=(-1:1:4);

xx((1:6),1)=121;
yy=(-1:1:4);

spreads = (1:length(dend)); %%number of ROIS
for  i=1:length(dend)
subplot (n,m,i)
%trace=dend(i).normtrace./(100000);
trace=movmean(dend(i).ztrace,20);%use a moving window of 10 frames%use a moving window of 10 frames
mean_trace=mean(dend(i).ztrace');
mean_trace=movmean(mean_trace,20);
% set(gca, 'ColorOrder', ColorSet);
hold all
plot (axis, trace(1:180,:),'color',[0.8 0.8 0.8])
hold on
plot (axis, mean_trace(1:180),'k','lineWidth',1)
plot(x,y,'r','lineWidth',1)
plot(xx,yy,'r','lineWidth',1)
str={dend(i).ID};
%text(5,3,str,'FontSize',5)
ylim([-2 3])
xlim([50 180])%
end
clearvars -except dend filename

%% plot raw data with shaded errorbar 

n= 5;%number of rows 
m= 5;%number of columns
x((1:2),1)=35;
y=(-0.5:1:0.5);

f=figure (1);
f.Position=[1,1,500,500];

spreads = (1:length(dend)); %%number of ROIS
for  i=1:length(dend)
subplot (n,m,i)%7x7 is 49 and makes enough subplots for 41 traces, make 7 equal to the root of the number of rois you have
fluo=movmean((mean(dend(i).ztrace(50:150,:)')),10);
err=movmean((std(dend(i).ztrace(50:150,:)')/sqrt(length(dend(i).ztrace(50:150,:)'))),10);
shadedErrorBar([],fluo,err)
str={i};
text(1,4,str)
hold on
plot(x,y,'r','lineWidth',1)
%ylim([-2 5])
%xlim([0 240])
set(gca,'fontsize',12)
end
clearvars -except dend
%% make dashes for stacked traces
hallo=[90:210:40000];
for i=1:54
x((1:6),1)=hallo(1,i);
y=(-0.25:0.1:0.25);
plot(x,y,'r','lineWidth',1)
hold on
end 
%%
f=figure (1);
f.Position=[1,1,200,500];
for i=1:length(dend)
    mod_matrix(i,1)=mean(mean(dend(i).ztrace(1:50,:)));
    mod_matrix(i,2)=mean(mean(dend(i).ztrace(87:120,:)));
    mod_matrix(i,3)=mean(mean(dend(i).ztrace));%overall mean 
    mod_matrix(i,4)=(mod_matrix(i,2)-mod_matrix(i,1));
    
end 
plot(mod_matrix(:,1:2)','-o')
hold on
plot(mean(mod_matrix(:,1:2)),'-ok','linewidth',2)
xlim([0.5 2.5])
%%
for i=1:length(dend)
    dend(i).respidx=mod_matrix(i,4);
end 
save(filename,'dend');
%%
for i=1:length(dend)
    roi(roi==i)=dend(i).respidx;
end 
%%
files = dir('*mc.tif');
out=size(files,1)
for ii=1:10 %fname = files'
    InfoImage=imfinfo(files(ii).name);
    mImage=InfoImage(1).Width;
    nImage=InfoImage(1).Height;
    NumberImages=length(InfoImage);
    
BaseMatrix=zeros(nImage,mImage,240,'uint16');%create Baseimage of FOV
        for i=1:240
        BaseMatrix(:,:,i)=imread((files(ii).name),'Index',i);
        end
        popBaseMatrix(:,:,ii)=mean(BaseMatrix,3);
end 
BaseImage=mean(popBaseMatrix,3);
%%
ax3=subplot(1,2,1); %create mean image
imagesc(BaseImage)
colormap (ax3,gray);
ax3=subplot(1,2,2);
roi(roi==0)=NaN;
 imagesc(roi,'AlphaData',~isnan(roi))
for i=1:2
    subplot(1,2,i)
    set(gca,'xtick',[]) 
    set(gca,'ytick',[]) 
    pbaspect([1 1 1])
end 
    
    
    