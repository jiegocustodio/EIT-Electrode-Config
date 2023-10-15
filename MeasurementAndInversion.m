% Input - Basic model with ready electrodes.
% Output - Add objects within the developed model - Geometric Shape

% Code mainly taken from:
% https://eidors3d.sourceforge.net/tutorial/EIDORS_basics/basic_3d.shtml
% If there are unclear functions:
% Right Click the Function, then Click Help to learn more.

% Forward Solving = Activating the electrodes and obtaining readings.
% We do this twice, before and after an object was introduced (img1 and 2)
vh= fwd_solve(img1);
vi= fwd_solve(img2);

%Optional Plot - View the data on a plot to see if there is a difference.
plot([vh.meas, vi.meas]);
axis tight
print_convert('Fh2v.png','-density 120','-p10x5');

%Background calculations for the reconstruction/inversion model.
%*Inversion is the process of interpretting the electrode readings.
J = calc_jacobian( calc_jacobian_bkgnd( imdl) );
iRtR = inv(prior_noser( imdl ));
hp = 0.17;
iRN = hp^2 * speye(size(J,1));
RM = iRtR*J'/(J*iRtR*J' + iRN);
imdl.solve = @solve_use_matrix; 
imdl.solve_use_matrix.RM  = RM;

% Inverse Solve. (remove vh if you want to do absolute imaging instead of
% comparing before and after).
imgr = inv_solve(imdl, vh, vi);

%Color adjustment.
imgr.calc_colours.ref_level = 0; % difference imaging
imgr.calc_colours.greylev = -0.05;

%Display image and print.
%3D Output!
show_fem(imgr); view(10,40); zoom(1.2);
print_convert('Fh2-s.png','-density 120');
