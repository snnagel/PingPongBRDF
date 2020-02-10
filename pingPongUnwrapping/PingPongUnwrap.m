
%% Image Parameters: 

% Image file to be unwrapped: 
imFilename='./IMG_9080.JPG'

%Camera Angle
camAng=[38, 0]*pi/180; % in radians, [polar, azimuthal] 
imRot=-2% % degrees.  camera slightly rotated from level

%  Pixel coordinates of the center of the ping pong ball
centerCoord= [1593,	2900];

% Radius of ping pong ball (in pixels)
R=round(435/2);

% how much to unwrap: 
width=pi

%resolution of unwrapping (N pixels per pi radians)
N=200%200

%used for cropping the image around the ping pong ball
CropDist=R+ 50


%% Do the unwrapping

%camera angles:
azAng=camAng(2)
polAng=camAng(1)

%read in image: 
inputIm=imread(imFilename);

%crop rotate etc
inputIm=flipud(permute(inputIm, [2, 1, 3]));
xc=centerCoord(1)
yc=centerCoord(2)
inputIm=inputIm(yc-CropDist:yc+CropDist,xc-CropDist:xc+CropDist, :);
inputIm = imrotate(inputIm,imRot, 'bilinear','crop');
xc=CropDist+1
yc=CropDist+1

% coordinates for unwrapping:
phi=linspace(-width, width, 6*N)
theta=linspace(-pi/2, 0, N)
remapped=zeros(length(phi), N, 3)

%rotation matrices: 
rz=rotz(azAng*180/pi)
ry=roty(polAng*180/pi)

%step through each pixel of new unwrapped space and find nearest neightbor
%of original image: (this is the implementation of the math in the SI section)
for ii=1:N
    thetai=theta(ii);
    for jj=1:length(phi)
        phij=phi(jj);   
        realCoord=[sin(thetai)*cos(phij);sin(thetai)*sin(phij); cos(thetai)]; %X, Y, Z
        mappedCoord=ry*rz*realCoord; %X', Y', Z'
        beta=atan(mappedCoord(2)/mappedCoord(1));
        if mappedCoord(1)<0
            beta=beta+pi;
        end
        del=acos(mappedCoord(3));
        
        if del<pi/2 % visible part of ping pong ball
            %pixel coordinate of nearest neighbor    
            xp=round(xc-R*sin(del)*sin(beta));
            yp=round(yc-R*sin(del)*cos(beta));
            remapped(jj, ii,:)=inputIm( yp,xp, :);
        end
    end
end

% matrix now type double, so 'image' works with values between 0 and 1.
% original image between 0 and 255. 
remapped=remapped/255;

%% Show data: 
figure
subplot(1,2,  1)
image( inputIm)
axis image
title('original')

subplot(1,2,  2)
image( phi*180/pi,-theta*180/pi, permute(remapped, [2, 1, 3]))
ylabel('\theta (^o)')
xlabel('\phi (^o)')
set(gcf, 'color', 'white')
title('unwrapped')
