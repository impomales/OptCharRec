% processes images, stores features.
% inputs: directory containing images, 1 to show plot, else dont show.
% output: Features matrix, class labels. 
function [Features, ClassLabels, mean, stdev, D, C, r] = OCR_Extract_Features(path, showPlot)
    Features = [];
    ClassLabels = [];
    files = dir( strcat(path, '/*.bmp'));
    for i=1:length(files)
        %open image
        file = strcat(strcat(path, '/'), files(i).name);
        letter = files(i).name(1);
        im = imread(file);
        if showPlot == 1
            figure
            imshow(im);
            title(letter);
        end
        % binarization.
        th = threshold(im);
        im2 = uint8(im < th);
        if ndims(im) ~= 2
            im2 = im2(:,:,3);
        end
        if showPlot == 1
            figure
            colormap(gray)
            imagesc(~im2);
        end
        % label and find features.
        fprintf('%s', files(i).name);
        disp(size(im2))
        L = bwlabel(im2);
        [Features, ClassLabels] = BoundingBox(L, im2, Features, ClassLabels, letter, showPlot);
    end
    [Features, mean, stdev] = normalize(Features);
    [D, C, r] = evalr(Features, ClassLabels);
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

% normalizes the Feature matrix.
%input: Feature matrix.
function [Features, mean, stdev] = normalize(Features)
    mean = [];
    stdev = [];
    for j=1:length(Features(1, :))
        sum = 0.0;
        n = length(Features(:,j));
        %compute mean.
        for i=1:n
            sum = sum + Features(i,j);    
        end
        mean = [mean, (sum/n)];
        %compute stdev.
        diff = 0.0;
        for i=1:n
            diff = diff + (Features(i, j) - mean(j)).^2;
        end
        stdev = [stdev, sqrt(diff/n)];
        %normalize.
        for i=1:n
            Features(i,j) = (Features(i,j) - mean(j))/stdev(j);
        end
    end
end

% evaulates recognition rate and Confusion matrix.
%input: Features and class labels.
%output: D and Confusion matrices, and recognition rate.
function [D, C, r] = evalr(Features, ClassLabels)
    D = dist2(Features, Features);
    res = [];
    r = 0.0;
    figure
    imagesc(D)
    title('Affinity Matrix');
    [D_sorted, D_index] = sort(D, 2);
    n = length(D_index(:, 2));
    for i=1:n
        closest = ClassLabels(D_index(i, 2));
        res = [res; closest];
        if ClassLabels(i) == closest
            r = r + 1;
        end
    end
    r = r/n;
    C = ConfusionMatrix(ClassLabels, res, 16);
    figure
    imagesc(C)
    title('Confusion Matrix');
end