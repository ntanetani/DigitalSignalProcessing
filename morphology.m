%% morphology
% 71844993 Nozomi Tanetani
%
filename = uigetfile('./*.jpg');
Is = imread(filename);
Ig = rgb2gray(Is);
imshow(Ig);
% the second argument is 'erode' for eroding.
P = morph(Ig, 'dilate');
% we can repeat the morphological transformation.
P = morph(P, 'dilate');
P = morph(P, 'dilate');
imshow(P);
%
% morphology transformation
%
function R = morph(Ig, op)
    [r, c] = size(Ig);
    R = uint8(zeros(r,c));
    for i=1:r
        for j=1:c
            mc = Ig(i,j);
            for k = -1:1
                for s = -1:1
                    cr = i+k;
                    cc = j+s;
                    if (i+k<1)
                        cr = abs(i+k)+1;
                    elseif (i+k>r)
                        cr = 2*r-i-k;
                    end
                    if (j+s<1)
                        cc = abs(j+s)+1;
                    elseif (j+s>c)
                        cc = 2*c - j-s;
                    end
                    if Ig(cr,cc) < mc && strcmp(op, 'dilate')
                        mc = Ig(cr,cc);
                    elseif Ig(cr,cc) > mc && strcmp(op, 'erode')
                        mc = Ig(cr,cc);
                    end
                end
            end
            R(i,j) = mc;
        end
    end
end