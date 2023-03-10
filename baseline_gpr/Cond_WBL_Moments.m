function Momentz ...
    = Cond_WBL_Moments( ...
    value_now, ...
    scalez, ...
    shapez, ...
    orderz ...
    )

x = ( value_now ./ scalez ).^shapez;

a = orderz./shapez;

Momentz = a.*exp(x).*((scalez).^orderz).*...
    gamma(a).*gammainc(x,a,'upper');

end