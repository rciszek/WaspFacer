function preprocessed_image = preprocess_image( original_image )
%preprocess_image - Preprocesses an image in order to speed up shape
%detection.
%Preprocesses the image given as an input by clustering the points into
%three clusters and by setting the lightest cluster to 256 and the 
%darkest to 0.
%
% Syntax:  preprocessed_image = preprocess_image( original_image )
%
% Inputs:
%    original_image - RGB image as NxMx3 matrix.
%
% Outputs:
%    preprocessed_image - Preprocessed image as as NxMx3 matrix.
%
% Example: 
%    preprocess_image( original_image )
%
%
% Author: Robert Ciszek 
% July 2015; Last revision: 31-May-2017

    cform = makecform('srgb2lab');
    if size(original_image,3) == 4
       original_image = original_image(:,:,1:3); 
    end
    lab_image = applycform(original_image,cform);
    ab = double(lab_image(:,:,2:3));
    nrows = size(ab,1);
    ncols = size(ab,2);
    ab = reshape(ab,nrows*ncols,2);

    %Check if parallel pool exists. If not, create a new one. 
    p = gcp('nocreate'); % 
    if isempty(p)
        parpool(maxNumCompThreads);
    end
    %Cluster pixels in parallel.
    [cluster_idx, cluster_center] = kmeans(ab,3,'distance','sqEuclidean', 'Replicates',10,'Options',statset('UseParallel',1));

    pixel_labels = reshape(cluster_idx,nrows,ncols);

    labels = unique(pixel_labels);

    means = zeros(1,length(labels));

    %Find the mean of each cluster
    for i=1:size(labels,1)
        means(i) = mean(original_image( pixel_labels == labels(i)));
    end

    [B,I] = sort(means);
      
    lightest = labels(I(3)); 
    darkest = labels(I(1)); 

    %Set the pixels in the darkest cluster to 0 and the ones in the lightest to 256.
    g_im = rgb2gray(original_image);
    g_im = imadjust(g_im);
    g_im( pixel_labels == darkest) = 0;
    g_im( pixel_labels == lightest) = 256;
    
    preprocessed_image = g_im;


end

