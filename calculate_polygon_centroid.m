function centroid = calculate_polygon_centroid( coordinates )
%calculate_polygon_centroid - Calculates the centroid of a given
%non-self-intersecting closed polygon.
%Calculates the centroid of a given non-self-intersecting closed polygon.
%The coordinates are assumed to be given in the order along the polygons
%perimeter.
%
% Syntax:  centroid = calculate_polygon_centroid( coordinates )
%
% Inputs:
%    coordinates - Nx2 array of coordinates
%
% Outputs:
%    centroid - Coordinates of the polygons centroid
%
% Example: 
%    calculate_polygon_centroid([1 1; 10 0; 5 10])
%
%
% Author: Robert Ciszek 
% July 2015; Last revision: 29-May-2017

    coordinates(end+1,:) = coordinates(1,:);

    centroid = [0,0];
    area = 0;
        
    for c = 1:size(coordinates,1)-1
        centroid(1) = centroid(1) + ( coordinates(c,1)+coordinates(c+1,1) ) * ( coordinates(c,1)*coordinates(c+1,2) - coordinates(c+1,1)*coordinates(c,2) ); 
        centroid(2) = centroid(2) + ( coordinates(c,2)+coordinates(c+1,2) ) * ( coordinates(c,1)*coordinates(c+1,2) - coordinates(c+1,1)*coordinates(c,2) );   
        area = area + ( coordinates(c,1)*coordinates(c+1,2) - coordinates(c+1,1)*coordinates(c,2) );      
    end

    area = area / 2;
    centroid = centroid / (6*area);
    
end