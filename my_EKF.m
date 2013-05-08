function xf = my_EKF(m, z, Rk, Q, P0),

P = P0;
y = z.y;
x = m.x0;
t = z.t;
u = z.u;

nx = m.nn(1);
nu = m.nn(2);
ny = m.nn(3);
nth = m.nn(4);

xhat = m.x0;
for k = 1:size(y, 1),
   % Measurement update
   xlin=sig(zeros(1,ny),t(k),zeros(1,nu),xhat.');
   C=nlnumgrad(m,xlin,'dhdx').';
   yphat=m.h(t(k),xhat,u(k,:).',m.th);
   Pyp(k,:,:)=C*P*C'+Rk(:,:,k);
   Sinv=inv(C*P*C'+Rk(:,:,k));
   K=P*C'*Sinv;
   P=P-K*C*P;
   P=0.5*(P+P');
   epsi=z.y(k,:).'-yphat;
   xhat=xhat+K*epsi;
   yfhat=m.h(t(k),xhat,u(k,:).',m.th);
   V(k)=epsi'*Sinv*epsi;

   xf(:,k)=xhat;
   Pf(k,:,:)=P;
   yf(:,k)=yfhat;
   yp(:,k)=yphat;
   Pyf(k,:,:)=C*P*C'+Rk(:,:,k);

   % Time update
   xlin=sig(zeros(1,ny),t(k),zeros(1,nu),xhat.');
   A=nlnumgrad(m,xlin,'dfdx').';
   fxhat=feval(m.f,t(k),xhat,u(k,:).',m.th);
   xhat=fxhat;
   P=A*P*A'+Q;
   xp(:,k+1)=xhat;
   Pp(k+1,:,:)=P;
end