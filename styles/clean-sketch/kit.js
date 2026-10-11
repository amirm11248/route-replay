// =====================================================================
//  styles/sketchbook/kit.js — graphite and one accent colour on a sketchbook page, hand lettering.
//  On top of kit/core.js (RNG, resample, subPath, trace, bbox, grain, toScreen, fillAll, screen, TT/ev/popS/DEFER/E0).
//  Names here never reuse core's: gline / gpencil (not ink / pencil), writeOn (not subPath), ghatch (not hatch),
//  loopPts / sketchBox (not ellipsePts / rrectPts), handLetter (not handwrite).
//  Needs from the piece head: HAND (hand font stack), CX (caption centre x). The marker stack is SK_MARKER below.
//
//  THE PAGE   one warm page (dot grid or ruled, tooth, fibres, smudges, a coffee ring, spiral binding), built once
//             from a seeded RNG and cached; the page is the world, so it moves with the camera.
//  THE HAND   every line is redrawn on 2s: wobble phases reseed per boil (B); structure (where a scribble goes)
//             is seeded by key and never reseeds, only the tremor does.
//  THE INKS   graphite = rough, provisional, the mess. Ink = what is settled. ONE accent colour (terracotta) = the hero.
//             Highlighter yellow marks what to read; red marker is for a title underline or a stamp, once.
// =====================================================================
const SK = {
  paper: '#f3f1e9', ink: '#20252b', graph: '#69747b', graphL: '#a0a8aa',
  terra: '#243e58', terraD: '#1b3248', cream: '#f7ecd9', sheet: '#fffdf6',
  hilite: '#f7d64a', red: '#e0483a', green: '#4f9d5d', blue: '#3b5c8c',
  pink: '#ef9aa6', glass: '#9cc6d8', tape: '#efe2b4', wood: '#ecc995', lead: '#3b3632', yellow: '#f1bf2c',
};
const SK_HAND = HAND;
const SK_MARKER = '"Segoe Print", "Marker Felt", "Bradley Hand", "Comic Sans MS", cursive';

// ---------------------------------------------------------------------
//  THE HAND: polylines that boil
// ---------------------------------------------------------------------
// wobble along the normal, phases reseeded every boil step; index-based so the tremor follows the stroke
function gwob(P, key, amp) {
  const R = RNG('gw', key, B), p1 = R.r(0, TAU), p2 = R.r(0, TAU), f1 = 0.28 + R.f() * 0.25, f2 = 0.9 + R.f() * 0.5;
  const n = P.length, out = new Array(n);
  for (let i = 0; i < n; i++) {
    const a = P[Math.max(0, i - 1)], b = P[Math.min(n - 1, i + 1)];
    let nx = a[1] - b[1], ny = b[0] - a[0]; const l = Math.hypot(nx, ny) || 1; nx /= l; ny /= l;
    const o = amp * (0.62 * Math.sin(i * f1 + p1) + 0.38 * Math.sin(i * f2 + p2));
    out[i] = [P[i][0] + nx * o, P[i][1] + ny * o];
  }
  return out;
}
// write-on: the first `part` of a polyline by length (null when nothing shows yet)
function writeOn(P, part) {
  if (part >= 1) return P;
  if (part <= 0) return null;
  const Q = subPath(P, part);
  return Q.length > 1 ? Q : null;
}
const writeEnd = (P, part) => { const Q = writeOn(resample(P, false, 12), clamp(part)); return Q ? Q[Q.length - 1] : P[0]; };
const closeP = (P) => [...P, P[0]];
// the ink line: one confident stroke and a thin second pass that doesn't quite agree.
// o: w, col, a, key, amp, part (write-on 0..1), step, second, closed
function gline(P, o = {}) {
  const { w = 5, col = SK.ink, a = 1, key = 'gl', amp = 1.7, part = 1, step = 12, second = true } = o;
  const Q = writeOn(resample(o.closed ? closeP(P) : P, false, step), part); if (!Q) return null;
  ctx.save(); ctx.globalAlpha *= a; ctx.strokeStyle = col; ctx.lineCap = 'round'; ctx.lineJoin = 'round';
  ctx.lineWidth = w; trace(gwob(Q, key, amp), false); ctx.stroke();
  if (second) { ctx.globalAlpha *= 0.55; ctx.lineWidth = w * 0.42; trace(gwob(Q, key + '~', amp * 1.6), false); ctx.stroke(); }
  ctx.restore();
  return Q;
}
// the graphite line: two light passes, the second looser (construction, mess, things not settled yet)
function gpencil(P, o = {}) {
  const { w = 2.4, col = SK.graph, a = 0.8, key = 'gp', amp = 2.4, part = 1, step = 12, passes = 2 } = o;
  const Q = writeOn(resample(o.closed ? closeP(P) : P, false, step), part); if (!Q) return null;
  ctx.save(); ctx.strokeStyle = col; ctx.lineCap = 'round'; ctx.lineJoin = 'round';
  for (let k = 0; k < passes; k++) {
    ctx.globalAlpha = a * (k ? 0.5 : 0.85); ctx.lineWidth = w * (k ? 0.8 : 1);
    trace(gwob(Q, key + ':' + k, amp * (1 + k * 0.6)), false); ctx.stroke();
  }
  ctx.restore();
  return Q;
}
// a hand-drawn loop: overshoots its start and drifts outward a little (over = how far past 360°)
function loopPts(cx, cy, rx, ry, over = 0.07, a0 = -2.2, n = 0) {
  const N = n || Math.max(24, Math.ceil((rx + ry) * 0.35)), P = [];
  for (let i = 0; i <= N; i++) {
    const u = i / N, a = a0 + u * TAU * (1 + over), s = 1 + 0.035 * u * Math.sign(over);
    P.push([cx + Math.cos(a) * rx * s, cy + Math.sin(a) * ry * s]);
  }
  return P;
}
// a box drawn in one go: rounded corners (r), the pen runs a little past the start (over)
function sketchBox(x, y, w, h, r = 0, over = 0.04) {
  const P = [], arc = (cx, cy, a0) => { for (let i = 0; i <= 6; i++) { const a = a0 + (i / 6) * Math.PI / 2; P.push([cx + Math.cos(a) * r, cy + Math.sin(a) * r]); } };
  arc(x + w - r, y + r, -Math.PI / 2); arc(x + w - r, y + h - r, 0); arc(x + r, y + h - r, Math.PI / 2); arc(x + r, y + r, Math.PI);
  if (over > 0) P.push([x + r + w * over, y - 1.5]);
  return P;
}
// a flat colour laid down slightly off the line (the colour pass never quite registers with the ink)
function gfill(P, col, o = {}) {
  const { a = 1, off = [4, 3], key = 'gf', amp = 2 } = o;
  const Q = gwob(resample(P, false, 14), key, amp);
  ctx.save(); ctx.globalAlpha *= a; ctx.fillStyle = col; ctx.translate(off[0], off[1]); trace(Q, false); ctx.closePath(); ctx.fill(); ctx.restore();
}
function gclip(P) { trace(resample(P, false, 16), false); ctx.closePath(); ctx.clip(); }
// parallel hatching inside a clip that is already set; structure seeded by key, tremor on the boil
function ghatch(x0, y0, x1, y1, o = {}) {
  const { ang = -0.85, gap = 7, col = SK.graph, w = 2, a = 0.5, key = 'gh' } = o;
  const S = RNG('ghs', key), R = RNG('ghj', key, B);
  ctx.save(); ctx.strokeStyle = col; ctx.lineWidth = w; ctx.globalAlpha *= a; ctx.lineCap = 'round';
  const cx = (x0 + x1) / 2, cy = (y0 + y1) / 2, rad = Math.hypot(x1 - x0, y1 - y0) / 2 + 4, ca = Math.cos(ang), sa = Math.sin(ang);
  ctx.beginPath();
  for (let d = -rad; d <= rad; d += gap) {
    const j = R.n(1.1), len = rad * (0.8 + S.f() * 0.25), px = cx - sa * (d + j), py = cy + ca * (d + j);
    ctx.moveTo(px - ca * len, py - sa * len); ctx.lineTo(px + ca * len, py + sa * len);
  }
  ctx.stroke(); ctx.restore();
}
// shade a shape with hatching, leaving a lit circle top-left (the way the page's round things are shaded)
function litHatch(P, o = {}) {
  const bb = bbox(P), cx = (bb.x0 + bb.x1) / 2, cy = (bb.y0 + bb.y1) / 2, r = Math.max(bb.x1 - bb.x0, bb.y1 - bb.y0) / 2;
  ctx.save(); gclip(P);
  ctx.beginPath(); ctx.rect(bb.x0 - r, bb.y0 - r, 4 * r, 4 * r); ctx.arc(cx - r * (o.lx ?? 0.3), cy - r * (o.ly ?? 0.34), r * (o.lr ?? 1.02), 0, TAU); ctx.clip('evenodd');
  ghatch(bb.x0, bb.y0, bb.x1, bb.y1, o); ctx.restore();
}
// a back-and-forth scribble that shades a shape in one colour (clipped; write it on with part)
function scribbleFill(P, col, o = {}) {
  const { ang = -0.6, gap = 11, w = 3.2, a = 0.85, key = 'sf', part = 1, amp = 1.3, base = 0.3 } = o;
  const bb = bbox(P, 6), cx = (bb.x0 + bb.x1) / 2, cy = (bb.y0 + bb.y1) / 2, rad = Math.hypot(bb.x1 - bb.x0, bb.y1 - bb.y0) / 2;
  const ca = Math.cos(ang), sa = Math.sin(ang), S = RNG('sfs', key), Z = [];
  for (let d = -rad, i = 0; d <= rad; d += gap, i++) {
    const e = i % 2 ? 1 : -1, L = rad * (0.9 + S.f() * 0.15);
    Z.push([cx - sa * d + ca * L * e, cy + ca * d + sa * L * e]);
  }
  ctx.save(); gclip(P);
  if (base > 0) { ctx.globalAlpha = base * clamp(part * 3); ctx.fillStyle = col; ctx.fillRect(bb.x0, bb.y0, bb.x1 - bb.x0, bb.y1 - bb.y0); ctx.globalAlpha = 1; }
  gline(Z, { w, col, a, key: key + 'z', amp, part, step: 14, second: false });
  ctx.restore();
}
// a tangle of graphite: raw stuff, the mess (seeded shape, boiling tremor)
function graphiteScribble(cx, cy, w, h, key, o = {}) {
  const S = RNG('gsc', key), n = o.n ?? 34, P = [], a1 = 1.2 + S.f() * 1.6, a2 = 2.3 + S.f() * 1.9, ph = S.f() * TAU;
  for (let i = 0; i < n; i++) {
    const u = (i / n) * Math.PI * 4;
    P.push([cx + Math.sin(u * a1 * 0.5 + ph) * w / 2 * (0.55 + 0.45 * S.f()), cy + Math.cos(u * a2 * 0.5) * h / 2 * (0.55 + 0.45 * S.f())]);
  }
  return gpencil(P, { key: 'gsc' + key, amp: 1.4, w: o.w ?? 2.8, a: o.a ?? 0.85, step: 10, col: o.col ?? SK.graph, part: o.part ?? 1 });
}
// a soft graphite smudge (a thumb dragged through pencil): radial falloff, no hard edge
function smudgeOn(g, x, y, rx, ry, a = 0.12, rot = 0) {
  g.save(); g.translate(x, y); g.rotate(rot); g.scale(1, ry / rx);
  const gr = g.createRadialGradient(0, 0, 0, 0, 0, rx);
  gr.addColorStop(0, `rgba(80,76,70,${a})`); gr.addColorStop(0.55, `rgba(80,76,70,${a * 0.5})`); gr.addColorStop(1, 'rgba(80,76,70,0)');
  g.fillStyle = gr; g.beginPath(); g.arc(0, 0, rx, 0, TAU); g.fill(); g.restore();
}
const smudge = (x, y, rx, ry, a, rot) => smudgeOn(ctx, x, y, rx, ry, a, rot);

// ---------------------------------------------------------------------
//  THE HAND: lettering (local system fonts; per-glyph jitter on the boil; letters write on one by one)
// ---------------------------------------------------------------------
const SK_GLYPH = new Map();   // static measurements, keyed by font + string
const skFont = (size, face = 'hand', weight) => face === 'marker' ? `${weight ?? 700} ${size}px ${SK_MARKER}` : `${weight ?? 400} ${size}px ${SK_HAND}`;
function glyphX(str, font) {
  const k = font + '|' + str; let v = SK_GLYPH.get(k); if (v) return v;
  ctx.save(); ctx.font = font; v = []; for (let i = 0; i <= str.length; i++) v.push(ctx.measureText(str.slice(0, i)).width); ctx.restore();
  SK_GLYPH.set(k, v); return v;
}
const letterW = (str, size, face = 'hand', weight) => { const xs = glyphX(str, skFont(size, face, weight)); return xs[xs.length - 1]; };
// o: face ('hand' | 'marker'), weight, col, align ('center' | 'left' | 'right'), reveal 0..1, key, jit, a, rot
// returns [left, right] of the string so callers can underline or highlight it
function handLetter(str, x, y, size, o = {}) {
  const { face = 'hand', weight, col = SK.ink, align = 'center', reveal = 1, key = str, jit = 1, a = 1, rot = 0 } = o;
  const stroke = o.stroke ?? (face === 'hand' ? size * 0.024 : 0);   // thin system hand fonts get a pen-weight stroke
  const font = skFont(size, face, weight), xs = glyphX(str, font), wTot = xs[xs.length - 1];
  const x0 = align === 'center' ? x - wTot / 2 : align === 'right' ? x - wTot : x;
  const n = str.length, shown = clamp(reveal) * n;
  if (shown <= 0) return [x0, x0 + wTot];
  ctx.save(); ctx.font = font; ctx.fillStyle = col; ctx.strokeStyle = col; ctx.lineWidth = stroke; ctx.lineJoin = 'round'; ctx.textBaseline = 'alphabetic';
  ctx.translate(x, y); ctx.rotate(rot); ctx.translate(-x, -y);
  for (let i = 0; i < n && i < shown; i++) {
    if (str[i] === ' ') continue;
    const k = clamp(shown - i), R = RNG('hl', key, i, B);
    const jx = R.n(1.2) * jit, jy = R.n(1.4) * jit, jr = R.n(0.025) * jit, gx = x0 + xs[i], gw = xs[i + 1] - xs[i];
    ctx.save(); ctx.globalAlpha = a * (0.25 + 0.75 * k);
    ctx.translate(gx + gw / 2 + jx, y + jy + (1 - k) * size * 0.12); ctx.rotate(jr); ctx.scale(0.8 + 0.2 * k, 0.8 + 0.2 * k);
    ctx.fillText(str[i], -gw / 2, 0); if (stroke > 0) ctx.strokeText(str[i], -gw / 2, 0); ctx.restore();
  }
  ctx.restore();
  return [x0, x0 + wTot];
}
// a highlighter swipe behind a word: rough ends, multiplied so the lettering sits on top
function highlight(x0, x1, y, h, part, o = {}) {
  if (part <= 0) return;
  const xe = lerp(x0, x1, EZ.o3(part));
  ctx.save(); ctx.globalCompositeOperation = 'multiply'; ctx.globalAlpha = o.a ?? 0.8; ctx.strokeStyle = o.col ?? SK.hilite; ctx.lineCap = 'butt'; ctx.lineWidth = h;
  trace(gwob(resample([[x0 - 8, y + 3], [xe + 8, y - 3]], false, 18), 'hi' + (o.key ?? x0), 2.5), false); ctx.stroke(); ctx.restore();
}
// a quick underline (slightly bowed), written on
function underline(x0, x1, y, o = {}) {
  return gline([[x0 - 6, y], [lerp(x0, x1, 0.5), y + (o.bow ?? 6)], [x1 + 10, y - 5]], { w: o.w ?? 5, col: o.col ?? SK.ink, key: o.key ?? 'ul' + x0, part: o.part ?? 1, amp: 2.2, second: false });
}

// ---------------------------------------------------------------------
//  THE PAGE (built once per grid kind, seeded, cached: a static thing, so nothing carries between frames)
// ---------------------------------------------------------------------

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
