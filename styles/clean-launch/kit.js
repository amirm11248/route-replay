// Reusable Clean Launch drawing kit. All geometry can be interpolated per frame.
const CL = {
  ground: '#f9f9f7', ink: '#17191c', blue: '#243e58', cyan: '#657f8d',
  violet: '#665f76', border: '#dcdddc', muted: '#7a7d83',
  tokenTop: '#648091', tokenMid: '#385870', tokenBottom: '#1b3248',
  ring: '#a7b4be', ringFaint: '#cdd3d7',
  font: '"Helvetica Neue", Arial, sans-serif'
};

function clText(text, x, y, size, o = {}) {
  ctx.save();
  ctx.font = `${o.weight ?? 500} ${size}px ${CL.font}`;
  ctx.letterSpacing = `${o.tracking ?? -size * 0.035}px`;
  ctx.textAlign = o.align ?? 'left'; ctx.textBaseline = 'alphabetic'; ctx.fillStyle = o.color ?? CL.ink;
  ctx.fillText(text, x, y);
  const width = ctx.measureText(text).width;
  ctx.restore(); return width;
}

function clRun(parts, x, y, size, o = {}) {
  ctx.save(); ctx.font = `${o.weight ?? 600} ${size}px ${CL.font}`;
  ctx.letterSpacing = `${o.tracking ?? -size * 0.035}px`;
  const widths = parts.map(p => ctx.measureText(p.text).width), total = widths.reduce((a, b) => a + b, 0);
  let at = x - total / 2;
  parts.forEach((p, i) => { clText(p.text, at, y, size, { ...o, color: p.color ?? CL.ink }); at += widths[i]; });
  ctx.restore(); return total;
}

function clPanel(x, y, w, h, o = {}) {
  ctx.save();
  ctx.shadowColor = 'rgba(12, 22, 35, 0.07)'; ctx.shadowBlur = o.shadow ?? 38; ctx.shadowOffsetY = o.lift ?? 10;
  ctx.beginPath(); ctx.roundRect(x, y, w, h, o.r ?? 32); ctx.fillStyle = o.fill ?? CL.ground; ctx.fill();
  ctx.shadowColor = 'transparent'; ctx.lineWidth = o.stroke ?? 2; ctx.strokeStyle = o.border ?? CL.border; ctx.stroke();
  ctx.restore();
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
  const aperture = clamp(Number(o.aperture ?? 0));
  if (aperture > .001) {
    const aw = r * .36 * aperture, ah = r * 1.16 * aperture;
    ctx.beginPath(); ctx.roundRect(x - aw / 2, y - ah / 2, aw, ah, Math.min(aw / 2, r * .18));
    ctx.fillStyle = CL.ground; ctx.fill();
  }
  SPARK_AT = toScreen(x, y); ctx.restore();
}

function clCaption(text, o = {}) {
  const draw = () => clText(text, W / 2, H * .83, 58, { color: CL.ink, align: 'center', ...o });
  if (DEFER) DEFER.push(draw); else draw();
}

const STYLE = {
  name: 'clean-launch', paper: CL.ground, heroColor: CL.blue, ones: true,
  backdrop(c) { fillAll(c); },
  window(P, key, src) { ctx.save(); trace(P, true); ctx.clip(); ctx.drawImage(src, 0, 0); ctx.restore(); },
  blob(P, color) { ctx.save(); trace(P, true); ctx.fillStyle = color; ctx.fill(); ctx.restore(); },
  hero(x, y, r, o = {}) { clToken(x, y, r, o); },
  heroPts(x, y, r) { return ellipsePts(x, y, r, r, 0, 64); },
  post() {}
};
