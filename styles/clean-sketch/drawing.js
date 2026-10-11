// Clean Sketch: one merged kit, with launch geometry and sketchbook material.
const CL = {
  ground: '#f3f1e9', ink: '#20252b', blue: '#243e58', cyan: '#657f8d',
  violet: '#665f76', border: '#dcdddc', muted: '#7a7d83',
  tokenTop: '#648091', tokenMid: '#385870', tokenBottom: '#1b3248',
  ring: '#a7b4be', ringFaint: '#cdd3d7',
  font: '"Helvetica Neue", Arial, sans-serif'
};

function clType(text, size, o = {}) {
  const hand = o.hand ?? /^(idea|What if\?|tangible\.|real\.)$/.test(text);
  return { font: `${hand ? 700 : o.weight ?? 500} ${size}px ${hand ? HAND : CL.font}`,
    tracking: hand ? -size * .012 : o.tracking ?? -size * .035, hand };
}
function clMeasure(text, size, o = {}) {
  const type = clType(text, size, o); ctx.save(); ctx.font = type.font;
  ctx.letterSpacing = `${type.tracking}px`; const w = ctx.measureText(text).width; ctx.restore(); return w;
}

function clText(text, x, y, size, o = {}) {
  ctx.save();
  const type = clType(text, size, o); ctx.font = type.font;
  ctx.letterSpacing = `${type.tracking}px`;
  ctx.textAlign = o.align ?? 'left'; ctx.textBaseline = 'alphabetic'; ctx.fillStyle = o.color ?? CL.ink;
  ctx.fillText(text, x, y);
  if (type.hand) {
    ctx.strokeStyle = ctx.fillStyle; ctx.lineWidth = Math.max(.3, size * .003);
    ctx.strokeText(text, x, y);
  }
  const width = ctx.measureText(text).width;
  ctx.restore(); return width;
}

function clRun(parts, x, y, size, o = {}) {
  ctx.save(); ctx.font = `${o.weight ?? 600} ${size}px ${CL.font}`;
  ctx.letterSpacing = `${o.tracking ?? -size * 0.035}px`;
  const widths = parts.map(p => clMeasure(p.text, size, { ...o, ...p })), total = widths.reduce((a, b) => a + b, 0);
  let at = x - total / 2;
  parts.forEach((p, i) => { clText(p.text, at, y, size, { ...o, color: p.color ?? CL.ink }); at += widths[i]; });
  ctx.restore(); return total;
}

function clPanel(x, y, w, h, o = {}) {
  ctx.save();
  ctx.shadowColor = 'rgba(12, 22, 35, 0.07)'; ctx.shadowBlur = o.shadow ?? 38; ctx.shadowOffsetY = o.lift ?? 10;
  ctx.beginPath(); ctx.roundRect(x, y, w, h, o.r ?? 32); ctx.fillStyle = o.fill ?? CL.ground; ctx.fill();
  ctx.shadowColor = 'transparent';
  ctx.save(); ctx.clip(); ctx.globalAlpha *= .80; ctx.drawImage(clPaperTexture(), x, y); ctx.restore();
  const P = sketchBox(x, y, w, h, o.r ?? 32, .012);
  gline(P, { w: 3.2, col: CL.ink, a: .64, key: 'hy-panel-ink', amp: 1.3, closed: true });
  gline(sketchBox(x - 5, y + 5, w + 8, h - 2, o.r ?? 32, .015),
    { w: 1.3, col: CL.muted, a: .28, key: 'hy-panel-pencil', amp: 2.1, closed: true });
  if (w > 700 && h > 300) clBinding(x + 40, x + w - 40, y + 32, .55, 110);
  ctx.restore();
}

let CL_PAPER_TEXTURE = null;
function clPaperTexture() {
  if (CL_PAPER_TEXTURE) return CL_PAPER_TEXTURE;
  const c = document.createElement('canvas'); c.width = W; c.height = H;
  const g = c.getContext('2d'), R = RNG('hybrid-paper-tooth');
  g.fillStyle = 'rgba(52,68,80,.035)'; g.beginPath();
  for (let i = 0; i < 25000; i++) g.rect(R.r(0, W), R.r(0, H), R.r(.5, 1.6), R.r(.5, 1.5));
  g.fill(); g.strokeStyle = 'rgba(74,84,88,.065)'; g.lineWidth = .65; g.beginPath();
  for (let i = 0; i < 800; i++) {
    const x = R.r(0, W), y = R.r(0, H), len = R.r(4, 16), a = R.r(0, TAU);
    g.moveTo(x, y); g.lineTo(x + len * Math.cos(a), y + len * Math.sin(a));
  }
  g.stroke(); g.fillStyle = 'rgba(75,88,95,.15)';
  for (let y = 24; y < H; y += 48) for (let x = 24; x < W; x += 48) {
    g.beginPath(); g.arc(x, y, 1.15, 0, TAU); g.fill();
  }
  return (CL_PAPER_TEXTURE = c);
}
function clBinding(x0, x1, y, alpha = .3, gap = 92) {
  for (let x = x0, i = 0; x < x1; x += gap, i++) {
    const P = [[x + 2, y], [x + 7, y - 15], [x + 4, y - 30], [x - 6, y - 36], [x - 11, y - 28]];
    gline(P, { w: 2.6, col: CL.ink, a: alpha, key: 'hy-binding-' + i, amp: .55, second: false });
    ctx.save(); ctx.globalAlpha *= alpha; ctx.fillStyle = CL.ink;
    ctx.beginPath(); ctx.ellipse(x + 2, y + 2, 3.5, 4.8, 0, 0, TAU); ctx.fill(); ctx.restore();
  }
}
function clSketchPage() {
  fillAll(CL.ground); ctx.drawImage(clPaperTexture(), 0, 0);
  clBinding(66, W - 50, 58, .34, 94);
  gline([[W - 20, 90], [W - 18, H - 60]], { w: 1.4, col: CL.muted, a: .28, key: 'hy-page-edge', amp: .8 });
  gline([[W - 26, 95], [W - 24, H - 55]], { w: 1.2, col: CL.muted, a: .17, key: 'hy-page-edge-2', amp: .7 });
}
function clIdeaUnderline(x, y, width, size) {
  const part = EZ.o3(seg(TT, .55, 1.06));
  if (part < .001) return;
  const P = [[x - 3, y], [x + width * .40, y + size * .018], [x + width + 3, y - size * .025]];
  gline(P, { w: Math.max(2, size * .027), col: CL.blue, a: .75, key: 'hy-idea-underline', amp: 1.4, part, second: false });
  if (TT > .55 && TT < 1.19) {
    const tip = writeEnd(P, part), alpha = 1 - EZ.io(seg(TT, 1.06, 1.19));
    ctx.save(); ctx.globalAlpha *= alpha; ctx.translate(...tip); ctx.rotate(-.62); ctx.scale(size / 154, size / 154);
    const pencilP = [[0, 0], [23, -9], [149, -9], [158, -6], [158, 6], [149, 9], [23, 9], [0, 0]];
    gfill(pencilP, CL.blue, { off: [0, 0], amp: .6, key: 'hy-pencil-body' });
    gfill([[0, 0], [23, -9], [23, 9]], '#ad9c83', { off: [0, 0], amp: .5, key: 'hy-pencil-wood' });
    gfill([[0, 0], [9, -3], [9, 3]], CL.ink, { off: [0, 0], amp: .3, key: 'hy-pencil-lead' });
    gline(pencilP, { w: 1.9, col: CL.ink, key: 'hy-pencil-outline', amp: .6, closed: true, second: false });
    gline([[32, -4], [144, -4]], { w: 1.2, col: CL.cyan, key: 'hy-pencil-highlight', amp: .4, second: false });
    ctx.restore();
  }
}

function clHalo(x, y, w, h, strength = 1) {
  ctx.save();
  // Deep slate light around the artboard; restrained saturation and no bright bloom.
  const wash = ctx.createLinearGradient(0, 0, W, H);
  wash.addColorStop(0, '#202c3a'); wash.addColorStop(.3, '#35495b');
  wash.addColorStop(.7, '#536977'); wash.addColorStop(1, '#3e384d');
  ctx.globalAlpha = strength; ctx.fillStyle = wash; ctx.fillRect(0, 0, W, H);
  const blobs = [
    [x - w * .60, y + h * .05, w * .48, 'rgba(43,66,87,.35)'],
    [x + w * .55, y - h * .15, w * .52, 'rgba(98,132,145,.32)'],
    [x + w * .60, y + h * .55, w * .37, 'rgba(88,75,105,.26)'],
    [x - w * .22, y + h * .60, w * .45, 'rgba(84,114,127,.24)']
  ];
  ctx.globalAlpha = strength;
  for (const [cx, cy, r, col] of blobs) {
    const g = ctx.createRadialGradient(cx, cy, 0, cx, cy, r); g.addColorStop(0, col); g.addColorStop(1, 'rgba(253,253,253,0)');
    ctx.fillStyle = g; ctx.fillRect(0, 0, W, H);
  }
  ctx.restore();
}

function clToken(x, y, r, o = {}) {
  ctx.save();
  ctx.shadowColor = 'rgba(18,40,60,.12)'; ctx.shadowBlur = r * .10; ctx.shadowOffsetY = r * .05;
  ctx.beginPath();
  const square = clamp(Number(o.square ?? 0));
  ctx.roundRect(x - r, y - r, 2 * r, 2 * r, lerp(r, r * .45, square));
  const g = ctx.createLinearGradient(x - r, y - r, x + r, y + r);
  g.addColorStop(0, CL.tokenTop); g.addColorStop(.42, CL.tokenMid); g.addColorStop(1, CL.tokenBottom);
  ctx.fillStyle = g; ctx.fill(); ctx.shadowColor = 'transparent';
  const P = sketchBox(x - r, y - r, 2 * r, 2 * r, lerp(r, r * .45, square), .012);
  ctx.save(); ctx.clip();
  ghatch(x - r, y - r, x + r, y + r, { ang: -.80, gap: Math.max(8, r * .075), col: '#9bb0b8',
    w: Math.max(1.3, r * .015), a: .34, key: 'hy-token-hatch' });
  ctx.restore();
  gline(P, { w: Math.max(2.5, r * .025), col: CL.ink, key: 'hy-token-outline', amp: Math.max(.5, r * .010), closed: true });
  gline(sketchBox(x - r - 4, y - r + 3, 2 * r + 5, 2 * r, lerp(r, r * .45, square), .024),
    { w: Math.max(1.2, r * .009), col: CL.muted, a: .50, key: 'hy-token-pencil', amp: Math.max(.8, r * .016), closed: true });
  const aperture = clamp(Number(o.aperture ?? 0));
  if (aperture > .001) {
    const aw = r * .36 * aperture, ah = r * 1.16 * aperture;
    ctx.beginPath(); ctx.roundRect(x - aw / 2, y - ah / 2, aw, ah, Math.min(aw / 2, r * .18));
    ctx.fillStyle = CL.ground; ctx.fill();
    gline(sketchBox(x - aw / 2, y - ah / 2, aw, ah, Math.min(aw / 2, r * .18), .02),
      { w: Math.max(1.2, r * .008), col: '#b2bdbe', a: .8, key: 'hy-aperture', amp: .6, closed: true, second: false });
  }
  SPARK_AT = toScreen(x, y); ctx.restore();
}

function clCaption(text, o = {}) {
  const draw = () => clText(text, W / 2, H * .83, 58, { color: CL.ink, align: 'center', ...o });
  if (DEFER) DEFER.push(draw); else draw();
}

const STYLE = {
  name: 'clean-sketch', paper: CL.ground, heroColor: CL.blue, ones: true,
  backdrop(c) { fillAll(c); ctx.drawImage(clPaperTexture(), 0, 0); },
  window(P, key, src) { ctx.save(); trace(P, true); ctx.clip(); ctx.drawImage(src, 0, 0); ctx.restore(); },
  blob(P, color) { ctx.save(); trace(P, true); ctx.fillStyle = color; ctx.fill(); ctx.restore(); },
  hero(x, y, r, o = {}) { clToken(x, y, r, o); },
  heroPts(x, y, r) { return ellipsePts(x, y, r, r, 0, 64); },
  post() {}
};
