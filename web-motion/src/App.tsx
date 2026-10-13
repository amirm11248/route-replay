import { useState } from 'react'
import { ArrowDownRight, ArrowRight, ArrowUpRight, Github, HeartPulse, MapPin, Play, ShieldCheck } from 'lucide-react'
import ReplayPlayer from './components/ReplayPlayer'
import SiteModal from './components/SiteModal'
import SmoothScroll from './components/SmoothScroll'
import { siteConfig } from './site.config'
import './App.css'
import './site-extra.css'

type ModalKind = 'video' | 'privacy'

function Logo() {
  return <span className="brand-mark" aria-hidden="true"><svg viewBox="0 0 24 24" fill="none"><path d="M4 18c4-1 4-12 10-12 4 0 3 5 6 4"/><circle cx="4" cy="18" r="2"/></svg></span>
}

function RouteIllustration({ large = false }: { large?: boolean }) {
  return <svg className={large ? 'large-route' : 'hero-route'} viewBox="0 0 600 480" role="img" aria-label="Illustrated route, not an actual workout">
    <path className="route-underlay" d="M55 394C120 295 187 375 211 266S318 133 371 185 436 294 533 82" />
    <path className={large ? 'large-route-line' : 'hero-route-stroke'} d="M55 394C120 295 187 375 211 266S318 133 371 185 436 294 533 82" />
    <circle className="map-start" cx="55" cy="394" r="9"/>
    <circle className="hero-map-finish" cx="533" cy="82" r="12"/>
    <circle className="map-finish-core" cx="533" cy="82" r="5"/>
  </svg>
}

export default function App() {
  const [modal, setModal] = useState<ModalKind | null>(null)
  return <>
    <SmoothScroll />
    <div className="scroll-progress" aria-hidden="true" />
    <div className="site-shell" id="top">
      <header className="topbar">
        <a href="#top" className="brand" aria-label="Route Replay home"><Logo /> ROUTE REPLAY</a>
        <nav className="topnav" aria-label="Main navigation">
          <a href="#story">The idea</a><a href="#trailer">Watch the film</a><a href="#features">Features</a>
        </nav>
        <a className="topbar-link" href={siteConfig.githubUrl} target="_blank" rel="noopener noreferrer"><Github size={16}/> Source <ArrowUpRight size={14}/></a>
      </header>

      <main>
        <section className="hero" aria-labelledby="hero-title">
          <div className="hero-copy">
            <p className="eyebrow"><span className="eyebrow-dot"/> OPEN-SOURCE IPHONE APP</p>
            <h1 className="hero-title" id="hero-title">Your route.<br/>Replayed<span className="hero-period">.</span></h1>
            <p className="hero-description">You remember how the workout felt. Now see where it took you. Turn outdoor Apple Health workouts into interactive 3D route replays.</p>
            <div className="hero-actions">
              <button className="button button-lime" onClick={() => setModal('video')}>Watch the trailer <Play size={15} fill="currentColor"/></button>
              <a href="#story" className="text-link">Explore the story <ArrowDownRight size={16}/></a>
            </div>
            <div className="hero-footnote"><span>SWIFTUI × HEALTHKIT × MAPKIT</span><span>IOS 17+</span></div>
          </div>
          <div className="hero-visual">
            <div className="map-grid"/><div className="map-ring map-ring-one"/><div className="map-ring map-ring-two"/>
            <div className="map-topline"><span>ROUTE CONCEPT / NOT LIVE DATA</span><span>3D VIEW</span></div>
            <RouteIllustration />
            <span className="map-label map-label-park">THE JOURNEY</span>
            <span className="map-label map-label-city">GO BACK.<br/><span>SEE IT DIFFERENTLY.</span></span>
            <span className="map-caption"><span className="live-dot"/> ILLUSTRATIVE MAP GRAPHIC</span>
          </div>
        </section>

        <section className="replay-section" id="story">
          <div className="section-heading">
            <p className="eyebrow eyebrow-dark">01 / THE IDEA</p>
            <h2>A new point<br/>of view.</h2>
            <p className="section-intro">Workouts usually end as numbers on a screen. Route Replay puts your recorded path back on the map, then moves a 3D camera along it.</p>
            <a className="dark-link" href="#trailer">See it in motion <ArrowUpRight size={16}/></a>
          </div>
          <div className="run-card">
            <div className="run-card-head">
              <div><p className="card-kicker">INCLUDED EXAMPLE WORKOUT</p><h3>New York Run</h3></div>
              <span className="activity-tag"><span/> Demo data</span>
            </div>
            <div className="run-stats">
              <div className="run-stat"><strong>2.54<small>km</small></strong><span>ROUTE DISTANCE</span></div>
              <div className="run-stat"><strong>16:00</strong><span>SIMULATED TIME</span></div>
              <div className="run-stat"><strong>3D</strong><span>MAP REPLAY</span></div>
            </div>
            <div className="run-card-bottom"><span>CENTRAL PARK / EXAMPLE MODE</span><a href={siteConfig.githubUrl}>Source <ArrowUpRight size={14}/></a></div>
            <p className="demo-note">Illustrative example metrics, not a real person's workout.</p>
          </div>
        </section>

        <section className="route-section">
          <div className="route-copy">
            <p className="eyebrow eyebrow-dark">02 / THE EXPERIENCE</p>
            <h2>More than<br/>a line on<br/>a map.</h2>
            <p>Move through your GPS route with the MapKit 3D camera. Pause, adjust replay speed, zoom and explore the route from a different angle.</p>
            <a className="dark-link" href={siteConfig.githubUrl} target="_blank" rel="noopener noreferrer">Explore the code <ArrowUpRight size={16}/></a>
          </div>
          <div className="route-visual">
            <div className="route-map-grid"/>
            <div className="route-coordinate coordinate-top">GPS ROUTE<br/>CAMERA INTERPOLATION</div>
            <RouteIllustration large />
            <span className="route-place place-one">SOURCE / GPS</span><span className="route-place place-two">PATH / CAMERA</span>
            <div className="route-coordinate coordinate-bottom">MAPKIT<br/><strong>3D FLYOVER</strong></div>
          </div>
        </section>

        <section className="film-section" id="trailer">
          <div className="film-intro">
            <div><p className="eyebrow">03 / THE LAUNCH FILM</p><h2>See it<br/><em>in motion.</em></h2></div>
            <p>Watch the Route Replay project trailer. The video showcases the project; the app does not currently export replay videos.</p>
          </div>
          <ReplayPlayer onExpand={() => setModal('video')} />
          <div className="film-footer"><span>ROUTE REPLAY / PROJECT SHOWCASE</span><a href={siteConfig.trailerUrl} target="_blank" rel="noopener noreferrer">Open original video <ArrowUpRight size={14}/></a></div>
        </section>

        <section className="features-section" id="features">
          <p className="eyebrow eyebrow-dark">04 / BUILT WITH INTENTION</p>
          <h2>Your workouts.<br/>Your perspective.</h2>
          <div className="feature-list">
            <article className="feature-row"><span>01</span><MapPin size={25}/><div><h3>See your routes</h3><p>Browse outdoor workouts and their GPS paths with a month-grouped library and search.</p></div><ArrowRight size={19}/></article>
            <article className="feature-row"><span>02</span><HeartPulse size={25}/><div><h3>Follow the details</h3><p>Review available pace, distance, elevation, heart rate and workout metadata.</p></div><ArrowRight size={19}/></article>
            <article className="feature-row"><span>03</span><ShieldCheck size={25}/><div><h3>Keep your data yours</h3><p>Read-only HealthKit access, local processing and no app-owned account or backend.</p></div><ArrowRight size={19}/></article>
          </div>
        </section>

        <section className="source-cta">
          <div><p className="eyebrow">BUILT IN THE OPEN</p><h2>Explore what makes<br/>it move.</h2><p>Native SwiftUI. HealthKit. MapKit. All source available on GitHub. No App Store download or installable binary yet.</p></div>
          <a className="button button-lime" href={siteConfig.githubUrl} target="_blank" rel="noopener noreferrer"><Github size={17}/> View on GitHub <ArrowUpRight size={17}/></a>
        </section>
      </main>
      <footer className="footer">
        <a className="brand brand-footer" href="#top"><Logo/> ROUTE REPLAY</a>
        <span>PERSONAL OPEN-SOURCE PROJECT · 2026</span>
        <div className="footer-nav"><button onClick={() => setModal('privacy')}>Privacy</button><a href={siteConfig.githubUrl + '/blob/main/LICENSE'}>License</a><a className="back-top" href="#top">Back to top ↑</a></div>
      </footer>
    </div>
    {modal && <SiteModal kind={modal} onClose={() => setModal(null)} />}
  </>
}
