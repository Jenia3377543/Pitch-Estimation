root = '...\*.m4a';
VERBOSE = false;
frame_size = 256;
MIN_FRAME_ENERGY = 1e-5;

audiofiles = struct2table(dir(root));
audiofiles = audiofiles(~ismember(audiofiles.name, {'.', '..'}), :);
audiofiles.path = fullfile(audiofiles.folder, audiofiles.name);
all_pitches = [];

for fi = 1:height(audiofiles)
[x, fs] = audioread(string(audiofiles(fi, :).path));

x = resample(x, 8000, fs);
fs = 8000;
if VERBOSE
    player = audioplayer(x, fs);
    play(player);
end

zeros_to_pad = frame_size - mod(length(x), frame_size);
xPadded = [x; zeros(zeros_to_pad, 1)];
xFramed = reshape(xPadded, frame_size, []);

frames_energy = vecnorm(xFramed) / frame_size;
valid_frames = frames_energy >= MIN_FRAME_ENERGY;
pitches_in_samples = pitch_detect(xFramed(:, valid_frames), fs);

pitches_in_samples = nonzeros(pitches_in_samples);

pitches_in_frequency = fs ./ pitches_in_samples;

if VERBOSE
    figure;
    plot(pitches_in_frequency, '*', 'DisplayName', 'Pitch estimation');
    xlabel('Frame index');
    ylabel('Pitch [Hz]');
    ylim([0, 700]);
end

curr_pitch = prctile(pitches_in_frequency, 50);
all_pitches = cat(1, all_pitches, curr_pitch);
end
audiofiles.pitch = all_pitches;