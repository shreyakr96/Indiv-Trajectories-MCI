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
   