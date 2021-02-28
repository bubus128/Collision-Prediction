n=4;            %ilość bil
sr=1;         %średnica bili   
wymiaryStolu=[100 200];
czas=0.1;     %czas jednej klatki
czasZderzenia=0.1;
polozenie=[22 12; 22.6 57; 40 17; 52 38];    %współrzędne x,y bil
block=  [0,0,0,0;
        0,0,0,0;
        0,0,0,0;
        0,0,0,0];
predkosc=[0 20; 0 0; 5 -17; 0 0];    %prędkości w osiach x,y bil
g=9.8135;       %przyspieszenie grawitacyjne
wtt=0.1;         %współczynnik tarcia tocznego
mb=0.1;         %masa bili

%rysowanie
f = figure;
ekran = get(0,'screensize');
prop = (wymiaryStolu(1))/wymiaryStolu(2);
set(f,'Position',[1 100 ekran(3)*0.95 1.4*ekran(3)*prop*0.95])  % wymiary okna
gca1 = axes('Position',[0.02 1-1/1.4+0.025 0.98 1/1.4-0.025]);
set(f,'Resize','off');                                          % zablokowanie zmiany wymiarow okna figure 
set(f,'name','Bilard');                                         % nazwa okna
set(gca1,'Color',[1,1,1]);                                      % kolor tla  
set(gcf, 'SelectionType','open');
axis([-10  wymiaryStolu(1)-10  -10 wymiaryStolu(2)-10]*1.2);  % podzialka na osiach wspolrzednych
patch([0, 0, wymiaryStolu(1),wymiaryStolu(1)],... %kontur stołu
    [wymiaryStolu(2), 0, 0,wymiaryStolu(2)] ...
    ,[0.1 0.8 0.1], 'erasemode','xor'); %kolor stołu
subplot(gca1);
h(1)=circle(polozenie(1,1),polozenie(1,2),sr,0,0,0); % narysowanie pierwszej bili - czarnej

for i=2:n
    red(i)=rand(1); %losowanie kolorow dla pozostalych bil
    green(i)=rand(1);
    blue(i)=rand(1);
    h(i)=circle(polozenie(i,1),polozenie(i,2),sr,red(i),green(i),blue(i));
end

while true
    %tu się zaczyna fizyka
    nzdezen=0;
    zdezenia=[];
    %obliczanie nowego położenia
    for i=1:n
        polozenie(i,1)=polozenie(i,1)+predkosc(i,1)*czas;
        polozenie(i,2)=polozenie(i,2)+predkosc(i,2)*czas;
    end
    for i=1:n
        opor=wtt*mb*g*sr;
        if(predkosc(i,1)>0)
            if(predkosc(i,1)-opor>0)
                predkosc(i,1)=predkosc(i,1)-opor;
            else
                predkosc(i,1)=0;
            end
        elseif(predkosc(i,1)<0)
            if(predkosc(i,1)+opor<0)
                predkosc(i,1)=predkosc(i,1)+opor;
            else
                predkosc(i,1)=0;
            end
        end
        if(predkosc(i,2)>0)
            if(predkosc(i,2)-opor>0)
                predkosc(i,2)=predkosc(i,2)-opor;
            else
                predkosc(i,2)=0;
            end
        elseif(predkosc(i,2)<0)
            if(predkosc(i,2)+opor<0)
                predkosc(i,2)=predkosc(i,2)+opor;
            else
                predkosc(i,2)=0;
            end
        end
    end
    for i=1:n
        if(polozenie(i,1)<sr || polozenie(i,1)>wymiaryStolu(1))
            predkosc(i,1)=-predkosc(i,1);
        end
        if(polozenie(i,2)<sr || polozenie(i,2)>wymiaryStolu(2))
            predkosc(i,2)=-predkosc(i,2);
        end
    end
    %wykrywanie zderzeń
    for i=1:n
        for j=i+1:n
            odl=sqrt((polozenie(i,1)-polozenie(j,1))^2+(polozenie(i,2)-polozenie(j,2))^2);
            if (odl<2*sr)
                if(block(i,j)==0)
                    block(i,j)=1;
                    predkosc1=sqrt(predkosc(i,2)^2+predkosc(i,1)^2);
                    predkosc2=sqrt(predkosc(j,2)^2+predkosc(j,1)^2);
                    predkoscWzgledna=sqrt((predkosc(i,2)-predkosc(j,2))^2+(predkosc(i,1)-predkosc(j,1))^2);
                    katZdez=atan(abs(polozenie(i,2)-polozenie(j,2))/abs(polozenie(i,1)-polozenie(j,1)));    %kąt między poziomem a prostą łączącą środki bil
                    katPredWzgl=0;
                    if abs(predkosc(i,1)-predkosc(j,1))==0
                        katPredWzgl=pi/2;
                    else
                        katPredWzgl=atan(abs(predkosc(i,2)-predkosc(j,2)/abs(predkosc(i,1)-predkosc(j,1))))
                    end
                        %kąt między poziomem a wektorem prędkości pierwszej bili względem drugiej
                    katZdezPred=katPredWzgl-katZdez;            %kąt między  prędkością względną a prostą łączącą środki bil
                    beta1=pi/2+katZdez;                         %kąt między nową prędkością pierwszej bilia poziomem
                    beta2=katZdez;                              %kąt między nową prędkością drugiej bili a poziomem
                    nowaPredkosc1X=predkoscWzgledna*sin(katZdezPred)*cos(beta1);
                    nowaPredkosc1Y=predkoscWzgledna*sin(katZdezPred)*sin(beta1);
                    nowaPredkosc2X=predkoscWzgledna*cos(katZdezPred)*cos(beta2);
                    nowaPredkosc2Y=predkoscWzgledna*cos(katZdezPred)*sin(beta2);
                    predkosc(i,1)=nowaPredkosc1X+predkosc(j,1);
                    predkosc(i,2)=nowaPredkosc1Y+predkosc(j,2);
                    predkosc(j,1)=nowaPredkosc2X+predkosc(j,1);
                    predkosc(j,2)=nowaPredkosc2Y+predkosc(j,2);
                end
            else
                block(i,j)=0;
            end
        end
    end

    %tu się kończy fizyka 


    patch([0, 0, wymiaryStolu(1),wymiaryStolu(1)],... %narysowanie stolu na nowo
    [wymiaryStolu(2), 0, 0,wymiaryStolu(2)] ...
    ,[0.1 0.8 0.1], 'erasemode','xor');
    h(1)=circle(polozenie(1,1),polozenie(1,2),sr,0,0,0);
    for i=2:n % narysowanie nowej pozycji bili
        h(i)=circle(polozenie(i,1),polozenie(i,2),sr,red(i),green(i),blue(i));
    end
    drawnow;% odrysowanie stołu na bieżąco
end