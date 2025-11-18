function noise_gain = calc_noise()

sigma = 0;
alpha_bnd = 100;
alpha = normrnd(0,sigma,[7,1]);
alpha = max(min(alpha,alpha_bnd),-alpha_bnd);

noise_gain = (1 + alpha./100);

end