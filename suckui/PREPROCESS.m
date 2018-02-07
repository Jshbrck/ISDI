function output = PREPROCESS(input) 
%%PREPROCESS: Running low- and high-pass on phi_k.
%%Output: Processed eigenvector from .... whereever
%%LOW_PASS will remain input until further analysis is done.
x = input;

%Apply FFT to input 
f_x = fft(x);

%Define low-pass filter threshold
LOW_PASS = 0.8*max(abs(f_x));

%Apply low-pass filter
f_x(abs(f_x) > LOW_PASS) = 0;  %Actual application of filter

%Return back to pressure domain
x = ifft(f_x);

%high-pass filter
output = sosmooth3(x,61);

end

