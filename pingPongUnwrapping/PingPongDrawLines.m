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

%used for cropping the image around the ping pong ball
CropDist=R+ 50

theta_vals=[0:22.5:90] %degrees.  Lines of constant theta to draw
phi_vals=[-180:45:180] %degrees.  Lines of constant phi to draw

%%

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

phi=linspace(0,2* pi)
theta=linspace(-pi/2, 0)


%rotation matrices: 
rz=rotz(azAng*180/pi)
ry=roty(polAng*180/pi)

%step through each pixel of new unwrapped space and find nearest neightbor
%of original image: (this is the implementation of the math in the SI section)

figure
subplot(1, 2, 1)
image( inputIm)
axis image
hold on

subplot(1, 2, 2)
image( inputIm*10)
axis image
hold on

%draw lines of constant theta: 
for ii=1:length(theta_vals)
    thetai=theta_vals(ii)*pi/180;
    x=[]
    y=[]
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
            %pixel coordinate    
            xp=(xc-R*sin(del)*sin(beta));
            yp=(yc-R*sin(del)*cos(beta));
            x=[x, xp]
            y=[y, yp]
        end
    end
    subplot(1, 2, 1)
    plot(x, y, 'w')
    subplot(1, 2, 2)
    plot(x, y,'color', [0, 0.7, 0])
end

%draw lines of constant phi: 
for jj=1:length(phi_vals)
    phij=phi_vals(jj)*pi/180;
    x=[]
    y=[]
    for ii=1:length(theta)
        thetai=theta(ii);
        realCoord=[sin(thetai)*cos(phij);sin(thetai)*sin(phij); cos(thetai)]; %X, Y, Z
        mappedCoord=ry*rz*realCoord; %X', Y', Z'
        beta=atan(mappedCoord(2)/mappedCoord(1));
        
        if mappedCoord(1)<0 % inverse tan domain correction. 
            beta=beta+pi;
        end
        
        del=acos(mappedCoord(3));
        
        if del<pi/2 % visible part of ping pong ball
            %pixel coordinate of nearest neighbor    
            xp=round(xc-R*sin(del)*sin(beta));
            yp=round(yc-R*sin(del)*cos(beta));
            x=[x, xp]
            y=[y, yp]
        end
    end
    subplot(1, 2, 1)
    plot(x, y, 'w')
    subplot(1, 2, 2)
    plot(x, y, 'color', [0, 0.7, 0])
end

th=linspace(0, -pi)
plot(R*cos(th)+yc, R*sin(th)+xc, 'r')


