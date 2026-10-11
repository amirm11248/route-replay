# Route Replay web motion starter

This is a separate React + Vite playground for web prototypes. It keeps browser-only motion dependencies out of the SwiftUI app.

Original project code uses the root [MIT License](../LICENSE). The copied
React Bits component and installed dependencies retain their own licenses;
see [third-party notices](../THIRD_PARTY_NOTICES.md). The maintainer's current
purpose is personal and noncommercial; see [project status](../PROJECT_STATUS.md).

## Start it

```sh
npm install
npm run dev
```

The sample page uses all three tools:

- **GSAP** sequences the entry reveals and the route line's scroll animation.
- **Lenis** smooths scrolling and feeds the same animation frame to GSAP ScrollTrigger.
- **React Bits** supplies the installed `SplitText` example in `src/components/SplitText.tsx`.

The integration lives in `src/components/SmoothScroll.tsx`; page animations are in `src/App.tsx`. The page honours the system reduced-motion setting.

## Add a React Bits component

From this directory, choose a component on [React Bits](https://reactbits.dev/components) and run its displayed command. For example:

```sh
npx shadcn@latest add @react-bits/BlurText-TS-TW
```

React Bits installs source files into this project, so each component can be edited directly. The suffix selects JavaScript or TypeScript and CSS or Tailwind. `components.json` and the Vite `@/` alias are configured for the CLI.

## Useful commands

```sh
npm run dev       # start the local playground
npm run build     # type-check and build for production
npm run preview   # serve the production build locally
```

Library references: [GSAP](https://github.com/greensock/GSAP), [Lenis](https://github.com/darkroomengineering/lenis), and [React Bits](https://github.com/DavidHDev/react-bits). See the repository's [third-party notices](../THIRD_PARTY_NOTICES.md) for license links.
