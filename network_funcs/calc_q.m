function q = calc_q(rho_m_i,v_m_i,param)
% Calculate section flow from density, speed, and lane count.

q = rho_m_i*v_m_i*param.lambda;

end

