function [thr, qi, M1, M2] = otsu_threshold(x)

% edited by ER on 25 June 07
%  INPUT: 
%  x = vector of 1-dim data
%
%  OUTPUT:  
% 
%  thr = optimal threshold which maximizes "between" sum of squares
%
%  qi = quality index =  ss_between/ss_total
%          0 <= qi <=1  
%          (high values indicate good separtion)
% M1/2= the optimal mean values corresponding to the Otsu's threshold

n = length(x);
m = mean(x);
ss = n*var(x);   % sum of squares (total)

% Determine lower and upper values for threshold

thr_lo = prctile(x,5);
thr_hi = prctile(x,95);

thr_rg = thr_hi-thr_lo;

thr_vals = thr_lo + thr_rg*(0:0.01:1);

Sb = zeros(size(thr_vals));

cnt = 0;
for t = thr_vals   %---------------(100)

    cnt = cnt+1;
    z1 = (x<t);   x1 = x(z1);  x2 = x(~z1);
   
    n1 = length(x1);  n2 = length(x2);
    
    if n1 > 0 && n2>0 
        m1 = mean(x1);  m2 = mean(x2);
        sb2 = n1*(m1-m)^2 + n2*(m2-m)^2;
        Sb(cnt) = sb2;
        m1_vals(cnt) = m1;
        m2_vals(cnt) = m2;
    else 
        Sb(cnt) = 0;
        m1_vals(cnt) = 0;
        m2_vals(cnt) = 0;        
    end
end  %---------------(100)


%figure(1), plot(thr_vals,Sb), 
%pause(.1)

[ssb,mi] = max(Sb);

% thr = mean(thr_vals(mi)); % take mean in case multiple values are returned
thr = thr_vals(mi);

M1 = m1_vals(mi);
M2 = m2_vals(mi);

if ss > 0
    qi = ssb/ss;
else 
    qi = 0;
end

return

%-----------------------------------

%  Test 1

QI = [];
T = [];

for d = 0:0.1:6
    
    x1 = randn(200,1);
    x2= randn(200,1)+d;
    x = [x1; x2];
    
    [thr,qi] = otsu_threshold(x);
    T = [T thr];
    QI = [QI qi];
end

figure(100), plot(T);
figure(101), plot(QI);



