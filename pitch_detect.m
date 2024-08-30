function pitch = pitch_detect(sample, fs)
arguments
    sample (:, :) % N_samples x N_frames
    fs 
end
frame_size = size(sample, 1);
NFFT = 2 * frame_size;
samplesFFT = fft(sample, NFFT, 1);

framesXCorr = ifftshift(ifft(samplesFFT .* conj(samplesFFT), NFFT, 1), 1);
framesXCorr = framesXCorr(frame_size:end, :);

Ts = 1/fs;
T_pitch_max = 1/50;
T_pitch_min = 1/400;


minPitchIndex = T_pitch_min/Ts;
maxPitchIndex = T_pitch_max/Ts;
[mv, k_max] = max(framesXCorr(minPitchIndex:maxPitchIndex, :), [], 1);

pitch = max(k_max + minPitchIndex - 1, 0);