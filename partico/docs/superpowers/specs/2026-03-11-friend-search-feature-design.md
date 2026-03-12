# Friend Search Feature Design

**Date:** 2026-03-11
**Feature:** Friend search accessible from home screen with mutual friends display
**Status:** Design Approved

## Overview

Add a dedicated friend search screen accessible from the home page via a magnifying glass icon. The screen displays up to 15 mutual friend suggestions by default, then shows filtered search results as the user types.

## User Stories

- As a user on the home screen, I want quick access to search for and add new friends without navigating to the Friends tab
- As a user searching for friends, I want to see how many mutual friends I have with each person
- As a user, I want to see my top mutual friend suggestions when I first open the search screen
- As a user, I want to add someone as a friend directly from search results and receive confirmation

## Implementation Details

### 1. Home Screen Changes

**Location:** HomeScreen component header (line ~1290)

**Changes:**
- Add magnifying glass icon (🔍) button next to notification bell in the sticky header
- Button specifications:
  - Size: 42px × 42px
  - Style: `background: rgba(255,255,255,0.08)`, `border: 1px solid rgba(255,255,255,0.1)`, `borderRadius: 12`
  - Icon: "🔍" emoji, fontSize 20
  - Click handler: `onClick={() => navigate("searchFriends")}`

**CSS/Styling:**
- Reuse existing button styles from notification bell
- Maintain consistent visual language with the app

### 2. SearchFriends Screen (New Component)

**File location:** New component within Partico-updated.html
**Component name:** `SearchFriendsScreen`
**Navigation route:** "searchFriends"

#### Screen Structure

**Header Section:**
- Sticky header with back button, title, and search input
- Back button: `onClick={() => navigate("home")}`
- Title: "Search Friends"
- Search input: `className: "input-field"`, placeholder: "🔍 Search by name, email or phone..."
- State: `searchQ` (search query string)

**Content Section - Default State (empty search):**
- Section title: "👥 People You May Know"
- Display: Up to 15 mutual friend suggestions from `getMutualFriendSuggestions()`
- Layout: Vertical stack of cards
- Each card displays:
  - User avatar (Avatar component, size 50px)
  - Name: `${user.firstName} ${user.lastName}`
  - Mutual friends count: "X mutual friends" (from `getMutualFriendSuggestions()` data)
  - Add button:
    - Text: "+ Add"
    - Style: `background: linear-gradient(135deg,#00ff41,#00d944)`
    - Or "✓ Sent" (disabled) if request already sent
  - Interaction: Click to send friend request

**Content Section - Search State (user typing):**
- Show search results (matching users)
- Same card layout as default state
- Max 25 results displayed
- Filtered from: All users except current user, existing friends, pending outgoing requests
- Search fields: firstName, lastName, email, phone
- Case-insensitive matching

**Content Section - Empty Results:**
- Centered message: `No users found for "[query]"`
- Color: `rgba(255,255,255,0.3)`
- Displayed only when search has no matches

#### State & Data Flow

**Context functions used:**
- `navigate(screenName, data)` - Navigate between screens
- `getMutualFriendSuggestions()` - Get top 15 mutual friend suggestions with mutual count
- `sendFriendRequest(userId)` - Send friend request
- `users` - All users array from context
- `currentUser` - Current logged-in user
- `currentUser.friends` - Array of friend IDs
- `currentUser.friendRequests` - Array of pending requests

**Local state:**
- `searchQ` - Search query string (useState)
- `toast` - Toast message state for feedback (useState)

**Logic:**
1. On mount: Load mutual friend suggestions via `getMutualFriendSuggestions()`
2. Display mutual friends if `searchQ` is empty
3. On input change:
   - Filter all users by search query
   - Exclude: current user, existing friends, pending outgoing requests
   - Update displayed results
4. On add button click:
   - Call `sendFriendRequest(userId)`
   - Show toast: "Friend request sent to [firstName]! 💬"
   - Update button to "✓ Sent" state
   - Track sent requests in local state or via context

#### Styling

**Use existing classes:**
- `.input-field` - Search input styling
- `.card` - Card container styling
- `.btn-primary` - Add button styling
- `fadeIn` animation - Screen entrance

**Color scheme:**
- Background: `linear-gradient(180deg,#0d0d0d 0%,#0d0d0d 100%)`
- Header: `rgba(0,0,0,0.9)` with `backdropFilter: blur(20px)`
- Text: `#fff` with secondary text at `rgba(255,255,255,0.5)`

### 3. Navigation Integration

**Route:** Add "searchFriends" case to main navigation switch
**From:** HomeScreen (magnifying glass icon click)
**Back:** To HomeScreen (back button)

### 4. Avatar Component Reuse

The existing `Avatar` component (already used in Friends screen and other places) will display user profile pictures in:
- Each mutual friend suggestion card
- Each search result card
- Size: 50px × 50px

### 5. Toast Notifications

**After successful add:**
- Message: `Friend request sent to [firstName]! 💬`
- Duration: 2.5 seconds (standard)
- Type: "success"

## Data Requirements

**No new data models needed** - Uses existing:
- User model (firstName, lastName, profilePic, etc.)
- Friend relationships (friends array, friendRequests array)
- Mutual friend calculations (already in `getMutualFriendSuggestions()`)

## Edge Cases

1. **No mutual friends:** Display "X mutual friends" as "0 mutual friends" (still shows count)
2. **Request already sent:** Show "✓ Sent" disabled button instead of "+ Add"
3. **Empty search results:** Show "No users found" message
4. **User is already a friend:** Filtered out from results
5. **No mutual friend suggestions:** Show empty state or "No mutual friends" message

## Testing Scenarios

1. Open search screen → See up to 15 mutual friend suggestions
2. Click "+ Add" on a mutual friend → Toast appears, button changes to "✓ Sent"
3. Type name in search → Results appear, mutual friends section replaced
4. Search finds no users → Empty state message displays
5. Search results show correct mutual friend counts
6. Back button → Navigate back to home screen
7. Existing friends/pending requests → Filtered out of search results

## Acceptance Criteria

- ✅ Magnifying glass icon appears in home screen header
- ✅ Clicking icon navigates to SearchFriends screen
- ✅ Default view shows up to 15 mutual friend suggestions
- ✅ Each suggestion displays avatar, name, and mutual friend count
- ✅ User can search by name, email, or phone
- ✅ Search results show correct filtering (exclude self, friends, pending requests)
- ✅ Each search result shows mutual friend count
- ✅ "+ Add" button sends friend request
- ✅ Toast confirms friend request sent
- ✅ Button changes to "✓ Sent" after adding
- ✅ Back button returns to home screen
- ✅ Visual styling matches Partico theme

## Implementation Order

1. Create SearchFriendsScreen component
2. Add search state and input handling
3. Add default mutual friends display logic
4. Add search results filtering logic
5. Add friend request sending and button state tracking
6. Add magnifying glass icon to home header
7. Add navigation route integration
8. Test all scenarios

## Files to Modify

- **Partico-updated.html** - Main changes:
  - Add SearchFriendsScreen component
  - Add search route to navigation switch
  - Add magnifying glass icon to HomeScreen header
  - Possibly add helper function for calculating mutual friends in search results
