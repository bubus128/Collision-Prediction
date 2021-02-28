function h = circle(x,y,r,red,green,blue )
d = r*2;
px = x-r;
py = y-r; % rysowanie kółka z kolorem w środku
h = rectangle('Position',[px py d d],'Facecolor',[red green blue],'EdgeColor',[red green blue],'Curvature',[1,1]);
daspect([1,1,1])