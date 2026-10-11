'use client'
import { useEffect, useRef } from 'react'
import { ArrowUpRight, X } from 'lucide-react'
import ReplayPlayer from './ReplayPlayer'

export default function SiteModal({ kind, onClose }: { kind: 'video' | 'privacy'; onClose: () => void }) {
  const dialog = useRef<HTMLDialogElement>(null)
  useEffect(() => {
    const element = dialog.current
    const previous = document.documentElement.style.overflow
    element?.showModal()
    document.documentElement.style.overflow = 'hidden'
    window.dispatchEvent(new CustomEvent('route-replay-modal', { detail: true }))
    return () => { document.documentElement.style.overflow = previous; window.dispatchEvent(new CustomEvent('route-replay-modal', { detail: false })); element?.close() }
  }, [])
  return <dialog className={`site-dialog ${kind === 'privacy' ? 'privacy-dialog' : ''}`} ref={dialog} onCancel={onClose} onClick={(event) => { if (event.target === dialog.current) onClose() }} aria-labelledby="dialog-title">
    <div className="dialog-heading"><h2 id="dialog-title">{kind === 'video' ? 'A workout, replayed.' : 'Your data. Your choice.'}</h2><button className="icon-button" onClick={onClose} aria-label="Close dialog"><X size={22} /></button></div>
    {kind === 'video' ? <><ReplayPlayer inDialog /><p className="dialog-caption">Captured from the Route Replay iOS simulator using a local example workout.</p></> : <div className="privacy-content"><p>Route Replay requests read-only access to workout and route information in Apple Health. You choose which data to allow.</p><h3>Processed on your iPhone</h3><p>The app processes your workout information on the device. It has no app-owned server, account system, analytics or advertising SDK.</p><h3>Apple Maps</h3><p>Maps and satellite imagery are provided by Apple Maps. MapKit can connect to Apple to load map content under Apple’s applicable terms and privacy practices.</p><h3>You stay in control</h3><p>You can change Health access in iPhone settings. Route Replay does not write or delete workouts in Apple Health.</p><a href="https://www.apple.com/privacy/" target="_blank" rel="noopener noreferrer" className="text-link">Apple privacy information <ArrowUpRight size={15} /></a></div>}
  </dialog>
}
