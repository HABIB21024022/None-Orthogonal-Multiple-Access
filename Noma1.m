% NOMA Simulation Parameters
numSymbols = 10^5;         % Number of symbols per user
Pt = 1;                    % Total transmit power
alpha = 0.8;               % Power allocation coefficient for User 1
beta = 0.15;               % Power allocation coefficient for User 2
gamma = 1 - alpha - beta;  % Power allocation coefficient for User 3
EbN0_dB = 0:2:30;          % Eb/N0 range in dB

% BPSK Modulation (Symbol Mapping)
data1 = randi([0 1], 1, numSymbols);  % Random binary data for User 1
data2 = randi([0 1], 1, numSymbols);  % Random binary data for User 2
data3 = randi([0 1], 1, numSymbols);  % Random binary data for User 3
x1 = 2 * data1 - 1;                   % BPSK for User 1
x2 = 2 * data2 - 1;                   % BPSK for User 2
x3 = 2 * data3 - 1;                   % BPSK for User 3

% Transmit signal with power allocation for each user
s = sqrt(alpha * Pt) * x1 + sqrt(beta * Pt) * x2 + sqrt(gamma * Pt) * x3;

% Initialize BER results
BER_User1 = zeros(1, length(EbN0_dB));
BER_User2 = zeros(1, length(EbN0_dB));
BER_User3 = zeros(1, length(EbN0_dB));

for idx = 1:length(EbN0_dB)
    % Noise and Channel
    EbN0 = 10^(EbN0_dB(idx)/10);
    N0 = Pt / ( EbN0);      % Noise spectral density
    noise = sqrt(N0/2) * (randn(1, numSymbols) + 1i * randn(1, numSymbols));
    h = (randn(1, numSymbols) + 1i * randn(1, numSymbols)) / sqrt(2); % Rayleigh fading

    % Generation of Received signal
    y = h .* s + noise;
    % Channel equalization
    y_equalized = y ./ h;

    % Successive Interference Cancellation (SIC) for User 1
    y_User1 = y_equalized / sqrt(alpha * Pt);  % Normalize for User 1
    detected_x1 = real(y_User1) > 0;           % BPSK Detection for User 1
    BER_User1(idx) = sum(detected_x1 ~= data1) / numSymbols;

    % Remove User 1's signal for User 2 decoding
    y_User2 = y_equalized - sqrt(alpha * Pt) * x1; % SIC to cancel User 1's signal
    y_User2 = y_User2 / sqrt(beta * Pt);          % Normalize for User 2
    detected_x2 = real(y_User2) > 0;              % BPSK Detection for User 2
    BER_User2(idx) = sum(detected_x2 ~= data2) / numSymbols;

    % Remove User 2's signal for User 3 decoding
    y_User3 = y_User2 - sqrt(beta * Pt) * x2;     % SIC to cancel User 2's signal
    y_User3 = y_User3 / sqrt(gamma * Pt);         % Normalize for User 3
    detected_x3 = real(y_User3) > 0;              % BPSK Detection for User 3
    BER_User3(idx) = sum(detected_x3 ~= data3) / numSymbols;
end

% Plot results
figure;
semilogy(EbN0_dB, BER_User1, 'b-o', 'LineWidth', 2);
hold on;
semilogy(EbN0_dB, BER_User2, 'r-*', 'LineWidth', 2);
semilogy(EbN0_dB, BER_User3, 'g-^', 'LineWidth', 2);
grid on;
xlabel('Eb/N0 (dB)');
ylabel('Bit Error Rate (BER)');
legend('User 1 (High Power)', 'User 2 (Medium Power)', 'User 3 (Low Power)');
title('NOMA BER Performance with 3 Users');

% Power Allocation vs Frequency Spectrum Plot
frequency = linspace(0, 1, 100);         % Normalized frequency spectrum
power1 = alpha * ones(size(frequency));  % Power allocated to User 1
power2 = beta * ones(size(frequency));   % Power allocated to User 2
power3 = gamma * ones(size(frequency));  % Power allocated to User 3
figure;

hold on;
area(frequency, power1, 'FaceColor', 'b', 'DisplayName', 'User 1 Power');
area(frequency,power2, 'FaceColor', 'r', 'DisplayName', 'User 2 Power');
area(frequency,  power3, 'FaceColor', 'g', 'DisplayName', 'User 3 Power');
grid on;
xlabel('Normalized Frequency');
ylabel('Power Allocation');
title('Power Allocation vs Frequency Spectrum');
legend('show');
hold off;

% % Create subplots for transmitted and received signals for three users
% figure;
% 
% % Transmitted Signal for User 1
% subplot(3, 2, 1);
% plot(1:500, real(sqrt(alpha * Pt) * x1(1:500)), 'b', 'LineWidth', 1.5);
% grid on;
% xlabel('Symbol Index');
% ylabel('Amplitude');
% title('Transmitted Signal - User 1');
% 
% % Received Signal for User 1
% subplot(3, 2, 2);
% plot(1:500, real(y(1:500)), 'r', 'LineWidth', 1.5);
% grid on;
% xlabel('Symbol Index');
% ylabel('Amplitude');
% title('Received Signal - User 1');
% 
% % Transmitted Signal for User 2
% subplot(3, 2, 3);
% plot(1:500, real(sqrt(beta * Pt) * x2(1:500)), 'b', 'LineWidth', 1.5);
% grid on;
% xlabel('Symbol Index');
% ylabel('Amplitude');
% title('Transmitted Signal - User 2');
% 
% % Received Signal for User 2
% subplot(3, 2, 4);
% plot(1:500, real(y(1:500)), 'r', 'LineWidth', 1.5);
% grid on;
% xlabel('Symbol Index');
% ylabel('Amplitude');
% title('Received Signal - User 2');
% 
% % Transmitted Signal for User 3
% subplot(3, 2, 5);
% plot(1:500, real(sqrt(gamma * Pt) * x3(1:500)), 'b', 'LineWidth', 1.5);
% grid on;
% xlabel('Symbol Index');
% ylabel('Amplitude');
% title('Transmitted Signal - User 3');
% 
% % Received Signal for User 3
% subplot(3, 2, 6);
% plot(1:500, real(y(1:500)), 'r', 'LineWidth', 1.5);
% grid on;
% xlabel('Symbol Index');
% ylabel('Amplitude');
% title('Received Signal - User 3');

% % Plot a subset of transmitted and received signals
% subset = 1:500; % Choose the first 500 symbols for visualization
% figure;
% plot(real(s(subset)), 'b-', 'LineWidth', 1.5);
% hold on;
% plot(real(y(subset)), 'r-', 'LineWidth', 1.5);
% grid on;
% xlabel('Symbol Index');
% ylabel('Amplitude');
% title('Comparison of Transmitted and Received Signals');
% legend('Transmitted Signal', 'Received Signal');
% hold off;
