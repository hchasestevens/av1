
function [ substracted_frame ] = background_sub(current_frame, background)
%BACKGROUND_SUB Summary of this function goes here
%   Detailed explanation goes here

    current_frame2 = current_frame;
    
    current_frame = rgb2hsv(current_frame);
    background = rgb2hsv(background);
    
    s_current_frame = current_frame(:, :, 2);
    s_background = background(:, :, 2);
    
    h_current_frame = current_frame(:, :, 1);
    h_background = background(:, :, 1);
    
    %hue_current_frame = 


    threshold = 0.10;
    
    y = size(current_frame, 1);
    x = size(current_frame, 2);
    
    diff = (abs(s_current_frame - s_background)) > 0.25; % | ... 
            %(min(abs(h_current_frame - h_background), 1 - abs(h_current_frame - h_background))) > 0.4;
    
    substracted_frame = zeros(y, x);
    
    %mask = diff > threshold;
    
    substracted_frame(diff) = 255;
    substracted_frame = bwmorph(substracted_frame, 'erode', 2);
    substracted_frame = bwmorph(substracted_frame, 'clean', 1);
    
    substracted_frame = medfilt2(substracted_frame);
    substracted_frame = bwmorph(substracted_frame, 'erode', 1);
    substracted_frame = bwmorph(substracted_frame, 'thicken', 6);
    substracted_frame = bwmorph(substracted_frame, 'bridge', 5);
    substracted_frame = bwmorph(substracted_frame, 'fill', 1);
    
    %mask = repmat(substracted_frame, [1, 1, 3]); 
    %current_frame2(~mask) = 0;
    %substracted_frame = current_frame2;
    
    %substracted_frame = (min(abs(v_current_frame - v_background), 1 - abs(v_current_frame - v_background)));

    %substracted_frame = adapthisteq(substracted_frame, 'NumTiles', [x/4 y/4], 'NBins', 16);
end

