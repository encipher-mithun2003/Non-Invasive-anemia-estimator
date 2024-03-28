% Read the image
img = imread("veera_nail.jpeg");

% Set thresholds for each color channel
red_threshold = 150;    % Adjust as needed
green_threshold = 100;  % Adjust as needed
blue_threshold = 120;   % Adjust as needed

% Create binary masks for each channel based on thresholds
red_mask = img(:, :, 1) > red_threshold;
green_mask = img(:, :, 2) > green_threshold;
blue_mask = img(:, :, 3) > blue_threshold;

% Combine the masks to create a final binary mask
combined_mask = red_mask & green_mask & blue_mask;

% Invert the mask to get finger pixels
finger_mask = ~combined_mask;

% Apply the binary mask to the original image
nail_boundary_img = img;
nail_boundary_img(repmat(finger_mask, [1, 1, size(img, 3)])) = 0;

% Convert the output image to grayscale
gray_nail_boundary_img = rgb2gray(nail_boundary_img);

% Apply a threshold (adjust as needed)
threshold_value = 50;
binary_nail_boundary = gray_nail_boundary_img > threshold_value;

% Perform connected component analysis
cc = bwconncomp(binary_nail_boundary);
num_objects = cc.NumObjects;

% Create a labeled image for each connected component based on neighboring pixels
labeled_nail_boundary_img = labelmatrix(cc);

% Define the neighborhood range
neighborhood_range = 5; % Adjust as needed

% Initialize variables to keep track of similarity counts
max_similarity_labels = zeros(1, 4);
max_similarity_counts = zeros(1, 4);

% Loop through connected components
for k = 1:num_objects
    % Get the pixel indices for the k-th connected component
    pixel_indices = cc.PixelIdxList{k};
    
    % Get row and column indices from linear indices
    [row, col] = ind2sub(size(binary_nail_boundary), pixel_indices);
    
    % Check for neighboring pixels within the specified range
    similarity_count = 0;
    
    for i = 1:numel(row)
        % Define the neighborhood bounds
        row_bounds = max(1, row(i) - neighborhood_range):min(size(binary_nail_boundary, 1), row(i) + neighborhood_range);
        col_bounds = max(1, col(i) - neighborhood_range):min(size(binary_nail_boundary, 2), col(i) + neighborhood_range);
        
        % Find indices of neighboring pixels
        neighbor_indices = sub2ind(size(binary_nail_boundary), row_bounds, col_bounds);
        
        % Check if the pixel values of neighboring pixels are within a certain range
        if all(abs(gray_nail_boundary_img(neighbor_indices) - gray_nail_boundary_img(pixel_indices(i))) <= 50)
            similarity_count = similarity_count + 1;
        end
    end
    
    % Update max similarity labels and counts
    [~, min_idx] = min(max_similarity_counts);
    if similarity_count > max_similarity_counts(min_idx)
        max_similarity_labels(min_idx) = k;
        max_similarity_counts(min_idx) = similarity_count;
    end
end

% Create a figure for displaying the resized grouped images
figure;

% Resize each group image to 20x20 pixels
resized_images = cell(1, 4);

for i = 1:4
    % Create a binary mask for the current group
    group_mask = labeled_nail_boundary_img == max_similarity_labels(i);
    
    % Find the bounding box for the current group
    stats = regionprops(cc, 'BoundingBox');
    boundingBox = stats(max_similarity_labels(i)).BoundingBox;
    
    % Crop the region of interest
    cropped_image = imcrop(img, boundingBox);
    
    % Resize the cropped image to 20x20 pixels
    resized_cropped_image = imresize(cropped_image, [40, 40]);
    
    % Store the resized cropped image in the cell array
    resized_images{i} = resized_cropped_image;
end

% Concatenate the resized images into a single image with two rows and two columns
composite_img = [resized_images{1}, resized_images{2}; resized_images{3}, resized_images{4}];

% Display the resized grouped images as a single image
imshow(composite_img);
title('Resized Grouped Images in a 2x2 Composite Image');

