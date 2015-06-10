function [Features, classLabels] = BoundingBox(L, im2, Features, classLabels, letter, showPlot)
Nc = max(max(L));
if showPlot == 1
    figure
    imagesc(L)
end
hold on;
for i=1:Nc;
    [r, c] = find(L == i);
    maxr = max(r);
    minr = min(r);
    maxc = max(c);
    minc = min(c);
    rectangle('Position', [minc, minr, maxc - minc + 1, maxr - minr + 1], 'EdgeColor', 'w');
    cim = im2(minr:maxr, minc:maxc);
    %size threshold.
    sth = 10;
    if maxr - minr + 1 > sth & maxc - minc + 1 > sth 
        [centroid, theta, roundness, inmo] = moments(cim, 0);
        Features = [Features; theta, roundness, inmo];
        classLabels = label(classLabels, letter);
    end
end
hold off
end

function classLabels = label(classLabels, letter)
    switch letter
            case 'a'
                classLabels = [classLabels; 1];
            case 'd'
                classLabels = [classLabels; 2]; 
            case 'f'
                classLabels = [classLabels; 3];
            case 'h'
                classLabels = [classLabels; 4];
            case 'k'
                classLabels = [classLabels; 5]; 
            case 'm'
                classLabels = [classLabels; 6];    
            case 'n'
                classLabels = [classLabels; 7];
            case 'o'
                classLabels = [classLabels; 8]; 
            case 'p'
                classLabels = [classLabels; 9];
            case 'q'
                classLabels = [classLabels; 10];
            case 'r'
                classLabels = [classLabels; 11];
            case 's'
                classLabels = [classLabels; 12];
            case 'u'
                classLabels = [classLabels; 13];
            case 'w'
                classLabels = [classLabels; 14];
            case 'x'
                classLabels = [classLabels; 15];
            case 'z'
                classLabels = [classLabels; 16];
    end
end