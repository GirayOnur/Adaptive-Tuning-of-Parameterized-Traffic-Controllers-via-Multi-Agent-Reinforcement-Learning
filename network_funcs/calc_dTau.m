function dTau = calc_dTau(x,param)

Tau1  =  (x(24)/x(26)).*(param.lambda.l4./x(22)) + (x(25)/x(26)).*(param.lambda.l4./x(23)) ...
      +  (x(31)/x(33)).*(param.lambda.l5./x(29)) + (x(32)/x(33)).*(param.lambda.l5./x(30)) ... 
      +  (x(38)/x(40)).*(param.lambda.l6./x(36)) + (x(39)/x(40)).*(param.lambda.l6./x(37));

Tau2  =  (x(45)/x(47)).*(param.lambda.l7./x(43)) + (x(46)/x(47)).*(param.lambda.l7./x(44)) ...
      +  (x(52)/x(54)).*(param.lambda.l8./x(50)) + (x(53)/x(54)).*(param.lambda.l8./x(51)) ... 
      +  (x(59)/x(61)).*(param.lambda.l9./x(57)) + (x(60)/x(61)).*(param.lambda.l9./x(58));


dTau = Tau2 - Tau1;

end