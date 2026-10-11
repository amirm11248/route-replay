function rrOpeningLook() {
  rrPage();
  rrScaleAt(CX,325,lerp(.82,1,rrSpring(.15,1.0,145,17)),()=>
    clText('Your workout.', CX, 325, 145, { align: 'center', weight: 500, tracking: -4.2 }));
  rvLandscape({part:rrProgress(.30,1.65)});
}
function rrReplayedBoard() {
  rvDark();
  rrDrawPlay(CX, 390, 198+25*rrSpring(4.85,5.65,140,17), { color: RV.white });
  gpencil(loopPts(CX, 390, 225, 225, .015),
    { w: 2, col: RV.light, a: .4, amp: .75, key: 'rv-title-construction', closed: true });
  rrScaleAt(CX,818,lerp(.93,1,rrSpring(3.35,4.1,150,17)),()=>{
    clText('Replayed.', CX, 818, 179, { align: 'center', weight: 500, color: '#ffffff' });
    clText('Route Replay', CX, 941, 53, { align: 'center', weight: 400, color: '#b3c7d9' });
  });
}
function rrRecordingLook() {
  rrPage();
  rvWords(['Pick a', 'workout.'], 220, 407, 130, { weight: 500 });
  rrRoute([[233,755],[390,755],[451,669],[604,669],[708,740],[891,740]],
    { w: 7, key: 'rv-library-route',part:rrProgress(6.15,7.05) });
  rrRecordingPlaceholder('Workout library', '01', '2');
}
function rrEffortBoard() {
  rrPage();
  clText('See the effort.', CX, 240, 105, { align: 'center', weight: 500 });
  rrRoute([[243,630],[303,600],[285,454],[377,461],[414,379],[519,398]],
    { w: 9, key: 'rv-distance-glyph',part:rrProgress(8.1,8.65) });
  rvHeart(960,520,rrProgress(8.70,9.45)); rvMountain(1535,515,rrProgress(9.35,10.05));
  ['Distance', 'Heart rate', 'Elevation'].forEach((s, i) =>
    clText(s, [375,960,1535][i], 808, 60,
      { align: 'center', weight: 400, color: RV.slate, tracking: -1.4 }));
}
function rrDetailsBoard() {
  rrPage();
  ctx.fillStyle = RV.navy; ctx.fillRect(906, 0, W-906, H);
  ctx.fillStyle = '#d8e3ed';
  ctx.beginPath(); ctx.moveTo(853,0); ctx.lineTo(906,0); ctx.lineTo(906,H); ctx.lineTo(750,H); ctx.closePath(); ctx.fill();
  rvWords(['See', 'the details.'], 1050, 385, 119, { weight: 500, color: '#ffffff' });
  gline([[1060,746],[1180,746],[1220,682],[1264,800],[1310,653],[1378,746],[1670,746]],
    { w: 5, col: RV.light, amp: .5, a: .8, key: 'rv-details-pulse', second: false,part:rrProgress(11.15,12.10) });
  rrRecordingPlaceholder('Workout details', '02', '2');
}
function rrPlayBoard() {
  rrPage();
  clText('Then', 188, 348, 90, { weight: 500 });
  clText('press play.', 188, 488, 113, { weight: 500 });
  const x = 1515, y = 610, r = 690*lerp(.76,1,rrSpring(13,14.45,100,16));
  ctx.save();
  const ink = ctx.createLinearGradient(x-r,y-r,x+r,y+r);
  ink.addColorStop(0,'#385a75'); ink.addColorStop(1,'#102337');
  ctx.fillStyle = ink; ctx.beginPath(); ctx.arc(x,y,r,0,TAU); ctx.fill();
  ctx.fillStyle = '#ffffff'; ctx.strokeStyle = '#ffffff'; ctx.lineWidth = 24; ctx.lineJoin = 'round';
  const glyphScale=r/690;
  ctx.beginPath(); ctx.moveTo(x-136*glyphScale,y-222*glyphScale);ctx.lineTo(x+233*glyphScale,y);ctx.lineTo(x-136*glyphScale,y+222*glyphScale);
  ctx.closePath(); ctx.fill(); ctx.stroke(); ctx.restore();
  gpencil(arcPts(x,y,r+20,-3.05,-1.07,80),
    { w: 3, col: RV.slate, a: .45, amp: .7, key: 'rv-macro-outline' });
  SPARK_AT = [x,y];
}
function rrReplayBoard() {
  rvDark(RV.deep);
  rvNightContours(345,815,320,190,'rv-replay-left-contour-',rrProgress(17,18.4));
  rvNightContours(1590,258,280,138,'rv-replay-right-contour-',rrProgress(17.25,18.75));
  clText('3D.', 204, 575, 286, { weight: 500, color: '#ffffff', tracking: -7 });
  rvWords(['Replay', 'your route.'], 1305, 548, 86, { weight: 500, color: '#ffffff', tracking: -2 });
  rrRecordingPlaceholder('3D satellite replay', '03', '3');
}
function rrPerspectiveLook() {
  rrPage();
  clText('Same route.', 176, 168, 67, { weight: 400, color: RV.slate });
  rvTerrain({depth:clamp(rrSpring(20.10,21.05,145,18)),part:rrProgress(20.25,21.35)});
  clText('New perspective.', 176, 983, 108, { weight: 500, tracking: -3.2 });
}
function rrReliveBoard() {
  rvDark();
  clText('Relive your route.', CX, 355, 143, { align: 'center', weight: 500, color: '#ffffff' });
  rvNightContours(986, 784, 680, 139, 'rv-callback-contour-');
  rrRoute(RV_ROUTE.map(([x,y]) => [(x-960)*1.22+960, (y-700)*.88+770]),
    { w: 15, color: RV.light, startFill: RV.navy, key: 'rv-dark-callback-route',markerProgress:rrProgress(23.20,24.40) });
}
function rrGithubBoard() {
  rrPage();
  rrScaleAt(475,515,lerp(.75,1,rrSpring(26,27.65,90,16)),()=>
    drawAsset('app-icon.png',302,342,346,346,{fit:'contain',r:78}));
  rrScaleAt(800,512,lerp(.89,1,rrSpring(26,28.35,45,12)),()=>{
    clText('Route Replay.', 800, 512, 142, { weight: 500, tracking: -4.0 });
    clText('Explore on GitHub.', 809, 654, 63, { weight: 400, color: RV.slate, tracking: -1.5 });
  },62*(1-rrProgress(26,28.35)));
  rrRoute([[815,779],[954,779],[1010,732],[1093,732],[1162,779],[1290,779]],
    { w: 6, key: 'rv-app-close-route',part:rrProgress(27.2,28.6) });
}
