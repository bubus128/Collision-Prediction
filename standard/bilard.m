function zdez=bilard(fismodel)
    
    n=4;            %ilość bil
    sr=1;         %średnica bili   
    wymiaryStolu=[100 
        200];
    
    czas=0.1;     %czas jednej klatki
    czasZderzenia=0.1;
    polozenie=[22 12; 22.6 57; 40 17; 52 38];    %współrzędne x,y bil
    predkosc=[0 15; 0 0; 5 -17; 0 0];    %prędkości w osiach x,y bil
    block=  [0,0,0,0;
        0,0,0,0;
        0,0,0,0;
        0,0,0,0];
    g=9.8135;       %przyspieszenie grawitacyjne
    wtt=0.1;         %współczynnik tarcia tocznego
    mb=0.1;         %masa bili
    
    a=readfis(fismodel);

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
        %wykrywanie odbic
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
                if odl<2*sr
                    if(block(i,j)==0)
                        block(i,j)=1;
                        predkoscWzgledna=sqrt((predkosc(i,2)-predkosc(j,2))^2+(predkosc(i,1)-predkosc(j,1))^2);
                        katZdez=atan(abs(polozenie(i,2)-polozenie(j,2))/abs(polozenie(i,1)-polozenie(j,1)));
                        katSily1=0;
                        katSily2=0;
                        katPredWzgl=0;
                        if abs(predkosc(i,1)-predkosc(j,1))==0
                            katPredWzgl=pi/2;
                        else
                            katPredWzgl=atan(abs(predkosc(i,2)-predkosc(j,2)/abs(predkosc(i,1)-predkosc(j,1))))
                        end
                        %kąt między poziomem a wektorem prędkości pierwszej bili względem drugiej
                        katZdezPred=katPredWzgl-katZdez;
                        if(polozenie(i,2)>polozenie(j,2))
                            katSily1=katZdez;
                            katSily2=katZdez+pi;
                        else
                            katSily2=katZdez;
                            katSily1=katZdez+pi;
                        end
                        
                        nzdezen=nzdezen+1;
                        zdezenia(nzdezen,1)=i;
                        zdezenia(nzdezen,2)=j;
                        zdezenia(nzdezen,3)=katZdezPred;
                        zdezenia(nzdezen,4)=katZdez;
                        zdezenia(nzdezen,5)=katSily1;
                        zdezenia(nzdezen,6)=katSily2;
                    end
                else
                    block(i,j)=0;
                end
            end
        end
        %obliczenie nowej prędkości bil
        for i=1:nzdezen
            
            stan=[zdezenia(i,3),zdezenia(1,4)];
            przysp=evalfis(a, stan);
            bila1=zdezenia(i,1);
            bila2=zdezenia(i,2);
            %bila1
            przyspx=przysp*cos(zdezenia(i,5));
            przyspy=przysp*sin(zdezenia(i,5));
            predkosc(bila1,1)=predkosc(bila1,1)+przyspx*czasZderzenia;
            predkosc(bila1,2)=predkosc(bila1,2)+przyspy*czasZderzenia;
            %bila2
            przyspx=przysp*cos(zdezenia(i,6));
            przyspy=przysp*sin(zdezenia(i,6));
            predkosc(bila2,1)=predkosc(bila2,1)+przyspx*czasZderzenia;
            predkosc(bila2,2)=predkosc(bila2,2)+przyspy*czasZderzenia;
            
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
end