
%% This class contains the parameters for OpenPit_GA_Schedule.m

classdef Params
    %This class contains all the parameters
    
    properties (Constant)
        %physical constraints
        rows = 50; % fixed, do not change
        cols = 20; % fixed, do not change
        deps = 32; % fixed, do not change
        
        maxMiningDepth = 14; %must be multiples of numOfPeriod
        
        interest = 0.08; % 8 percent
        numOfSchedule = 20; % population size
        numOfPeriod = 2; % number of mine periods
        
        % a constraint that restrict the maximum number of features
        maxFeature = 10; % max number of feature within a period
        
        elitismRate = 0.05; % 5 percent
        extinctionRate = 0.1; % optimum set at 0, do not change
        mutationRate = 0.1; % 10 percent
        
    end
end

