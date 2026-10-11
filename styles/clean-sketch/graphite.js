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
