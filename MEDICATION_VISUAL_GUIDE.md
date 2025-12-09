# 💊 Medication Module - Visual Design Reference

## 🎨 Screen Previews (Described)

### 1️⃣ Medication Home Screen

```
┌────────────────────────────────────────┐
│  Medication                    📅      │ ← Header (Light font)
│  2 of 4 medications taken today        │ ← Progress text
│                                        │
│  ┌──┬──┬──┬──┬──┬──┬──┐              │
│  │Su│Mo│Tu│We│Th│Fr│Sa│              │ ← Day selector
│  │9 │10│11│12│13│14│15│              │   (Horizontal scroll)
│  │○○│●●│○○│○●│●●●│●●│○○│              │   ● = Medication dots
│  └──┴──┴──┴──┴──┴──┴──┘              │
│                                        │
│  ☀️ Morning                            │ ← Category header
│  ┌────────────────────────────┐       │
│  │ 💊 Vitamin C      🕐 08:00 │       │ ← Medication card
│  │    2 caps                   │       │   (Pastel gradient bg)
│  └────────────────────────────┘       │
│  ┌────────────────────────────┐       │
│  │ 💊 Omega-3        🕐 09:00 │       │
│  │    1 pill                   │       │
│  └────────────────────────────┘       │
│                                        │
│  🌤️ Afternoon                         │
│  ┌────────────────────────────┐       │
│  │ 💊 Multivitamin   🕐 14:00 │       │
│  │    1 tablet   🍽️ After meal│       │
│  └────────────────────────────┘       │
│                                        │
│  🌙 Evening                            │
│  ┌────────────────────────────┐       │
│  │ 💊 Magnesium      🕐 20:00 │       │
│  │    1 cap                    │       │
│  └────────────────────────────┘       │
│                                        │
│                                   ➕   │ ← FAB (Add button)
└────────────────────────────────────────┘
```

**Design Features:**
- Pastel gradient cards with soft shadows
- Color-coded by medication type
- Time displayed in rounded badge
- Meal timing icons when applicable
- Category icons (sun, moon, etc.)
- Empty state with gentle illustration

---

### 2️⃣ Medication Detail Screen

```
┌────────────────────────────────────────┐
│  ← Medication Details                  │ ← Header with back
│                                        │
│              ┌─────────┐              │
│              │         │              │
│              │   💊   │              │ ← Large icon
│              │         │              │   (Gradient circle)
│              └─────────┘              │
│                                        │
│            Vitamin C                   │ ← Name (Bold)
│              2 caps                    │ ← Dosage (Light)
│                                        │
│  ┌──────────────────────────────┐     │
│  │  🕐  Time                     │     │ ← Time selector
│  │     08:00                     │     │   (Pastel gradient)
│  └──────────────────────────────┘     │
│                                        │
│  ┌──────────────────────────────┐     │
│  │  🍽️  Take after meals         │     │ ← Meal indicator
│  └──────────────────────────────┘     │
│                                        │
│  ┌──────────────────────────────┐     │
│  │  ✓  Take                     │     │ ← Take button
│  └──────────────────────────────┘     │   (Green gradient)
│  ┌───────────┐ ┌──────────────┐      │
│  │  ✗ Skip   │ │ ⏱️ Postpone  │      │ ← Skip/Postpone
│  └───────────┘ └──────────────┘      │   (Red & Purple)
│                                        │
│  ┌──────────────────────────────┐     │
│  │  📦 You have 28 pills left    │     │ ← Pills left
│  └──────────────────────────────┘     │   (Green/Red alert)
│                                        │
└────────────────────────────────────────┘
```

**Design Features:**
- Large centered icon with glow effect
- Gradient time selector card
- Prominent action buttons with icons
- Color-coded inventory warning
- Smooth button press animations
- Success/error feedback snackbars

---

### 3️⃣ Add Medication Screen

```
┌────────────────────────────────────────┐
│  ← Add Medication                      │ ← Header
│                                        │
│  Medication Name                       │
│  ┌──────────────────────────────┐     │
│  │ 💊 e.g., Vitamin C            │     │ ← Name input
│  └──────────────────────────────┘     │
│                                        │
│  Dosage                                │
│  ┌──────────────────────────────┐     │
│  │ 💊 e.g., 2 caps, 1 pill       │     │ ← Dosage input
│  └──────────────────────────────┘     │
│                                        │
│  Schedule                              │
│  ┌─────────┐┌──────────┐┌─────────┐  │
│  │Morning  ││Afternoon ││Evening  │   │ ← Category pills
│  └─────────┘└──────────┘└─────────┘  │   (Selected = gradient)
│                                        │
│  Notification Time                     │
│  ┌──────────────────────────────┐     │
│  │  🕐  Time                     │     │ ← Time picker
│  │     08:00                     │     │
│  └──────────────────────────────┘     │
│                                        │
│  Meal Timing                           │
│  ┌────────┐┌────────┐┌────────┐      │
│  │Before  ││After   ││Anytime │       │ ← Meal timing pills
│  └────────┘└────────┘└────────┘      │
│                                        │
│  Choose Icon                           │
│  ┌──┐┌──┐┌──┐┌──┐┌──┐┌──┐┌──┐       │
│  │💊││💧││🍶││⭐││💉││💧││🥤│       │ ← Icon selector
│  └──┘└──┘└──┘└──┘└──┘└──┘└──┘       │   (7 options)
│                                        │
│  Choose Color                          │
│  ⚪🟡🟢🟣🔵🟠🟣🟢                      │ ← Color picker
│                                        │   (8 pastel colors)
│  ┌──────────────────────────────┐     │
│  │  ✓ Add Medication             │     │ ← Confirm button
│  └──────────────────────────────┘     │   (Large gradient)
│                                        │
└────────────────────────────────────────┘
```

**Design Features:**
- Clean form layout with sections
- Interactive pill selectors (tap to select)
- Visual icon grid with borders
- Color circles with check marks
- Form validation
- Large gradient submit button

---

## 🎨 Color Palette Used

### Primary Colors
- **Purple (Medication)**: `#9D84FF` - Main theme color
- **Yellow (Morning)**: `#FFD166` - Warm, energetic
- **Mint (Success)**: `#06D6A0` - Fresh, positive
- **Red (Alert)**: `#FF6B6B` - Warning, attention
- **Blue (Night)**: `#4FC3F7` - Calm, evening

### Gradients
```dart
// Purple gradient (Primary)
[Color(0xFF9D84FF), Color(0xFFB8A4FF)]

// Green gradient (Take button)
[Color(0xFF06D6A0), Color(0xFF48E5BB)]

// Red gradient (Skip button)
[Color(0xFFFF6B6B), Color(0xFFFF8E8E)]

// Card backgrounds (Light)
[color.withAlpha(0.15), color.withAlpha(0.08)]
```

### Text Colors
- **Dark**: `#2D3436` (Headings)
- **Medium**: `#8B92A0` (Body)
- **Light**: `#B2BEC3` (Hints)

### Backgrounds
- **Main**: `#FBFBFB` (Off-white)
- **Cards**: `#FFFFFF` (Pure white)

---

## 📏 Spacing & Sizing

### Border Radius
- Cards: `24px`
- Buttons: `22-24px`
- Pills/Chips: `14-18px`
- Icons: `16px`

### Padding
- Screen edges: `24px`
- Card padding: `20px`
- Between sections: `24-32px`
- Between items: `12-16px`

### Icon Sizes
- Large (Detail screen): `60px`
- Medium (Cards): `32px`
- Small (Badges): `20px`

### Font Sizes
- Display: `32px` (Light 300)
- Heading: `24-28px` (SemiBold 600)
- Body: `16-18px` (Regular 400)
- Small: `12-14px` (Medium 500)

---

## 🎯 UI Patterns

### Card Style
```dart
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [color.withAlpha(0.15), color.withAlpha(0.08)],
    ),
    borderRadius: BorderRadius.circular(24),
    boxShadow: [
      BoxShadow(
        color: color.withAlpha(0.1),
        blurRadius: 16,
        offset: Offset(0, 6),
      ),
    ],
  ),
)
```

### Button Style
```dart
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [Color(0xFF9D84FF), Color(0xFFB8A4FF)],
    ),
    borderRadius: BorderRadius.circular(24),
    boxShadow: [
      BoxShadow(
        color: Color(0xFF9D84FF).withAlpha(0.4),
        blurRadius: 16,
        offset: Offset(0, 8),
      ),
    ],
  ),
)
```

### Pill/Chip Style
```dart
Container(
  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
  decoration: BoxDecoration(
    color: isSelected ? Color(0xFFE8DEFF) : Colors.white,
    borderRadius: BorderRadius.circular(14),
    border: Border.all(
      color: isSelected ? Color(0xFF9D84FF) : Color(0xFFE8E8E8),
    ),
  ),
)
```

---

## ✨ Animations Used

### Card Tap
- Scale: 0.98 on press
- Duration: 150ms
- Curve: ease-out

### Button Press
- Scale: 0.95 on press
- Shadow reduction
- Duration: 100ms

### Screen Transitions
- Fade + Slide
- Duration: 300ms
- Curve: easeInOut

### SnackBar
- Slide from bottom
- Duration: 2 seconds
- Auto-dismiss

---

## 🎭 Empty States

### No Medications
```
    ┌─────────┐
    │         │
    │   💊   │  ← Large icon in circle
    │         │
    └─────────┘
    
    No medications
    Tap + to add your first medication
```

**Design:**
- Large pastel circle background
- Centered icon
- Gentle text
- Encourages action

---

## 📱 Responsive Behavior

### Cards
- Horizontal margins: 20px
- Adapt to screen width
- Stack on narrow screens

### Day Selector
- Horizontal scroll
- Snap to items
- 7 days visible

### Form Fields
- Full width minus margins
- Minimum touch target: 48px
- Keyboard aware scrolling

---

## 🎨 Icon Reference

### Medication Types
- **Pill**: `Icons.medication` (💊)
- **Capsule**: `Icons.medication_liquid` (💧)
- **Bottle**: `Icons.local_pharmacy` (🏪)
- **Vitamin**: `Icons.star` (⭐)
- **Injection**: `Icons.vaccines` (💉)
- **Drops**: `Icons.water_drop` (💧)
- **Syrup**: `Icons.local_drink` (🥤)

### UI Elements
- **Time**: `Icons.access_time` (🕐)
- **Meal**: `Icons.restaurant` (🍽️)
- **Calendar**: `Icons.calendar_today` (📅)
- **Success**: `Icons.check_circle` (✓)
- **Skip**: `Icons.close` (✗)
- **Postpone**: `Icons.schedule` (⏱️)

---

## 🎉 Design Philosophy

This module follows your app's core design principles:

1. **Soft & Gentle**: Pastel colors, light shadows
2. **Minimal**: Clean layouts, ample whitespace
3. **Friendly**: Rounded corners, cute icons
4. **Consistent**: Matches Breathing & Water modules
5. **Accessible**: Large touch targets, clear labels
6. **Delightful**: Smooth animations, positive feedback

The result is a medication tracker that feels calm and non-clinical, perfectly fitting your health tracking app's soothing aesthetic. 🌸
