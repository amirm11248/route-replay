# Route Replay website

This optional React / Vite workspace presents the Route Replay open-source
iPhone project and its [launch trailer](../pieces/route-replay-launch-v6/renders/final.mp4).

The iOS application itself is in [RouteReplay/](../RouteReplay/).

## Develop locally

~~~sh
cd web-motion
npm ci
npm run dev
~~~

To check the production build:

~~~sh
npm run build
npm run preview
~~~

The site uses GSAP, Lenis and React; it respects reduced-motion preferences.
It links to the real repository rather than the GitHub profile. The trailer
player streams the MP4 from the public GitHub repository; the local fallback
is the GitHub-hosted trailer page. Network access is required to load the video.

**Deployment:** updating this folder does not automatically update a separately
hosted website. Build and deploy the current commit in your hosting environment.

The site has no sign-in or account creation. The native app is not an App Store
download. Refer to [PRIVACY.md](../PRIVACY.md) for the iOS app's technical
privacy notice, and review German website operator-disclosure obligations
before publishing or changing the hosting arrangement.

Original site code follows the root [MIT License](../LICENSE). Third-party
libraries and assets follow their own terms described in
[THIRD_PARTY_NOTICES.md](../THIRD_PARTY_NOTICES.md).
