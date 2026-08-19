---
name: dom-review
description: Use when the user mentions DOM Review, dom-review-data, __domReviewAPI, or asks to fix/check/resolve the review comments or annotations they left on the page in Chrome. Covers reading, fixing, replying to, and resolving DOM Review comments.
---

# DOM Review — Chrome Extension for Visual Code Review

This project uses the DOM Review Chrome extension together with the **chrome-devtools MCP server**. Every browser tool mentioned below — `evaluate_script`, `take_snapshot`, `navigate_page` — is a tool method on that server; call it through your client's chrome-devtools MCP connection.

## Reading Reviews

Use the `evaluate_script` tool (chrome-devtools MCP) to read review data from the page:

```javascript
// function to pass to evaluate_script
() => JSON.parse(document.getElementById('dom-review-data')?.textContent || '{"reviews":[]}')
```

Each review has: `id`, `selector`, `comment`, `priority`, `category`, `resolved`, `context` (styles, a11y, framework component info), and `replies`.

## Programmatic API

The extension exposes `window.__domReviewAPI` on the page. Call all methods via the `evaluate_script` tool (chrome-devtools MCP). All methods are synchronous and return `{ success, data?, error? }`.

```javascript
// Get all reviews
() => window.__domReviewAPI.getReviews()

// Get one review
() => window.__domReviewAPI.getReview('r_...')

// Add a new review comment on an element
() => window.__domReviewAPI.addComment({
  selector: 'button.submit',        // CSS selector (required)
  comment: 'Needs aria-label',      // review text (required)
  priority: 'high',                 // 'high' | 'medium' | 'low'
  category: 'a11y'                  // 'style' | 'logic' | 'a11y' | 'text' | 'layout' | 'remove' | 'add'
})

// Reply to an existing review
() => window.__domReviewAPI.addReply({
  reviewId: 'r_...',                // review ID (required)
  comment: 'Fixed in Component.vue', // reply text (required)
  author: 'agent'                   // author name
})

// Resolve / reopen a review
() => window.__domReviewAPI.resolveReview('r_...')
() => window.__domReviewAPI.unresolveReview('r_...')

// Update a review
() => window.__domReviewAPI.updateComment({
  reviewId: 'r_...',
  comment: 'Updated text',
  priority: 'medium',
  category: 'style'
})

// Delete a review
() => window.__domReviewAPI.deleteReview('r_...')
```

## Workflow

When asked to check reviews, fix review comments, or work with DOM Review:

1. **Navigate** — use the `navigate_page` tool (chrome-devtools MCP) to open the page if not already open
2. **Read reviews** — use the `evaluate_script` tool (chrome-devtools MCP) with function `() => JSON.parse(document.getElementById('dom-review-data')?.textContent || '{"reviews":[]}')` to get all reviews
3. **Fix issues** — for each unresolved review, use `selector` and `context.framework` to find the right file and component, then make the code changes
4. **Reply** — after fixing, use `evaluate_script` to call `window.__domReviewAPI.addReply({ reviewId, comment, author: 'agent' })` with a short summary of what was changed
5. **Resolve** — use `evaluate_script` to call `window.__domReviewAPI.resolveReview(reviewId)` to mark it done
6. **Report** — tell the user what was fixed and what remains

## Key Details

- All browser interaction goes through the chrome-devtools MCP server's tools
- `evaluate_script` requires a function string: `() => { ... }` — not raw expressions
- Reviews live in a `<script id="dom-review-data" type="application/json">` element in the page DOM
- `context.framework` contains the component name, file path, props, and parent component — use this to find source files
- `selector` is a CSS selector pointing to the reviewed element
- Priority order: `high` > `medium` > `low` — fix high priority first
- The API works via synchronous DOM events — no async/await needed, all results return immediately
- The extension only runs on localhost/127.0.0.1 by default (custom dev sites are user-added)
