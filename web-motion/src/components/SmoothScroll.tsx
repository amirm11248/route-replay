import { useEffect } from 'react'
import Lenis from 'lenis'
import { gsap } from 'gsap'
import { ScrollTrigger } from 'gsap/ScrollTrigger'
import 'lenis/dist/lenis.css'

gsap.registerPlugin(ScrollTrigger)

function SmoothScroll() {
  useEffect(() => {
    const lenis = new Lenis({
      autoRaf: false,
      anchors: true,
      respectReducedMotion: true,
    })

    lenis.on('scroll', (event) => {
      ScrollTrigger.update()
      document.documentElement.style.setProperty('--page-progress', `${event.progress * 100}%`)
    })

    const update = (time: number) => lenis.raf(time * 1000)
    gsap.ticker.add(update)
    gsap.ticker.lagSmoothing(0)

    return () => {
      gsap.ticker.remove(update)
      lenis.destroy()
      document.documentElement.style.setProperty('--page-progress', '0%')
    }
  }, [])

  return null
}

export default SmoothScroll
