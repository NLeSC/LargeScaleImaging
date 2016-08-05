function invts=rotmi(a,r,p0,q0)
% invts=rotmi(a,r,p0,q0)
% computes values of rotation invariants (invariants to TRS) of the image a 
% up to the order limit r (min.2).
% The phase cancellation is provided by multiplication with a proper power 
% of c_{p0,q0}, implicitly c_{12}, if r==2, then c_{02}. 
% If p0==q0, only c_{pp} are computed.

if r<2
    error('The order limit r must be at least 2');
end
if nargin<4
    p0=1;
    q0=2;
end
if r==2
    p0=0;
    q0=2;
end
if p0>q0
    aux=p0;p0=q0;q0=aux;
end
if r<p0+q0
    error('The order limit r must be greater than or equal to p0+q0');
end

m=cm(a,r);                              %computation of the central geometric moments
c=cmfromgm(r,m);                        %conversion of the central moments to complex
[qm,pm]=meshgrid(0:r);
c=c./(m(1,1).^((qm+pm+2)/2));	        %scaling normalization
c=c.*((pm+qm)/2+1).*pi.^((pm+qm)/2);    %magnitude normalization to order
id=q0-p0;                               %index difference
ni=1;                                   %sequential number of the invariant
if id==0
	for r1=2:2:r
        p=round(r1/2);
        invts(ni)=real(c(p+1,p+1));
        pwi(ni)=1;
        ni=ni+1;
%        disp(sprintf('c_{%d%d}',p,p))
	end
else
	for r1=max(2,id):id:r
        for p=round(r1/2):r1
            q=r1-p;
            if mod(p-q,id)==0
                invts(ni)=real(c(p+1,q+1)*c(p0+1,q0+1)^((p-q)/id));
                pwi(ni)=1+(p-q)/id;
                ni=ni+1;
%                disp(sprintf('Re(c_{%d%d}c_{%d%d}^(%d))',p,q,p0,q0,(p-q)/id))
                if p>q & (p~=q0 | q~=p0)
                    invts(ni)=imag(c(p+1,q+1)*c(p0+1,q0+1)^((p-q)/id));
                    pwi(ni)=1+(p-q)/id;
                    ni=ni+1;
%                    disp(sprintf('Im(c_{%d%d}c_{%d%d}^(%d))',p,q,p0,q0,(p-q)/id))
                end
            end
        end
	end
end
invts=sign(invts).*abs(invts).^(1./pwi);    %magnitude normalization to degree