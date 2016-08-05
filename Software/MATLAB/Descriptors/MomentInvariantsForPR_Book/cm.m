function [M]=cm(l,r)

% M is a matrix of central moments up to the r-th order of the image l
% l(n1,n2) - image matrix
% The moment \mu_{pq} = M(p+1,q+1)

[n1,n2]=size(l);

m00 =sum(sum(l));
w=linspace(1,n2,n2);
v=linspace(1,n1,n1);
if m00~=0
    tx=(sum(l*w'))/m00;
    ty=(sum(v*l))/m00;
else
    tx=0;
    ty=0;
end

a=w-tx;
c=v-ty;

for i=1:r+1;
    for j=1:r+2-i;
        p=i-1;
        q=j-1;
        A=a.^p;
        C=c.^q;
        M(i,j)=C*l*A';
    end;
end;

if r>0
    M(1,2)=0;
    M(2,1)=0;
end;