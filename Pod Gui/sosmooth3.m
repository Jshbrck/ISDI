function output = sosmooth3(x,N) %%N is odd
 h = ones(N,1);
 output = conv(h,x);
 a = [(1:N)';N.*ones(length(output)-(2*N),1);(N:-1:1)'];
 output = output./a;
 n = (N-1)/2;
 cut = output(2*n+1:end-(2*n));
 for i = 1:n 
     cut = [output(2*(n-i+1)-1);cut;output(2*(n-1))];
 end
 output = cut;
end
