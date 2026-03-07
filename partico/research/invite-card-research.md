# Partico Invite Card System

*Condensed research and implementation spec - March 2026*

---

## What We Built (Differentiators vs Partiful)

### 1. Themed Full-Page Invite Experiences
Each event type has a unique visual identity - different background gradients, fonts, and animations. Not a one-size-fits-all page.

| Event Type | Design Direction |
|---|---|
| Wedding | Dark rose gradient, serif fonts, petal animations |
| Halloween | Near-black with orange tones, spooky particles |
| Club / Rave | Pure black to purple, neon particles, fast energy |
| Christmas | Dark green/red, snowfall effect |
| Brunch | Warm amber tones, gentle animations |
| Baby Shower | Pink/blue pastel gradient, hearts and stars |
| NYE | Black/gold, upward firework bursts |

### 2. Per-Guest Personalisation
Every guest sees "Hey [their name]!" on the invite landing page. Same invite link, personalised experience.

### 3. Live Countdown Timer on Invite
Days, hours, minutes, seconds - visible on the landing page, RSVP page, and confirmation page. Builds anticipation.

### 4. Animated RSVP Confirmation
When a guest submits "I'm going," a celebration burst plays - themed fireworks + event particles. Makes the RSVP moment feel like a reward.

### 5. Embedded Spotify / Apple Music Player
Hosts paste a playlist link. Guests see an embedded player on the invite page - they can listen to the party vibe before arriving.

### 6. Mood Board / Photo Gallery
Hosts upload inspo photos (venue shots, decor ideas, outfit refs). Guests see a scrollable gallery on the invite. Expandable view.

### 7. Smart Event Sections
Auto-suggested info fields based on event type. Not generic "add-on bubbles" - context-aware:

- **Birthday**: Gift list link, age milestone, surprise mode
- **Wedding**: Registry, accommodation, ceremony times
- **BBQ**: What to bring, parking, dietary
- **Club Night**: Door/set times, dress code, tickets
- **Kids Party**: Age range, allergy info, parent contact
- **Hen/Stag**: Itinerary, cost split, dress code

### 8. Invite Analytics for Hosts
Dashboard showing: invite views, invites sent, RSVP count, RSVP rate %, conversion funnel (viewed > responded > accepted). Shows which card features are active.

### 9. Invite Effect Picker
Hosts choose their invite animation: Auto (matches event), Confetti, Fireworks, Bubbles, Petals, or None.

---

## UK Event Types (18 total)

Party, Birthday, Wedding, Dinner Party, Casual Hang, Graduation, Housewarming, Halloween, Christmas, BBQ, Engagement, Hen/Stag, New Year's Eve, Baby Shower, Game Night, Club/Rave, Brunch, Kids Party.

No Thanksgiving, no US-specific holidays.

---

## Architecture Notes

All features built into `Partico-updated.html` (single file, no build step):

- **Party data model** extended with: `playlistUrl`, `moodBoard[]`, `smartSections{}`, `inviteFont`, `inviteEffect`, `inviteViews`
- **CreatePartyScreen** has new "Invite Card" step (step 1 of 9): playlist link, mood board upload, effect picker, smart sections
- **InvitationScreen** fully rewritten: themed backgrounds, personalised greeting, countdown, embedded player, mood board gallery, smart sections display, RSVP celebration
- **PartyManageScreen** has new "Analytics" tab: views, funnel, feature status
- **EVENT_TYPES** expanded from 12 to 18 entries with `font` and `smartSections` properties
- **SMART_SECTION_LABELS** lookup table (22 section types) with emoji, label, placeholder
- **EventParticles** handles all 18 event types
- **trackInviteView()** context method increments view counter on each invite open
