%Declaration of variables


lambda = [0.8 0.8 0.8 0.8];
C = [3 6 4 5];


B = [0.5 0.5 0.5 0.5]; %Initial guess
Ac = 0.0001; %Accuracy
Ae = 1000; %Actual error
n=0; %Iteration counter
Bold = B;
ServerUsage=[1 1 0 0;0 1 1 0; 0 0 1 0;1 0 0 1];%bkl matrix
%ServerUsage=[1  0 0 0;0 1 0 0; 0 0 1 0;0 0 0 1];%bkl matrix

base=max(C);
totalcapacity=sum(C);
l=size(ServerUsage);
for i=1:l(1)
    Bk(i)=sum(ServerUsage(i,:));
end

%start-Erlang Fixed-Point Method
while Ae > Ac
    
    B(1) = erlangb(C(1), lambda(1)*(1-B(2)) + lambda(4)*(1-B(4)));
    B(2) = erlangb(C(2), lambda(1)*(1-B(1)) + lambda(2)*(1-B(3)));
    B(3) = erlangb(C(3), lambda(3) + lambda(2)*(1-B(2)));
    B(4) = erlangb(C(4), lambda(4)*(1-B(1)));
    maxerror = [abs(B(1)-Bold(1)) abs(B(2)-Bold(2)) abs(B(3)-Bold(3)) abs(B(4)-Bold(4))];
    Ae = max(maxerror)*100;
    Bold = B;
    n = n+1;
end

%Compute blocking probability of individual class from blocking probability
%of links
b(1)=1-(1-B(1))*(1-B(2));
b(2)=1-(1-B(2))*(1-B(3));
b(3)=1-(1-B(3));
b(4)=1-(1-B(1))*(1-B(4));

B %Blocking probability of links -Erlang Fixed Point
n% Number of iterations to solve
b%Blocking Probability of classes-Erlanf Fixed point

%End-Erlang Fixed-Point Method




%Start- Brute force calclulation

p=0;
%Initialization of all possible State Space (Valid + Invalid Configuration)
for i=0:base
    for j=0:base
        for k=0:base
            for l=0:base
                p=p+1;
                SP(p)=SysState;
                SP(p)=SP(p).Initialize([l,k,j,i],base);%Iniatilization of State Objaect
                SP(p)=SP(p).SetTraffic(lambda);%Configuring tarffic values in the State Object
                SP(p)=SP(p).SetCapacity(C);%Configuring capacity values in the State Object
                SP(p)=SP(p).SetServerUsage(ServerUsage);%Configuring Bkl matrix in the State Object
                SP(p)=SP(p).ComputeValidity;%compute validity of current configuration
                SP(p)=SP(p).ComputeContribution;% Compute product form for each class
                SP(p)=SP(p).computeLinkSet;
                
            end
        end
    end
end

%Computation of Normalization constant from Valid Set
NormalizationConstant=0;
for i=1:length(SP)
    if(SP(i).Valid)
        NormalizationConstant=NormalizationConstant+SP(i).Contribution;
    end
end

%Computiing Probability of each state from individual contributions and
%from Normalization Constant computed above for all valid sates.
for i=1:length(SP)
    SP(i)= SP(i).SetNormalizationConstant(NormalizationConstant);
    SP(i)= SP(i).ComputeProbability;
    
end
sumP=0;



%Check if total probability of all valid states is 1.
for i=1:length(SP)
    if(SP(i).Valid)
        sumP=sumP+SP(i).Probability;
    end
end

sumP % Assertion that total probability is 1.
p=0;


%Seperating Valid Statespace
for i=1:length(SP)
    if(SP(i).Valid)
        p=p+1;
        SPnew(p)=SP(i);%for storing only valid configurations
    end
end




Bl=zeros(1,4);%Initilizing Blocking probabilities of each link to 0
for i=1:length(C)
    Bsum=0;
    for j=1:length(SPnew)
        
        if(SPnew(j).LinkSet(i)==C(i))
            Bsum=Bsum+SPnew(j).Probability; % Summing probailitis of states which reach blocking capcity of the link to find Blocking probability of the corresponding link.
        end
    end
    Bl(i)=Bsum;
end

%Compute blocking probability of individual class from blocking probability
%of links

bl(1)=1-(1-Bl(1))*(1-Bl(2));
bl(2)=1-(1-Bl(2))*(1-Bl(3));
bl(3)=1-(1-Bl(3));
bl(4)=1-(1-Bl(1))*(1-Bl(4));


Bl %Blocking probability of links -Brute Force
bl %Blocking Probability of classes-Brute Force

for j=1:length(SPnew)
    
    SetV(j,:)=SPnew(j).Set;% Valid set 
end
for j=1:length(SPnew)
    
    SetP(j)=SPnew(j).Probability;% Probalities of valid sets.
end

%End- Brute force calclulation

