function [ substracted_frame ] = separate_balls( substracted_frame, masked_image )
    
    % Find all the objects and their properties present in the frame
    props = regionprops(substracted_frame, 'pixelList', 'BoundingBox', 'Eccentricity', 'Centroid');
    % Separate balls from each connected component that seems to have
    % more than one ball in it
    allPixels = int16.empty;
    for i = 1 : size(props, 1)
        % First check if there might be more than one ball in the component
        if props(i).Eccentricity < 0.6
           continue
        end
        allPixels = [allPixels; props(i).PixelList];
    end
    
    % Create an image with visible components that might have more than one
    % ball in it
    current_component = substracted_frame;
    current_component(substracted_frame ~= -1) = 0;
    for i = 1 : size(allPixels, 1)
        current_component(allPixels(i, 2), allPixels(i, 1)) = 255;
    end
    % Create a mask of these components
    mask = repmat(current_component, [1, 1, 3]);
    current_masked_image = masked_image;
    current_masked_image(~mask) = 0;
    %hsv_i = rgb2hsv(current_masked_image);
    %imshow(hsv_i)
    %[X_no_dither,map]= rgb2ind(current_masked_image,4,'nodither');
    %imshow(X_no_dither, map)
        
    % Separate balls in the components
    separated_component = separate_connected_component(current_masked_image);
    % Apply changes on the original substracted frame
    for i = 1 : size(allPixels, 1)
        substracted_frame(allPixels(i, 2), allPixels(i, 1)) = separated_component(allPixels(i, 2), allPixels(i, 1));
    end
    
%     mask = repmat(substracted_frame, [1, 1, 3]);
%     masked_image(~mask) = 0;
%     
%     substracted_frame = separate_connected_component(masked_image);
    %imshow(substracted_frame)
    %hold on
end

function [ balls ] = separate_connected_component(masked_image)
    hsv_image = rgb2hsv(masked_image);
    hue_values = hsv_image(:, :, 1);
    sat_values = hsv_image(:, :, 2);
    greyscale_image = rgb2gray(masked_image);
  
    %x_kernel = [1 0 -1; 2 0 -2; 1 0 -1]; % Sobel kernel
    %y_kernel = [1 2 1; 0 0 0; -1 -2 -1]; 
    x_kernel = [3 0 -3; 10 0 -10; 3 0 -3]; % Sobel kernel
    y_kernel = [3 10 3; 0 0 0; -3 -10 -3]; 
    
    x_hue_convolved = conv2(hue_values, x_kernel, 'same');
    y_hue_convolved = conv2(hue_values, y_kernel, 'same');
    x_sat_convolved = conv2(sat_values, x_kernel, 'same'); 
    y_sat_convolved = conv2(sat_values, y_kernel, 'same');
    
    background = bwmorph(greyscale_image == 0, 'clean', 2);
    bool_x_hue_convolved = x_hue_convolved > 0.9;
    bool_y_hue_convolved = y_hue_convolved > 0.9;
    bool_x_sat_convolved = x_sat_convolved > 1;
    bool_y_sat_convolved = y_sat_convolved > 0.9;
    
    balls = bool_x_hue_convolved | ...
            bool_y_hue_convolved | ...
            bool_x_sat_convolved | ...
            bool_y_sat_convolved | ...
            background;
      
    balls = ~balls;
    balls = medfilt2(balls);
    balls = bwmorph(balls, 'erode', 1);
    %imshow(balls)
    %hold on
%     balls = bwmorph(balls, 'clean', 1);
%     
%     balls = medfilt2(balls);
%     imshow(balls)
%     hold on
%     balls = bwmorph(balls, 'erode', 1);
%     balls = bwmorph(balls, 'thicken', 2);
    
end

