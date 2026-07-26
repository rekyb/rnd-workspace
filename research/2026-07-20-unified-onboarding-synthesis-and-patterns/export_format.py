import re

with open(r'C:\research-workspace\research\2026-07-20-unified-onboarding-synthesis-and-patterns\SYNTHESIS.md', 'r', encoding='utf-8') as f:
    text = f.read()

title_block = """# Executive Summary: Onboarding Strategy & Patterns
**Date:** 2026-07-20
**Prepared for:** solve.education Stakeholders
**Subject:** Job-Readiness Onboarding UX Patterns
"""

tldr_match = re.search(r'## TL;DR\n(.*?)(?=\n## )', text, re.DOTALL)
tldr = tldr_match.group(1).strip() if tldr_match else ""

di_match = re.search(r'## Design implications\n(.*?)(?=\n## )', text, re.DOTALL)
di = di_match.group(1).strip() if di_match else ""

conc_match = re.search(r'## Conclusion\n(.*?)(?=\n## )', text, re.DOTALL)
conclusion = conc_match.group(1).strip() if conc_match else ""

overview_match = re.search(r'## Overview of Literature & Benchmarks\n(.*?)(?=\n## Synthesized Themes)', text, re.DOTALL)
overview = overview_match.group(1).strip() if overview_match else ""

themes_match = re.search(r'## Synthesized Themes & Benchmark Teardown\n(.*?)(?=\n### Theme 5: Distraction-Free Program Routing)', text, re.DOTALL)
themes = themes_match.group(1).strip() if themes_match else ""

theme_5_match = re.search(r'### Theme 5: Distraction-Free Program Routing\n(.*?)(?=\n## Design implications)', text, re.DOTALL)
theme_5 = theme_5_match.group(1).strip() if theme_5_match else ""

weak_match = re.search(r'## Refuted / weak claims\n(.*?)(?=\n## Evidence gaps|\n## Gaps & caveats)', text, re.DOTALL)
weak = weak_match.group(1).strip() if weak_match else ""

gaps_match = re.search(r'## Gaps & caveats\n(.*?)(?=\n## Peer Review|\n## Sources)', text, re.DOTALL)
gaps = gaps_match.group(1).strip() if gaps_match else ""

sources_match = re.search(r'## Sources table\n(.*?)(?=\n## Gaps & caveats|\n## Peer Review)', text, re.DOTALL)
sources = sources_match.group(1).strip() if sources_match else ""

peer_review_match = re.search(r'## Peer Review \(2026-07-20\)\n(.*)', text, re.DOTALL)
peer = peer_review_match.group(1).strip() if peer_review_match else ""

themes_clean = themes.replace('<br><br>', ' ').replace('<br>', ' ')
themes_clean = re.sub(r'!\[.*?\]\(.*?\)', '[Screenshot available in original markdown]', themes_clean)

theme_5_clean = theme_5.replace('<br><br>', ' ').replace('<br>', ' ')
theme_5_clean = re.sub(r'!\[.*?\]\(.*?\)', '[Screenshot available in original markdown]', theme_5_clean)

export_md = f"""{title_block}

## TL;DR
{tldr}

## Conclusion
{conclusion}

## Executive Design Implications
{di}

---

## 1. Overview of Literature & Benchmarks
{overview}

## 2. Synthesized Themes & Benchmark Teardown
{themes_clean}

### Theme 5: Distraction-Free Program Routing
{theme_5_clean}

## 3. Refuted & Weak Claims
{weak}

## 4. Sources
{sources}

## 5. Gaps, Caveats & Hypotheses
{gaps}

## 6. Peer Review Record
{peer}
"""

with open(r'C:\research-workspace\research\2026-07-20-unified-onboarding-synthesis-and-patterns\SYNTHESIS_EXPORT.md', 'w', encoding='utf-8') as f:
    f.write(export_md)

print("done")
