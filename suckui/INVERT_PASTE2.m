function actual_suck_info = INVERT_PASTE2(suck_info, cs)

actual_suck_info = zeros(size(suck_info));
for i = 1:length(suck_info)
  actual_suck_info(i) = find(cs == suck_info(i),1);
end
    