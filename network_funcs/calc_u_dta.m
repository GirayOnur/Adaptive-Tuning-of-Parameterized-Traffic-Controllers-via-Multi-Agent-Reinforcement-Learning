function u_dta = calc_u_dta(u,params,dTau,dTau_prev)

u_dta = max(min(u + params.KP*(dTau - dTau_prev) + params.KI.*(dTau) ,1),0);

end