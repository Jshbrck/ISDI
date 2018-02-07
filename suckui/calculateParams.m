%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This fuction is used to calcualte the following parameters %
%'number_of_sucks',                                          %
%'mean_adjusted_max_pressure_(mmHg)'                         %
%'mean_real_max_pressure(mmHg)',                             %
%'number_of_bursts',                                         %
%'mean_burst_duration(s)',                                   %
%'mean_pause_duration(s)',                                   %
%'mean_number_of_sucks_per_burst',                           %
%'mean_inter_suck_interval(s)'                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [content,d,burstCell] = calculateParams(occurence,length_of_signal,SR)

size_of_pause=2;  

%Using tmpOccurence in TotalMatrix later
tmpOccurence = occurence;

dimension = size(occurence,2);         
%----- Mean of max sucking pressure

adjusted_max_pressure=mean(occurence(3,:));
real_max_pressure=mean(occurence(4,:));

%-----  Filling distance and calculating time between bursts and number of sucks per burst 

there_is_a_pause=0;
if isempty(occurence) %%if occurence is empty, we return -1 to end the program
  content = cell(1);
  content{1,1} = -1;
  d = -1;
  burstCell = -1;
  return 
end
q=occurence(1,1); %Refers to beginning of the suck series before burst

k=1; %Refers to array of time between bursts and array of sucks per burst
j=0;
%Predefining array sizes
distance = zeros(100,1);
array_of_sucks_per_burst = zeros(100,1);
array_of_burst_duration = zeros(100,1);
array_of_inter_burst_intervals = zeros(100,1);

%Filling arrays
for i=1:dimension-1
 %occurence(1,) is start of suck and occurence(2,) is duration of suck
 distance(i)=occurence(1,i+1)-(occurence(1,i)+occurence(2,i));
 if distance(i)>=size_of_pause
      there_is_a_pause=1; 
      if j == i
          array_of_sucks_per_burst(k) = 1;
      else
          array_of_sucks_per_burst(k)=i-j;
      end
      j=i;
      array_of_burst_duration(k)=(occurence(2,i)+occurence(1,i))-q;
      array_of_inter_burst_intervals(k) = distance(i);
      k=k+1;
      q=occurence(1,i+1);
      suck_correction = occurence(1,1:i);
      duration_correction = occurence(1,i+1);
  end
  %Now we correct for the last suck
  if occurence(1,i+1) == occurence(1,end)
      array_of_sucks_per_burst(k) = i+1-j;
      if exist('duration_correction','var')
            array_of_burst_duration(k) = occurence(1,end)+occurence(2,end)-duration_correction;
      else
            array_of_burst_duration(1) = occurence(1,end)+occurence(2,end)-occurence(1,1);
      end
      array_of_inter_burst_intervals(k) = -1;
  end
end

%Removing zeros from arrays
distance = distance(distance~=0);
array_of_sucks_per_burst = array_of_sucks_per_burst(array_of_sucks_per_burst~=0);
array_of_burst_duration = array_of_burst_duration(array_of_burst_duration~=0);
array_of_inter_burst_intervals = array_of_inter_burst_intervals(array_of_inter_burst_intervals~=0);

%Correcting last elements
if j ~= 0       %If there is more than one burst
    array_of_sucks_per_burst(end) = size(occurence,2)-length(suck_correction);
end

%-------- # of bursts and length of pause & inter suck interval
number_of_pause = 0;
%Predefining array sizes
length_of_pause = zeros(100,1);
array_of_inter_suck_interval = zeros(size(tmpOccurence,2),1);
h = 1; % Index to length of pause
j = 1;
%Filling length of pause array
for i=1:length(distance);     %Check the distance to see if there is any gap greater than 2s sample
    if distance(i)>=size_of_pause
       number_of_pause=number_of_pause+1;
       length_of_pause(h)=distance(i);
       h=h+1;
    end
    %------- Inter suck interval
    array_of_inter_suck_interval(j)=(occurence(1,i+1)+occurence(5,i+1))-(occurence(1,i)+occurence(5,i));
    j=j+1; 
end
%Removing zeros from length of pause
length_of_pause = length_of_pause(length_of_pause~=0);

%If there are no pauses then entire signal is a burst
if number_of_pause==0   
   number_of_bursts=1;
   mean_pause_duration=0;
else
   number_of_bursts=number_of_pause+1; 
   mean_pause_duration=mean(length_of_pause);
end

%Removing zeros from array of inter suck interval
%array_of_inter_suck_interval = array_of_inter_suck_interval(array_of_inter_suck_interval~=0); %Getting rid of zeros

total_matrix = [tmpOccurence',array_of_inter_suck_interval];
total_matrix = total_matrix(~all(total_matrix==0,2),:);
array_of_inter_suck_interval = total_matrix(:,7);

%If array isn't empty, replace last element with -1
if ~isempty(array_of_inter_suck_interval)
    %No suck interval for last suck
    array_of_inter_suck_interval(end)=-1; 
end
%Calculating the mean
mean_inter_suck_interval=mean(array_of_inter_suck_interval(1:end-1)); %The last element is always -1 because there is no suck interval

%------Time of Pmax
j=1;
%predefining size
array_of_time_of_Pmax = zeros(100,1);
%assigning values to array elements
for i=1:dimension
    array_of_time_of_Pmax(j)=occurence(1,i)+occurence(5,i);
    j=j+1;
end
%removing zeros
array_of_time_of_Pmax = array_of_time_of_Pmax(array_of_time_of_Pmax~=0);

OT=occurence';               %% Occurence  table
temp(:,1)=(1:size(OT,1));     %% First column is suck#
temp(:,2)=OT(:,1);           %% Second column is time of occurence T.O.O
temp(:,3)=OT(:,2);           %% Third column is suck duration 
temp(:,4)=OT(:,3);            %% Fourth column is adjusted maximum pressure of the suck (max-min)
temp(:,5)=OT(:,4);            %% Fifth column is real maximum pressure  
temp(:,6)=array_of_time_of_Pmax;  %% Sixth column is T of Pmax
temp(:,7)=array_of_inter_suck_interval; %% Seventh column is I.S.I
temp(:,8)=OT(:,6);             %% Eighth column is A.U.C
temp=num2cell(temp);
content={'Suck#', 'T.O.O','Duration','Adjusted Pmax','Real Pmax','T of Pmax','I.S.I','A.U.C'};
content=[content;temp];

%Finding number of sucks
perSuck = content;
perSuck(1,:)=[];
perSuck(:,1) = [];
perSuck = cell2mat(perSuck);
perSuck = perSuck(~all(perSuck==0,2),:);
number_of_sucks = size(perSuck,1);

%Calculating mean burst duration and mean num of sucks per burst
if there_is_a_pause==1
    mean_burst_duration=mean(array_of_burst_duration);
    mean_number_of_sucks_per_burst=mean(array_of_sucks_per_burst);
else
    mean_burst_duration=length_of_signal/SR; % Assuming before and after the segment is pause
    mean_number_of_sucks_per_burst=number_of_sucks;
end

%Forming burst number vector
burstNum = zeros(100,1);
for i = 1:length(array_of_sucks_per_burst)
    burstNum(i) = i;
end
burstNum = burstNum(burstNum~=0);
    
%Forming the cell for burst data
burstContent = [burstNum,array_of_sucks_per_burst,array_of_burst_duration,array_of_inter_burst_intervals];
burstCell = num2cell(burstContent);
    

%Forming the cell for suck data
d={'size of signal(s)','number of sucks','mean adjusted max pressure (mmHg)','mean real max pressure(mmHg)','number of bursts','mean burst duration(s)','mean pause duration(s)','mean number of sucks per burst','mean inter_suck interval(s)'; length_of_signal/SR,number_of_sucks,adjusted_max_pressure,real_max_pressure,number_of_bursts,mean_burst_duration,mean_pause_duration,mean_number_of_sucks_per_burst,mean_inter_suck_interval};

