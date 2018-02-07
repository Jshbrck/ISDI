function tmp_loc = Pk2Pk(input,smallest) 
%%Pk2Pk: Finds peaks of input signal
%%Returns locations of peaks in input signal

%Find peaks
[pks1,loc1] = findpeaks(input); 
[~,loc2,~] = findpeaks(pks1);

%Gives locations of peaks
loc = loc1(loc2);
pks = input(loc); 
tmp_loc=loc;
tmp_pks = pks;

notEnd = 1;
ctr = 0;
while (notEnd)
    ctr = ctr + 1;
    d = tmp_loc(ctr+1)-tmp_loc(ctr);
    if(d<smallest)
        mn_loc = tmp_loc(ctr+(tmp_pks(ctr)>tmp_pks(ctr+1)));
        tmp_pks = tmp_pks (tmp_loc~=mn_loc);
        tmp_loc = tmp_loc (tmp_loc~=mn_loc);
        ctr = ctr - 1;
    end
    notEnd = ~((ctr+1)==length(tmp_loc));
end


end

