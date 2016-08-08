function [e,ew]=cafmi(f,m)
% [e,ew]=cafmi(f,m) computes values of the invariants in the array f from
% the values of the moments in the matrix m and store them to the vector e
% ew contains weights of the invariants.

s=size(f);
if size(s)<3
    s(3)=1;
end
ms=size(m);
mm=ms(1);
m00=m(1,1);
if(m00==0)
    m00=1;
end

[q,p]=meshgrid(0:mm-1);
m1=m./(m00.^((q+p+2)/2));	%normalization to scaling
m1=m1.*pi.^((p+q)/2).*((p+q)/2+1);   %magnitude normalization to order
for i1=1:s(3)
    k=1;
    while k<s(1) & f(k,1,i1)~=0	%How many coefficients ?
        k=k+1;
    end
    if f(k,1,i1)==0
        k=k-1;
    end
    j=1;
    while j<(s(2)-1)/2 & f(1,2*j,i1)+f(1,2*j+1,i1)~=0	%How many moments is in one term ?
        j=j+1;
    end
    if f(1,2*j,i1)+f(1,2*j+1,i1)==0
        j=j-1;
    end
    e(i1)=sum(prod(m1(f(1:k,2:2:2*j,i1)+f(1:k,3:2:2*j+1,i1)*mm+1)')'.*f(1:k,1,i1));
    e(i1)=sign(e(i1))*abs(e(i1))^(1/j); %magnitude normalization to degree
    ew(i1)=sum(f(1,2:2:2*j,i1));	%weight of the invariant
end