function rrOpeningLook() {
  rrPage();
  rrScaleAt(238, 534, lerp(.72, 1, rrSpring(.18, 1.05, 135, 15)), rrOpeningWords);
  const cx = 1360, cy = 543;
  rrContour(cx, cy, 262, 190, .65, 'rr-open-contour');
  rrRoute(RR_ROUTE, { w: 10, key: 'rr-opening-route', part: rrProgress(.25, 1.40) });
  // Visible construction makes this a drawing about a route, never a fake map.
}

function rrRecordingLook() {
  rrPage();
  clText('Pick a workout.', CX, 172, 103,
    { align: 'center', weight: 500, tracking: -3.0 });
  rrRecordingPlaceholder('Workout library', '01', '2');
}

function rrPerspectiveLook() {
  rrPage();
  clHalo(CX, H / 2, 1488, 900, 1);
  ctx.save(); const s = lerp(.96, 1, rrSpring(20, 20.8, 155, 17));
  ctx.translate(CX, H / 2); ctx.scale(s, s); ctx.translate(-CX, -H / 2);
  rrCleanPanel(216, 90, 1488, 900);
  clText('Same route.', 327, 392, 102, { weight: 500 });
  clText('New', 327, 520, 102, { weight: 500 });
  clText('perspective.', 327, 650, 111,
    { weight: 500, color: CL.blue });
  rrTerrain({ depth: clamp(rrSpring(20.15, 21.05, 150, 18)), part: rrProgress(20.20, 21.25) });
  ctx.restore();
}

function rrReplayedBoard() {
  rrPage();
  rrScaleAt(245, 580, lerp(.95, 1, rrSpring(3.35, 3.95, 170, 18)), rrReplayedWords);
  const grow = rrSpring(4.85, 5.65, 170, 18);
  rrDrawPlay(1440, 536, 134 + 28 * grow);
  gpencil([[1250,720],[1345,739],[1410,708]],
    { w: 1.5, col: CL.muted, a: .40, key: 'rr-replayed-pencil', amp: .7 });
}

function rrEffortBoard() {
  rrPage();
  rrScaleAt(295, 287, lerp(.94, 1, rrSpring(8, 8.65, 190, 19)), () =>
    clText('See the effort.', 295, 287, 126, { weight: 500 }));
  gpencil([[310,629],[1600,629]],
    { w: 1.5, col: CL.muted, a: .30, key: 'rr-effort-pencil', amp: .7 });
  rrRoute([[332,620],[634,620],[756,574],[814,683],[886,428],
    [959,764],[1040,568],[1124,620],[1568,620]],
    { w: 10, key: 'rr-effort-route', part: rrProgress(8.20, 9.20) });
}

function rrDetailsBoard() {
  rrPage();
  clText('See the details.', CX, 172, 103,
    { align: 'center', weight: 500, tracking: -3 });
  rrRecordingPlaceholder('Workout details', '02', '2');
}

function rrPlayBoard() {
  rrPage();
  rrScaleAt(231, 520, lerp(.95, 1, rrSpring(13, 13.75, 155, 18)), () => {
    clText('Then', 231, 448, 126, { weight: 500 });
    clText('press play.', 231, 597, 126, { weight: 500 });
  });
  const x = 1370, y = 550;
  const r = 265 * lerp(.80, 1, rrSpring(13, 14.0, 140, 17)) + 28 * rrSpring(14.75, 15.70, 170, 18);
  ctx.save();
  const ink = ctx.createLinearGradient(x - r, y - r, x + r, y + r);
  ink.addColorStop(0, '#385870'); ink.addColorStop(1, '#1b3248');
  ctx.fillStyle = ink; ctx.beginPath(); ctx.arc(x, y, r, 0, TAU); ctx.fill();
  const P = [[x - 64, y - 113],[x + 128, y],[x - 64, y + 113]];
  ctx.fillStyle = '#ffffff'; ctx.strokeStyle = '#ffffff';
  ctx.lineWidth = 16; ctx.lineJoin = 'round';
  ctx.beginPath(); ctx.moveTo(...P[0]); ctx.lineTo(...P[1]); ctx.lineTo(...P[2]);
  ctx.closePath(); ctx.fill(); ctx.stroke(); ctx.restore();
  gpencil(loopPts(x, y, r + 19, r + 19, .015),
    { w: 2.4, col: CL.muted, a: .36, key: 'rr-macro-construction', amp: .8, closed: true });
  SPARK_AT = [x, y];
}

function rrReplayBoard() {
  rrPage();
  clText('Replay it in 3D.', CX, 172, 103,
    { align: 'center', weight: 500, tracking: -3 });
  rrRecordingPlaceholder('3D satellite replay', '03', '3');
}

function rrReliveBoard() {
  rrPage();
  clText('Relive', 238, 455, 126, { weight: 500 });
  clText('your route.', 234, 612, 128, { weight: 500, color: CL.blue });
  rrContour(1360, 543, 262, 190, .65, 'rr-open-contour');
  const route = [[1080,702],[1112,623],[1268,629],[1264,521],[1410,497],
    [1448,369],[1596,371],[1648,300]];
  rrRoute(route, { w: 10, key: 'rr-opening-route', markerProgress: rrProgress(23.20, 24.35) });
  gpencil(loopPts(1648, 300, 39, 39, .02),
    { w: 1.7, col: CL.muted, a: .40, key: 'rr-callback-ring', amp: .6, closed: true });
}

function rrGithubBoard() {
  rrPage();
  rrDrawPlay(CX, 284, 68);
  rrScaleAt(CX, 567, lerp(.82, 1, rrSpring(26, 28.45, 38, 11)), () => {
    clText('Route Replay.', CX, 567, 153, { align: 'center', weight: 500, tracking: -4.5 });
    clText('Explore on GitHub.', CX, 708, 60,
      { align: 'center', weight: 400, color: '#687b8e', tracking: -1.5 });
  }, 70 * (1 - rrProgress(26, 28.45)));
  rrRoute([[830,822],[908,822],[947,794],[1001,794],[1065,822]],
    { w: 6, key: 'rr-closing-route', part: rrProgress(27.2, 28.6) });
}
