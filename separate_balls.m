function [ balls ] = separate_balls( substracted_frame, masked_image )
    mask = repmat(substracted_frame, [1, 1, 3]); 
    masked_image(~mask) = 0;

    hsv_image = rgb2hsv(masked_image);
    hue_values = hsv_image(:, :, 1);
    sat_values = hsv_image(:, :, 2);
    greyscale_image = rgb2gray(masked_image);
    
    x_kernel = [1 0 -1; 2 0 -2; 1 0 -1]; % Sobel kernel
    y_kernel = [1 2 1; 0 0 0; -1 -2 -1]; 
    x_hue_convolved = conv2(hue_values, x_kernel, 'same');
    y_hue_convolved = conv2(hue_values, y_kernel, 'same');
    x_sat_convolved = conv2(sat_values, x_kernel, 'same'); 
    y_sat_convolved = conv2(sat_values, y_kernel, 'same');
    
    background = bwmorph(greyscale_image == 0, 'clean', 2);
    bool_x_hue_convolved = x_hue_convolved > 0.5;
    bool_y_hue_convolved = y_hue_convolved > 0.5;
    bool_x_sat_convolved = x_sat_convolved > 0.5;
    bool_y_sat_convolved = y_sat_convolved > 0.25;
    
    balls = bool_x_hue_convolved | ...
            bool_y_hue_convolved | ...
            bool_x_sat_convolved | ...
            bool_y_sat_convolved | ...
            background;
      
    balls = ~balls;
        
    balls = bwmorph(balls, 'clean', 1);
    balls = medfilt2(balls);
    balls = bwmorph(balls, 'erode', 1);
    balls = bwmorph(balls, 'thicken', 3);

end

