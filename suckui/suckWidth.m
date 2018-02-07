function [str_suck,end_suck] = suckWidth(loc_pks,loc_vly,lgthData,WS) 
%%suckWidth: returns start and end of peak

%Construct vector of interlacing valleys and peaks
[y,st_idx] = sort([loc_pks;loc_vly]);

%Initialize starts and ends of peak (Think start, peak, end)
str_suck = zeros(size(loc_pks));
end_suck = zeros(size(loc_pks));

st_tmp = y;
lgthPks = length(loc_pks);

%Boolean vector to be used later.
%r(i) = 1 is a peak, r(i) = 0 is a valley.
r = st_idx<=lgthPks;
r_tmp = r;

%It is possible that our vector has the location of 2 peaks together or
% 3 valleys together. In the first case, we artificially insert a valley in
% between the 2 peaks. In second case, artificially insert a peak between
% 2nd and 3rd valley
i=0;
while i <length(st_tmp)-1;
    i = i+1;
    if (r_tmp(i) && r_tmp(i+1)) %%1st case: Peaks
        addVly = round((st_tmp(i)+st_tmp(i+1))/2);
        st_tmp = [st_tmp(1:i);addVly;st_tmp(i+1:end)]; %%Inserts artificial valley
        r_tmp = [r_tmp(1:i);0;r_tmp(i+1:end)]; %%Modifies Boolean vector accordingly
        i = i+1;
    end
    
    if ~(r_tmp(i) || r_tmp(i+1) || r_tmp(i+2)) %%2nd case: Valleys
        addPk = round((st_tmp(i+1)+st_tmp(i+2))/2);
        st_tmp = [st_tmp(1:i+1);addPk;st_tmp(i+2:end)]; %%Inserts artificial peak
        r_tmp = [r_tmp(1:i+1);1;r_tmp(i+2:end)]; %%Modifies Boolean vector accordingly
        i =i+1;
    end
end

%Want location vector to start and end with valley
if r_tmp(end)
    r_tmp = [r_tmp;0];
    st_tmp = [st_tmp;lgthData];
end

if r_tmp(1)
    r_tmp = [0;r_tmp];
    st_tmp = [1;st_tmp];
end

r = r_tmp;
y = st_tmp;
r = logical(r);


%Since y starts with a valley, let that valley be the first start of suck
str_suck(1) = y(1);

%Fills in starts and ends of peaks.
j = 3; %Start at j = 3 since r(1) = 0, r(2) = 1
s = 2; %Start counter
e = 1; %End counter
while (j <= length(r)-2) % end at j = end-2 since r(end-1) = 1, r(end)=0
    if r(j+1)
        str_suck(s) = y(j);
        end_suck(e) = y(j);
        j = j+2;
    else
        end_suck(e)=y(j);
        str_suck(s)=y(j+1);
        j = j+3;
    end
    s = s+1;  
    e = e+1;  
end

if length(end_suck)~=length(str_suck)
   end_suck = [end_suck;y(end)];
else
   end_suck(end) = y(end);
end





