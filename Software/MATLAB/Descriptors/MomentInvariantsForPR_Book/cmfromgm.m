function c=cmfromgm(r,gm);

% c=cmfromgm(r,gm) computation of complex moments c_{pq} from geometric moments in matrix gm
% to the order r

c=zeros(r+1);
for p=0:r;
    for q=0:r-p;
        for k=0:p;
           pk=nchoosek(p,k);
           for j=0:q;
              qj=nchoosek(q,j);
              c(p+1,q+1)=c(p+1,q+1)+pk*qj*(-1)^(q-j)*i^(p+q-k-j)*gm(k+j+1,p+q-k-j+1);
           end;
        end;
    end;
end;