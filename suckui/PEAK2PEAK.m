function [actual_suck_width, actualStrSk] = PEAK2PEAK(p_b,cutoff)
%%PEAK2PEAK: Finds peaks for input signal
%%Returns initial suck width and start of peaks

%Crops input signal for better analysis
[crop_data, id_vec] = PASTE3(p_b, cutoff, 200);

loc_pks = Pk2Pk(crop_data,75); %Finds peaks of cropped data;
loc_vly = Pk2Pk(-crop_data,75);%Finds valleys of cropped data

lgthData = length(crop_data);
WS = 500;

%Finds starts and ends of peaks, i.e. valleys before and after peaks.
[str_suck,end_suck] = suckWidth(loc_pks,loc_vly,lgthData,WS);

%Identifies start and ends of peaks on original signal.
%calculates starting suck widths
csId = cumsum(id_vec);
actualStrSk = INVERT_PASTE2(str_suck,csId);
actualEndSk = INVERT_PASTE2(end_suck,csId);
actual_suck_width = actualEndSk - actualStrSk;
end

