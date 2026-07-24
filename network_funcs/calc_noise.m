function noise_gain = calc_noise()
% Return bounded multiplicative gains for seven route observations.
% A positive sigma enables noise; sigma = 0 leaves observations unchanged.

sigma = 0;
alpha_bnd = 100;
alpha = normrnd(0,sigma,[7,1]);
alpha = max(min(alpha,alpha_bnd),-alpha_bnd);

noise_gain = (1 + alpha./100);

end
