function plotUAgainstR()

M = [0.8 0.0 0.0 0.0 0.2 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0
    0.7 0.3 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0
    0.0 0.7 0.1 0.0 0.0 0.2 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0
    0.0 0.0 0.7 0.1 0.0 0.0 0.2 0.0 0.0 0.0 0.0 0.0 0.0 0.0
    0.1 0.0 0.0 0.0 0.7 0.0 0.0 0.2 0.0 0.0 0.0 0.0 0.0 0.0
    0.0 0.0 0.1 0.0 0.0 0.7 0.0 0.0 0.0 0.2 0.0 0.0 0.0 0.0
    0.0 0.0 0.0 0.1 0.0 0.7 0.2 0.0 0.0 0.0 0.0 0.0 0.0 0.0
    0.0 0.0 0.0 0.0 0.1 0.0 0.0 0.7 0.0 0.0 0.2 0.0 0.0 0.0
    0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.7 0.1 0.0 0.0 0.2 0.0 0.0
    0.0 0.0 0.0 0.0 0.0 0.1 0.0 0.0 0.7 0.0 0.0 0.0 0.2 0.0
    0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0
    0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0
    0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.1 0.0 0.7 0.2 0.0
    0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.7 0.3 ];

eye(14,14);
A = eye(14,14) - M;
AInv = A^(-1);

b = [-0.2 -0.2 -0.2 -0.2 -0.2 -0.2 -0.2 -0.2 -0.2 -0.2 1.0 -1.0 -0.2 -0.2];

v1 = [ 0 0 0 0 0 0 0 0 0 0 1 -1 0 0];
v2 = [ 1 1 1 1 1 1 1 1 1 1 0 0 1 1];

hold off
for r=-4:0.02:1
    b = r * v2 + v1;
    u = AInv * b';
    plot(u(5), r ,'--rs','LineWidth',1,...
        'MarkerEdgeColor','k',...
        'MarkerFaceColor','k',...
        'MarkerSize',1);
    
    
    plot(u(9), r, '--rs','LineWidth',1,...
        'MarkerEdgeColor','g',...
        'MarkerFaceColor','g',...
        'MarkerSize',1);
    
    plot(u(14), r, '--rs','LineWidth',1,...
        'MarkerEdgeColor','r',...
        'MarkerFaceColor','r',...
        'MarkerSize',1);
    hold all
    
end
b = -2*v2 + v1;
x = AInv*b';
text(x(5),-2,'\leftarrow S_{23}',...
    'HorizontalAlignment','left')
text(x(9),-2,'\leftarrow S_{32}',...
    'HorizontalAlignment','left')
text(x(14),-2,'\leftarrow S_{44}',...
    'HorizontalAlignment','left')

title('Plot State Utility against Reward');
xlabel('Rewards');
ylabel('State Utility');

set(0,'DefaultAxesFontName', 'Times New Roman');
set(0,'DefaultAxesFontSize', 15)

set(0,'DefaultTextFontname', 'Times New Roman')
set(0,'DefaultTextFontSize', 15)