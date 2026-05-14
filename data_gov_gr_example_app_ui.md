# Enhanced Stitch Prompt: Greek Open Data Command Center (Flutter SDK Showcase)

**Vibe:** Sophisticated, Professional, Focused. A "Command Center" aesthetic that blends high-tech monitoring with the official Greek "National Blue" accents. Clean dark mode by default with glassmorphism elements.

**Architecture & Layout:**
- **Navigation:** A sleek Bottom Navigation Bar with three distinct sections: "Monitor" (Real-time data), "Catalog" (Dataset Discovery), and "System" (Client Settings & Rate Limits).
- **Grid System:** A responsive 8-point grid layout. Use staggered animations for entry.
- **Components:**
    - **Header:** A dynamic "Command Header" showing the currently connected API provider and a "Pulse" indicator for the live/mock connection state.
    - **Data Cards:** High-contrast cards with subtle borders. Use a "Dashboard Tile" style for metrics (e.g., Average Fuel Price, Total Vaccinations).
    - **Interactive Filters:** A bottom-sheet-style filtering drawer with horizontal pill-selectors for Fuel Types and Prefectures.
    - **Discovery List:** A clean, searchable list of metadata cards. Each card should feel like a "Profile" for a dataset, showing modified dates and provider tags.

**Typography & Styling:**
- **Fonts:** Clean, geometric sans-serif (e.g., 'Inter' or 'Public Sans'). High contrast between headers (Semi-Bold) and data points (Mono-spaced for numbers).
- **Borders:** "Soft-Tech" rounded corners (16px). Subtle 1px borders using an opacity-reduced variant of the primary blue.
- **Imagery/Icons:** Use minimal, outline-style FontAwesome icons. Coordinate icon colors with the thematic module (e.g., Amber for Fuel, Cyan for Health).

**Interaction:**
- Implement "Micro-feedback" on all taps (subtle scale-down).
- Use skeleton loaders that mimic the "Command Center" pulse while fetching.
- A "Live Rate-Limit Meter" widget that glows red when approaching 429 errors.

**Target Logic:**
Focus implementation on the `MonitorScreen` first. This screen must show the "Fuel Prices" module as the hero component, using the `client.fuel.query()` DSL.
