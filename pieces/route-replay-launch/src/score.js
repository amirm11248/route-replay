  // Original dry electronic score. No imported music and no narration.
  function rrTone(t, note, vel, decay = .42, pan = 0) {
    const g = ac.createGain(); env(g, t, .012, vel, decay);
    osc('sine', nz(note), t, t + decay + .035).connect(g); out(g, pan, 0);
  }
  to = 'm';
  drone(.08, 2.55, nz('D3'), .018, { att: .25, rel: .40 });
  [[.5,'D4',.026],[.75,'E4',.032],[1,'A4',.040],[1.5,'Fs4',.041],
    [2,'A4',.043],[2.5,'D5',.040]].forEach(([t,n,v], i) =>
    pluck(t, nz(n), v, (i % 2 ? .12 : -.12), .34, 1500, 0));
  rrTone(3, 'D3', .075, .55, -.1);
  pad(3.15, 5.8, ['D3','A3'], .009, { type: 'triangle', att: .20, rel: .30, cut: 850, send: 0 });
  [[3.5,'D4'],[4,'E4'],[4.5,'Fs4'],[5,'A4'],[5.5,'D5']].forEach(([t,n], i) =>
    pluck(t, nz(n), .056, i % 2 ? .10 : -.10, .32, 1800, 0));

  // Even, light groove across the two short product clips and effort sketch.
  pad(6, 12.85, ['D3','A3','E4'], .008,
    { type: 'triangle', att: .18, rel: .30, cut: 820, send: 0 });
  const journey = ['D4','A4','E4','Fs4','D4','A4','Fs4','E4'];
  for (let i = 0; i < 14; i++) {
    const t = 6 + i * .5;
    pluck(t, nz(journey[i % journey.length]), .060,
      i % 2 ? .13 : -.13, .34, 1550, 0);
    if (i % 2 === 0) rrTone(t, 'D3', .030, .32);
  }

  // The macro play move builds energy, then everything finishes before 16s.
  drone(13, 15.75, nz('D3'), .023, { att: .12, rel: .30 });
  [[13,'A3'],[13.5,'D4'],[14,'E4'],[14.5,'Fs4'],[15,'A4'],[15.25,'D5']]
    .forEach(([t,n], i) => rrTone(t, n, .068, .34, i % 2 ? .12 : -.12));
  // 16–17s is digitally silent: no reverb send or lingering oscillator.

  // The single largest musical hit belongs to the replay reveal at 17s.
  ['D3','A3','D4','Fs4'].forEach((n,i) =>
    rrTone(17, n, .30 / (1 + i * .20), .68, (i - 1.5) * .14));
  pad(17.18, 19.80, ['D3','A3','Fs4'], .035,
    { type: 'triangle', att: .10, rel: .35, cut: 820, send: 0 });

  // Back to breathing room, a warmer perspective, and a quiet GitHub close.
  pad(20, 23.7, ['D3','A3','E4'], .008,
    { type: 'triangle', att: .35, rel: .6, cut: 780, send: 0 });
  rrTone(20, 'D4', .047, .65, -.08);
  rrTone(21, 'A4', .044, .55, .08);
  rrTone(23, 'D4', .070, .55, -.10);
  rrTone(23.5, 'A4', .053, .55, .10);
  rrTone(24, 'D5', .042, .60, .05);
  drone(24.5, 26, nz('D3'), .014, { att: .30, rel: .50 });
  rrTone(26, 'D4', .058, .65, -.10);
  rrTone(26.5, 'A4', .047, .65, .10);
  rrTone(27, 'D5', .038, .72, .05);
  drone(27.1, 29.25, nz('D3'), .012, { att: .40, rel: .80 });

  to = 's';
  noiseHit(.30, .09, 'bandpass', 1500, .8, .013, -.12, 0, 1800);
  noiseHit(.65, .10, 'bandpass', 1700, .8, .010, .10, 0, 1200);
  noiseHit(3, .15, 'lowpass', 700, .8, .040, 0, 0, 350);
  [6,8,11].forEach(t => noiseHit(t, .045, 'bandpass', 1100, 1, .043, 0, 0));
  noiseHit(8.25, .16, 'bandpass', 1450, .8, .012, -.08, 0, 1900);
  noiseHit(13, .12, 'lowpass', 650, .8, .045, .08, 0, 320);
  noiseHit(15.3, .22, 'bandpass', 700, .7, .020, 0, 0, 1300);
  sub(17, .46);
  noiseHit(20, .10, 'lowpass', 750, .8, .025, 0, 0, 420);
  noiseHit(27.3, .12, 'bandpass', 1500, .8, .008, 0, 0, 1000);
