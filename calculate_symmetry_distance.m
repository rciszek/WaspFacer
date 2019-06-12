function [symmetry_distance, un_left_symmetric, un_right_symmetric ]= calculate_symmetry_distance(left_landmarks, right_landmarks, symmetry_axis_start, symmetry_axis_end, draw_plot)
%calculate_symmetry_distance - Calculates continuous asymmetry distance for
%a given shape
%Calculates the continuous asymmetry distance as define by H. Zabrodsky, S. 
%Peleg and D. Avnir in "Symmetry as a continuous feature,", IEEE Transactions 
%on Pattern Analysis and Machine Intelligence, vol. 17, no. 12, pp. 1154-1166, 
%Dec 1995.doi: 10.1109/34.476508
%
% Syntax:  [symmetry_distance, un_left_symmetric, un_right_symmetric ]= calculate_symmetry_distance(left_landmarks, right_landmarks, line_start, line_end, draw_plot)
%
% Inputs:
%    left_landmarks - Landmark coordinates on the left side of the shape as
%    Nx2 array of x and y coordinates
%    right_landmarks - Landmark coordinates on the left side of the shape 
%    as Nx2 array of x and y coordinates
%    line_start - The coordinates of the topmost intersection between the
%    symmetry axis and and the shape
%    line_end - The coordinates of the lowest intersection between the
%    symmetry axis and and the shape
%    draw_plot - Draw plot of the normalized shape and the normalized
%    symmetrized shape
%
% Outputs:
%    symmetry_distance - Continuous symmetry distance
%    un_left_symmetric - Symmetric version of the left landmarks presented unnormalized in the original coordinate system
%    un_left_symmetric - Symmetric version of the right landmarks presented unnormalized in the original coordinate system
%
% Example: 
%    calculate_symmetry_distance(left_landmarks, right_landmarks, [10,10], [50,11], true)
%
% Other m-files required: calculate_polygon_centroid.m
%
% Author: Robert Ciszek 
% July 2015; Last revision: 29-May-2017

    if nargin < 5
       draw_plot = 0; 
    end

    centroid = calculate_polygon_centroid( vertcat(left_landmarks, flipud(right_landmarks)) );  

    left_landmarks = (left_landmarks - centroid);
    right_landmarks = (right_landmarks - centroid);
    coordinates = vertcat(left_landmarks, right_landmarks);
    scaling_factor = mean(sqrt( coordinates(:,1).^2 + coordinates(:,2).^2));

    left_landmarks = left_landmarks ./ scaling_factor;
    right_landmarks = right_landmarks ./ scaling_factor;       

    symmetry_axis_start = (symmetry_axis_start - centroid ) ./scaling_factor;
    symmetry_axis_end = (symmetry_axis_end - centroid ) ./scaling_factor;
 
    a_line_start = repmat(symmetry_axis_start,size(left_landmarks,1),1);
    a_line_end = repmat(symmetry_axis_end,size(left_landmarks,1),1);            
    X = a_line_start + ( a_line_end-a_line_start).*( dot((a_line_end-a_line_start),(left_landmarks -a_line_start),2))./sqrt(sum(abs(a_line_end-a_line_start).^2,2)).^2;

    vr = 2*X - left_landmarks; 

    %Average the left side
    left_average = [ (vr(:,1)+right_landmarks(:,1))/2, (vr(:,2)+right_landmarks(:,2))/2 ];

    X = a_line_start + ( a_line_end-a_line_start).*( dot((a_line_end-a_line_start),(left_average -a_line_start),2))./sqrt(sum(abs(a_line_end-a_line_start).^2,2)).^2; 
    left_reflected = 2*X - left_average; 
    right_reflected = left_average;

    %Unnormalize the coordinates
    un_left_symmetric = (left_reflected  ).*scaling_factor  + centroid;
    un_right_symmetric = (right_reflected ).*scaling_factor + centroid;

    n_landmarks = size(left_landmarks,1) + size(right_landmarks,1);

    %Calculate the distance between the original and symmetrized shape.
    distances = pdist2( vertcat(left_landmarks, right_landmarks), vertcat(left_reflected , right_reflected ));
    distances = diag(distances);
    distance_sum = sum(distances);
    symmetry_distance = distance_sum / (n_landmarks);

    %Draw the plot for debuggin purposes
    if draw_plot
        figure;
        hold on;
        origina_points = vertcat(left_landmarks, right_landmarks);
        symmetric_points = vertcat(left_reflected , right_reflected );
        scatter(origina_points(:,2),origina_points(:,1),10,'green', 'filled');
        scatter(symmetric_points(:,2),symmetric_points(:,1),10,'blue', 'filled');        
        hold off;
    end

end