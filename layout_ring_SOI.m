%Md Borhan Mia
%Texas Tech University 
%05/04/2019
clear all;
close all;
clc;

%% setup CNSTdefaultValues file

% save file name
fname='layout_resonator';
fname_gds=[fname,'.gds'];                                  % file name
fname_script=[fname,'.cnst'];                              % file name for cnst script

% save folder
fpath='.\layout\';                                         % save your directory for klayout
if (exist(fpath) == 0)
    mkdir (fpath);
end

% open & replace the saving folder
fid=fopen('CNSTdefaultValues.xml','r');
f=fread(fid,'*char')';
fclose(fid);
fs_ind1=strfind(f,'<SaveToDirectory>')+17;
fs_ind2=strfind(f,'</SaveToDirectory>')-1;
f=strrep(f,f(fs_ind1:fs_ind2),fpath);
fid=fopen('CNSTdefaultValues.xml','w');
fprintf(fid,'%s',f);
fclose(fid);
%% geometric parameters
% unit: um

% resonator parameters
ring_rad=[30 50 80];                                % inner ring radius 
ring_width=0.45;                                    % ring width
ring_gap=[0.1 0.15 0.2 0.25 0.3 0.35 0.4];          % ring_gap between waveguide and ring
ring_racetrack_L=0;                                 % racetrack resonator straight length
ring_theta=0;                                       % shifting angle of racetrack resonator, (0 horizontal, 90 vertical)
mul=[0 20 50];
% ring_rad=80;
% ring_gap=0.15;

% edge coupler parameters
wg_width=0.45;                                      % waveguide width
taper_L=[50 100 150];                               % taper length 
taper_tip_w=[0.11 0.13 0.14 0.15 0.17 0.18 0.2];    % taper tip width
taper_angle=0;                                      % shifting angle of the taper waveguide
% taper_L=100;
% taper_tip_w=0.18;

% position parameters
pos_x=0;                                            % center position of the resonator, pos_x and pos_y
pos_y=0;
fx=200;                                             % frame width - x
fy=200;                                             % frame width - y
upper_gap=20;
% diff=180;                                         % separation between two structure

%% layout generation - cnst file
% open cnst file
fileID = fopen(fname_script,'w');
fprintf(fileID,'0.001 gdsReso\n');
fprintf(fileID,'0.0001 shapeReso\n\n');
%center waveguide and ring

fprintf(fileID,'<Centerwaveguide_and_ring struct>\n\n\n');

for k=1:3
    N=2*pi*ring_rad(k)/(pi/10);              % number of segments in the ring
    for m=1:7
        pos_y=fy*(m-1)+7*fy*(k-1)-mul(k);
        x_str=-fx/2;
        x_str_end=fx/2;
        y_str=ring_rad(k)+1.5*wg_width+ring_gap(m)+ring_racetrack_L/2+fy*(m-1)+7*fy*(k-1)-mul(k);
        y_str_end=y_str;
        %s band
        x_band=fx/2;
        x_band_end=1.5*fx-taper_L(k);
        y_band=y_str;
        y_band_end=-10+fy*(m-1)+7*fy*(k-1);
        w_band=wg_width;
        %end taper;
        x_taper2=1.5*fx-taper_L(k);
        x_taper_f=x_taper2+taper_L(k);
        y_taper2=y_band_end;
        y_taper_f=y_taper2;
        %front straight waveguide
        x_str2=-fx/2;
        x_str2_end=-1.5*fx+taper_L(k);
        %front taper waveguide
        x_taper1=-1.5*fx+taper_L(k);
        x_taper1_f=x_taper1-taper_L(k);
        y_taper1=y_str;
        y_taper1_f=y_str;
        %frame
        pos_frame_y=(y_str+wg_width+upper_gap)-fy/2;
        pos_frame_x=pos_x;
        
        %% center waveguide, ring, taper and straight waveguide 
        fprintf(fileID,'1 layer\n');
        fprintf(fileID,['<',num2str(x_str),' ',num2str(y_str),' ',num2str(x_str_end),' ',num2str(y_str_end),' ',num2str(wg_width),' ',num2str(wg_width),' ',num2str(taper_angle),' linearTaper>\n\n\n']);
        fprintf(fileID,['<',num2str(pos_x),' ',num2str(pos_y),' ',num2str(ring_racetrack_L),' ',num2str(ring_width),' ',num2str(ring_rad(k)),' ',num2str(ring_theta),' ',num2str(N),' raceTrack>\n\n']);
        fprintf(fileID,['<',num2str(x_band),' ',num2str(y_band),' ',num2str((x_band_end+x_band)/2),' ',num2str(y_band),' ',num2str((x_band_end+x_band)/2),' ',num2str(y_band_end),' ',num2str(x_band_end),' ',num2str(y_band_end),' ',num2str(w_band),' ',num2str(taper_angle),' bezierCurve>\n\n\n']);
        fprintf(fileID,['<',num2str(x_taper2),' ',num2str(y_taper2),' ',num2str(x_taper_f),' ',num2str(y_taper_f),' ',num2str(wg_width),' ',num2str(taper_tip_w(m)),' ',num2str(taper_angle),' linearTaper>\n\n\n']);
        fprintf(fileID,['<',num2str(x_str2),' ',num2str(y_str),' ',num2str(x_str2_end),' ',num2str(y_str_end),' ',num2str(wg_width),' ',num2str(wg_width),' ',num2str(taper_angle),' linearTaper>\n\n\n']);
        fprintf(fileID,['<',num2str(x_taper1),' ',num2str(y_taper1),' ',num2str(x_taper1_f),' ',num2str(y_taper1_f),' ',num2str(wg_width),' ',num2str(taper_tip_w(m)),' ',num2str(taper_angle),' linearTaper>\n\n\n']);
        fprintf(fileID,'4 layer\n');
        fprintf(fileID,[num2str(pos_frame_x),' ',num2str(pos_frame_y),' ',num2str(fx),' ',num2str(fy),' ',num2str(taper_angle),' rectangleC\n\n\n']);
        fprintf(fileID,[num2str(pos_frame_x+fx),' ',num2str(pos_frame_y),' ',num2str(fx),' ',num2str(fy),' ',num2str(taper_angle),' rectangleC\n\n\n']);
        fprintf(fileID,[num2str(pos_frame_x-fx),' ',num2str(pos_frame_y),' ',num2str(fx),' ',num2str(fy),' ',num2str(taper_angle),' rectangleC\n\n\n']);
       

       
    end 
end 
for kk=1:7
    
    fprintf(fileID,'8 layer\n');
    fprintf(fileID,['<{{ringA',num2str(kk),'}}',' ','{{Arial}}',' ',num2str(12),' ',num2str(1.3*fx),' ',num2str(fy/20+(kk-1)*fy),' ','textgdsC>\n\n']);
    
end
for kk=8:14
    
    fprintf(fileID,'8 layer\n');
    fprintf(fileID,['<{{ringB',num2str(kk-7),'}}',' ','{{Arial}}',' ',num2str(12),' ',num2str(1.3*fx),' ',num2str(fy/20+(kk-1)*fy),' ','textgdsC>\n\n']);
    
end
for kk=15:21
    
    fprintf(fileID,'8 layer\n');
    fprintf(fileID,['<{{ringC',num2str(kk-14),'}}',' ','{{Arial}}',' ',num2str(12),' ',num2str(1.3*fx),' ',num2str(fy/20+(kk-1)*fy),' ','textgdsC>\n\n']);
    
end

fclose(fileID);
%% generate layout

% run the java code from matlab
[status,cmdout] = dos(join(['java -jar CNSTNanolithographyToolbox.jar cnstscripting ',fname_script,' ',fname]));
status, cmdout

% % % run klayout code from matlab
[status,cmdout] = dos(join(['"C:\Users\mdmia\AppData\Roaming\KLayout\klayout" ' fpath,'/',fname]));
status, cmdout



