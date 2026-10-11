function shotAtFrame(fr) {
  return TIMELINE.shots.find(s => fr >= Math.round(s.t0 * FPS) && fr < Math.round(s.t1 * FPS)) || TIMELINE.shots.at(-1);
}
function renderFrame(t, canvas, sub = false) {
  const cv = canvas || document.getElementById('c'); ctx = cv.getContext('2d');
  const wrapped = ((t % LOOP_T) + LOOP_T) % LOOP_T;
  F = Math.min(NFRAMES - 1, Math.floor(wrapped * FPS + .000001)); B = Math.floor(F / 2);
  TT = sub ? wrapped : F / FPS; E0 = shotAtFrame(F).t0; DEFER = null; SPARK_AT = null;
  ctx.save(); ctx.setTransform(1, 0, 0, 1, 0, 0); ctx.globalAlpha = 1;
  ctx.globalCompositeOperation = 'source-over'; ctx.filter = 'none'; ctx.setLineDash([]);
  clComposition(); ctx.restore(); return shotAtFrame(F).id;
}
window.renderFrame = renderFrame;
window.anchorAt = () => SPARK_AT ? { x: SPARK_AT[0], y: SPARK_AT[1] } : null;
