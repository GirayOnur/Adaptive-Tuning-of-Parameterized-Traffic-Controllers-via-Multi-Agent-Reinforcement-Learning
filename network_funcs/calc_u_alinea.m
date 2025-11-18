function u_alinea = calc_u_alinea(rho,u,params,rho_prev)

u_alinea = max(min(u + params.KI*(params.rho_c -  rho) - params.KP*(rho - rho_prev),1),0);

end