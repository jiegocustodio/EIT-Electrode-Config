clear
run startup.m

%Add 2 rows and varietations
%adjust Stim patterns, zig or curly!

n_elect = 16;
n_elein = 4;
%Can change n_row to be 2 or higher for taller column
n_row = 3;

d = 2;
ra = 0.5*d;
top = (0.2*(n_row)*d);
body_geometry.intersection.cylinder(1) = struct;
body_geometry.intersection.cylinder(1).top_center = [0;0;top];
body_geometry.intersection.cylinder(1).radius = ra;



theta = linspace(0, 2*pi, n_elect+1); theta(end) = [];
thet2 = linspace(0, 2*pi, n_elein+1); thet2(end) = [];
%thet2 = linspace(2*pi/32, 2*pi+2*pi/32, n_elein+1); thet2(end) = [];

intrad = 0.75*ra;

for i = 1:n_elein
    k = 1+i;
    body_geometry.intersection.cylinder(k).radius = 0.075*ra;
    body_geometry.intersection.cylinder(k).top_center = [intrad*cos(thet2(i)) intrad*sin(thet2(i)) top];
    body_geometry.intersection.cylinder(k).bottom_center = [intrad*cos(thet2(i)) intrad*sin(thet2(i)) 0.1];
    body_geometry.intersection.cylinder(k).complement_flag = 1;
end

electrode_geometry = cell(1, n_row*(n_elect+n_elein));

for j = 1:n_row
    s = 0.2*d*(j-1) + 0.1*d;
    r = (j-1)*(n_elect+n_elein);
    for i = 1:n_elect
        electrode_geometry{i+r}.cylinder.top_center    = [1.03*cos(theta(i))*ra 1.03*sin(theta(i))*ra s];
        electrode_geometry{i+r}.cylinder.bottom_center = [0.97*cos(theta(i))*ra 0.97*sin(theta(i))*ra s];
        electrode_geometry{i+r}.cylinder.radius = 0.1*ra;
    end
    
    for i = 1:n_elein
        l = i+n_elect+r;
        electrode_geometry{l}.cylinder.top_center    = [intrad*cos(thet2(i)) intrad*sin(thet2(i)) s+0.05*d];
        electrode_geometry{l}.cylinder.bottom_center = [intrad*cos(thet2(i)) intrad*sin(thet2(i)) s-0.05*d];
        electrode_geometry{l}.cylinder.radius = 0.075*ra;
    end
end
fmdl = ng_mk_geometric_models(body_geometry, electrode_geometry);
show_fem(fmdl); view(45,45);

imdl = mk_common_model('a2c',16); % Will replace most fields
imdl.fwd_model = fmdl;
%imdl.fwd_model.stimulation = mk_stim_patterns(n_elect+n_elein,n_row,[0,1],[0,1],{},1);
imdl.fwd_model.stimulation = mk_stim_patterns(n_elect+n_elein,n_row,[0,3],[0,3],{},1);
img1 = mk_image(imdl);

%print_convert('basic_3d_01a.png','-density 60')
% Basic 3d model $Id: basic_3d_02.m 3790 2013-04-04 15:41:27Z aadler $
% Add a circular object at 0.2, 0.5
% Calculate element membership in object
select_fcn = inline('(x).^2 + (y).^2 + (z-(1.2/2)).^2 < 0.2 ^2','x','y','z');
memb_frac = elem_select( img1.fwd_model, select_fcn);
img2 = mk_image(img1, 1 + memb_frac );

img2.calc_colours.cb_shrink_move = [0.1,0.1,0.8];
%show_fem(img2); view(45,45);
%show_fem(img2); view(10,40); 
%print_convert('Standard.png','-density 120');
%show_fem(img2); view(10,40); zoom(1.2);
%print_convert('Fh2.png','-density 120');
