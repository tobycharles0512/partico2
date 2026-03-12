# Friend Search Feature Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a magnifying glass icon to the home screen that opens a dedicated friend search screen displaying mutual friends by default and search results with mutual friend counts.

**Architecture:**
- Create new `SearchFriendsScreen` React component with search input and conditional rendering (mutual friends vs search results)
- Update `HomeScreen` header to include magnifying glass icon button
- Add "searchFriends" route to the main navigation switch
- Reuse existing context functions: `getMutualFriendSuggestions()`, `sendFriendRequest()`, `users`, `currentUser`

**Tech Stack:** React 18 (CDN), localStorage for state, existing utility functions

---

## File Structure

**Modified Files:**
- `Partico-updated.html` — Single file containing entire app
  - HomeScreen component: Add magnifying glass icon to header (line ~1295)
  - SearchFriendsScreen component: New component (insert before HomeScreen, ~line ~1290)
  - Main navigation switch: Add "searchFriends" route (line ~2805)

**No new files created** — All changes inline in Partico-updated.html

---

## Chunk 1: Create SearchFriendsScreen Component

### Task 1: Create SearchFriendsScreen Component Shell

**Files:**
- Modify: `Partico-updated.html:1290` (insert before HomeScreen)

**Overview:** Create the basic component structure with header, search input, and conditional rendering logic.

- [ ] **Step 1: Understand current component patterns**

Read the existing FriendsScreen to understand:
- Tab state management pattern
- Search input field pattern
- Card layout pattern
- Toast notification usage

Run: In your editor, search for `const FriendsScreen = () => {` (line ~2437)
Examine: How searchQ state is managed, how filtered results are computed

- [ ] **Step 2: Identify insertion point**

Find the exact line number where HomeScreen starts:
```bash
grep -n "const HomeScreen = () => {" Partico-updated.html
```

Expected output: Line number around 1290

Note this line number for insertion point (new SearchFriendsScreen goes right before HomeScreen)

- [ ] **Step 3: Create SearchFriendsScreen component structure**

Insert this code RIGHT BEFORE `const HomeScreen = () => {`:

```javascript
const SearchFriendsScreen = () => {
  const { navigate, currentUser, users, getMutualFriendSuggestions, sendFriendRequest, showToast } = useApp();
  const [searchQ, setSearchQ] = useState("");
  const [sentRequests, setSentRequests] = useState({}); // Track which requests we just sent

  const myId = currentUser?.id || "";
  const myFriends = currentUser?.friends || [];
  const myRequests = currentUser?.friendRequests || [];

  // Get mutual friend suggestions (up to 15)
  const suggestions = useMemo(() => {
    const all = getMutualFriendSuggestions ? getMutualFriendSuggestions() : [];
    return all.slice(0, 15);
  }, []);

  // Get all users to search from (exclude current user, friends, pending requests)
  const allOtherUsers = useMemo(() => {
    return users.filter(
      (u) => u.id !== myId &&
             !myFriends.includes(u.id) &&
             !myRequests.some((r) => r && r.from === u.id)
    );
  }, [users, myId, myFriends, myRequests]);

  // Filter based on search query
  const searchResults = useMemo(() => {
    if (!searchQ.trim()) return [];
    const q = searchQ.toLowerCase();
    return allOtherUsers.filter((u) =>
      `${u.firstName} ${u.lastName} ${u.email} ${u.phone || ""}`.toLowerCase().includes(q)
    ).slice(0, 25);
  }, [searchQ, allOtherUsers]);

  // Determine what to display
  const displayItems = searchQ.trim() ? searchResults : suggestions;
  const isSearchMode = searchQ.trim().length > 0;

  const handleAddFriend = (userId, firstName) => {
    sendFriendRequest(userId);
    setSentRequests(prev => ({ ...prev, [userId]: true }));
    showToast(`Friend request sent to ${firstName}! 💬`);
  };

  return /* @__PURE__ */ React.createElement("div", { className: "screen", style: { background: "linear-gradient(180deg,#0d0d0d 0%,#0d0d0d 100%)", paddingBottom: 80 } },
    // Header
    /* @__PURE__ */ React.createElement("div", { style: { padding: "50px 20px 16px", background: "rgba(0,0,0,0.9)", backdropFilter: "blur(20px)", borderBottom: "1px solid rgba(255,255,255,0.08)", position: "sticky", top: 0, zIndex: 50 } },
      /* @__PURE__ */ React.createElement("div", { style: { display: "flex", alignItems: "center", gap: 12, marginBottom: 16 } },
        /* @__PURE__ */ React.createElement("button", { onClick: () => navigate("home"), style: { background: "rgba(255,255,255,0.08)", border: "none", color: "#fff", borderRadius: 10, width: 36, height: 36, fontSize: 18, cursor: "pointer" } }, "←"),
        /* @__PURE__ */ React.createElement("div", { style: { fontSize: 20, fontWeight: 800 } }, "Search Friends")
      ),
      /* @__PURE__ */ React.createElement("input", {
        className: "input-field",
        placeholder: "🔍 Search by name, email or phone...",
        value: searchQ,
        onChange: (e) => setSearchQ(e.target.value),
        autoFocus: true,
        style: { marginBottom: 0 }
      })
    ),

    // Content
    /* @__PURE__ */ React.createElement("div", { style: { padding: "16px" } },
      !isSearchMode && suggestions.length === 0 ?
        // No suggestions
        /* @__PURE__ */ React.createElement("div", { style: { textAlign: "center", padding: "48px 20px", color: "rgba(255,255,255,0.4)", fontSize: 14 } },
          /* @__PURE__ */ React.createElement("div", { style: { fontSize: 48, marginBottom: 12 } }, "👥"),
          "No mutual friends yet"
        )
        :
        // Show suggestions or search results
        /* @__PURE__ */ React.createElement("div", { style: { animation: "fadeIn 0.3s ease" } },
          !isSearchMode && /* @__PURE__ */ React.createElement("div", { style: { fontSize: 16, fontWeight: 700, marginBottom: 12, color: "#fff" } }, "👥 People You May Know"),
          isSearchMode && searchResults.length === 0 && /* @__PURE__ */ React.createElement("div", { style: { textAlign: "center", color: "rgba(255,255,255,0.3)", padding: 40, fontSize: 14 } }, 'No users found for "', searchQ, '"'),

          // List of users
          displayItems.map((user) => {
            const mutualFriends = suggestions.find(s => s.user.id === user.id)?.mutualCount || 0;
            const alreadySent = sentRequests[user.id];
            return /* @__PURE__ */ React.createElement("div", { key: user.id, className: "card", style: { marginBottom: 10, display: "flex", alignItems: "center", gap: 12 } },
              /* @__PURE__ */ React.createElement(Avatar, { user, size: 50 }),
              /* @__PURE__ */ React.createElement("div", { style: { flex: 1, minWidth: 0 } },
                /* @__PURE__ */ React.createElement("div", { style: { fontWeight: 700, fontSize: 15, marginBottom: 2 } }, user.firstName, " ", user.lastName),
                /* @__PURE__ */ React.createElement("div", { style: { fontSize: 12, color: "rgba(255,255,255,0.5)" } }, mutualFriends, " mutual ", mutualFriends === 1 ? "friend" : "friends")
              ),
              /* @__PURE__ */ React.createElement("button", {
                onClick: () => handleAddFriend(user.id, user.firstName),
                disabled: alreadySent,
                style: {
                  background: alreadySent ? "rgba(255,255,255,0.08)" : "linear-gradient(135deg,#00ff41,#00d944)",
                  color: "#fff",
                  border: alreadySent ? "1px solid rgba(255,255,255,0.2)" : "none",
                  borderRadius: 10,
                  padding: "8px 14px",
                  fontSize: 12,
                  fontWeight: 700,
                  cursor: alreadySent ? "default" : "pointer",
                  flexShrink: 0,
                  opacity: alreadySent ? 0.6 : 1
                }
              }, alreadySent ? "✓ Sent" : "+ Add")
            );
          })
        )
    ),

    /* @__PURE__ */ React.createElement(BottomNav, { screen: "home", navigate })
  );
};
```

- [ ] **Step 4: Verify component syntax**

Search for the inserted code in your editor to confirm:
- Component is properly declared
- All React.createElement calls are balanced
- No syntax errors visible

- [ ] **Step 5: Commit**

```bash
cd /Users/tobycharles/partico
git add Partico-updated.html
git commit -m "feat: add SearchFriendsScreen component shell

- Create SearchFriendsScreen with search input
- Display mutual friends by default (up to 15)
- Show search results when user types
- Manage sent friend request tracking"
```

---

### Task 2: Fix Mutual Friends Display Logic

**Files:**
- Modify: `Partico-updated.html` - SearchFriendsScreen component (the code from Task 1)

**Issue:** Current code uses `mutualCount` from suggestions array, but needs to calculate for each search result too.

- [ ] **Step 1: Understand mutual friends data structure**

In the SearchFriendsScreen component, `getMutualFriendSuggestions()` returns an array of objects with structure:
```javascript
[
  { user: { id, firstName, lastName, ... }, mutualCount: 3 },
  { user: { id, firstName, lastName, ... }, mutualCount: 5 },
  ...
]
```

But search results come from the `users` array directly, which doesn't have `mutualCount`.

- [ ] **Step 2: Create helper function to get mutual friends count**

Add this helper function BEFORE SearchFriendsScreen definition (around line 1280):

```javascript
const getMutualFriendsCount = (userId, currentUserId, allUsers, friends) => {
  const user = allUsers.find(u => u.id === userId);
  if (!user) return 0;
  const userFriends = user.friends || [];
  const myFriends = friends || [];
  const mutuals = userFriends.filter(fid => myFriends.includes(fid));
  return mutuals.length;
};
```

- [ ] **Step 3: Update SearchFriendsScreen to use helper**

In the card mapping section, replace:
```javascript
const mutualFriends = suggestions.find(s => s.user.id === user.id)?.mutualCount || 0;
```

With:
```javascript
const mutualFriends = getMutualFriendsCount(user.id, myId, users, myFriends);
```

- [ ] **Step 4: Test mutual friends display**

Open `Partico-updated.html` in a browser
- Create 2+ test users with shared friends
- Search for a user
- Verify mutual friends count displays correctly

- [ ] **Step 5: Commit**

```bash
git add Partico-updated.html
git commit -m "fix: calculate mutual friends count for all search results

- Add getMutualFriendsCount helper function
- Use helper to display correct count for both suggestions and search results
- Count is based on overlapping friends list"
```

---

## Chunk 2: Update HomeScreen Header

### Task 3: Add Magnifying Glass Icon to HomeScreen

**Files:**
- Modify: `Partico-updated.html:1295` (HomeScreen header)

- [ ] **Step 1: Locate HomeScreen header**

Search for the header section in HomeScreen (around line 1300-1305):
```bash
grep -n "display: \"flex\", justifyContent: \"space-between\", alignItems: \"center\"" Partico-updated.html | head -5
```

Find the header that contains the Partico logo and notification bell. This is where we'll add the search icon.

- [ ] **Step 2: Understand current header structure**

The header has:
- Left side: Logo div with Partico branding
- Right side: Notification bell button

We'll add the search icon to the right side, BEFORE the notification bell.

- [ ] **Step 3: Find notification bell button code**

Search for the notification bell code pattern:
```bash
grep -n "onClick: () => navigate(\"notifications\")" Partico-updated.html
```

This shows the notification bell location. We'll insert the search icon right before it.

- [ ] **Step 4: Insert magnifying glass icon button**

Find this code in the HomeScreen header (around line 1320):
```javascript
/* @__PURE__ */ React.createElement("button", { onClick: () => navigate("notifications"), ...
```

Right before this button, insert:
```javascript
/* @__PURE__ */ React.createElement("button", { onClick: () => navigate("searchFriends"), style: { background: "rgba(255,255,255,0.08)", border: "1px solid rgba(255,255,255,0.1)", borderRadius: 12, width: 42, height: 42, fontSize: 20, display: "flex", alignItems: "center", justifyContent: "center", cursor: "pointer" } }, "🔍"),
```

This creates a button with:
- Size: 42×42px (same as notification bell)
- Icon: 🔍 emoji
- Style: Glass-morphism matching other buttons
- Click handler: Navigates to searchFriends

- [ ] **Step 5: Verify placement**

In the header, you should now see (left to right):
1. Partico logo
2. Greeting text
3. [empty space/flex]
4. 🔍 search icon
5. 🔔 notification bell

- [ ] **Step 6: Commit**

```bash
git add Partico-updated.html
git commit -m "feat: add search friends icon to home screen header

- Add magnifying glass button to HomeScreen header
- Button navigates to SearchFriendsScreen
- Styled to match notification bell button
- Positioned right of header, left of notification bell"
```

---

## Chunk 3: Wire Navigation

### Task 4: Add searchFriends Route to Navigation

**Files:**
- Modify: `Partico-updated.html` (main navigation switch)

- [ ] **Step 1: Find main navigation switch**

Search for where routes are defined:
```bash
grep -n "if (screen === \"home\") return wrap" Partico-updated.html
```

This shows the main navigation routing logic (around line 2805).

- [ ] **Step 2: Understand route pattern**

The routing uses a series of if statements:
```javascript
if (screen === "home") return wrap(/* @__PURE__ */ React.createElement(HomeScreen, null));
if (screen === "friends") return wrap(/* @__PURE__ */ React.createElement(FriendsScreen, null));
// etc.
```

- [ ] **Step 3: Add searchFriends route**

Find the route section and add this route BEFORE the HomeScreen default case:

```javascript
if (screen === "searchFriends") return wrap(/* @__PURE__ */ React.createElement(SearchFriendsScreen, null));
```

Exact placement: After `if (screen === "notifications")` and before `if (screen === "home")`

- [ ] **Step 4: Verify routing**

Search the file to confirm:
- `navigate("searchFriends")` is called from home header
- `if (screen === "searchFriends")` route exists
- `SearchFriendsScreen` component is defined earlier in file

- [ ] **Step 5: Test navigation**

Open `Partico-updated.html` in browser:
1. Home screen visible
2. Click magnifying glass icon → SearchFriendsScreen loads
3. Click back arrow → Home screen returns
4. Check console for no errors

- [ ] **Step 6: Commit**

```bash
git add Partico-updated.html
git commit -m "feat: wire searchFriends route to navigation

- Add searchFriends case to main route switch
- Enables navigation from home icon to SearchFriendsScreen
- Tested: forward and back navigation works"
```

---

## Chunk 4: Testing & Refinement

### Task 5: End-to-End Testing

**Files:**
- Test: `Partico-updated.html` (manual testing in browser)

- [ ] **Step 1: Test default state (mutual friends display)**

Prerequisites:
- Have at least 2 test users with shared friends
- Log in as one user

Actions:
1. Click home 🔍 icon
2. SearchFriendsScreen opens
3. Search box is empty
4. "People You May Know" section visible
5. Up to 15 suggestions displayed with avatars, names, mutual count

Expected: "X mutual friends" count is correct for each suggestion

- [ ] **Step 2: Test search functionality**

Actions:
1. In search box, type partial name (e.g., "john")
2. Results filter in real-time
3. Each result shows name, avatar, mutual friends count
4. Results exclude: current user, existing friends, pending requests
5. Typing invalid name shows "No users found for..."

Expected: Search works instantly, results are accurate

- [ ] **Step 3: Test add friend flow**

Actions:
1. From search results (or suggestions), click "+ Add" button
2. Button immediately changes to "✓ Sent" (disabled)
3. Toast notification appears: "Friend request sent to [Name]! 💬"
4. Toast disappears after 2.5 seconds

Expected: All three steps work smoothly

- [ ] **Step 4: Test after sending request**

Actions:
1. Search for same user again (in same session)
2. Button still shows "✓ Sent"
3. User no longer appears in search after page refresh

Expected: Request state persists

- [ ] **Step 5: Test back navigation**

Actions:
1. From SearchFriends, click back arrow
2. Returns to HomeScreen
3. HomeScreen displays normally
4. Click search icon again → SearchFriendsScreen reopens (clean state)

Expected: Navigation is smooth, state resets properly

- [ ] **Step 6: Test edge cases**

- [ ] Empty search (no mutual friends): Shows appropriate message
- [ ] Very long names: Truncate properly in card
- [ ] Special characters in search: Handle gracefully
- [ ] Mobile view: Layout responsive, buttons accessible

- [ ] **Step 7: Verify styling**

- [ ] Matches Partico dark theme (#0d0d0d, green #00ff41)
- [ ] Cards use glass-morphism (rgba(255,255,255,0.07))
- [ ] Text colors follow hierarchy (white primary, rgba for secondary)
- [ ] Buttons have proper hover/active states
- [ ] Smooth animations (fadeIn on content)

- [ ] **Step 8: Test in both platforms**

- [ ] Web: Open `Partico-updated.html` in Safari/Chrome
- [ ] iOS: Build in Xcode, test in simulator (app uses same HTML file)

Expected: Feature works identically on both platforms

- [ ] **Step 9: Commit testing notes**

```bash
git add Partico-updated.html
git commit -m "test: verify end-to-end friend search flow

- Tested mutual friends display (up to 15 suggestions)
- Tested search filtering and results accuracy
- Tested add friend flow and button state
- Tested navigation (forward/back)
- Tested edge cases and styling
- Verified on web and iOS platforms
- All tests passed ✅"
```

---

### Task 6: Final Polish & Verification

**Files:**
- Verify: `Partico-updated.html`
- Check: `docs/superpowers/specs/2026-03-11-friend-search-feature-design.md`

- [ ] **Step 1: Verify acceptance criteria**

Go through each acceptance criterion from the spec:

✅ Magnifying glass icon appears in home screen header
✅ Clicking icon navigates to SearchFriends screen
✅ Default view shows up to 15 mutual friend suggestions
✅ Each suggestion displays avatar, name, and mutual friend count
✅ User can search by name, email, or phone
✅ Search results show correct filtering (exclude self, friends, pending requests)
✅ Each search result shows mutual friend count
✅ "+ Add" button sends friend request
✅ Toast confirms friend request sent
✅ Button changes to "✓ Sent" after adding
✅ Back button returns to home screen
✅ Visual styling matches Partico theme

- [ ] **Step 2: Code review checklist**

- [ ] No console errors
- [ ] No unused imports or variables
- [ ] Consistent code style with rest of file
- [ ] Comments added for complex logic
- [ ] PropTypes not needed (React inline, already validated)
- [ ] Performance: No unnecessary re-renders
- [ ] Accessibility: Buttons are keyboard accessible

- [ ] **Step 3: Browser testing final pass**

Test on:
- [ ] Safari (primary target per CLAUDE.md)
- [ ] Chrome
- [ ] Mobile Safari
- [ ] iOS app in simulator

- [ ] **Step 4: Test profile scenarios**

- [ ] User with 0 mutual friends
- [ ] User with 15+ mutual friends (truncate to 15)
- [ ] User with very long name
- [ ] User with no profile picture (fallback avatar)
- [ ] User with special characters in name

- [ ] **Step 5: Commit final changes**

```bash
git add Partico-updated.html
git commit -m "polish: finalize friend search feature

- Verify all acceptance criteria met
- Code review: style, consistency, performance
- Browser compatibility: Safari, Chrome, mobile
- Edge cases handled gracefully
- Ready for production ✅"
```

- [ ] **Step 6: Create CHANGELOG entry**

Add to top of any CHANGELOG file or commit message:

```
## [Unreleased]

### Added
- Friend search screen accessible from home page via magnifying glass icon
- View mutual friends by default (up to 15 suggestions)
- Search all Partico users by name, email, or phone
- See mutual friend count for each search result
- Add friends directly from search screen
```

---

## Summary of Changes

| File | Change | Lines |
|------|--------|-------|
| Partico-updated.html | Add SearchFriendsScreen component | Before line 1290 |
| Partico-updated.html | Add getMutualFriendsCount helper | ~line 1280 |
| Partico-updated.html | Add 🔍 icon to HomeScreen header | ~line 1320 |
| Partico-updated.html | Add searchFriends route to navigation | ~line 2805 |

**Total Changes:** ~200 lines of code
**Files Modified:** 1
**Files Created:** 0

---

## Testing Checklist

- [ ] Default state shows mutual friends
- [ ] Search filters results correctly
- [ ] Mutual friend count displays accurately
- [ ] Add friend button works and updates state
- [ ] Toast notifications appear
- [ ] Back navigation returns to home
- [ ] Responsive on mobile
- [ ] No console errors
- [ ] Works in iOS app
- [ ] Styling matches theme

---

## Rollback Plan

If issues arise:

```bash
# View recent commits
git log --oneline -n 5

# Revert specific commits (in reverse order)
git revert <commit-hash>

# Or reset to before feature
git reset --hard <commit-before-feature>
```

The feature is self-contained in one file, making rollback safe and simple.
