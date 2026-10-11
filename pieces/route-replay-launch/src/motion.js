// Closed-form motion: direct seeking never depends on a previous frame.
const rrProgress = (a, b) => EZ.io(seg(TT, a, b));
function rrSpringAt(t, a, b, k = 170, damping = 18) {
  if (t <= a) return 0;
  if (t >= b) return 1;
  const u = seg(t, a, b), d = b - a;
  return springEase(t - a, k, damping) + (1 - springEase(d, k, damping)) * EZ.io(u);
}
const rrSpring = (a, b, k, damping) => rrSpringAt(TT, a, b, k, damping);
function rrAlpha(a, draw) {
  if (a <= .001) return;
  ctx.save(); ctx.globalAlpha *= clamp(a); draw(); ctx.restore();
}
function rrScaleAt(x, y, s, draw, dy = 0) {
  ctx.save(); ctx.translate(x, y + dy); ctx.scale(s, s); ctx.translate(-x, -y);
  draw(); ctx.restore();
}
const RR_ROUTE = [[1080,702],[1112,623],[1268,629],[1264,521],[1410,497],
  [1448,369],[1596,371],[1648,300]];

function rrOpeningWords() {
  clText('Your', 238, 455, 126, { weight: 500 });
  clText('workout.', 234, 612, 148, { weight: 500, color: CL.ink });
}
function rrReplayedWords() {
  clText('Replayed.', 245, 580, 170, { weight: 500, color: CL.blue });
  clText('Route Replay', 254, 711, 55, { weight: 400, color: '#687b8e' });
}
function rrIntroBridge() {
  rrPage();
  const u = clamp(rrSpring(2.65, 3.35, 155, 18));
  rrAlpha(1 - rrProgress(2.65, 2.94), () => {
    ctx.translate(0, -110 * rrProgress(2.65, 2.94)); rrOpeningWords();
  });
  rrAlpha(1 - rrProgress(2.65, 3.06), () => {
    rrContour(1360, 543, 262, 190, .65, 'rr-open-contour');
    rrRoute(RR_ROUTE, { w: 10, key: 'rr-opening-route', hideEnd: true });
  });
  rrAlpha(rrProgress(3.01, 3.35), () => {
    ctx.translate(-46 * (1 - rrProgress(3.01, 3.35)), 0); rrReplayedWords();
  });
  const x = lerp(1648, 1440, u), y = lerp(300, 536, u), r = lerp(16, 134, u);
  ctx.save(); ctx.fillStyle = CL.blue; ctx.beginPath(); ctx.arc(x, y, r, 0, TAU); ctx.fill();
  const aperture = Math.max(0, r - 3.5) * EZ.io(seg(u, .42, 1));
  if (aperture > .01) {
    ctx.fillStyle = '#ffffff'; ctx.beginPath(); ctx.arc(x, y, aperture, 0, TAU); ctx.fill();
  }
  ctx.restore();
  rrAlpha(EZ.io(seg(u, .62, 1)), () => rrDrawPlay(x, y, r, { circle: false }));
  SPARK_AT = [x, y];
}
