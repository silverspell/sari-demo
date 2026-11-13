---
name: Sarı Urban Transit
colors:
  surface: '#f9f9f9'
  surface-dim: '#dadada'
  surface-bright: '#f9f9f9'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f3f3f3'
  surface-container: '#eeeeee'
  surface-container-high: '#e8e8e8'
  surface-container-highest: '#e2e2e2'
  on-surface: '#1a1c1c'
  on-surface-variant: '#4f4632'
  inverse-surface: '#2f3131'
  inverse-on-surface: '#f1f1f1'
  outline: '#81765f'
  outline-variant: '#d2c5ab'
  surface-tint: '#755b00'
  primary: '#755b00'
  on-primary: '#ffffff'
  primary-container: '#ffc800'
  on-primary-container: '#6e5500'
  inverse-primary: '#f4bf00'
  secondary: '#5f5e5e'
  on-secondary: '#ffffff'
  secondary-container: '#e5e2e1'
  on-secondary-container: '#656464'
  tertiary: '#006e2d'
  on-tertiary: '#ffffff'
  tertiary-container: '#5dea7e'
  on-tertiary-container: '#006729'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#ffdf92'
  primary-fixed-dim: '#f4bf00'
  on-primary-fixed: '#241a00'
  on-primary-fixed-variant: '#594400'
  secondary-fixed: '#e5e2e1'
  secondary-fixed-dim: '#c8c6c5'
  on-secondary-fixed: '#1c1b1b'
  on-secondary-fixed-variant: '#474646'
  tertiary-fixed: '#72fe8f'
  tertiary-fixed-dim: '#53e076'
  on-tertiary-fixed: '#002108'
  on-tertiary-fixed-variant: '#005320'
  background: '#f9f9f9'
  on-background: '#1a1c1c'
  surface-variant: '#e2e2e2'
typography:
  headline-xl:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 38px
    letterSpacing: -0.02em
  headline-xl-mobile:
    fontFamily: Inter
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 34px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 30px
    letterSpacing: -0.015em
  headline-md:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 26px
    letterSpacing: -0.01em
  headline-sm:
    fontFamily: Inter
    fontSize: 17px
    fontWeight: '600'
    lineHeight: 22px
    letterSpacing: -0.005em
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 22px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  body-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 16px
  label-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '600'
    lineHeight: 20px
  label-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 18px
  label-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
  label-mono:
    fontFamily: Inter
    fontSize: 13px
    fontWeight: '700'
    lineHeight: 16px
    letterSpacing: 0.04em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  gutter: 1rem
  margin: 1rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2rem
---

## Brand & Style

This design system drives a premium, fast, and pragmatic taxi-hailing experience optimized for city navigation under varying outdoor lighting conditions. It pairs modern functional minimalism with high-contrast, industrial clarity. The identity relies on rapid legibility, precise geometry, and zero visual clutter.

### Key Tenets
- **Instant Recognition:** Vibrant transportation yellow paired with dense ink-black creates an immediate visual anchor for calls to action, dispatch statuses, and vehicle markers.
- **Utilitarian Elegance:** Information is structured strictly through structured typographic hierarchy, subtle borders, and intentional spacing, eliminating decorative illustrations and stock photography.
- **Tactile Directness:** Buttons and bottom sheets feel solid, responsive, and immediate, engineered specifically for single-handed thumb-reach usage on iPhone devices.
- **Turkish Localization:** Form factors and vertical baselines natively accommodate Turkish diacritics (`ç, ğ, ı, İ, ö, ş, ü`) without awkward clipping or uneven bounding boxes.

## Colors

The palette is engineered for extreme clarity, day-lit street readability, and strict state communication.

### Palette Architecture
- **Primary Taxi Yellow (`#FFC800`):** Reserved for brand moments, active route paths, arrival states, and selected vehicle tiers.
- **Primary Ink / Accent Black (`#111111`):** Primary action buttons, primary typography, high-priority icons, and map pins.
- **Surface Canvas (`#FFFFFF`):** Base canvas for bottom sheets, navigation bars, and modals.
- **Secondary Surface (`#F2F2F2`):** Pill tags, non-selected vehicle cards, search input backgrounds, and fare breakdown segments.
- **Border Neutral (`#E5E5E5`):** 1px structural hairline borders separating list rows, sheet headers, and card containers.
- **Text Secondary (`#666666`):** Secondary meta-information such as distance, estimated times of arrival, license plate subtitles, and inactive tabs.
- **Success Green (`#1DB954`):** Strictly functional; indicates payment confirmation, driver arrival, trip completion, and applied discounts.
- **Critical Red (`#E53935`):** Driver cancellation, emergency alert triggers (SOS), network disconnection, or payment decline.

## Typography

Typography relies entirely on Inter to ensure uncompromised clarity and native OpenType rendering across all Turkish letterforms.

### Rules & Hierarchy
- **Turkish Diacritics (`İ, ı, ş, ğ, ç, ö, ü`):** Line heights are explicitly tuned to prevent ascender and descender clipping in upper-case display lines (e.g., `ŞİŞLİ`, `KADIKÖY`).
- **Data & Pricing:** Pricing figures use `headline-lg` with tabular figures enabled for seamless real-time recalculation without layout shifts.
- **License Plates:** License plates (e.g., `34 TKB 82`) utilize `label-mono` inside structured rectangular badges.

## Layout & Spacing

Designed specifically around the iPhone viewport baseline (390×844pt) with full adherence to iOS safe areas.

### Spatial Rhythm
- **Grid Structure:** Fluid 4-column layout on mobile with `16px` (`1rem`) outer margins and `16px` gutters.
- **Safe Area Insets:** Fixed 48px top padding for the Dynamic Island / status bar, and 34px bottom padding for the home indicator bar.
- **Zonal Distribution:**
  - **Upper Canvas (Top 55%):** Interactive map viewport, location pins, and live driver tracking.
  - **Lower Canvas (Bottom 45%):** Interactive sheet hosting ride configurations, address search entries, vehicle classes, and payment triggers.

## Elevation & Depth

This design system departs from heavy skeuomorphic shadows in favor of crisp borders, tonal separation, and subtle ambient ground-level diffusion.

### Elevation Levels
- **Level 0 (Base Map):** Canvas level holding the Vector Map layer.
- **Level 1 (Card & Sub-sheet):** `#FFFFFF` surfaces bounded by a 1px solid `#E5E5E5` border with zero drop shadow.
- **Level 2 (Interactive Floating Controls):** Map recentering button, SOS action, back navigation buttons. Styled with `#FFFFFF` fill, 1px `#E5E5E5` border, and an ultra-diffused shadow: `0px 4px 16px rgba(0, 0, 0, 0.08)`.
- **Level 3 (Modal Bottom Sheets):** Main interaction bottom sheets floating over the map with a top edge border (`1px solid #E5E5E5`) and an ambient shadow: `0px -8px 32px rgba(0, 0, 0, 0.06)`.

## Shapes

The geometry balances smooth handheld ergonomic curves with architectural precision.

### Radius System
- **16px (`rounded-2xl`):** Primary bottom sheets, bottom modal dialogue containers, and vehicle tier selection cards.
- **12px (`rounded-xl`):** Primary and secondary action buttons, input search fields, trip route summary badges, and floating action buttons.
- **8px (`rounded-md`):** Inline status badges, license plate containers, and payment chip selector indicators.
- **Full Pill (`9999px`):** Drag handles on sheets (`36x4px` centered pill) and floating status tags (e.g., `Taksi Yolda`).

## Components

Standard interface patterns and interactive elements designed with Turkish microcopy.

### 1. Primary & Secondary Buttons
- **Primary CTA:** Background `#111111`, text `#FFFFFF`, border-radius `12px`, height `56px`, font `label-lg`. Tap state shifts background to `#262626`.
- **Primary Accent CTA:** Background `#FFC800`, text `#111111`, border-radius `12px`, height `56px`, font `label-lg`. Used for definitive confirmation: `"Sarı Taksi Çağır"`.
- **Secondary Action:** Background `#F2F2F2`, text `#111111`, border-radius `12px`, height `48px`, font `label-md`.

### 2. Search & Text Input Fields
- **Container:** Height `52px`, fill `#F2F2F2`, border-radius `12px`, 1px border `#E5E5E5`.
- **Active State:** Fill `#FFFFFF`, 1.5px border `#111111`.
- **Placeholder:** Text `#666666` (e.g., `"Nereye gitmek istersiniz?"`).

### 3. Ride Selection Cards
- **Structure:** Surface `#FFFFFF`, border-radius `16px`, 1px border `#E5E5E5`, padding `16px`.
- **Selected State:** Border width switches to `2px` solid `#111111` or `#FFC800` with subtle background tint.
- **Content Row:** Vehicle class name (`"Sarı Taksi"`), estimated arrival (`"3 dk"`), dynamic fare (`"₺145,00"`), and capacity badge (`"4 kişilik"`).

### 4. Chips & Tags
- **Filter & Payment Chips:** Height `36px`, border-radius `8px`, border `1px solid #E5E5E5`, background `#FFFFFF`. Active state uses background `#111111` with text `#FFFFFF`.
- **Plate Badge:** Height `24px`, background `#F2F2F2`, border `1px solid #111111`, border-radius `4px`, padding `0 6px`, text formatted in `label-mono`.

### 5. Bottom Sheet Layout
- **Container:** Pure `#FFFFFF` background, top border-radius `16px`, top border `1px solid #E5E5E5`.
- **Handle:** Dimensions `36px × 4px`, background `#CCCCCC`, centered `8px` below the top rim.
- **Spacing:** `16px` padding around content, anchoring the primary CTA `16px` above the bottom home indicator safe zone.