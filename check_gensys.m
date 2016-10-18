% solves and simulates the linear model in IRIS using shocks from irf.mat and checks for replication of impulse responses
clear; clc; close all
load irf
o = struct; o.kimball = true; o.bgg = true; o.nant = 0;
m = model('frbny.model','assign=',o,'linear=',true);
m = assign(m,get_params(para));
m = refresh(m);
m = steady_state(m,o.bgg);
m = solve(m);
m = sstate(m);
chksstate(m);
%% check impulse responses
t=0:20;
d=sstatedb(m,t);
for shock={'g_sh','b_sh','mu_sh','z_sh','zp_sh','laf_sh','law_sh','rm_sh','pist_sh','sigw_sh','mue_sh','gamm_sh','lr_sh','tfp_sh','gdpdef_sh','pce_sh'}
    d.(shock{1})=s.(shock{1});
end
s_=simulate(m,d,t,'anticipate=',false);
v=[get(m,'xList') get(m,'yList')]; e=zeros(size(v));
for j=1:length(v)
    e(j) = max(abs(s.(v{j})-s_.(v{j})));
end
[e,j]=sort(e,'descend');
fprintf('Differences in IRFs (in log10, largest first):\n',shock{1});
for k=find(e>0)
    fprintf('%s %g, ',v{j(k)},log10(e(k)));
end
fprintf('\n')
dbplot(s&s_,get(m,'xList'),t,'maxPerFigure=',50); legend('gensys','IRIS')
dbplot(s&s_,get(m,'yList'),t); legend('gensys','IRIS')
[A,B,C,D,F,G,H,J,List,Nf] = system(m);
x=eval(['[' sprintf('s.%s ',List{2}{:}) ']']);
e=eval(['[' sprintf('s.%s ',List{3}{:}) ']']);
z=x*A'+x{-1}*B'+C'+e*D';
eq=get(m,'xEqtn');
er=max(abs(z.data));
for i=find(er>1e-10)
    if ~isempty(i)
        fprintf('%g : %s\n',er(i),eq{i})
    end
end
% addpath('..\DSGE-2015-Apr\dsgesolv')
% solve_gensys(m)
