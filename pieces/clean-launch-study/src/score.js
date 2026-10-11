  // Original dry, warm electronic motif. Deliberate silence precedes the reveal.
  function clTone(t, note, vel, decay = .4, pan = 0) {
    const g = ac.createGain(); env(g, t, .012, vel, decay);
    osc('sine', nz(note), t, t + decay + .03).connect(g); out(g, pan, 0);
  }
  to = 'm';
  drone(.02, 1.25, nz('D3'), .033, { att: .1, rel: .3 });
  pluck(.0, nz('D4'), .065, -.15, .32, 1500, 0);
  pluck(.25, nz('E4'), .048, -.08, .23, 1900, 0);
  pluck(.5, nz('A4'), .045, .15, .35, 1300, 0);
  pluck(.75, nz('Fs4'), .045, .06, .25, 1800, 0);
  pluck(1.0, nz('A4'), .050, .12, .25, 1700, 0);
  clTone(1.5, 'D3', .070, .45, -.1);
  clTone(2.0, 'E4', .055, .4, .10);
  clTone(2.5, 'A3', .065, .5, -.1);
  // Everything above resolves before 3.35 s: 650 ms of quiet anticipation.
  ['D3', 'A3', 'D4', 'Fs4'].forEach((n, i) => clTone(4.0, n, .26 / (1 + i * .2), .65, (i - 1.5) * .15));
  pad(4.15, 5.45, ['D3', 'A3', 'Fs4'], .014, { type: 'triangle', att: .12, rel: .45, cut: 780, send: 0 });
  clTone(4.5, 'D5', .055, .45, .12);
  clTone(5.0, 'A4', .050, .42, -.12);
  clTone(6.0, 'D4', .065, .52, -.10);
  clTone(6.25, 'A4', .060, .65, .10);
  drone(6.5, 7.6, nz('D3'), .025, { att: .2, rel: .55 });
  to = 's';
  noiseHit(.0, .032, 'bandpass', 900, 1, .045, 0, 0);
  noiseHit(1.5, .22, 'lowpass', 750, .6, .060, -.15, 0, 340);
  noiseHit(2.0, .034, 'bandpass', 1150, 1, .048, .12, 0);
  noiseHit(3.05, .23, 'bandpass', 600, .6, .070, -.12, 0, 1350);
  sub(4.0, .32);
  noiseHit(5.75, .18, 'lowpass', 650, .7, .055, .1, 0, 320);
