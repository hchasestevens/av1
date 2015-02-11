function [] = draw_line( x1, y1, x2, y2, color )
	
    x_points = linspace(x1, x2, 50);  
    y_points = linspace(y1, y2, 50); 
    plot(x_points, y_points, 'Color', color);
    
end
