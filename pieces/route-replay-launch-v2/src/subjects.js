// Static, original illustrations. These are not simulated app screens.
const RV = { navy: '#13273b', deep: '#0d1e30', light: '#94b4cc', slate: '#687f95', white: '#ffffff' };
const RV_ROUTE = [[180,752],[352,752],[454,612],[628,612],[754,810],
  [962,810],[1104,552],[1392,552],[1528,728],[1730,728]];

function rvDark(color = RV.navy) { fillAll(color); }
function rvWords(lines, x, y, size, options = {}) {
  lines.forEach((s, i) => clText(s, x, y + i * size * 1.16, size, options));
}
function rvTree(x, y, s = 1) {
  const p = [[x,y-50*s],[x-22*s,y-13*s],[x-11*s,y-13*s],
    [x-31*s,y+15*s],[x+31*s,y+15*s],[x+11*s,y-13*s],[x+22*s,y-13*s],[x,y-50*s]];
  gpencil(p, { w: 2.5, col: RV.slate, a: .55, amp: .5, key: 'rv-tree-' + x });
  gpencil([[x,y+15*s],[x,y+43*s]],
    { w: 2.5, col: RV.slate, a: .55, amp: .5, key: 'rv-tree-trunk-' + x });
}
function rvLandscape(o={}) {
  for (let i = 0; i < 3; i++) rrContour(970, 688, 535 + i * 115, 116 + i * 40, .8, 'rv-wide-contour-' + i);
  rvTree(318, 580, 1.1); rvTree(1350, 850, .9); rvTree(1580, 540, .85);
  rrRoute(RV_ROUTE, { w: 12, key: 'rv-landscape-route', part:o.part??1, hideEnd:o.hideEnd??false });
  gpencil([[1760,730],[1760,648],[1800,663],[1760,680]],
    { w: 2.6, col: RV.slate, a: .65, amp: .7, key: 'rv-finish-flag' });
}
function rvHeart(x, y, part=1) {
  const outline = Array.from({ length: 100 }, (_, i) => {
    const a = i / 99 * TAU;
    return [x + 16 * Math.sin(a) ** 3 * 8.2,
      y - (13 * Math.cos(a) - 5 * Math.cos(2*a) - 2 * Math.cos(3*a) - Math.cos(4*a)) * 8.2];
  });
  gpencil(outline, { w: 3.5, col: RV.slate, a: .7, amp: .7, key: 'rv-heart-outline', closed: true });
  gline([[x-123,y+15],[x-67,y+15],[x-39,y-26],[x-7,y+65],
    [x+27,y-64],[x+55,y+35],[x+80,y+15],[x+127,y+15]],
    { w: 8, col: CL.blue, amp: .65, key: 'rv-heart-pulse', second: false, part });
}
function rvMountain(x, y, part=1) {
  const mountain = [[x-154,y+119],[x-21,y-120],[x+136,y+119]];
  gfill(mountain, '#edf3f8', { key: 'rv-mountain-paper', off: [0,0] });
  gpencil([[x-180,y+119],[x-106,y-17],[x-75,y+34]],
    { w: 3, col: RV.slate, a: .65, amp: .6, key: 'rv-secondary-mountain' });
  gline(mountain, { w: 7, col: CL.blue, amp: .8, key: 'rv-mountain-edge', second: false, part });
  gpencil([[x-50,y-68],[x-18,y-46],[x+13,y-66],[x+40,y-21]],
    { w: 3, col: RV.slate, a: .55, amp: .7, key: 'rv-mountain-snow' });
}
function rvTerrain(o={}) {
  const project = (u, v, z = 0) => [1060 + u * 660 - v * 480, 200 + u * 240 + v * 440 - z * 200];
  const corners = [[0,0],[1,0],[1,1],[0,1]].map(([u,v]) => project(u,v));
  gfill([corners[3], corners[2], corners[1], [corners[1][0],corners[1][1]+34],
    [corners[2][0],corners[2][1]+34],[corners[3][0],corners[3][1]+34]],
    '#d4e0ea', { off: [0,0], key: 'rv-large-plane-side' });
  gfill(corners, '#f8fafc', { off: [0,0], key: 'rv-large-plane-paper' });
  const height = (u,v) => (o.depth??1) * .70 * Math.sin(Math.PI*u) * Math.sin(Math.PI*v) ** 2;
  for (let k = 0; k <= 12; k++) {
    const fixed = k / 12;
    const a = Array.from({ length: 45 }, (_, j) => {
      const u = j / 44; return project(u, fixed, height(u,fixed));
    });
    const b = Array.from({ length: 45 }, (_, j) => {
      const v = j / 44; return project(fixed, v, height(fixed,v));
    });
    gpencil(a, { w: 2.1, col: RV.slate, a: .48, amp: .7, key: 'rv-large-grid-a-' + k });
    gpencil(b, { w: 1.8, col: RV.slate, a: .32, amp: .7, key: 'rv-large-grid-b-' + k });
  }
  gline(corners, { w: 3.2, col: RV.slate, a: .7, amp: .8, key: 'rv-large-plane-border', closed: true });
  const uv = [[.12,.82],[.22,.64],[.40,.64],[.44,.45],[.67,.40],[.71,.21],[.87,.15]];
  rrRoute(uv.map(([u,v]) => project(u,v,height(u,v))), { w: 14, key: 'rv-large-plane-route', part:o.part??1 });
}
function rvNightContours(cx, cy, rx, ry, key, part=1) {
  for (let k = 0; k < 5; k++) {
    const P = Array.from({ length: 100 }, (_, i) => {
      const a = i / 99 * TAU, wob = 1 + .05 * Math.sin(a*4 + k*.2);
      return [cx + Math.cos(a)*(rx + k*44)*wob, cy + Math.sin(a)*(ry + k*30)*wob];
    });
    gpencil(P, { w: 2, col: '#8299ae', a: .25, amp: .8, closed: true, key: key + k, part });
  }
}
