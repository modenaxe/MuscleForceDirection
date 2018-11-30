% Trova le tangenti ai punti dati spostandoli in un riferimento col centro
% della crf al centro degli assi. Quando non c'e' wrapping calcola la
% distanza cmq tra i punti e mette come tangenti i punti iniziali. Infine
% se i punti sono sulla crf non usa ottimizzazione ma identifica tangente
% col punto.
% lato = 1;% 1 dx o sotto----  -1 sx o sopra
% problematico GA perche' sulla crf
function [L,T1_glob,T2_glob,contact] = Wrapping2(centro_glob,R,P1,P2,lato,graphics)

% lavoro sempre con circonferenza al centro degli assi: l'algoritmo è più
% preciso.
v1 = P1-centro_glob;
v2 = P2-centro_glob;

dist_P = v2-v1;
if cross([1 0 0 ],[v1/norm(v1) 0])>0 == [0 0 1]
%     display('P1 sopra la circonferenza')
else
%     display('P1 sotto la circonferenza')
    lato = lato*-1;
end
if cross([1 0 0 ],[v2/norm(v2) 0])<0 == [0 0 1]
%     display('P2 sotto la circonferenza')
else
%     display('P2 sopra la circonferenza')
end

if cross([1 0 0 ],[v1/norm(v1) 0])>0 == [0 0 1] & cross([1 0 0 ],[v2/norm(v2) 0])>0 == [0 0 1]
%     display('P1 e P2 sopra la circonferenza')
    lato = lato*-1;
end
%direzione: se P1 è sopra P2:
%-----> lato = 1 wrapping  a dx
%-----> lato = -1 wrapping a sx
% se P1 e sotto P2 è il contrario

%stima della distanza tra centro e vettore che unisce i punti (limit
%condition)
h = cross([-lato*v1,0],[dist_P,0]/norm([dist_P,0]));

if h(3)>R
%     display('   '),display('NO WRAPPING!!!'),display('   ')
    L = norm([dist_P,0]);
    contact = 0;
    T1_glob = P1;
    T2_glob = P2;
    if strcmp(graphics,'on') == 1
        %grafica normalizzata
%         plot(v1(1), v1(2),'o'),plot(v2(1), v2(2),'o')
%         plot([v1(1),v2(1)], [v1(2),v2(2)],'g')
        %grafica globale
            t = 0:(2*pi)/300:2*pi;
        CRF = [R*cos(t'), R*sin(t')];
        plot(centro_glob(:,1)+CRF(:,1), centro_glob(:,2)+CRF(:,2),'k'),hold on
        plot([P1(1),P2(1)], [P1(2),P2(2)],'k')
        plot(P1(1), P1(2),'o','MarkerEdgeColor','k','MarkerFaceColor','w');
        plot(P2(1), P2(2),'o','MarkerEdgeColor','k','MarkerFaceColor','w')
        
    end
    return
else
%     display('   '),display('WRAP!!!'),display('   ')
    contact = 1;
end

%% algorithm
% pos punto tangenza + vettore tangente  = pos_punto est
%% tangente nel verso delle theta positive se lato = 1
% l'algoritmo chiude OT1P1 in pratica
dist1 = sqrt(norm(v1)^2-R^2);

fun_min1= @(x) R*[cos(x) sin(x)]+lato*dist1*[-sin(x) cos(x)]-v1;
options1=optimset('TolFun',10e-13,'TolX',10e-11);

x0 = pi/4;
[sol1,fval,exitflag] = fsolve(fun_min1,x0,options1);
% retry with new initial point
if exitflag == -2
    x0 = sol1;
    [sol1,fval,exitflag] = fsolve(fun_min1,x0,options1);
end
% if no solution then it doesn't work
if exitflag == -2
    display('La tangente superiore non converge!!!')
    waitforbuttonpress
end
T1 = [R*cos(sol1), R*sin(sol1)];
if(dist1<10e-6)
    T1 = v1;
%     display('PUNTO SULLA CRF');
%     waitforbuttonpress
end
%% tangente nel verso opposto al precedente
% l'algoritmo chiude OT1P2 in pratica
%tangente nel verso delle theta negative
dist2 = sqrt(norm(v2)^2-R^2);
fun_min2= @(x) R*[cos(x) sin(x)]-lato*dist2*[-sin(x) cos(x)]-v2;
x0 = -pi/4;
options2=optimset('TolFun',10e-11,'TolX',10e-11);
[sol2,fval2,exitflag2] = fsolve(fun_min2,x0,options2);
% retry with new initial point
if exitflag2 == -2
    x0 = sol+20/180*pi;
    [sol2,fval2,exitflag2] = fsolve(fun_min2,x0,options2);
end
% if no solution then it doesn't work
if exitflag2 == -2
    display('La tangente inferiore non converge!!!')
    waitforbuttonpress
end
T2 = [R*cos(sol2), R*sin(sol2)];
if(dist2<10e-6)
    T2 = v2;
%     display('PUNTO SULLA CRF');
%     waitforbuttonpress
end
%%  length mi fido
% arco (archi minori di 180)
L_arch = R*asin(norm(cross([T1/R,0], [T2/R,0])));

if L_arch<0
    display('ARCO DI WRAPPING MINORE DI ZERO: FORSE WRAPPING NON CORRETTO?')
    waitforbuttonpress
end
%dist lineare
Lin_vect1 = (v1-T1); L1 = hypot(Lin_vect1(:,1),Lin_vect1(:,2));
Lin_vect2 = (v2-T2); L2 = hypot(Lin_vect2(:,1),Lin_vect2(:,2));
%controllato GA e' affidabile nel wrapping
% L1
% L2
% L_arch
% waitforbuttonpress

L = L1+L2+L_arch;

%% points in global coordinates
T1_glob = T1+centro_glob;
T2_glob = T2+centro_glob;
% local graphics of the wrapping in normalized coordinates
%% grafica punti base

if strcmp(graphics,'on') == 1
%% grafica normalizzata (no casi di no wrapping)
%     t = 0:(2*pi)/300:2*pi;
%     CRF = [R*cos(t'), R*sin(t')];
%     line(CRF(:,1), CRF(:,2)),hold on
%     % punti esterni
%     plot(v1(1), v1(2),'o'),plot(v2(1), v2(2),'o')
%     axis equal
%     % tangenti
%     plot([v1(1),T1(1)], [v1(2),T1(2)],'r')
%     plot([v2(1),T2(1)], [v2(2),T2(2)])
%% grafica globale (no casi di no wrapping)

    t = 0:(2*pi)/300:2*pi;
    CRF = [R*cos(t'), R*sin(t')];
    plot(centro_glob(:,1)+CRF(:,1), centro_glob(:,2)+CRF(:,2),'k'),hold on
    % punti esterni
    
    
    % tangenti
    plot([P1(1),T1_glob(1)], [P1(2),T1_glob(2)],'k');
    plot([P2(1),T2_glob(1)], [P2(2),T2_glob(2)],'k');
    plot(P1(1), P1(2),'o','MarkerEdgeColor','k','MarkerFaceColor','w');
    plot(P2(1), P2(2),'o','MarkerEdgeColor','k','MarkerFaceColor','w');
    axis equal
end
clc