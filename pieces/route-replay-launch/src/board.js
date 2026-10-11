// The storyboard uses the piece's real static scene functions and a cool surround.
function drawPanel(k) { renderFrame(TIMELINE.board[k].t, ctx.canvas); }
function renderBoard() {
  const cols = 5, pw = 480, ph = 270, gap = 28, note = 156, head = 132;
  const rows = Math.ceil(TIMELINE.board.length / cols);
  const c = document.createElement('canvas');
  c.width = gap + cols * (pw + gap); c.height = head + rows * (ph + note + gap);
  const g = c.getContext('2d'); g.fillStyle = '#202c3a'; g.fillRect(0, 0, c.width, c.height);
  const font = '"Helvetica Neue", Arial, sans-serif';
  g.font = `500 42px ${font}`; g.fillStyle = '#ffffff';
  g.fillText('Route Replay — launch storyboard', gap, 62);
  g.font = `400 24px ${font}`; g.fillStyle = '#b5c4d2';
  g.fillText('30s · 1920 × 1080 · 120 BPM · White, navy and slate · Three recording placeholders', gap, 103);
  const wrap = (s, x, y, max, lh) => {
    let line = '';
    for (const word of s.split(' ')) {
      const next = line ? line + ' ' + word : word;
      if (g.measureText(next).width > max && line) { g.fillText(line, x, y); y += lh; line = word; }
      else line = next;
    }
    if (line) g.fillText(line, x, y);
    return y + lh;
  };
  const pc = document.createElement('canvas'); pc.width = W; pc.height = H;
  TIMELINE.board.forEach((b, i) => {
    renderFrame(b.t, pc);
    const x = gap + i % cols * (pw + gap), y = head + Math.floor(i / cols) * (ph + note + gap);
    g.drawImage(pc, x, y, pw, ph);
    g.fillStyle = '#ffffff'; g.font = `500 24px ${font}`;
    g.fillText(`${i + 1}  ·  ${b.title}`, x, y + ph + 35);
    g.font = `400 21px ${font}`; g.fillStyle = '#b5c4d2';
    const yy = wrap(b.sound, x, y + ph + 68, pw, 26);
    g.fillStyle = '#8fa2b5'; wrap('→ ' + b.next, x, yy + 4, pw, 26);
  });
  return c;
}
window.renderBoard = renderBoard; window.drawPanel = drawPanel;
