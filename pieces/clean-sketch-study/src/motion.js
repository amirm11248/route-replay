// Four compositions joined by one persistent object and one interpolated surface.
const clProgress = (a, b) => EZ.io(seg(TT, a, b));
const clArrive = (a, b) => EZ.o3(seg(TT, a, b));
// Closed-form springs with a tiny endpoint correction: safe to seek in any order.
function clSpringAt(t, a, b, k = 180, damping = 17) {
  if (t <= a) return 0;
  if (t >= b) return 1;
  const u = seg(t, a, b), duration = b - a;
  return springEase(t - a, k, damping) + (1 - springEase(duration, k, damping)) * EZ.io(u);
}
const clSpring = (a, b, k = 180, damping = 17) => clSpringAt(TT, a, b, k, damping);
function clKick(t0, amplitude, frequency = 3.5, damping = 5.5) {
  const dt = TT - t0;
  return dt < 0 ? 0 : amplitude * Math.exp(-damping * dt) * Math.sin(TAU * frequency * dt);
}
const clOpeningSize = () => lerp(62, 154, clSpring(.20, 1.15, 115, 13));
function clAlpha(alpha, draw) {
  if (alpha <= .001) return;
  ctx.save(); ctx.globalAlpha *= clamp(alpha); draw(); ctx.restore();
}
function clOpeningLayout(draw = true, dy = 0, size = 154) {
  const a = 'Start with an ', b = 'idea', baseline = H / 2 + size * .31 + dy;
  ctx.save(); ctx.font = `600 ${size}px ${CL.font}`; ctx.letterSpacing = `${-size * .035}px`;
  const wa = clMeasure(a, size, { weight: 600 }), wb = clMeasure(b, size, { weight: 600 });
  const wp = clMeasure('.', size, { weight: 600 }), left = (W - wa - wb - wp) / 2;
  if (draw) {
    clText(a, left, baseline, size, { weight: 600 });
    clText(b, left + wa, baseline, size, { weight: 600, color: CL.blue });
    clIdeaUnderline(left + wa, baseline + size * .13, wb, size);
  }
  ctx.restore();
  return { x: left + wa + wb + wp * .46, y: baseline - size * .065, r: size * .0615 };
}
function clFocusWords(alpha) {
  const rise = 72 * (1 - clSpring(1.73, 2.48, 240, 19));
  clAlpha(alpha, () => {
    clText('What if?', 228, 530 + rise, 172, { weight: 400, tracking: -6 });
    const subtitleRise = 54 * (1 - clSpring(1.83, 2.58, 220, 19));
    clText('A little possibility.', 236, 655 + subtitleRise, 70, { weight: 400, color: CL.muted, tracking: -1.8 });
  });
}
function clRevealWords(alpha) {
  const rise = 68 * (1 - clSpring(3.65, 4.45, 210, 18));
  clAlpha(alpha, () => {
    clText('Make it', 368, 482 + rise, 142, { weight: 500 });
    clText('tangible.', 368, 637 + rise, 142, { weight: 500, color: CL.blue });
  });
}
function clClosingWords(alpha) {
  const enter = clSpring(6.05, 6.82, 220, 18), rise = 66 * (1 - enter);
  clAlpha(alpha, () => clRun([{ text: 'An idea. Made ' }, { text: 'real.', color: CL.blue }], W / 2, 607 + rise, 122 * lerp(.88, 1, enter), { weight: 600 }));
}
function clComposition() {
  clSketchPage();
  const grow = clSpring(1.35, 2.30, 140, 16);
  const form = clSpring(3.35, 4.40, 145, 16);
  const close = Math.min(1.04, clSpring(5.60, 6.62, 140, 17));
  const dot = clOpeningLayout(false, 0, TT < 1.35 ? clOpeningSize() : 154);
  const halo = clamp(form) * (1 - clamp(close));
  if (halo > .001) clHalo(W / 2, H / 2, 1488, 900, halo);
  // One board grows from the dot, changes aspect, then contracts into the mark.
  const boardGrow = Math.min(1.045, grow), boardClose = clamp(close);
  if (grow > .001 && boardClose < .999) {
    let px = lerp(dot.x - 90, 98, boardGrow), py = lerp(dot.y - 90, 226, boardGrow);
    let pw = lerp(180, 1724, boardGrow), ph = lerp(180, 628, boardGrow), pr = lerp(90, 58, boardGrow);
    px = lerp(px, 216, form); py = lerp(py, 90, form);
    pw = lerp(pw, 1488, form); ph = lerp(ph, 900, form); pr = lerp(pr, 24, form);
    const bx = lerp(px + pw / 2, W / 2, boardClose), by = lerp(py + ph / 2, 338, boardClose);
    pw = lerp(pw, 110, boardClose); ph = lerp(ph, 110, boardClose); pr = lerp(pr, 24.75, boardClose);
    clAlpha(Math.min(1, grow * 2) * (1 - clProgress(6.10, 6.35)), () => {
      clPanel(bx - pw / 2, by - ph / 2, pw, ph, { r: Math.min(pr, pw / 2, ph / 2), shadow: lerp(22, 52, form), lift: lerp(5, 16, form) });
    });
  }
  const titleExit = clProgress(1.30, 1.63);
  clAlpha(1 - titleExit, () => clOpeningLayout(true, -100 * titleExit, clOpeningSize() * (1 + .05 * titleExit)));
  clFocusWords(clArrive(1.73, 2.23) * (1 - clProgress(3.35, 3.62)));
  clRevealWords(clArrive(3.65, 4.18) * (1 - clProgress(5.60, 5.87)));
  clClosingWords(clArrive(6.05, 6.62));
  // Maintain object identity through circle -> tile -> closing mark.
  let x = lerp(dot.x, 1450, grow), y = lerp(dot.y, 540, grow), r = lerp(dot.r, 178, grow);
  x = lerp(x, 1306, form); y = lerp(y, 540, form); r = lerp(r, 206, form);
  x = lerp(x, W / 2, close); y = lerp(y, 338, close); r = lerp(r, 55, close);
  y += clKick(1.72, 30, 3.2, 5) * (1 - clProgress(3.20, 3.35));
  y -= 14 * Math.sin(TAU * seg(TT, 2.30, 3.35)) * Math.sin(Math.PI * seg(TT, 2.30, 3.35)) ** 2;
  y += clKick(5.93, 35, 3.6, 5.5);
  const aperture = clamp(clSpring(3.63, 4.38, 200, 17));
  // The idea is still provisional in the focus beat: a pencil construction loop and arrow.
  clAlpha(clArrive(1.95, 2.38) * (1 - clProgress(3.24, 3.50)), () => {
    gline(loopPts(x + 5, y - 1, r * 1.16, r * 1.15, .04),
      { w: 2.2, col: CL.muted, a: .38, key: 'hy-construction', amp: 2.0, part: clArrive(1.95, 2.38) });
    const arrow = [[850, 676], [960, 718], [1090, 687], [1204, 609]];
    gline(arrow, { w: 2.9, col: CL.muted, a: .58, key: 'hy-thought-arrow', amp: 1.8, part: clArrive(2.23, 2.70) });
    if (TT > 2.70) gline([[1198, 638], [1204, 609], [1175, 617]],
      { w: 2.9, col: CL.muted, a: .58, key: 'hy-thought-arrow-tip', amp: 1.3 });
  });
  const orbit = clArrive(4.02, 4.68) * (1 - clProgress(5.60, 5.96));
  if (orbit > .001) clAlpha(orbit, () => {
    gline(arcPts(x + 26, y + 12, r + 70, -1.20, 2.08, 60),
      { w: 3.2, col: CL.muted, a: .74, key: 'hy-orbit-ink', amp: 1.4, part: clArrive(4.02, 4.68) });
    gline(arcPts(x + 26, y + 12, r + 104, -1.32, 1.75, 60),
      { w: 2.0, col: CL.muted, a: .35, key: 'hy-orbit-pencil', amp: 2.1, part: clArrive(4.10, 4.72) });
  });
  if (grow < .001) {
    ctx.fillStyle = CL.blue; ctx.beginPath(); ctx.arc(x, y, r, 0, TAU); ctx.fill(); SPARK_AT = [x, y];
  } else {
    const squash = clKick(1.80, .09, 3.6, 5) + clKick(5.96, .08, 3.6, 5.5);
    const tilt = clKick(3.48, .12, 2.8, 4.7) + clKick(5.90, .16, 2.8, 5.5);
    ctx.save(); ctx.translate(x, y); ctx.rotate(tilt); ctx.scale(1 + squash, 1 - squash);
    clToken(0, 0, Math.max(20, r), { square: clamp(form), aperture }); ctx.restore();
  }
}
