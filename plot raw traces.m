%prep zscored traces

for i=1:length(dend)
    dend(i).ztrace=zscore(dend(i).normtrace);
    dend(i).ztrace_st=dend(i).ztrace(:);
end 
filename='p25_mag2_gen_gen_trace';
save(filename,'dend');
%%
%%raw traces for all cells
f=figure (1);
f.Position=[1,1,1000,1000];

axis = (1:180);
n= 8;%number of rows 
m= 7;%number of columns
x((1:6),1)=87;
y=(-1:1:4);

spreads = (1:length(dend)); %%number of ROIS
for  i=1:length(dend)
subplot (n,m,i)
%trace=dend(i).normtrace./(100000);
trace=movmean(dend(i).ztrace,20);%use a moving window of 10 frames%use a moving window of 10 frames
mean_trace=mean(dend(i).ztrace');
mean_trace=movmean(mean_trace,20);
set(gca, 'ColorOrder', ColorSet);
hold all
plot (axis, trace(1:180,:))
hold on
plot (axis, mean_trace(1:180),'k','lineWidth',1)
plot(x,y,'r','lineWidth',1)
str={dend(i).ID};
text(5,3,str,'FontSize',5)
ylim([-2 4])
xlim([0 180])%
end
clearvars -except dend
%%

for k=1:length(dend)
    matrixbs(k,:)=mean(dend(k).normtrace(1:30,:)); %diff cells are in each row, diff recording in each column (87 - 7 frames);
    matrixstim(k,:)=mean(dend(k).normtrace(90:120,:));%response within2 sec (60 frames) after stim onset 
    matrixall(k,:)=mean(dend(k).ztrace(:,:)); %mean Ca fluo during across all frames
    [h,p]=ttest(matrixbs(k,:),matrixstim(k,:));
    matrix_pval(1,k)=h;
    matrix_pval(2,k)=p;
end 

baseline_pop=mean(matrixbs');
stim_pop=mean(matrixstim');
all_pop=mean(matrixall');
%convert to z-score
%normbs=baseline_pop./all_pop;
%normstim=stim_pop./all_pop;

%diff_pop=(stim_pop-baseline_pop)./((stim_pop+baseline_pop)/2);
diff_pop=(stim_pop-baseline_pop)./((stim_pop+baseline_pop)/2);

%select only the significant ones: 
pos=find(matrix_pval(1,:)==1);
baseline_idxed=baseline_pop(1,pos);
stim_idxed=stim_pop(1,pos);
diff_idxed=baseline_idxed-stim_idxed;
diff_pop_idxed=diff_pop(1,pos);

f=figure (2);
f.Position=[1,1,700,400];
subplot(1,3,1)
hist(diff_pop)
xlabel('Percent change in mean(?F/F)')
ylabel('no of cells')
set(gca,'fontsize',12)


subplot(1,3,2)
scatter(baseline_pop,stim_pop);
refline(1,0)
xlabel('Mean delta f/f baseline')
ylabel('Mean delta f/f Stim')
set(gca,'fontsize',14)

subplot(1,3,3)
scatter(baseline_idxed,stim_idxed);
refline(1,0)
xlabel('Mean delta f/f baseline')
ylabel('Mean delta f/f Stim')
set(gca,'fontsize',14)
%% plot raw data with shaded errorbar 

n= 7;%number of rows 
m= 8;%number of columns
x((1:2),1)=87;
y=(-0.5:1:0.5);

f=figure (1);
f.Position=[1,1,1000,1000];

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
%%
%for one cell: 
meanbs=mean(dend(1).normtrace(1:87,:))';
meanstim=mean(dend(1).normtrace(88:117,:))';
mean(meanbs)
mean(meanstim)
%%
%%traces for one cells
cells=43;

 axis = (1:240);

    k= 56;%recordings
    n= 8;%number of rows 
    m= 8;%number of columns
    x((1:180),1)=87;
    y=(-29:1:150);

for p=43:cells;
    figure (p)
   
    spreads = (1:k); %%number of ROIS
    for  i=1:k
    subplot (n,m,i)%7x7 is 49 and makes enough subplots for 41 traces, make 7 equal to the root of the number of rois you have
    trace=dend(p).normtrace(:,i)/(100000);
    plot (axis,trace )
    hold on
    plot(x,y)
    ylim([6.5 7.5])
    xlim([0 240])%1000 max for cells, dend higher (1500?)
    trace=[];
    end 
end
%%
for i=1:80
    plot(smooth(dend(i).ztrace_st))
    hold on 
end 

    
    
    
    