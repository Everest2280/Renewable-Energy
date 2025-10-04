% mppt_po.m
% MATLAB'de Perturb & Observe (P&O) algoritmasıyla MPPT simülasyonu
% Basitleştirilmiş bir PV modeline göre çalışır

clear; clc; close all;

%% PV Panel Parametreleri (örnek değerler)
Voc = 21;             % Açık devre gerilimi [V] – PV panelin yük bağlı değilkenki çıkış gerilimi
Isc = 4.5;            % Kısa devre akımı [A] – PV panelin çıkış uçları kısa devre edildiğindeki akımı
Vmp = 17;             % Maksimum güç noktası gerilimi [V]
Imp = 4.2;            % Maksimum güç noktası akımı [A]

Rload = 10;           % Yüke bağlanmış direnç (başlangıç değeri) [Ohm]
V = linspace(0, Voc, 100);   % 0'dan Voc'a kadar 100 noktalı gerilim vektörü oluşturulur

%% PV Modeli – Lineerleştirilmiş I-V 
% Basitleştirilmiş I-V modeli: Doğrusal; gerçek PV panelden farklı ama temel analiz için yeterlidir
I = Isc * (1 - V / Voc);      % I-V karakteristiği: akım gerilim arttıkça lineer olarak azalır
P = V .* I;                   % Güç hesaplanır: P = V * I

% Gerçek maksimum güç noktası – referans amaçlı
[Pmax, idx_max] = max(P);     % Maksimum güç değeri ve indeksi
Vmax_ref = V(idx_max);        % Maksimum güçteki gerilim
Imax_ref = I(idx_max);        % Maksimum güçteki akım

%% MPPT Algoritması Başlatma
Vpv = 0;                      % Başlangıçta PV çıkış gerilimi
Ipv = 0;                      % Başlangıçta PV çıkış akımı
Ppv = 0;                      % Başlangıçta PV çıkış gücü
dV = 0.2;                     % MPPT algoritması için gerilim adımı (perturbation)
Vpv = 5;                      % Başlangıç PV gerilim değeri
iter = 100;                   % Simülasyon iterasyon sayısı (süre gibi düşünülebilir)

% Sonuçları kaydetmek için boş diziler oluştur
P_arr = zeros(1, iter);       % Güç değerlerini tutar
V_arr = zeros(1, iter);       % Gerilim değerlerini tutar
I_arr = zeros(1, iter);       % Akım değerlerini tutar

%% MPPT – Perturb & Observe Döngüsü
for k = 2:iter
    % Mevcut PV akımı (basitleştirilmiş modele göre hesaplanır)
    Ipv = Isc * (1 - Vpv / Voc);
    
    % Mevcut güç değeri
    Ppv = Vpv * Ipv;

    % Bir önceki iterasyondaki değerleri sakla
    V_prev = Vpv;
    P_prev = P_arr(k-1);

    % P&O Karar Mekanizması
    % Güç artarsa, önceki gerilim yönünde devam
    % Güç azalırsa, ters yöne sapılır
    if Ppv > P_prev
        if Vpv > V_prev
            Vpv = Vpv + dV;   % Aynı yönde artır
        else
            Vpv = Vpv - dV;   % Aynı yönde azalt
        end
    else
        if Vpv > V_prev
            Vpv = Vpv - dV;   % Yönü değiştir (azalt)
        else
            Vpv = Vpv + dV;   % Yönü değiştir (artır)
        end
    end

    % Güncel değerleri dizilere kaydet
    P_arr(k) = Ppv;
    V_arr(k) = Vpv;
    I_arr(k) = Ipv;
end

%% Grafiklerle Sonuçların Görselleştirilmesi
t = 1:iter;   % Zaman vektörü (sadece iterasyon sayısı kadar)

% PV Gerilimi zamanla nasıl değişti?
figure;
subplot(3,1,1)
plot(t, V_arr, 'b', 'LineWidth', 1.5); grid on;
ylabel('Gerilim [V]');
title('MPPT: Gerilim Zaman Grafiği');

% PV Akımı zamanla nasıl değişti?
subplot(3,1,2)
plot(t, I_arr, 'g', 'LineWidth', 1.5); grid on;
ylabel('Akım [A]');
title('MPPT: Akım Zaman Grafiği');

% PV Gücü zamanla nasıl değişti?
subplot(3,1,3)
plot(t, P_arr, 'r', 'LineWidth', 1.5); grid on;
ylabel('Güç [W]');
xlabel('Zaman (iterasyon)');
title('MPPT: Güç Zaman Grafiği');

%% Sonuçların Konsola Yazdırılması
% MPPT ile ulaşılan güç, gerilim ve akım değerleri referans (teorik) maksimumla karşılaştırılır
fprintf('--- MPPT Sonuçları ---\n');
fprintf('Teorik Max Güç: %.2f W (V=%.2fV, I=%.2fA)\n', Pmax, Vmax_ref, Imax_ref);
fprintf('MPPT Son Güç : %.2f W (V=%.2fV, I=%.2fA)\n', Ppv, Vpv, Ipv);
 