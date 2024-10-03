%Reading in ADNIMERGE
[~,~,ADNI] = xlsread('/Users/shreyarajagopal/Documents/Research/ADNI_4/Subject_Selection/ADNIMERGE.xls');
ADNI_sz = size(ADNI);

%Reading in Neurpsychological battery scores, and computing the month of
%visit as a number from the string of the form 'm06' etc.

[~,~,NeuroBat] = xlsread('/Users/shreyarajagopal/Documents/Research/ADNI_4/Subject_Selection/NEUROBAT.xls');
for i = 1: length(NeuroBat)
    visit = NeuroBat{i,6};
    if strcmp(visit(1,1),'m')
        l = length(visit);
        NeuroBat{i,82} = str2num(visit(2:l)); %82nd column is the month of visit
    elseif strcmp(visit,'bl')
        NeuroBat{i,82} = 0;
    end
end

%Replacing empty visits with -4

for i = 1: length(NeuroBat)
    if isempty(NeuroBat{i,82})
        NeuroBat{i,82} = -4;
    end
end


%%Identifying AD, MCI and CN throughout subjects (remain in the same diagnosis as
%%their baseline diagnosis throughout all visits), and then identifying
%%MCI_C Subjects (baseline MCI, changes once to AD, or baseline CN, changes
%%twice from CN to MCI and MCI to AD

i = 2;

AD = {};
MCI_NC ={};
CN = {};
MCI_C = {};
sub_ctr = 0;
%%Subjects that did noy make it into any cohorts 

AD_X = {}; %Change from AD to some other diagnosis
CN_AD = {}; %Change from CN to AD and remain there
MCI_CN = {}; %Change from MCI to CN and stay in CN
CN_MCI = {}; %Change from CN to MCI and remain there
CN_MCI_AD = {}; %Change from CN to MCI to AD and remain there
MCI_multi ={}; %chagne from MCI to another diagnosis(AD/CN), and then make atleast 1 more change(to AD/CN or back to MCI)

while(i <= ADNI_sz(1,1))
    
    sub_ID = ADNI(i,2); %Subject ID
    
    sub_ctr = sub_ctr +1;%counts number of subjects in ADNI
    
    %Only use those subjects who have "bl" visit information available
    
    if strcmp(ADNI(i,3),"bl")
        
        baseline = ADNI(i,60);
        dx_change = 0; %Checks if diagnosis changes from baseline for the subject in question
        sub_visits = {}; %create an empty cell array for storing details of this subject's visits
        sub_vis = 1;
        diag_prev = ADNI(i,60); %initiating previous diagnosis
        
        while(strcmp(ADNI(i,2),sub_ID)) %Traverses through different visits of the same subject
            
            %Storing essential information from subject's visit
            
            sub_visits{sub_vis,1} = ADNI{i,1}; %RID
            sub_visits{sub_vis,2} = ADNI{i,2}; %PTID
            sub_visits{sub_vis,3} = baseline; %Dx_bl
            sub_visits{sub_vis,4} = ADNI{i,112}; %month of visit
            sub_visits{sub_vis,5} = ADNI{i,60}; %Diagnosis
            sub_visits{sub_vis,6} = ADNI{i,112}./12 + ADNI{i,9}; %Age
            sub_visits{sub_vis,7} = ADNI{i,10}; %Gender
            sub_visits{sub_vis,8} = ADNI{i,7}; %Date of Visit
            sub_visits{sub_vis,9} = ADNI{i,5}; %Current ADNI Protocol
            
            %%Cognitive Scores Corresponding to Visits
            
            sub_visits{sub_vis,10} = ADNI{i,23};  %ADAS-11
            sub_visits{sub_vis,11} = ADNI{i,24}; %ADAS-13
            sub_visits{sub_vis,12} = ADNI{i,26}; %MMSE
            sub_visits{sub_vis,13} = ADNI{i,22}; %CDRSB
            sub_visits{sub_vis,14} = ADNI{i,27}; %RAVLT_Immediate
            sub_visits{sub_vis,15} = ADNI{i,28}; %RAVLT_learn
            sub_visits{sub_vis,16} = ADNI{i,29}; %RAVLT_forget
            sub_visits{sub_vis,17} = ADNI{i,31}; %LDEL_total
            sub_visits{sub_vis,18} = ADNI{i,32}; %Digit_SCore
            sub_visits{sub_vis,19} = ADNI{i,42}; %ECog_Patient_Total
            
            %Assigning Structural Scores to Visits
            sub_visits{sub_vis,20} = ADNI{i,53}; %Ventricle Volume
            sub_visits{sub_vis,21} = ADNI{i,54}; %Hippocampus Volume
            sub_visits{sub_vis,22} = ADNI{i,55}; %WholeBrain volume
            sub_visits{sub_vis,23} = ADNI{i,56}; %Entorhinal volume
            sub_visits{sub_vis,24} = ADNI{i,57}; %Fusiform Volume
            sub_visits{sub_vis,25} = ADNI{i,58}; %MidTemp Volume
            sub_visits{sub_vis,26} = ADNI{i,59}; %Intracranial Volume (ICV)
            
            
            sub_vis = sub_vis +1; % Visit # of current subject
            
            nan_check = isnan(ADNI{i,60});
            
            %prev_nan_check = isnan(char(diag_prev(1,1))); %If the prev diagnosis does not match the current one as the previous one was empty, that's not a change
            
            if(~strcmp(diag_prev,ADNI{i,60}) && nan_check(1,1)~=1) %&&~isa(diag_prev,'double') %The diagnosis for a visit does not match the baseline, and additionally is not empty
                
                dx_change = dx_change + 1;
                diag_prev = ADNI{i,60}; %MISTAKE??
            end
            
            %            if(nan_check(1,1)~=1) % Only update previous diagnosis if current diagnosis is not NaN
            %             diag_prev = ADNI{i,60}; %storing previous diagnosis
            %            end
            %
            i = i+1;
            
            if i > ADNI_sz(1,1)
                break;
            end
            
            
        end
        
        %At the end of the above loop, diag_prev is the last known diagnosis of
        %the subject
        
        last_visit = sub_vis;
        
        if dx_change == 0 % Subject stays in same diagnosis throughout all visits
            
            if strcmp(baseline,'Dementia') %stayed in baseline diag as AD till last visit
                AD = cat(1,AD,sub_visits);
            elseif strcmp(baseline,'CN') %stayed in baseline diag as CN till last visit
                CN = cat(1,CN,sub_visits);
            elseif strcmp(baseline,'MCI') %stayed in baseline diag as MCI till last visit
                MCI_NC = cat(1,MCI_NC,sub_visits);
            end
            
        elseif strcmp(baseline,'MCI') && dx_change == 1 && strcmp(diag_prev,'Dementia' ) %strcmp(sub_visits{last_visit,5},'Dementia' %changed once from baseline visit as MCI, to AD and stayed AD till last visit
            MCI_C = cat(1,MCI_C,sub_visits);
            
            
        elseif strcmp(baseline,'MCI') && dx_change == 1 && strcmp(diag_prev,'CN') %strcmp(sub_visits{last_visit,5},'CN' %changed once from baseline visit as MCI, to CN and stayed CN till last visit
            MCI_CN = cat(1,MCI_CN,sub_visits);
            
        elseif  strcmp(baseline,'Dementia') && dx_change>0
            AD_X = cat(1,AD_X,sub_visits);
            
        elseif  strcmp(baseline,'CN') && dx_change==1 && strcmp(diag_prev,'Dementia') %Sub who go from CN to AD and remain there
            CN_AD = cat(1,CN_AD,sub_visits);
            
        elseif  strcmp(baseline,'CN') && dx_change==1 && strcmp(diag_prev,'MCI') %Sub who go from CN to MCI and remain there
            CN_MCI = cat(1,CN_MCI,sub_visits); %prospective candidates for MCI_S IF THEY STAY MCI for 2 years
            
        elseif  strcmp(baseline,'CN') && dx_change==2 && strcmp(diag_prev,'Dementia') %Sub who go from CN to MCI to AD and remain there
            CN_MCI_AD = cat(1,CN_MCI_AD,sub_visits);
            
        elseif  strcmp(baseline,'MCI') && dx_change>1
            MCI_multi = cat(1,MCI_multi,sub_visits);
            
            %3. Only take those MCI stable subjects who have remained MCI for 2
            %years
            
            %Get these scores, and separately fix MCI matrices (concatenate MCI visits from CN to MCI subjects, and then count years)
            
        end
        %%SKIP subjects whose baseline visit is not recorded - CHANGE 2/9/20
        
    else
        while(strcmp(ADNI(i,2),sub_ID))
            i = i+1;
            if i > ADNI_sz(1,1)
                break;
            end
        end
        
    end
    
    
end

% save('AD_Subject_Visits.mat','AD');
% save('CN_Subject_Visits.mat','CN_fin');
% save('MCI-C_Subject_Visits.mat','MCI_C');
% save('MCI-NC_Subject_Visits.mat','MCI_NC');
%
% save('AD_X_Subject_Visits.mat','AD_X');
% save('CN_X_Subject_Visits.mat','CN_X');
% save('MCI-CN_Subject_Visits.mat','MCI_CN');
% save('MCI-multi_Subject_Visits.mat','MCI_multi');
% save('CN_MCI_Subject_Visits.mat','CN_MCI');
% save('CN_MCI_AD_Subject_Visits.mat','CN_MCI_AD');

%ADD NEUROBAT SCORES to AD and CN - Need to stay in AD/CN for at least two years??

%Adding NeuroBat to AD

for i = 1: length(AD)
    for j = 2:length(NeuroBat)
        if (AD{i,1} == NeuroBat{j,3} && AD{i,4} == NeuroBat{j,82})
            
            AD(i,27:88) = NeuroBat(j,10:71);
            
        end
    end
end

%Adding NeuroBat to CN

for i = 1: length(CN)
    for j = 2:length(NeuroBat)
        if (CN{i,1} == NeuroBat{j,3} && CN{i,4} == NeuroBat{j,82})
            
            CN(i,27:88) = NeuroBat(j,10:71);
            
        end
    end
end

%In the R code, previous 10:71 corresponds to the new 27:88 (see
%corresponding columns!)


%1.1 Concatenate MCI_NC and CN_MCI and only retain subjects with >2 years
%in MCI state -MAJ 2

MCI_NC = [MCI_NC;CN_MCI];

%for each subject, last MCI visit - first MCI visit should be >=24 (column
%4)

%Computing the duration each subject spends in MCI stage
%Computing the duration each subject spends in MCI stage
i = 1;
k = 1;
MCI_diff = {};
while(i<length(MCI_NC))
    sub_RID = cell2mat(MCI_NC(i,1));
    prev_diagnosis = MCI_NC(i,5);
    MCI_switch = 0; %should be flipped to one once the first MCI visit is encountered
    MCI_vis1 = 0;
    MCI_visfin = 0;
   
    
    if cell2mat(MCI_NC(i,1))== 680
        disp("hi")
    end
    
    while(cell2mat(MCI_NC(i,1))== sub_RID) %Traversing through visits of the same subject
         
    nan_check2 = isnan(cell2mat(MCI_NC(i,5)));
    %disp(MCI_NC{i,5})
        if (strcmp(MCI_NC{i,5},'CN') && MCI_switch == 0 || nan_check2(1,1)==1 && MCI_switch == 0)  %subject has a diagnosis of CN or blank diagnosis
            i = i+1;
            if (i>length(MCI_NC))
                break;
            end
        else
            if (MCI_switch == 0 && strcmp(MCI_NC{i,5},'MCI'))
                MCI_switch =1;
      
                MCI_vis1 = cell2mat(MCI_NC(i,4));
                MCI_visfin = cell2mat(MCI_NC(i,4));
                i = i+1;
                if (i>length(MCI_NC))
                    break;
                end
                
                
            elseif (MCI_switch==1 && nan_check2(1,1)==1 || strcmp(MCI_NC{i,5},"MCI") && MCI_switch==1)
                MCI_visfin = cell2mat(MCI_NC(i,4));
                i = i +1;
                if(i>length(MCI_NC))
                    break
                end
            end
        end
    end
    
    MCI_diff{k,1} = sub_RID;
    MCI_diff{k,2} = MCI_visfin - MCI_vis1;
    k=k+1;
    
end

%Retaining subject Ids who have been in MCI stage>=24 months

MCI_NC_fin = {};
l = 1;
for i = 1:length(MCI_NC)
    for k = 1:length(MCI_diff)
    if (MCI_NC{i,1} == MCI_diff{k,1} && MCI_diff{k,2}>=24)
        MCI_NC_fin(l,:) = MCI_NC(i,:);
        l = l+1;
    end
    end
end
   
%2.1 ADD NEUROBAT Scores to MCI_NC
for i = 1: length(MCI_NC_fin)
    for j = 2:length(NeuroBat)
        if (MCI_NC_fin{i,1} == NeuroBat{j,3} && MCI_NC_fin{i,4} == NeuroBat{j,82})
            
            MCI_NC_fin(i,27:88) = NeuroBat(j,10:71);
           
        end
    end
end

%Concatenate MCI_C and CN_MCI_AD
MCI_C = [MCI_C;CN_MCI_AD];

%2.1 ADD NEUROBAT Scores to MCI_C
for i = 1: length(MCI_C)
    for j = 2:length(NeuroBat)
        if (MCI_C{i,1} == NeuroBat{j,3} && MCI_C{i,4} == NeuroBat{j,82})
            
            MCI_C(i,27:88) = NeuroBat(j,10:71);
        end
    end
end


%Number of subjects in each cohort


MCI_NC_IDs_new1 = unique(MCI_NC_fin(:,2));
MCI_C_IDs_new1 = unique(MCI_C(:,2)); 

% save('AD_IDS_new.mat','AD_IDs_new');
% save('MCI_NC_IDS_new.mat','MCI_NC_IDs_new'); %from 599 to 370 (<2year MCI discarded - spot check on discarded done)
% 
% save('CN_IDS_new.mat','CN_IDs_new');
% save('MCI_C_IDS_new.mat','MCI_C_IDs_new');
% 
% save('AD_Visits_new.mat','AD');
%save('MCI_NC_Visits_new.mat','MCI_NC_fin');
% 
% save('CN_Visits_new.mat','CN');
% save('MCI_C_Visits_new.mat','MCI_C'); %from 328 to 324 (lost 22, gained 17 due to CN -> MCI -> AD inclusion


%Add headers, save everything as .xls also

%2.2 Create a separate list with only MCI visits of MCI_C subjects (Can do
%in excel)

%3. Create a CN_bl list as well (Can do in Excel)


%different subjects in both analyses check

%%%%Checking why certain MCI subjects were discarded by this new script

% load('MCI_C_Subject_IDs.mat')
% MCI_C_discarded = setdiff(MCI_C_IDs,MCI_C_IDs_new);
% save("MCI_C_Rejects.mat","MCI_C_discarded");
% MCI_C_newly_included = setdiff(MCI_C_IDs_new, MCI_C_IDs);
% 
% load('MCI_NC_Subject_IDs.mat')
% MCI_NC_discarded = setdiff(MCI_NC_IDs,MCI_NC_IDs_new);
% save("MCI_NC_Rejects.mat","MCI_NC_discarded");
% MCI_NC_newly_included = setdiff(MCI_NC_IDs_new,MCI_NC_IDs);
% 
% 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
