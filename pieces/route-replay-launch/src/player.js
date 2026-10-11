// Preview transport. The animation itself is always renderFrame(explicitTime).
const previewQuery = new URLSearchParams(location.search);
const preview = { time: Number(previewQuery.get('t') ?? 0), playing: false,
  sound: true, lastTick: null, audio: null, gain: null, buffer: null, source: null, preparing: false };
const playButton = document.getElementById('play'), soundButton = document.getElementById('sound');
const seekInput = document.getElementById('seek'), timeOutput = document.getElementById('time');
function rrPreviewState() {
  seekInput.value = preview.time;
  timeOutput.value = `${preview.time.toFixed(1)} / 30s`;
  playButton.textContent = preview.preparing ? 'Starting…' : preview.playing ? 'Pause' : 'Play trailer';
  soundButton.textContent = preview.sound ? 'Sound on' : 'Sound off';
  soundButton.setAttribute('aria-pressed', String(preview.sound));
  for (const a of document.querySelectorAll('nav a')) {
    const t = Number(new URL(a.href).searchParams.get('t'));
    const s = TIMELINE.shots.find(s => t >= s.t0 && t < s.t1);
    a.setAttribute('aria-current', String(preview.time >= s.t0 && preview.time < s.t1));
  }
}
function rrStopAudio() {
  if (preview.source) { try { preview.source.stop(); } catch {} preview.source = null; }
}
async function rrPrepareAudio() {
  if (preview.buffer) return;
  preview.audio = new AudioContext(); preview.gain = preview.audio.createGain();
  preview.gain.gain.value = preview.sound ? 1 : 0; preview.gain.connect(preview.audio.destination);
  const score = await buildScore(preview.audio.sampleRate);
  preview.buffer = preview.audio.createBuffer(2, score.left.length, score.sampleRate);
  preview.buffer.copyToChannel(score.left, 0); preview.buffer.copyToChannel(score.right, 1);
}
function rrStartAudio() {
  if (!preview.buffer) return;
  rrStopAudio(); const source = preview.audio.createBufferSource(); source.buffer = preview.buffer;
  source.connect(preview.gain); source.start(0, preview.time); preview.source = source;
}
async function rrPlayPreview() {
  if (preview.preparing) return;
  if (preview.playing) { preview.playing = false; rrStopAudio(); rrPreviewState(); return; }
  preview.preparing = true; rrPreviewState();
  try {
    if (preview.time >= DURATION - 1 / FPS) preview.time = 0;
    await rrPrepareAudio(); await preview.audio.resume();
    preview.playing = true; preview.lastTick = null; rrStartAudio();
  } finally { preview.preparing = false; rrPreviewState(); }
}
function rrSeekPreview(t) {
  preview.time = clamp(t, 0, DURATION - 1 / FPS); preview.lastTick = null;
  renderFrame(preview.time); if (preview.playing) rrStartAudio(); rrPreviewState();
}
playButton.addEventListener('click', rrPlayPreview);
soundButton.addEventListener('click', () => {
  preview.sound = !preview.sound;
  if (preview.gain) preview.gain.gain.setValueAtTime(preview.sound ? 1 : 0, preview.audio.currentTime);
  rrPreviewState();
});
seekInput.addEventListener('input', () => rrSeekPreview(Number(seekInput.value)));
document.getElementById('c').addEventListener('click', rrPlayPreview);
for (const a of document.querySelectorAll('nav a')) a.addEventListener('click', e => {
  e.preventDefault(); rrSeekPreview(Number(new URL(a.href).searchParams.get('t')));
});
function rrPreviewTick(ms) {
  if (preview.playing) {
    if (preview.lastTick !== null) preview.time += Math.max(0, (ms - preview.lastTick) / 1000);
    preview.lastTick = ms;
    if (preview.time >= DURATION - 1 / FPS) {
      preview.time = DURATION - 1 / FPS; preview.playing = false; rrStopAudio();
    }
    renderFrame(preview.time); rrPreviewState();
  }
  requestAnimationFrame(rrPreviewTick);
}
document.fonts.ready.then(() => {
  renderFrame(preview.time); rrPreviewState();
  if (!previewQuery.has('export')) requestAnimationFrame(rrPreviewTick);
});
