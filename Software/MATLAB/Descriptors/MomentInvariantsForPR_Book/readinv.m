function f=readinv(fname)
%f=readinv(fname) reads invariants from the file fname and store them to the array f
fid=fopen(fname,'rt');
if fid==-1
    return
end
i=1;
while(~feof(fid))
    m=fscanf(fid,'%d',1);
    c=fscanf(fid,'%d',1);
    r=fscanf(fid,'%d',1);
    %[i,m,c,r]
    for k=1:c;
        for l=1:2*r+1;
            f(k,l,i)=fscanf(fid,'%d',1);
        end
    end
    i=i+1;
end
fclose(fid);