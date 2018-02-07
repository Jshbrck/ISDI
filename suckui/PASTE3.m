function [crop_data, id_vec] = PASTE3(input, cutoff, smallest)
%%PASTE3: Crops data 

data = input;
r = rem(length(data),smallest);

%Ensures data vector is of length divisible by 'smallest';
%Used for reshaping
if r~= 0
  v=repmat(data(end),smallest-r,1);
  data = [data; v];
  r = smallest-r;
end

%calculating norm(data - mean(data))
l = length(data)/smallest;
temp_data = (reshape(data,[smallest,l]))';
d = temp_data - repmat(mean(temp_data,2),1,smallest); %'data-mean(data)'
N = sqrt(diag(d*d')); %Norms of each row of d

%Condition for cropping data
%if N > cutoff for specific row, id_vec for that row is a row of ones,
%else a row of zeros
id_vec = (N>cutoff)*ones(1,smallest);
id_vec = reshape(id_vec,l*smallest,1);

crop_data = data(logical(id_vec));


end

