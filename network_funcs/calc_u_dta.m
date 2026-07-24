function u_dta = calc_u_dta(u,params,dTau,dTau_prev)
% Update the route split from the current and previous travel-time imbalance.

u_dta = max(min(u + params.KP*(dTau - dTau_prev) + params.KI.*(dTau) ,1),0);

end
