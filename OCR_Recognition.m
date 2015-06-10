%processes test image and recognizes classes using training data.
%input: filename, prints all figures if showPlots == 1
function [TestFeatures, compL, coord,res, r, D] = OCR_Recognition(filename, showPlots)
    % training phase.
    [Features, ClassLabels, mean, stdev, C, D, r] = OCR_Extract_Features('./images', showPlots);
    % testing phase.
    testim = imread(filename);
    if showPlots == 1
        figure
        imageshow(testim)
        title('test image');
    end
    %binarize
    th = threshold(testim);
    testim2 = uint8(testim < th);
    if ndims(testim) ~= 2
            testim2 = testim2(:,:,3);
        end
        if showPlots == 1
            figure
            colormap(gray)
            imagesc(~testim2);
        end
        % label and find features.
        L = bwlabel(testim2);
        [TestFeatures, compL, coord] = getFeatures(L, testim2);
        TestFeatures = normalize(TestFeatures, mean, stdev);
        [D, res] = evalr(TestFeatures, Features, ClassLabels);
end
% finds components and features of each component.
% input: label matrix, image copy.
% output: Feature matrix, component label matrix, and coordinates.
function [Features, compL, coord] = getFeatures(L, im2)
Features = [];
compL = [];
coord = [];
Nc = max(max(L));
figure
imagesc(L)
hold on;
for i=1:Nc;
    [r, c] = find(L == i);
    maxr = max(r);
    minr = min(r);
    maxc = max(c);
    minc = min(c);
    sth = 10;
    if maxr - minr + 1 > sth & maxc - minc + 1 > sth
        compL = [compL; i];
        coord = [coord; minr minc maxr maxc]; 
        rectangle('Position', [minc, minr, maxc - minc + 1, maxr - minr + 1], 'EdgeColor', 'w');
        cim = im2(minr:maxr, minc:maxc);
        [centroid, theta, roundness, inmo] = moments(cim, 0);
        Features = [Features; theta, roundness, inmo];
    end
end
hold off
end

%normalizes features.
%input: features, standdeviation, mean
%output: updated features.
function Features = normalize(Features, mean, stdev)
    for j=1:length(Features(1, :))
        sum = 0.0;
        n = length(Features(:,j));
        %normalize.
        for i=1:n
            Features(i,j) = (Features(i,j) - mean(j))/stdev(j);
        end
    end
end

% evaulates recognition rate and Confusion matrix.
%input: Features and class labels.
%output: D and recognition rate.
function [D, res] = evalr(TestFeatures, Features, ClassLabels)
    D = dist2(TestFeatures, Features)
    res = [];
    figure
    imagesc(D)
    title('Test Affinity Matrix');
    [D_sorted, D_index] = sort(D, 2);
    n = length(D_index(:, 1));
    for i=1:n
        closest = ClassLabels(D_index(i, 1));
        res = [res; closest];
    end
end

% computes optimal threshold for an image (Otsu's method). 
% input: image.
% output: threshold.
function th = threshold(im)
    h = hist(double(reshape(im, numel(im), 1)), [0:1:255]);
   
    sum = 0;
    for i=1:255
        sum = sum + (i * h(i));
    end
    
    sumb = 0;
    wb = 0;
    wf = 0;
    mb = 0.0;
    mf = 0.0;
    max = 0.0;
    bt = 0.0;
    t1 = 0.0;
    t2 = 0.0;
    for i=1:255
       wb = wb + h(i);
       if wb == 0
           continue
       end
       wf = numel(im) - wb;
       if wf == 0
           break
       end
       sumb = sumb + (i * h(i));
       mb = sumb/wb;
       mf = (sum - sumb)/wf;
       bt = wb * wf * (mb -mf).^2;
       if bt >= max
           t1 = i;
           if bt > max
               t2 = i;
           end
           max = bt;
       end   
    end
    th = (t1 + t2)/2.0;
end
