syms t;

s(t) = 4*t + 1.6*t^2 - 0.08*t^3;

v = diff(s);
a = diff(v);

disp(a);

v(4); 
Empty sym: 0-by-1
a(4);

% maximum velocity when acceleration is zero
vmax= (16/5) / (12/25);


