%
% %This is the script for running the program
clear
clc
close all

bestSchedule = OpenPit_GA_Schedule('bm.csv');

fileID = fopen('ai.out','w');
for r=1:Params.rows
    for c=1:Params.cols
        for k =1:Params.deps
            fprintf(fileID,'%d, %d, %d, %d\n', r,c,k,bestSchedule(r,c,k));
        end
    end
end

fclose(fileID);
hold on


