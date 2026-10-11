'use client'
import { useRef, useState } from 'react'
import { Maximize2, Pause, Play } from 'lucide-react'
import { siteConfig } from '../site.config'

export default function ReplayPlayer({ onExpand, inDialog = false }: { onExpand?: () => void; inDialog?: boolean }) {
  const video = useRef<HTMLVideoElement>(null)
  const slider = useRef<HTMLInputElement>(null)
  const timeLabel = useRef<HTMLSpanElement>(null)
  const [playing, setPlaying] = useState(false)
  const [speed, setSpeed] = useState(1)
  const [failed, setFailed] = useState(false)
  const toggle = async () => {
    if (!video.current) return
    if (video.current.paused) { try { await video.current.play() } catch { setFailed(true) } }
    else video.current.pause()
  }
  return <div className={`replay-player ${inDialog ? 'in-dialog' : ''}`}>
    <div className="player-picture"><video ref={video} src={siteConfig.assets.video} poster={siteConfig.assets.replay} preload="metadata" playsInline muted onPlay={() => setPlaying(true)} onPause={() => setPlaying(false)} onEnded={() => setPlaying(false)} onError={() => setFailed(true)} onTimeUpdate={() => {
      const element = video.current
      if (!element) return
      if (slider.current && element.duration) slider.current.value = String(element.currentTime / element.duration * 100)
      if (timeLabel.current) timeLabel.current.textContent = `0:${String(Math.floor(element.currentTime)).padStart(2, '0')}`
    }} />
    {!playing && !failed && <button className="player-big-play" onClick={toggle} aria-label="Play the Route Replay demo"><Play size={25} fill="currentColor" strokeWidth={1.5} /></button>}
    {failed && <div className="player-error"><p>The replay couldn’t load.</p><button onClick={() => { setFailed(false); video.current?.load() }}>Try again</button></div>}</div>
    <div className="player-controls"><button onClick={toggle} aria-label={playing ? 'Pause replay' : 'Play replay'}>{playing ? <Pause size={17} fill="currentColor" /> : <Play size={17} fill="currentColor" />}</button><span className="player-time" ref={timeLabel}>0:00</span><input ref={slider} className="player-seek" type="range" min="0" max="100" defaultValue="0" aria-label="Replay progress" onChange={(event) => { if (video.current?.duration) video.current.currentTime = Number(event.target.value) / 100 * video.current.duration }} /><button className="player-speed" onClick={() => { const next = speed === 1 ? 2 : speed === 2 ? 4 : 1; setSpeed(next); if (video.current) video.current.playbackRate = next }} aria-label={`Playback speed ${speed} times. Click to change.`}>{speed}×</button>{onExpand && <button onClick={onExpand} aria-label="Expand replay"><Maximize2 size={16} /></button>}</div>
  </div>
}
