function [occurence,real_signal,real_SR]=suckDetector (prototype,SR,ccoeff,threshold,signal)
occurence=zeros(6,100);

%Finding dimension of prototype subspace
proto_dimension = size(prototype,2);

%------Save the real signal before resampling
real_signal=PREPROCESS(signal);                   
%real_signal=real_signal-baseline;    % Adjust the baseline 
real_SR=SR;

%------Initialization
size_real_signal=round(length(real_signal));
cutoff_pressure=threshold;             %cutoff pressure is threshold i.e. 20 mmHg  
smallest_suck=round(SR*0.250);         %SR x 0.250s  smallest suck is 0.250 s
widest_suck=round(SR*2);               %SR x 2s      widest suck is 2s   
step1=round(0.2 * smallest_suck);
step2=round(0.2 * smallest_suck);      % overlap equals to 20% of samllest suck
j=1;
correlation_coeff=ccoeff;                          

%This is what we are resampling to
k = 50;
%Resample prototype to have same dimension as data
prototype = resample(prototype,k,length(prototype));  
tic
%----Detection
[suck_width,start_loc]=PEAK2PEAK(real_signal,cutoff_pressure);

%Checking the last element to make sure it does not extend past size of
%signal
if start_loc(end)+suck_width(end) > length(real_signal)
    suck_width(end) = length(real_signal)-start_loc(end);
end    

for i = 1:length(start_loc) 
    catch_a_suck=0;                           % There is no suck 
    counter = start_loc(i);
    window_size=suck_width(i);    %Start with smallest suck interval
    data = real_signal(start_loc(i):start_loc(i)+suck_width(i));
    data = resample(data,k,length(data));
    if norm(data-mean(data)) > cutoff_pressure 
        corrcos = zeros(1,proto_dimension);
        while ~catch_a_suck && window_size<=widest_suck && (counter+window_size)<=size_real_signal 
            data=real_signal(counter:counter+window_size); % read a window
            %resampling to 200 to correct for prototype size
            data=resample(data,k,length(data)); 
            %Here we calculate the correlation between proto
            %and data
            for m=1:proto_dimension
                coeff=corrcoef(data,prototype(:,m)); %Computing corrcoef
                corrcos(m)=coeff(1,2);   %This is corrcoef of this window
            end
            corrcos(corrcos<0)=0;
            y = sqrt(sum(corrcos.^2)); %this is the correlation 
            %Compare to input corrcoef
            is_suck=1;              %Flag as possible suck
            go_ahead=1;             %Flag to continue to next loop
            while go_ahead  && counter+window_size+step2<= size_real_signal&&  window_size-step2>=smallest_suck%as far as you see a better signal move the begining of the window (end is fixed)
                counter=counter+step1;      %Move window to right
                window_size=window_size-step2;  %Shrink window
                data=real_signal(counter:counter+window_size);   %Redifine data
                %resampling to 200 to correct for prototype size
                data=resample(data,k,length(data));
                %Here we calculate the correlation between proto
                %and data
                for m=1:proto_dimension
                    coeff=corrcoef(data,prototype(:,m)); %Computing corrcoef
                    corrcos(m)=coeff(1,2);   %This is corrcoef of this window
                end
                corrcos(corrcos<0)=0;
                x = sqrt(sum(corrcos.^2));  %new correlation to compare with
                %Is new corrcoeff better?
                
                if x>y             
                       y=x;         %If yes, take new value
                else
                    go_ahead=0;     %If no, end this loop, keep previous value
                    counter=counter-step1;  %Move window back to where it was previously
                    window_size=window_size+step2;  %Expand window back to previous size
                end     %if statement
            end %Third while loop

            if y < correlation_coeff
                is_suck = 0;
            end
                
            % if there is suck in this window and window is big enough
            if is_suck && window_size>=smallest_suck  
                %Defining beginning and end of suck?

                 b_suck=counter;
                 e_suck=(counter+window_size);

                 % not exceeding the end of real signal
                 if e_suck>size_real_signal   
                     e_suck=size_real_signal; 
                 end   

                 %Finding max and min pressures of suck
                 [max_pressure,index]=max(real_signal(b_suck:e_suck));
                 min_pressure=min(real_signal(b_suck:e_suck));
                               
                 %Final check to see if difference in pressure is greater
                 %than cutoff pressure
                 catch_a_suck=1;       %verified suck
                 occurence(1,j)=b_suck/real_SR;  % beginning  of a suck
                 occurence(2,j)=(e_suck-b_suck)/real_SR;   %length of suck
                 occurence(3,j)=max_pressure-min_pressure;
                 occurence(4,j)=max_pressure;
                 occurence(5,j)=index/real_SR;
                 occurence(6,j)=trapz(real_signal(b_suck:e_suck)); %Area under curve
                 j=j+1;                       
                 counter=counter+window_size;  % go to the end of the suck
            else
                 window_size=window_size+step1;   %strech the window
            end
        end %second while loop        
    end %if statement with norm
end %first for loop

%Getting rid of zeros to shorten next for loop
occurence = occurence';
occurence = occurence(~all(occurence==0,2),:);
occurence = occurence'; 

%Getting rid of sucks with the same time of peak
for n=1:length(occurence(5,:))-1
    if occurence(1,n)+occurence(5,n) == occurence(1,n+1)+occurence(5,n+1)
        occurence(:,n) = zeros(6,1);
    end    
end 

%removing zeros that may have been added in loop
occurence = occurence';
occurence = occurence(~all(occurence==0,2),:);
occurence = occurence'; 
toc