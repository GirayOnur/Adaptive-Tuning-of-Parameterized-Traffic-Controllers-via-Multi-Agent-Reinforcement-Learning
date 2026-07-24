function w_o_n = calc_w_o_n(w_o,d_o,q_o,param)
% Advance an origin queue from demand and admitted flow.

w_o_n = w_o + param.T*(d_o - q_o);

end

