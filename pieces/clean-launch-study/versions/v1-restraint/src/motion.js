// Four compositions joined by one persistent object and one interpolated surface.
const clProgress = (a, b) => EZ.io(seg(TT, a, b));
const clArrive = (a, b) => EZ.o3(seg(TT, a, b));
function clAlpha(alpha, draw) {
  if (alpha <= .001) return;
  ctx.save(); ctx.globalAlpha *= clamp(alpha); draw(); ctx.restore();
}
function clOpeningLayout(draw = true, dy = 0) {
  const size = 122, a = 'Start with an ', b = 'idea';
  ctx.save(); ctx.font = `600 ${size}px ${CL.font}`; ctx.letterSpacing = `${-size * .035}px`;
  const wa = ctx.measureText(a).width, wb = ctx.measureText(b).width;
  const wp = ctx.measureText('.').width, left = (W - wa - wb - wp) / 2;
  if (draw) {
    clText(a, left, H / 2 + 38 + dy, size, { weight: 600 });
    clText(b, left + wa, H / 2 + 38 + dy, size, { weight: 600, color: CL.blue });
  }
  ctx.restore();
  return { x: left + wa + wb + wp * .46, y: H / 2 + 30, r: 7.5 };
}
function clFocusWords(alpha) {
  const rise = 26 * (1 - clArrive(1.73, 2.23));
  clAlpha(alpha, () => {
    clText('What if?', 228, 530 + rise, 172, { weight: 400, tracking: -6 });
    clText('A little possibility.', 236, 655 + rise, 64, { weight: 400, color: CL.muted, tracking: -1.8 });
  });
}
function clRevealWords(alpha) {
  const rise = 32 * (1 - clArrive(3.65, 4.18));
  clAlpha(alpha, () => {
    clText('Make it', 368, 482 + rise, 142, { weight: 500 });
    clText('tangible.', 368, 637 + rise, 142, { weight: 500, color: CL.blue });
  });
}
function clClosingWords(alpha) {
  const rise = 28 * (1 - clArrive(6.05, 6.62));
  clAlpha(alpha, () => clRun([{ text: 'An idea. Made ' }, { text: 'real.', color: CL.blue }], W / 2, 607 + rise, 122, { weight: 600 }));
}
function clComposition() {
  fillAll(CL.ground);
  const grow = clProgress(1.35, 2.08), form = clProgress(3.35, 4.15), close = clProgress(5.60, 6.35);
  const dot = clOpeningLayout(false);
  const halo = form * (1 - close);
  if (halo > .001) clHalo(W / 2, H / 2, 1488, 900, halo);
  // One board grows from the dot, changes aspect, then contracts into the mark.
  if (grow > .001 && close < .999) {
    let px = lerp(dot.x - 90, 98, grow), py = lerp(dot.y - 90, 226, grow);
    let pw = lerp(180, 1724, grow), ph = lerp(180, 628, grow), pr = lerp(90, 58, grow);
    px = lerp(px, 216, form); py = lerp(py, 90, form);
    pw = lerp(pw, 1488, form); ph = lerp(ph, 900, form); pr = lerp(pr, 24, form);
    const bx = lerp(px + pw / 2, W / 2, close), by = lerp(py + ph / 2, 338, close);
    pw = lerp(pw, 110, close); ph = lerp(ph, 110, close); pr = lerp(pr, 24.75, close);
    clAlpha(Math.min(1, grow * 2) * (1 - clProgress(6.10, 6.35)), () => {
      clPanel(bx - pw / 2, by - ph / 2, pw, ph, { r: Math.min(pr, pw / 2, ph / 2), shadow: lerp(22, 52, form), lift: lerp(5, 16, form) });
    });
  }
  clAlpha(1 - clProgress(1.35, 1.67), () => clOpeningLayout(true, -18 * grow));
  clFocusWords(clArrive(1.73, 2.23) * (1 - clProgress(3.35, 3.62)));
  clRevealWords(clArrive(3.65, 4.18) * (1 - clProgress(5.60, 5.87)));
  clClosingWords(clArrive(6.05, 6.62));
  // Maintain object identity through circle -> tile -> closing mark.
  let x = lerp(dot.x, 1450, grow), y = lerp(dot.y, 540, grow), r = lerp(dot.r, 178, grow);
  x = lerp(x, 1306, form); y = lerp(y, 540, form); r = lerp(r, 206, form);
  x = lerp(x, W / 2, close); y = lerp(y, 338, close); r = lerp(r, 55, close);
  y -= 5 * Math.sin(Math.PI * seg(TT, 2.23, 3.35)) ** 2;
  const aperture = clProgress(3.63, 4.13);
  const orbit = clArrive(4.02, 4.68) * (1 - clProgress(5.60, 5.96));
  if (orbit > .001) clAlpha(orbit, () => {
    ctx.lineWidth = 2; ctx.strokeStyle = CL.ring;
    ctx.beginPath(); ctx.arc(x + 26, y + 12, r + 70, -1.20, lerp(-1.20, 2.08, clArrive(4.02, 4.68))); ctx.stroke();
    ctx.strokeStyle = CL.ringFaint;
    ctx.beginPath(); ctx.arc(x + 26, y + 12, r + 104, -1.32, lerp(-1.32, 1.75, clArrive(4.10, 4.72))); ctx.stroke();
  });
  if (grow < .001) {
    ctx.fillStyle = CL.blue; ctx.beginPath(); ctx.arc(x, y, r, 0, TAU); ctx.fill(); SPARK_AT = [x, y];
  } else clToken(x, y, r, { square: form, aperture });
}
