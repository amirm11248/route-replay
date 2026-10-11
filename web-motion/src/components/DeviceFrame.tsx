import { useState } from 'react'
import { ScrollTrigger } from 'gsap/ScrollTrigger'
import { siteConfig } from '../site.config'

export default function DeviceFrame({ src, alt, className = '', eager = false }: { src: string; alt: string; className?: string; eager?: boolean }) {
  const [loaded, setLoaded] = useState(false)
  const [failed, setFailed] = useState(false)
  return <div className={`device-frame ${className} ${loaded ? 'is-loaded' : ''}`}><div className="device-screen">
    {!loaded && <div className="device-placeholder"><img src={siteConfig.assets.icon} alt="" /><span>{failed ? 'Preview unavailable' : 'Loading the app'}</span></div>}
    <img src={src} alt={alt} loading={eager ? 'eager' : 'lazy'} decoding="async" onLoad={() => { setLoaded(true); requestAnimationFrame(() => ScrollTrigger.refresh()) }} onError={() => setFailed(true)} />
  </div></div>
}
