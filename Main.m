%% Project Fitting a quantitative model onto a market smile. [Derivados Avanzados] [Rodrigo Duran]
%% STEP 2
%% Pregunta 1

Date=(Date);
Spot=(Spot);

plot(Date,Spot);
xlabel('Date')
ylabel('Spot')
title('Spot as a function of Date')
legend('Spot','Location','northeast')

%% Pregunta 2
Vol3M=(Vol3M);
Vol6M=(Vol6M);
Vol1Y=(Vol1Y);
Date=(Date);

plot(Date, Vol3M, Date, Vol6M, Date, Vol1Y);
title('Volatility as a function of Date')
xlabel('Date')
ylabel('Volatility (%)')
legend('Vol3M','Vol6M','Vol1Y','Location','northeast')

%% Pregunta 3
Vol3M=(Vol3M)./100;
Vol6M=(Vol6M)./100;
Vol1Y=(Vol1Y)./100;
Spot=(Spot);


hold on
scatter(Spot, Vol3M) 
scatter(Spot, Vol6M)
scatter(Spot, Vol1Y)
xlabel('Spot')
ylabel('Volatility')
legend('Vol3M','Vol6M','Vol1Y','Location','northeast')
hold off
%% media
mediav3M=mean(Vol3M);
mediav6M=mean(Vol6M);
mediav1Y=mean(Vol1Y);
mediaSpot=mean(Spot);
%% desv.estandar
desvV3M=std(Vol3M);
desvV6M=std(Vol6M);
desvV1Y=std(Vol1Y);
desvSpot=std(Spot);
%% maximo
maxV3m=max(Vol3M);
maxV6m=max(Vol6M);
maxV1Y=max(Vol1Y);
maxSpot=max(Spot);
%% minimo
minV3m=min(Vol3M);
minV6m=min(Vol6M);
minV1Y=min(Vol1Y);
minSpot=min(Spot);

%% STEP 3
clear all
clc
%% Forward
Spot=(Spot);                        %Se vincula la base de datos.
q=(Foreing);
r=(Domestic);
ForwardEmpirico=(ForwardPoints);

DiscountFactor=q./r; %Factor de descuento
for j=1:5
    for i=1:2663
        Forward(i,j)=Spot(i,1).*DiscountFactor(i,j);    %Spot por Factor de descuento
        ForwardCalculado(i,j)=abs(Forward(i,j)-Spot(i,1)); %Diferencia Forward Calculado menos Spot para obtener nuestros valores de Forward points
        ecm_forwards(i,j)=(ForwardEmpirico(i,j)-ForwardCalculado(i,j)).^2; %Calculo ECM
    end
end
format long
promedio_errores=mean2(ecm_forwards(i,j))       %Promedio para matrices


%% Strike

load('WorkingDays25.mat')
load('Vol25.mat')
load('Strike.mat')
load('Spot.mat')
load('Domestic25.mat')
load('Deltas.mat')
load('Foreing25.mat')

vol=(Vol25)./100; %check
Spot=(Spot); %check
q=(Foreing25); %check
r=(Domestic25); % check
T=(WorkingDays25)/365; %check
StrikeEmpirico=(Strike); %check
Delta=(Deltas); %check
alpha=1;
e=1;

d1=e*norminv(e*Delta/alpha);

Strikes=zeros(2663,25);
ecm_strike=zeros(2663,25);

for j=1:25
    for i=1:2663
        F(i,j)=Spot(i,1).*exp((r(i,j)-q(i,j)).*T(i,j));
        Strikes(i,j)=F(i,j).*exp((((vol(i,j).^2).*T(i,j)./2)-(d1(1,j).*vol(i,j).*sqrt(T(i,j)))));
        ecm_strike(i,j)=abs(StrikeEmpirico(i,j)-Strikes(i,j)).^2;      
    end
end
promedio_errores2=mean2(ecm_strike)

%% Option Value

load('WorkingDays25.mat')
load('Vol25.mat')
load('Strike.mat')
load('Spot.mat')
load('Domestic25.mat')
load('Deltas.mat')
load('Foreing25.mat')
load('OptionValue.mat')

vol=(Vol25)./100; %check
Spot=(Spot); %check
q=(Foreing25); %check
r=(Domestic25); % check
T=(WorkingDays25)/360; %check
StrikeEmpirico=(Strike); %check
OptionEmpirico=(OptionValue); %check
e=1;

d1=(log(Spot./Strike)+(r-q).*T)./(vol.*sqrt(T))+(vol.*sqrt(T)./2);
d2=d1-(vol.*sqrt(T));

for j=1:25
    for i=1:2663
        V(i,j)=e.*Spot(i,1).*exp(-q(i,j).*T(i,j)).*norm(e.*d1(1,j))-e.*Strike(i,j).*exp(-r(i,j).*T(i,j)).*norm(e.*d2(i,j));
        ecm_option(i,j)=immse(OptionEmpirico(i,j),V(i,j));
    end
end

promedio_errores3=mean2(ecm_option)



%% Step 4
clear all
clc
strike=500;
tenor=1;
rateclp=0.05;
rateusd=0.01;
spot=600;
vol=0.25;

%Black-Scholes
tic 
CallBS=ValueBS( strike, tenor, spot, rateclp, rateusd, vol, 1)
toc
N=100000;
dt=1/12;

% MonteCarlo

[value_mc,accuracy ] = MonteAnalytical( spot, rateclp, rateusd, vol, strike, tenor, N,dt )

%% DF

N=100;
z=3;
dtau=0.5;

[ Smax, Smin ] = extremes_values( spot, rateclp, rateusd, vol, tenor,z );
[S] = SpaceNodes( Smax, Smin, N);
[ A ] = MatrizA( spot, rateclp, rateusd, tenor, N, vol, z);

[ value_cn ] = CrankNicolson( spot, strike, rateclp, rateusd, vol, tenor, z, N, dtau )


%% Step 5
% Deposito a plazo
% Term Deposit
r=[0.05 0.1 0.2 0.3];
T=1;
Deposito=exp(-r*T);

%% Forward
[ value_f_bs ] = Forward_BS( strike, tenor, spot, rateclp, rateusd, vol );
N=1000000;
[value_f_mc,accuracy ] = ForwardMC( spot, rateclp, rateusd, vol, strike, tenor, N,dt ); %MonteCarlo
N=100;
[ value_f_cn ] = Forward_CN( spot, strike, rateclp, rateusd, vol, tenor, z, N, dtau );

%% Step 6
spotbarra=600;
omega=1;
eta=0.1;
N=100000;
tenor=1;
e=1;
vol=0.1;
strike=400;
[ value_bs_DD ] = ValueBS( strike, tenor, spot, rateclp, rateusd, vol, e);
[value_mc_DD,accuracy ] = DDMC( spot, rateclp, rateusd, spotbarra, strike, tenor, N, dt, eta, omega );
N=100;
[ value_cn_DD ] = CrankNicolson_DD( spot, strike, rateclp, rateusd, vol, tenor, z, N, dtau, eta, omega, spotbarra );
%% Analisis sensibilidad
clear all
clc
spot=600;
strike=500;
rateclp=0.05;
rateusd=0.01;
vol=0.1;
tenor=1;
z=3;
N=100;
dtau=0.5;
eta=0.32;
spotbarra=600;
omega=0.32;
x=0:0.05:1;
% Omega
[ value_DFDD_omega ] = sensibilidad_omega( spot, strike, rateclp, rateusd, vol, tenor, z, N, dtau, eta, spotbarra );
% Eta
[ value_DFDD_eta ] = sensibilidad_eta( spot, strike, rateclp, rateusd, vol, tenor, z, N, dtau, omega, spotbarra );
% Graficos
figure(4)
plot(x,value_DFDD_omega);
xlabel('Omega')
ylabel('Call Value')
legend('Value DF ')
figure(5)
plot(x,value_DFDD_eta);
xlabel('Eta')
ylabel('Call Value')
legend('Value DF ')
%% Step 7

absisa=600./Spot;

figure (6)
hold on
scatter(absisa,V1M, 'c')
scatter(absisa,V2M, 'g')
scatter(absisa,V3M, 'k')
scatter(absisa,V6M, 'b')
scatter(absisa,V1Y, 'r')
xlabel('Spot Ratio')
ylabel('Volatility')
legend('Vol 1M', 'Vol 2M', 'Vol 3M', 'Vol 6M', 'Vol 1Y')
h = lsline;
set(h(1),'color','c')
set(h(2),'color','g')
set(h(3),'color','k')
set(h(4),'color','b')
set(h(5),'color','r')
hold off

%% Valores obtenidos por regresion lineal mediante app: Curve Fitting Matlab
A1M=0.1573;
A2M=0.1551;
A3M=0.1547;
A6M=0.1561;
A1Y=0.1618;

B1M=-0.001014;
B2M=0.004675;
B3M=0.009371;
B6M=0.01688;
B1Y=0.02217;

eta1M=A1M+B1M;
eta2M=A2M+B2M;
eta3M=A3M+B3M;
eta6M=A6M+B6M;
eta1Y=A1Y+B1Y;

omega1M=A1M/(A1M+B1M);
omega2M=A2M/(A2M+B2M);
omega3M=A3M/(A3M+B3M);
omega6M=A6M/(A6M+B6M);
omega1Y=A1Y/(A1Y+B1Y);

etapromedio=(eta1M+eta2M+eta3M+eta6M+eta1Y)/5
omegapromedio=(omega1M+omega2M+omega3M+omega6M+omega1Y)/5

%% Smile MALA
spot=600;
rateclp=0.05;
rateusd=0.01;
vol=0.1;
tenor=1;
z=3;
N=100;
dtau=0.5;
spotbarra=600;
x=400:1:800;

k=0;
value_DFDD_smile=zeros(1,401);
for strike=400:1:800
    k=k+1;
    [ value_cn_DD ] = CrankNicolson_DD( spot, strike, rateclp, rateusd, vol, tenor, z, N, dtau, etapromedio, omegapromedio, spotbarra );
    value_DFDD_smile(1,k)=value_cn_DD;
end


plot(x, value_DFDD_smile)

%% The Model Calibration
% Primera Smile 1Y
% OMEGA = 0.9404 , ETA = 0.1674

N=100;
z=3;
dtau=1/365;
spotbarra=600;
omega=-11.9384061312991;
eta=0.0215274210669943;
%omega=0.9404; %inicial
%eta=0.1674; %inicial
%omega=1.32243750000000; % 10 iteraciones
%eta=0.0962549999999998; % 10 iteraciones
tenor=1;
e=1;

volM=[7.188	7.038	7.500	8.863	10.113]/100;
spot=497.75;
strike=[551.63	526.85	501.30	469.31	427.81];
%rateclp=-log(0.940642)/(365/365);
%rateusd=-log(0.949429514414867)/(365/365);
rateclp=0.0612;
rateusd=0.0512;

vol=0.1;

ValorObjetivo=zeros(1,5);
for i=1:5
    [ valor_cn_dd ] = CrankNicolson_DD( spot, strike(i), rateclp, rateusd, vol, tenor, z, N, dtau, eta, omega, spotbarra );
    ValorObjetivo(1,i)=valor_cn_dd;
end
% NEWTON-RAPHSON
y=zeros(1,5);
for j=1:5
    sigma=vol;
    for i= 1:N
        [ ValorBS, VegaBS ] = Pr1(strike(1,j), tenor, spot, rateclp, rateusd, sigma, e);
        [ sigma ] = nr( sigma, ValorObjetivo(1,j), ValorBS, VegaBS );
    end

    y(1,j)= sigma;
end
display (y)

%% Primera Smile

Volmodeloinicial=[0.1687    0.1691    0.1694    0.1697    0.1694];
Volmodelo10it=[0.0917    0.0909    0.0900    0.0887    0.0869];
Volmodelo200it= y;
VolmercadoDia2=[0.07188	0.07038	0.07500	0.08863	0.10113];


pilares = {'10P'; '25P'; 'ATM'; '25C'; '10C'};
plot(VolmercadoDia2)
hold on
plot(Volmodeloinicial, '--')
plot(Volmodelo10it, '--')
plot(Volmodelo200it, '--')
set(gca,'xtick',1:5,'xticklabel',pilares);
ylim([0.06 0.18])
legend('Vol mercado','Vol modelo inicial','Vol modelo 10 iter','Vol modelo 200 iter');
xlabel('Pilares')
ylabel('Volatilidad')
title('Smiles')
%% Smile de mercado

pilares = {'10P'; '25P'; 'ATM'; '25C'; '10C'};
VolatilityMarket = [M1 M2 M3 M6 Y1]/100;
plot(VolatilityMarket(1,1:5));
hold on
plot(VolatilityMarket(1,6:10));
hold on
plot(VolatilityMarket(1,11:15));
hold on
plot(VolatilityMarket(1,16:20));
hold on
plot(VolatilityMarket(1,21:25));
set(gca,'xtick',1:5,'xticklabel',pilares);
legend('1M','2M','3M','6M','1Y');
xlabel('Pilares')
ylabel('Volatilidad')
title('Dia 1')


%% Step 9 [Derivados Avanzados] [Rodrigo Duran]

% Parametros Iniciales
%omega0=0.9404;
%eta0=0.1674;
% Parametros Calibrados 200 it
omega0=-20.5799;
eta0=0.0143;
%%
%Parametros promedio 2663 dias
eta0=0.0906;
omega0=-12.3647;
%%
%Parametros calibracion final
eta0=0.1271;
omega0=-4.6241;
%%
omega0=0.9404;
eta0=0.1674;
tic
% Datos a Calibrar
for i=2663:2663
    x=[omega0 eta0];
% Funcion Optimizacion
    options=optimset('MaxFunEvals',200);
    fun=@(x)Min_Error(x,i);
    [Estimadores,error]=fminsearch(fun,x,options);
% Limites superior e inferior
%    if Estimadores(1)<-12.3647   % Inferior OMEGA
%        Estimadores(1)=-12.3647;
%    elseif Estimadores(1)>-12.3647  %Superior OMEGA
%        Estimadores(1)=-12.3647;
%    end
%    if Estimadores(2)<0.0906   % Inferior ETA
%        Estimadores(2)=0.0906;
%    elseif Estimadores(2)>0.0906  %Superior ETA
%        Estimadores(2)=0.0906;
%    end
% Asignacion Matriz
    Parametros(i,1) = Estimadores(1);
    Parametros(i,2) = Estimadores(2);
    Parametros(i,3) = error;
% Actualizacion Valores
    omega0=Estimadores(1);
    eta0=Estimadores(2);
end
toc
%% Plots parametros

fecha = {'Jan 2 2008'; 'Dec 5 2008'; '10 Nov 2009'; '14 Oct 2010'; '19 Sep 2011';'22 Aug 2012'; '26 Jul 2013'; '7 Jan 2014'; '4 Jun 2015';'9 May 2016';'12 April 2017';'16 Mar 2018'};
%fecha = {'Jan 2'; 'Mar 12'; '21 May'; '30 July'};
figure(1)
plot(Parametros(:,1), 'r');
set(gca,'xtick',1:242:2663,'xticklabel',fecha);
%set(gca,'xtick',1:50:200,'xticklabel',fecha);
legend('Omega','Location','southeast');
xlabel('Tiempo')
ylabel('Valor Omega')
title('Comportamiento Omega')

figure(2)
plot(Parametros(:,2));
set(gca,'xtick',1:242:2663,'xticklabel',fecha);
%set(gca,'xtick',1:50:200,'xticklabel',fecha);
legend('Eta');
xlabel('Tiempo')
ylabel('Valor Eta')
title('Comportamiento Eta')

%fecha = {'17 Oct 2013'; '14 July 2014'; '8 April 2015';'1 Jan 2016';'27 Sep 2016';'22 June 2017'};
x=ones(1,2663)*5;
y=ones(1,1148);
figure(3)
plot(Parametros(1:2663,3)*100,'black');
hold on
plot(x, '--red')
%plot(y,'--blue')
legend('Error', 'Error 5% cte', 'Error 1% cte');
xlabel('Tiempo')
ylabel('Error Volatilidad (%)')
set(gca,'xtick',1:242:2663,'xticklabel',fecha);
%set(gca,'xtick',1:192:1148,'xticklabel',fecha);
title('Error entre Mercado y Modelo')


%% Promedios

Omega_promedio=mean(Parametros(1515:2663,1));
Omega_std=std(Parametros(:,1));

Eta_promedio=mean(Parametros(1515:2663,2));
Eta_std=std(Parametros(:,2));

error_promedio=mean(Parametros(:,3));
error_std=std(Parametros(:,3));
%% Promedios sin crisis
omega_mean=((39/2265)*-28.8691)+((81/2265)*-9.4096)+((129/2265)*-5.9422)+((405/2265)*-22.3558)+((1611/2265)*-10.6726);
eta_mean=((39/2265)*0.0101)+((81/2265)*0.0649)+((129/2265)*0.0788)+((405/2265)*0.0314)+((1611/2265)*0.0961);
%% Optimizacion SIN CRISIS
eta0=0.0809;
omega0=-12.7604;
H=[1:39 113:194 416:545 567:973 1051:2663];
tic
% Datos a Calibrar
for i=H
    x=[omega0 eta0];
% Funcion Optimizacion
    options=optimset('MaxFunEvals',10);
    fun=@(x)Min_Error(x,i);
    [Estimadores,error]=fminsearch(fun,x,options);
% Limites superior e inferior
    if Estimadores(1)<-12.3647   % Inferior OMEGA
        Estimadores(1)=-12.3647;
    elseif Estimadores(1)>-12.3647  %Superior OMEGA
        Estimadores(1)=-12.3647;
    end
    if Estimadores(2)<0.0906   % Inferior ETA
        Estimadores(2)=0.0906;
    elseif Estimadores(2)>0.0906  %Superior ETA
        Estimadores(2)=0.0906;
    end
% Asignacion Matriz
    Parametros(i,1) = Estimadores(1);
    Parametros(i,2) = Estimadores(2);
    Parametros(i,3) = error;
% Actualizacion Valores
    %omega0=Estimadores(1);
    %eta0=Estimadores(2);
end
toc

%% The Model Calibration
% Ultima Smile

N=100;
z=3;
dtau=1/365;
spotbarra=600;
eta=0.1271;
omega=-4.6241;

tenor=1;
e=1;

volM=[8.718	8.329	8.823	10.047	12.208]/100;    %check
spot=608.21;                                        %check
strike=[685.72	647.92	611.86	570.41	517.67];    %check
rateclp=-log(0.973354)/(365/365);                   %check
rateusd=-log(0.977802996432153)/(365/365);          %check

vol=0.1;

ValorObjetivo=zeros(1,5);
for i=1:5
    [ valor_cn_dd ] = CrankNicolson_DD( spot, strike(i), rateclp, rateusd, vol, tenor, z, N, dtau, eta, omega, spotbarra );
    ValorObjetivo(1,i)=valor_cn_dd;
end
% NEWTON-RAPHSON
y=zeros(1,5);
for j=1:5
    sigma=vol;
    for i= 1:N
        [ ValorBS, VegaBS ] = Pr1(strike(1,j), tenor, spot, rateclp, rateusd, sigma, e);
        [ sigma ] = nr( sigma, ValorObjetivo(1,j), ValorBS, VegaBS );
    end

    y(1,j)= sigma;
end
display (y)

%% Ultima Smile


Volmodelo= y;
Volmodelo200it=[0.0669    0.0778    0.0882    0.1005    0.1165];
Volmercado=[8.718	8.329	8.823	10.047	12.208]/100;


pilares = {'10P'; '25P'; 'ATM'; '25C'; '10C'};
plot(Volmercado)
hold on
plot(Volmodelo200it)
plot(Volmodelo)
set(gca,'xtick',1:5,'xticklabel',pilares);
ylim([0.06 0.18])
legend('Vol mercado','Vol modelo 200 it', 'Vol modelo parametros ctes');
xlabel('Pilares')
ylabel('Volatilidad')
title('Smiles')
