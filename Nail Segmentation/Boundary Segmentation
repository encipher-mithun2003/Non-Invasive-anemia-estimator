% Read the image
img = imread("nail_image.jpg");

% Display the original image
subplot(1, 2, 1);
imshow(img);
title('Original Image');

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

% Display the image with the identified fingernail boundary
subplot(1, 2, 2);
imshow(nail_boundary_img);
title('Fingernail Boundary');
