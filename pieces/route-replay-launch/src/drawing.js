// Static, reusable drawing vocabulary. Motion is added after board approval.
function rrPage() {
  fillAll('#ffffff');
  ctx.save(); ctx.globalAlpha = .18;
  ctx.drawImage(clPaperTexture(), 0, 0); ctx.restore();
}

function rrCleanPanel(x, y, w, h, r = 28) {
  ctx.save(); ctx.shadowColor = 'rgba(15,30,45,.07)';
  ctx.shadowBlur = 36; ctx.shadowOffsetY = 10;
  ctx.beginPath(); ctx.roundRect(x, y, w, h, r);
  ctx.fillStyle = '#ffffff'; ctx.fill();
  ctx.shadowColor = 'transparent'; ctx.strokeStyle = '#dce3ea';
  ctx.lineWidth = 2; ctx.stroke(); ctx.restore();
}

function rrRoute(P, o = {}) {
  const key = o.key ?? 'rr-route';
  const part = clamp(o.part ?? 1);
  gpencil(P.map(([x, y]) => [x - 5, y + 6]),
    { col: CL.muted, w: 2.2, a: .36, amp: 1.8, key: key + '-construction' });
  if (part > .001) gline(P, { col: CL.blue, w: o.w ?? 9, a: 1, amp: .9,
    key, second: false, part });
  const start = P[0], end = writeEnd(P, clamp(o.markerProgress ?? part));
  ctx.save(); ctx.fillStyle = '#ffffff'; ctx.strokeStyle = CL.blue;
  ctx.lineWidth = 3.5; ctx.beginPath(); ctx.arc(...start, 11, 0, TAU); ctx.fill(); ctx.stroke();
  if (!o.hideEnd) {
    ctx.fillStyle = CL.blue; ctx.beginPath(); ctx.arc(...end, 16, 0, TAU); ctx.fill();
  }
  SPARK_AT = toScreen(...end); ctx.restore();
}

function rrContour(cx, cy, rx, ry, phase, key) {
  const P = Array.from({ length: 91 }, (_, i) => {
    const a = i / 90 * TAU;
    const mod = 1 + .075 * Math.sin(a * 3 + phase) + .06 * Math.sin(a * 5 - phase);
    return [cx + Math.cos(a) * rx * mod, cy + Math.sin(a) * ry * mod];
  });
  gpencil(P, { w: 1.8, col: CL.muted, a: .28, key, amp: .8, closed: true });
}

function rrUnderline(x, y, width, key) {
  gline([[x, y], [x + width * .52, y + 3], [x + width, y - 4]],
    { w: 3.8, col: CL.blue, a: .80, key, amp: .8, second: false });
}

function rrDrawPlay(x, y, r, o = {}) {
  const P = [[x - r * .27, y - r * .45], [x + r * .46, y], [x - r * .27, y + r * .45]];
  if (o.circle !== false) {
    gline(loopPts(x, y, r, r, .014), { w: 3.5, col: CL.blue,
      a: .72, key: 'rr-play-circle', amp: .9, closed: true });
  }
  gfill(P, CL.blue, { off: [0, 0], key: 'rr-play-fill' });
  gline(P, { w: 2.8, col: CL.blue, key: 'rr-play-ink', amp: .6, closed: true });
}

function rrRecordingPlaceholder(label, number, seconds) {
  const { x, y, w, h, r } = RR_INSERT;
  ctx.save(); rrCleanPanel(x - 12, y - 12, w + 24, h + 24, r + 10);
  // Everything within the exact insert rectangle is replaced by later footage.
  ctx.beginPath(); ctx.roundRect(x, y, w, h, r); ctx.fillStyle = '#f3f6fa'; ctx.fill();
  rrDrawPlay(CX, y + h * .30, 48);
  clText('Your screen recording', CX, y + h * .48, 62,
    { align: 'center', weight: 500, color: CL.ink, tracking: -1.5 });
  clText('goes here.', CX, y + h * .58, 62,
    { align: 'center', weight: 400, color: CL.blue, tracking: -1.5 });
  clText(`${number}  /  ${label}  /  ${seconds}s`, CX, y + h * .82, 42,
    { align: 'center', weight: 400, color: '#626c72', tracking: -.6 });
  ctx.restore();
}

function rrTerrain(o = {}) {
  const depthAmount = o.depth ?? 1;
  const proj = (u, v, z = 0) => [1260 + u * 430 - v * 220, 360 + u * 170 + v * 275 - z * 150];
  const corners = [[0, 0], [1, 0], [1, 1], [0, 1]].map(([u, v]) => proj(u, v));
  // An illustrated paper landform, with no labels, map imagery, or product UI.
  const depth = 30;
  const skirt = [corners[3], corners[2], corners[1],
    [corners[1][0], corners[1][1] + depth], [corners[2][0], corners[2][1] + depth],
    [corners[3][0], corners[3][1] + depth]];
  gfill(skirt, '#d4dfe9', { key: 'rr-terrain-skirt', off: [0, 0] });
  gfill(corners, '#f8fafc', { key: 'rr-terrain-paper', off: [0, 0] });
  for (let i = 0; i <= 9; i++) {
    const v = i / 9;
    const row = Array.from({ length: 33 }, (_, j) => {
      const u = j / 32;
      const z = depthAmount * .65 * Math.sin(Math.PI * u) * Math.sin(Math.PI * v) ** 2;
      return proj(u, v, z);
    });
    gpencil(row, { w: 1.7, col: CL.muted, a: .47, amp: .55, key: 'rr-terrain-row-' + i });
  }
  for (let i = 0; i <= 9; i++) {
    const u = i / 9;
    const row = Array.from({ length: 33 }, (_, j) => {
      const v = j / 32;
      const z = depthAmount * .65 * Math.sin(Math.PI * u) * Math.sin(Math.PI * v) ** 2;
      return proj(u, v, z);
    });
    gpencil(row, { w: 1.5, col: CL.muted, a: .32, amp: .55, key: 'rr-terrain-column-' + i });
  }
  gline(corners, { w: 2.8, col: CL.ink, a: .48, amp: .8, closed: true, key: 'rr-terrain-edge' });
  const uv = [[.10,.77],[.23,.73],[.29,.52],[.47,.53],[.58,.36],[.80,.30],[.87,.13]];
  const route = uv.map(([u, v]) => proj(u, v, depthAmount * .65 * Math.sin(Math.PI * u) * Math.sin(Math.PI * v) ** 2));
  rrRoute(route, { w: 9, key: 'rr-dimensional-route', part: o.part ?? 1 });
  const end = route.at(-1);
  gpencil(loopPts(end[0], end[1], 40, 22, .02),
    { w: 1.7, col: CL.muted, a: .52, amp: .7, key: 'rr-terrain-focus', closed: true });
}
