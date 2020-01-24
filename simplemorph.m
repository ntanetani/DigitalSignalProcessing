%% simplemorph
% 71844993 Nozomi Tanetani
% Exercise 5.9
%
filename = uigetfile('./*.jpg');
Is = imread(filename);
imshow(Is);
% the second argument is 'erode' for eroding.
P = morph(Is, 'erode');
% we can repeat the morphological transformation.
P = morph(P, 'dilate');
P = morph(P, 'dilate');
P = morph(P, 'erode');
imshow(P);
%
% morphology transformation
%
function R = morph(Is, op)
    [r, c, d] = size(Is);
    R = uint8(zeros(r,c));
    for i=1:r
        for j=1:c
            for k=1:d
                mc = Is(i,j,k);
                for l = -1:1
                    for m = -1:1
                        cr = i+l;
                        cc = j+m;
                        if (i+l<1)
                            cr = abs(i+l)+1;
                        elseif (i+l>r)
                            cr = 2*r-i-l;
                        end
                        if (j+m<1)
                            cc = abs(j+m)+1;
                        elseif (j+m>c)
                            cc = 2*c - j-m;
                        end
                        if Is(cr,cc,k) < mc && strcmp(op, 'dilate')
                            mc = Is(cr,cc,k);
                        elseif Is(cr,cc,k) > mc && strcmp(op, 'erode')
                            mc = Is(cr,cc,k);
                        end
                    end
                end
                R(i,j,k) = mc;
            end
        end
    end
end