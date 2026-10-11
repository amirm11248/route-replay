// Seek-safe animation; portrait footage slots remain stationary during their windows.
function shotAtFrame(fr) {
  return TIMELINE.shots.find(s => fr >= Math.round(s.t0*FPS) && fr < Math.round(s.t1*FPS)) ?? TIMELINE.shots.at(-1);
}
function renderFrame(t, canvas, sub=false) {
  const cv = canvas ?? document.getElementById('c'); ctx = cv.getContext('2d');
  F = Math.min(NFRAMES-1, Math.max(0, Math.floor(t*FPS + .000001)));
  TT = sub?clamp(t,0,DURATION-.000001):F/FPS;
  B = TT>=16&&TT<17?240:Math.floor(F/2);
  const shot = shotAtFrame(F); E0 = shot.t0; DEFER = null; SPARK_AT = null;
  ctx.save(); ctx.setTransform(1,0,0,1,0,0); ctx.globalAlpha = 1;
  ctx.globalCompositeOperation = 'source-over'; ctx.filter = 'none'; ctx.setLineDash([]);
  if(TT>=2.65&&TT<3.35) rvIntroBridge();
  else [rrOpeningLook, rrReplayedBoard, rrRecordingLook, rrEffortBoard, rrDetailsBoard,
    rrPlayBoard, rrReplayBoard, rrPerspectiveLook, rrReliveBoard, rrGithubBoard][shot.id-1]();
  ctx.restore(); return shot.id;
}
window.renderFrame = renderFrame;
window.anchorAt = () => SPARK_AT ? { x: SPARK_AT[0], y: SPARK_AT[1] } : null;
