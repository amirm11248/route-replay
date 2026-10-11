function clSceneOpen() {
  fillAll(CL.ground);
  clRun([{ text: 'Start with an ' }, { text: 'idea.', color: CL.blue }], W / 2, H / 2 + 38, 122, { weight: 600 });
  SPARK_AT = toScreen(W * .735, H * .52);
}

function clSceneFocus() {
  fillAll(CL.ground);
  clPanel(98, 226, 1724, 628, { r: 58, shadow: 22, lift: 5 });
  clText('What if?', 228, 530, 172, { weight: 400, tracking: -6 });
  clText('A little possibility.', 236, 655, 64, { weight: 400, color: CL.muted, tracking: -1.8 });
  clToken(1450, 540, 178);
}

function clSceneReveal() {
  fillAll(CL.ground);
  clHalo(W / 2, H / 2, 1488, 900, 1);
  clPanel(216, 90, 1488, 900, { r: 24, shadow: 52, lift: 16 });
  // An original typographic artboard, rather than a representation of a product screen.
  ctx.save();
  ctx.beginPath(); ctx.roundRect(234, 108, 1452, 864, 18); ctx.clip();
  ctx.fillStyle = CL.ground; ctx.fillRect(234, 108, 1452, 864);
  clText('Make it', 368, 482, 142, { weight: 500 });
  clText('tangible.', 368, 637, 142, { weight: 500, color: CL.blue });
  clToken(1306, 540, 206, { square: true, aperture: true });
  ctx.beginPath(); ctx.arc(1332, 552, 276, -1.20, 2.08); ctx.lineWidth = 2; ctx.strokeStyle = CL.ring; ctx.stroke();
  ctx.beginPath(); ctx.arc(1332, 552, 310, -1.32, 1.75); ctx.lineWidth = 2; ctx.strokeStyle = CL.ringFaint; ctx.stroke();
  ctx.restore();
}

function clSceneEnd() {
  fillAll(CL.ground);
  clToken(W / 2, 338, 55, { square: true, aperture: true });
  clRun([{ text: 'An idea. Made ' }, { text: 'real.', color: CL.blue }], W / 2, 607, 122, { weight: 600 });
}
