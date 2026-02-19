---
name: web-search
description: Web search using Jina Search API. Returns search results with titles, URLs, and descriptions. Use for finding documentation, facts, current information, or any web content. Lightweight, no browser required.
---

<!-- Source: https://github.com/pasky/pi-amplike/blob/25ff804d0cbd5dbf71d9922ac8eb9f0023ce24cd/skills/web-search/SKILL.md; local modifications: use `skill-web-search` shim command instead of `{baseDir}/search.py`, plus this attribution comment. -->

# Web Search

Perform web searches using the Jina Search API. Returns formatted search results with titles, URLs, and descriptions.

## Setup

Optionally get a Jina API key for higher rate limits:
1. Create an account at https://jina.ai/
2. Get your API key from the dashboard
3. Add to your shell profile (`~/.profile` or `~/.zprofile` for zsh):
   ```bash
   export JINA_API_KEY="your-api-key-here"
   ```

Without an API key, the service works with rate limits.

## Usage

```bash
skill-web-search "your search query"
```

## Examples

```bash
# Basic search
skill-web-search "python async await tutorial"

# Search for recent news
skill-web-search "latest AI developments 2024"

# Find documentation
skill-web-search "nodejs fs promises API"
```

## Output Format

Returns markdown-formatted search results:

```
## Search Results

[Title of first result](https://example.com/page1)
Description or snippet from the search result...

[Title of second result](https://example.com/page2)
Description or snippet from the search result...
```

## When to Use

- Searching for documentation or API references
- Looking up facts or current information
- Finding relevant web pages for research
- Any task requiring web search without interactive browsing
