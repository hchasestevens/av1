function [ substracted_frame ] = separate_balls( substracted_frame, masked_image )
    
%     % Find all the objects and their properties present in the frame
%     props = regionprops(substracted_frame, 'pixelList', 'BoundingBox');
%     % Separate balls from each connected component that seems to have
%     % more than one ball in it
%     for i = 1 : 1%size(props, 1)
%         % First check if there might be more than one ball in the component
%         pixelLists = props(i).PixelList;
%         % Create a image with only one visible component in it
%         current_component = substracted_frame;
%         current_component(substracted_frame ~= -1) = 0;
%         for j = 1 : size(pixelLists, 1)
%             current_component(pixelLists(j, 2), pixelLists(j, 1)) = 255;
%         end
%         % Create a mask of this component
%         mask = repmat(current_component, [1, 1, 3]);
%         current_masked_image = masked_image;
%         current_masked_image(~mask) = 0;
%         % Separate balls in the component
%         separated_component = separate_connected_component(current_masked_image);
%         % Apply changes on the original substracted frame
%         for j = 1 : size(pixelLists, 1)
%             substracted_frame(pixelLists(j, 2), pixelLists(j, 1)) = separated_component(pixelLists(j, 2), pixelLists(j, 1));
%         end
%     end
    
    mask = repmat(substracted_frame, [1, 1, 3]);
    masked_image(~mask) = 0;
    substracted_frame = separate_connected_component(masked_image);
    
    %imshow(substracted_frame);
    %hold on
    
end

function [ balls ] = separate_connected_component(masked_image)
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
    balls = bwmorph(balls, 'thicken', 2);
end

