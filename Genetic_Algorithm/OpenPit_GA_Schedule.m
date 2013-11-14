function bestSchedule = OpenPit_GA_Schedule(inputFile)
%OpenPit scheduling using Genetic Algorithm

%% read the input files
% bm(1:4, 1:totalNumOfBlocks)
% bm(1:3, :) = [row col dep]
% bm(4, :) = copper content in a block
fid = fopen(inputFile);
bm = fscanf(fid, '%g,%g,%g,%g', [4 inf]);
fclose(fid);

%% initialize value of all the blocks
% value(row, col, dep)
value = initializeValue(bm);

Y1 = zeros(1,7);
Y2 = zeros(1,7);
Y3 = zeros(1,7);
Y4 = zeros(1,7);

for run = 1:4
    if run == 1
        Params.mutationRate = 0.1;
        Params.numOfSchedule = 20;
    elseif run == 2
        Params.mutationRate = 0.3;
        Params.numOfSchdule = 20;
    elseif run == 3
        Params.mutationRate = 0.5;
        Params.numOfSchdule = 20;
    elseif run == 4
        Params.mutationRate = 0.7;
        Params.numOfSchedule = 20;
    end



%% initializeFeature
% initialize features and the schedule matrix that correspond to the
% feature
% scheduleMatrix(numOfSchedule, rows, cols, deps)
% feature(1:numOfSchedule, 1:numOfPeriod, Params.maxFeature)
[feature, scheduleMatrix] = initializeFeature();


%% the total net present values for all the schedules
% npv(schedule)
npv = NPV(value, scheduleMatrix);

%% sort the values in npv in descending order
% outputs a descending order of schedule base on the npv of the schedule
descendSch = sortNPV(npv);

%% While loop

    iteration = 1;
    generation = 0;
    while (generation < 7)
        
        % reproduce the next generation from current population and bring over
        % the elites to next generation
        % feature(1:numOfSchedule, 1:numOfPeriod, 1:Params.maxFeature)
        feature = reproduce(feature, descendSch);
        
        % mutate the non-elites base on the Params.mutationRate
        feature = mutation(feature, descendSch);
        
        [feature, scheduleMatrix] = normalize(feature);
        
        npv = NPV(value, scheduleMatrix);
        descendSch = sortNPV(npv);
        
        generation = generation + 1;
        
        npv(descendSch(1))
        
        X(iteration) = iteration;
        
        if run == 1
            
            Y1(iteration) = npv(descendSch(1));
            
        elseif run == 2
            Y2(iteration) = npv(descendSch(1));
        elseif run == 3
            Y3(iteration) = npv(descendSch(1));
        elseif run == 4
            Y4(iteration) = npv(descendSch(1));
        end
        iteration = iteration + 1;
        
    end
    
    hold on
    if run == 1
    plot(X,Y1,'o','color','blue')
    elseif run == 2
    plot(X,Y2,'o','color','red')
    elseif run == 3
    plot(X,Y3,'x','color','blue')
    elseif run == 4
    plot(X,Y4,'x','color','red')
    end
    
    xlabel('Iteration')
    ylabel('NPV')
    title('\it{Genetic Algorithm for OpenPit Mining}','FontSize',16)
    legend('blue-circle: mutate(10%) size(20)','red-circle: mutate(30%) size(20)',...
        'blue-cross: mutate(50%) size(20)', 'red-cross: mutate(70%) size(20)')

end

bestSchedule = zeros(Params.rows,Params.cols,Params.deps);

for r = 1 : Params.rows
    for c = 1:Params.cols
        for d = 1:Params.maxMiningDepth
            bestSchedule(r,c,d) = scheduleMatrix(descendSch(1),r,c,d);
        end
    end
end


end


%% numOfFeature
function nf = numOfFeature(feature)
nf = zeros(Params.numOfPeriod, Params.numOfSchedule);

for s = 1:Params.numOfSchedule
    for p = 1:Params.numOfPeriod
        for f = 1:Params.maxFeature
            if feature(s,p,f).row ~= 0
                nf(p,s) = nf(p,s) + 1;
            end
        end
    end
end
end



%% printScheduleMatrix
function printScheduleMatrix(scheduleMatrix, p, s)

x = zeros(Params.rows, Params.cols);
for r = 1:Params.rows
    for c = 1:Params.cols
        for d = 1:Params.deps
            if scheduleMatrix(s,r,c,d) == p
                x(r,c) = d;
            end
        end
    end
end
figure
bar3(x);
end



%% printFeature
function printFeature(feature,s)

for p = 1:Params.numOfPeriod
    for f = 1:Params.maxFeature
        f
        r = feature(s,p,f).row
        c = feature(s,p,f).col
        d = feature(s,p,f).dep
    end
end
end

%% featureImage
function featureImage(feature,s)
X = ones(1, Params.maxFeature, 3);

for i = 1:Params.maxFeature
    for p = 1:Params.numOfPeriod
        X(p, i, 1) = feature(s,p,i).row ;
        X(p, i, 2) = feature(s,p,i).col ;
        X(p, i, 3) = feature(s,p,i).dep ;
    end
end
X = 5 * X;
figure
image(uint8(X))
end

%% Normalize
% normalize the feature points such that the feature points within a
% schedule remains constant after normalization, and all the feature points
% are outside the cut out field of another feature point
function [feature, scheduleMatrix] = normalize(feature)

scheduleMatrix = zeros(Params.numOfSchedule, Params.rows, Params.cols, Params.deps);
periodDepth = floor(Params.maxMiningDepth / Params.numOfPeriod);
for s = 1:Params.numOfSchedule
    for p = 1:Params.numOfPeriod
        for f = 1:Params.maxFeature
            r = feature(s,p,f).row;
            c = feature(s,p,f).col;
            d = feature(s,p,f).dep;
            
            if r == 0 || c == 0 || d == 0
                continue;
            end
            
            if scheduleMatrix(s,r,c,d) == 0 && withinBoundary(r,c,d) && ~collideFeature(feature,s,p,f,r,c,d)
                scheduleMatrix = updateScheduleMatrix(scheduleMatrix, feature, s, p, f);
                
            else
                while scheduleMatrix(s,r,c,d) ~= 0 || ~withinBoundary(r,c,d) || collideFeature(feature,s,p,f,r,c,d)
                    r = randi(Params.rows,1);
                    c = randi(Params.cols,1);
                    d = randi([(p-1)*periodDepth+1, p*periodDepth],1);
                    
                    if scheduleMatrix(s,r,c,d) == 0 && withinBoundary(r,c,d) && ~collideFeature(feature,s,p,f,r,c,d)
                        feature(s,p,f).row = r;
                        feature(s,p,f).col = c;
                        feature(s,p,f).dep = d;
                        scheduleMatrix = updateScheduleMatrix(scheduleMatrix, feature, s, p, f);
                        break;
                    end
                end
            end
            
        end
    end
end

end

%% collide feature
function bool = collideFeature(feature, s, p, f, r, c, d)

bool = 0;
for k = 1:Params.maxFeature
    if k ~= f
        r1 = feature(s,p,k).row;
        c1 = feature(s,p,k).col;
        d1 = feature(s,p,k).dep;
        
        if abs(d1-d) > abs(r1-r) && abs(d1-d) > abs(c1-c)
            bool = 1;
        end
    end
    
end



end

%% check if the feature point is within the feasible region
function bool = withinBoundary(r,c,d)

if r - d < 0 || c - d < 0 || r + d > Params.rows+1 || c + d > Params.cols+1
    bool = 0;
else
    bool = 1;
end

end

%% updateScheduleMatrix
function scheduleMatrix = updateScheduleMatrix(scheduleMatrix, feature, s, p, f)

depth = feature(s,p,f).dep;
side = 0;
while depth > 0
    
    for r = feature(s,p,f).row - side : feature(s,p,f).row + side
        for c = feature(s,p,f).col - side : feature(s,p,f).col + side
            if scheduleMatrix(s,r,c,depth) == 0
                scheduleMatrix(s,r,c,depth) = p;
            end
        end
    end
    
    side = side + 1;
    depth = depth - 1;
end
end

%% Initialize the values for all the blocks base on the inputFile bm
% value(1:rows, 1:cols, 1:deps)
function value = initializeValue(bm)

ore_tonnes = zeros(Params.rows, Params.cols, Params.deps);
revenue = zeros(Params.rows, Params.cols, Params.deps);
cost = zeros(Params.rows, Params.cols, Params.deps);
cu = zeros(Params.rows, Params.cols, Params.deps);
value = zeros(Params.rows, Params.cols, Params.deps);

index=1;
for k=1:32
    for j=1:20
        for i=1:50
            cu(i,j,k)=bm(4,index);
            % Each block is 20x20x10m, 10800 tonnes
            % 10,800 tonnes per block
            % Net selling price of 3,747.85 $/Cu t
            % OpEx $3/t
            % Recovery 90%
            
            if cu(i,j,k)==-999
                ore_tonnes(i,j,k)=0;
                revenue(i,j,k)=0;
            else
                ore_tonnes(i,j,k) = 10800*0.9*cu(i,j,k)/100;
                revenue(i,j,k) = ore_tonnes(i,j,k)*3747.85;
            end
            cost(i,j,k) = 10800*6;
            value(i,j,k) = revenue(i,j,k) - cost(i,j,k);
            index=index+1;
        end
    end
end
end


%% Initialize the features
% features are coordinates of all the low points
% feature(1:numOfSchedule, 1:numOfPeriod, Params.maxFeature)
function [feature, scheduleMatrix] = initializeFeature()

fea(Params.numOfSchedule, Params.numOfPeriod, Params.maxFeature) = Features;

periodDepth = floor(Params.maxMiningDepth / Params.numOfPeriod);

for s = 1:Params.numOfSchedule
    for p = 1:Params.numOfPeriod
        numOfFeature = randi(ceil(Params.maxFeature/p),1);
        for f = 1:numOfFeature
            fea(s,p,f).row = randi(Params.rows,1);
            fea(s,p,f).col = randi(Params.cols,1);
            fea(s,p,f).dep = randi([(p-1)*periodDepth+1, p*periodDepth],1);
        end
    end
end

[feature, scheduleMatrix] = normalize(fea);

end


%% NPV
% value(row,col,dep)
% scheduleMatrix(1:numOfSchedule,row,col,dep)
% npv(1:numOfSchedule)
function npv = NPV(value, scheduleMatrix)
npv = zeros(1,Params.numOfSchedule);

for s = 1:Params.numOfSchedule
    for r = 1:Params.rows
        for c = 1:Params.cols
            for d = 1:Params.deps
                if scheduleMatrix(s,r,c,d) ~= 0
                    npv(s) = npv(s) + value(r,c,d)/((1+Params.interest)^scheduleMatrix(s,r,c,d));
                    
                end
            end
        end
    end
end
end

%% sort the schedules base on their npv values
function descendSch = sortNPV(npv)
descendSch = zeros(1,Params.numOfSchedule);
temp = npv;
for k = 1:Params.numOfSchedule
    max = -inf;
    kill = 0;
    for i = 1:Params.numOfSchedule
        if temp(i) > max
            max = temp(i);
            kill = i;
        end
    end
    temp(kill) = -inf;
    descendSch(k) = kill;
end
end

%% reproduce
% feature(1:numOfSchedule, 1:numOfPeriod, 1:maxFeature)
% Move the fittest few parents to the next generation without modification
% randomly generate two parents 
function feature = reproduce(feature, descendSch)

fea = feature;
e = ceil(Params.elitismRate * Params.numOfSchedule);

for s = 1:e
    fea(s,:,:) = feature(descendSch(s),:,:);
end

for s = e+1:2:Params.numOfSchedule-1
    
    s1 = randi(Params.numOfSchedule,1);
    s2 = randi(Params.numOfSchedule,1);
    
    while isShit(s1, descendSch) && isShit(s2, descendSch)
        s1 = randi(Params.numOfSchedule,1);
        s2 = randi(Params.numOfSchedule,1);
    end
    
    
    if (s1 == s2)
        fea(s, :, :) = feature(s1,:,:);
        fea(s+1, :, :) = feature(s2,:,:);
        continue;
    end
    
    n1 = zeros(1:Params.numOfPeriod);
    n2 = zeros(1:Params.numOfPeriod);
    for n = 1:Params.maxFeature
        for p = 1:Params.numOfPeriod
            if feature(s1,p,n).row ~= 0
                n1(p) = n1(p) + 1;
            end
            if feature(s2,p,n).row ~= 0
                n2(p) = n2(p) + 1;
            end
        end
    end
    
    for p = 1:Params.numOfPeriod
        
        if n1(p) < n2(p)
            cut = randi(n1(p),1);
        else
            cut = randi(n2(p),1);
        end
        
        
        for k = 1:cut
            fea(s,p,k) = feature(s1,p,k);
            fea(s+1,p,k) = feature(s2,p,k);
            
        end
        
        for k = cut+1:Params.maxFeature
            fea(s,p,k) = feature(s2,p,k);
            fea(s+1,p,k) = feature(s1,p,k);
        end
        
        
        
    end
    
end

fea(Params.numOfSchedule, :, :) = feature(Params.numOfSchedule, :, :);

feature = fea;
end

%% check if schedule s is a shit schedule
% A schedule is a shit schedule if it has one of the worst NPV
function bool = isShit(sch, descendSch)
sh = floor(Params.extinctionRate * Params.numOfSchedule);
bool = 0;
for s = Params.numOfSchedule-sh+1:Params.numOfSchedule
    if sch == descendSch(s)
        bool = 1;
        break;
    end
end
end

%% Mutation
% for each non elite schedule, look for m number of feature points. Randomly generate
% the period and the feature number, and change the location of the
% feature point for that feature number to a different location within the
% same period.
% feature(1:numOfSchedule, 1:numOfPeriod, 1:maxFeature)
function feature = mutation(feature, descendSch)

m = ceil(Params.mutationRate * Params.numOfSchedule);
periodDepth = floor(Params.maxMiningDepth / Params.numOfPeriod);

count = 0;
while count < m
    s = randi(Params.numOfSchedule,1);
    if ~isElite(s, descendSch)
        p = randi(Params.numOfPeriod,1);
        
        mf = 0;
        for f1 = 1:Params.maxFeature
            if feature(s,p,f1).row ~= 0
                mf = mf + 1;
            end
        end
        
        f = randi(mf,1);
        r = randi(Params.rows,1);
        c = randi(Params.cols,1);
        d = randi([(p-1)*periodDepth+1,p*periodDepth],1);
        if feature(s,p,f).row ~= 0
            feature(s,p,f).row = r;
            feature(s,p,f).col = c;
            feature(s,p,f).dep = d;
        end
        count = count + 1;
        
    end
    
end
end

%% Check if sch is a member of elites
function bool = isElite(sch, descendSch)
numOfElites = floor(Params.elitismRate * Params.numOfSchedule);

bool = 0;
for s = 1:numOfElites
    if sch == descendSch(s)
        bool = 1;
        break;
    end
end
end

