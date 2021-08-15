%% get a section of the sound file
D = 'C:\Users\Tushar\Desktop\data\aeroplane';
S = dir(fullfile(D,'*.wav'));
N = numel(S);
y = cell(1,N);
Fs = cell(1,N);
quest = 'Do you want to detrend the signal?';
    dlgtitle = 'Detrending';
    btn1 = 'Yes, detrend the signal';
    btn2 = 'No, do not detrend the signal';
    defbtn = btn1;
    answer1 = questdlg(quest, dlgtitle, btn1, btn2, defbtn);
quest = 'What type of normalization do you want?';
    dlgtitle = 'Normalization';
    btn1 = 'Normalize the signal to unity peak';
    btn2 = 'Normalize the signal to unity RMS-value';
    btn3 = 'Do not normalize the signal';
    defbtn = btn1;
    answer2 = questdlg(quest, dlgtitle, btn1, btn2, btn3, defbtn);

for k = 1:N
    F = fullfile(D,S(k).name);
    [y{k},Fsa{k}] = audioread(F);
    x=y{k}
    fs=Fsa{k}
    x = x(:, 1);                     	% get the first channel
    N = length(x);                   	% signal length
    to = (0:N-1)/fs;                    % time vector
  

    % detrend the signal 
    switch answer1
        case btn1
        % detrend the signal    
        x = detrend(x);                             
        case btn2
        % do not detrend the signal
    end
    
    % normalize the signal
    switch answer2
        case btn1
        % normalize to unity peak
        x = x/max(abs(x));
        case btn2
        % normalize to unity RMS-value
        x = x/std(x); 
        case btn3
        % do not normalize the signal
    end
    % time-frequency analysis
    winlen = 1024;
    win = blackman(winlen, 'periodic');
    hop = round(winlen/4);
    nfft = round(2*winlen);
    [~, F, T, STPS] = spectrogram(x, win, winlen-hop, nfft, fs, 'power');
    STPS = 10*log10(STPS);

    % plot the spectrogram
    h(2*k)=figure(1)
    surf(T, F, STPS)
    shading interp
    axis tight
    box on
    view(0, 90)
    ax = gca;
    ax.Visible = 'off';
    path='C:\Users\Tushar\Desktop\data\z_output\aeroplane'
    exportgraphics(h(2*k),fullfile(path,['spectrogram' num2str(2*k) '.jpeg']));

    % cepstral analysis
    [C, q, tc] = cepstrogram(x, win, hop, fs);          % calculate the cepstrogram
    C = C(q >= 1e-3, :);                                % ignore all cepstrum coefficients for 
                                                        % quefrencies bellow 1 ms  
    q = q(q >= 1e-3);                                   % ignore all quefrencies bellow 1 ms
    q = q*1000;                                         % convert the quefrency to ms

    % plot the cepstrogram
    h(2*k+1)=figure(2)
    [T, Q] = meshgrid(tc, q);
    surf(T, Q, C)
    shading interp
    axis tight
    box on
    view(0, 90)
    ax = gca;
    ax.Visible = 'off';
    path='C:\Users\Tushar\Desktop\data\output\aeroplane'
    exportgraphics(h(2*k+1),fullfile(path,['cepstrogram' num2str(2*k+1) '.pdf']));

    %set(gca, 'FontName', 'Times New Roman', 'FontSize', 14)
    %xlabel('Time, s')
    %ylabel('Quefrency, ms')
    %title('Cepstrogram of the signal')

    commandwindow

    end