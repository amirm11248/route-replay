// Closed-form motion. Every visual frame is independently seekable.
const rrProgress = (a,b) => EZ.io(seg(TT,a,b));
function rrSpringAt(t,a,b,k=170,damping=18) {
  if(t<=a) return 0; if(t>=b) return 1;
  const d=b-a, u=seg(t,a,b);
  return springEase(t-a,k,damping)+(1-springEase(d,k,damping))*EZ.io(u);
}
const rrSpring = (a,b,k,d) => rrSpringAt(TT,a,b,k,d);
function rrAlpha(a,draw) {
  if(a<=.001) return; ctx.save(); ctx.globalAlpha*=clamp(a); draw(); ctx.restore();
}
function rrScaleAt(x,y,s,draw,dy=0) {
  ctx.save();ctx.translate(x,y+dy);ctx.scale(s,s);ctx.translate(-x,-y);draw();ctx.restore();
}
function rvIntroBridge() {
  rrPage();
  rrAlpha(1-rrProgress(2.65,2.97),()=>{
    ctx.translate(0,-68*rrProgress(2.65,2.97));
    clText('Your workout.',CX,325,145,{align:'center',weight:500,tracking:-4.2});
  });
  rvLandscape({hideEnd:true});
  const travel=clamp(rrSpring(2.65,3.35,150,18));
  const x=lerp(1730,CX,travel), y=lerp(728,390,travel);
  const radius=lerp(16,2200,EZ.o3(seg(TT,2.65,3.15)));
  ctx.fillStyle=RV.navy;ctx.beginPath();ctx.arc(x,y,radius,0,TAU);ctx.fill();
  const reveal=rrProgress(2.66,2.88), r=lerp(16,198,travel);
  rrAlpha(reveal,()=>rrDrawPlay(x,y,r,{color:RV.white}));
  rrAlpha(rrProgress(3.09,3.35),()=>{
    clText('Replayed.',CX,818,179,{align:'center',weight:500,color:'#ffffff'});
    clText('Route Replay',CX,941,53,{align:'center',weight:400,color:'#b3c7d9'});
  });
  SPARK_AT=[x,y];
}
