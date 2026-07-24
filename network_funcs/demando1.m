function [demand_c1, demand_c2] = demando1(k,scenario)
% Generate the main-origin demand profile for both vehicle classes.

if k<= 1060
    k=floor((k-60)/6);
    switch scenario
        case 1
            t1=105;t2=130; d0=3000; d1=3500; d2=1040;
            demand=d0.*(k<0)+ d1.*(k>=0 & k<=t1)+(d1-(d1-d2)/(t2-t1)*(k-t1)).*(k>t1 & k<=t2)+d2.*(k>t2);
        case 3
            t1=105;t2=130; d0=3000; d1=3500; d2=1040;
            demand=d0.*(k<0) +d1.*(k>=0 & k<=t1)+(d1-(d1-d2)/(t2-t1)*(k-t1)).*(k>t1 & k<=t2)+d2.*(k>t2);
    end
    demand_scale = 1.2; % Scale the demand before the weather transition.
else
    k=floor((k-1060)/6);
    switch scenario
        case 1
            t0=6; t1=105;t2=130; d0=2496; d1=3500; d2=1040;
            demand=d0.*(k<0)+ d1.*(t0-k).*(k>=0 & k<t0) +d1.*(k>=0 & k<=t1)+(d1-(d1-d2)/(t2-t1)*(k-t1)).*(k>t1 & k<=t2)+d2.*(k>t2);
        case 3
            t0=6; t1=105;t2=130; d0=2496; d1=3500; d2=1040;
            demand=d0.*(k<0)+ (d0+ (d1-d0).*(k)./t0).*(k>=0 & k<t0) +d1.*(k>=t0 & k<=t1)+(d1-(d1-d2)/(t2-t1)*(k-t1)).*(k>t1 & k<=t2)+d2.*(k>t2);
    end
    demand_scale = 0.5; % Use a lower scale after the weather transition.
end


c_1_ratio = 0.8;

c_2_ratio = 1 - c_1_ratio;
% The factor of two converts the profile to the four-lane main origin.
demand_c1 = c_1_ratio*2*demand*demand_scale;
demand_c2 = c_2_ratio*2*demand*demand_scale;

end

