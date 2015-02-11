
function [ substracted_frame ] = background_sub(current_frame, background)

    % Get R values from RGB frame
    r_current_frame = current_frame(:, :, 1);
    r_background = background(:, :, 1);
    
    current_frame = rgb2hsv(current_frame);
    background = rgb2hsv(background);
    
    % Get S values from HSV frame
    s_current_frame = current_frame(:, :, 2);
    s_background = background(:, :, 2);
    
    y = size(current_frame, 1);
    x = size(current_frame, 2);
    
    % Create a mask for moving objects
    diff = ((abs(r_current_frame - r_background) > 25) | (abs(s_current_frame - s_background)) > 0.25);
    
    substracted_frame = zeros(y, x);
    
    substracted_frame(diff) = 255;
    
    substracted_frame = bwmorph(substracted_frame, 'erode', 1);
    substracted_frame = bwmorph(substracted_frame, 'close', Inf);
    substracted_frame = medfilt2(substracted_frame);
    
%     substracted_frame = bwmorph(substracted_frame, 'clean', 1);
%     
%     substracted_frame = medfilt2(substracted_frame);
%     substracted_frame = bwmorph(substracted_frame, 'erode', 1);
%     substracted_frame = bwmorph(substracted_frame, 'thicken', 6);
%     substracted_frame = bwmorph(substracted_frame, 'bridge', 5);
%     substracted_frame = bwmorph(substracted_frame, 'fill', 1);
    
    %imshow(substracted_frame)
    %hold on
    
end

