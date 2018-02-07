function output = POD_STUFF(input_matrix, k) %%DoF = 3, default
  
  [~,eigVal]=eig(input_matrix'*input_matrix);
  eigVal = flip(diag(eigVal));
% k=0.9;
% prompt='Number of eigenvalues: ';
% n=input(prompt);
% r1=randi(10000,n,1);
B=sum(eigVal);
A=cumsum(eigVal);
p= A./B;
a= p>k;
if sum(a) ~= 0
    DoF= length(a)-sum(a)+1;
    [eigVec,eigVal]=eig(input_matrix*input_matrix');
    %output = eigVec (:,end-DoF+1:end);
    eigVal = diag(eigVal);
    eigVal = eigVal(end-DoF+1:end);
    % weighted first eigenvector & second eigenvector weighted less
    output = eigVec (:,end-DoF+1:end).*repmat(eigVal',200,1)./sum(eigVal);
else
    error('no significant eigenvalues detected, try choosing a smaller threshold')
end