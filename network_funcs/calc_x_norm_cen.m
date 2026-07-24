function x_norm = calc_x_norm_cen()
% Return scale factors for the 22 centralized observations.

% Route-guidance observations
x_norm = [1000;
          1000;
          100;
          100;
          1;
          0.1;
          0.1;
          % First ramp observations
          1000;
          1000;
          100;
          100;
          100;
          100;
          1;
          % Second ramp observations
          1000;
          1000;
          100;
          100;
          100;
          100;
          1;
          1];
end
