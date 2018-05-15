%File-SysState.m
%Contains properties and methods of SysState class.(Represents state of the system)

classdef SysState
    properties
        Number; %state number j,class number-k
        Value; %Sum of number of server used by each class( nj=sum(nk(j) )
        Set;% set of servers used by each class in the current state ( Sj=SET{nk(j)} )
        Probability;%Probability of current state pi(nj)
        Valid;%to find if the configuration of current set is valid with respect to the capacity constrints
        base; %for storing maximum capacity
        NormalizationConstant; %for storing normalixation constant of the whole system
        traffic;% for storing lamda/u array
        Capacity;%for storing capacity array
        ServerUsage;%for storing bkl matrix 
        Contribution; % Contribution of current state to the whole system
        LinkSet;%occupation on each link
    end
    methods
        
        %Constructor for creating object
        function S= SysState
            
            S.Number=0;
            S.Value=0;
            S.base=4;
            S.Valid=0;
            S.Probability=1;
            S.NormalizationConstant=1;
            S.Contribution=1;
        end
        
        
        
        %Initialization and updating prameters 
        function S= Initialize(S,set,base)
            
            S.Number=0;
            S.Set=set;
            S=S.UpdateStateNum;
            S.base=base;
            S.Value=sum(set);
           
            
        end
        
        
        function S=UpdateStateNum(S)
            set=S.Set;
            
            for i=1:length(set)
                S.Number=S.Number+(S.base)^(i-1)*set(i);%compute unique statenumber for current configuration
            end
            S.Number=S.Number+1;
        end
        
        function S= SetTraffic(S,traffic)
            S.traffic=traffic;
        end
        
        function S= SetCapacity(S,Capacity)
            S.Capacity=Capacity;
        end
        
        function S= SetServerUsage(S,ServerUsage)
            S.ServerUsage=ServerUsage;
        end
        
        function S= computeLinkSet(S)
            S.LinkSet=S.Set*S.ServerUsage;
        end
         
        
        
        
        %Compute if the curernt state  configuration satisfies the Capacity
        %constraints
        function S= ComputeValidity(S)
            S.Valid=1;
            Nclass=length(S.Set);
            Nlinks=length(S.Capacity);
            
            for i=1:Nlinks
            sum=0;
            for j=1:Nclass
               sum=sum+S.ServerUsage(j,i)*S.Set(j);
                
            end
            if(sum>S.Capacity(i))
               S.Valid=S.Valid*0;
            else
                S.Valid=S.Valid*1;
            end
                
            end
            
            
        end
        
        %Compute contribution as a product form of each class
        function S= ComputeContribution(S)
            S.Contribution=1;
            for i=1:length(S.Set)
                S.Contribution=S.Contribution*(S.traffic(i) ^ S.Set(i)/factorial(S.Set(i)));
            end
            
        end
        
        
        %Update NormalizationConstant computed from the statespace
        function S= SetNormalizationConstant(S,NormalizationConstant)
            S.NormalizationConstant=NormalizationConstant;
        end
        
        
        %Compute Probability of current state from the contribution and NormalizationConstant
        
        function S= ComputeProbability(S)
            
            S.Probability=S.Contribution/S.NormalizationConstant;
        end
        
        
    end
    
end