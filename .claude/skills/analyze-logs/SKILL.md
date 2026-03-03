---
name: analyze-logs
description: Analyze log files for errors, warnings, and anomalies. Use when the user mentions "analyze logs," "log errors," "parse logs," "log report," "error analysis," "what's in this log," or provides .log/.csv/.txt files for diagnostic review.
---

# Log Analysis Skill

You are orchestrating a thorough log file analysis. Your job is to coordinate sub-agents that do the actual parsing, then synthesize their findings into a single prioritized report.

## Input

The user provides one or more log files via:
- File path(s): `/path/to/app.log`, `*.log`, etc.
- Inline pasted log content (save to a temp file first)
- A directory to scan for log files

Optional user parameters:
- **Severity filter**: errors only, warnings+errors, all anomalies (default: warnings+errors)
- **Time range**: only analyze entries within a window
- **Focus area**: specific service, module, or error pattern to prioritize

## Pre-Flight

1. **Resolve file list.** Use Glob to expand any patterns. Confirm files exist and are readable.
2. **Sample each file.** Read the first 50 lines to determine:
   - Log format (structured JSON, syslog, CSV, freeform, etc.)
   - Field layout (timestamp position, severity field, message field)
   - Approximate total line count (`wc -l`)
3. **Plan agent allocation.** One sub-agent per log file (up to 5 concurrent). If more than 5 files, batch them.

## Execution

For EACH log file, spawn a **general-purpose sub-agent** via the Task tool with this prompt structure:

```
You are analyzing a single log file for errors, warnings, and anomalies.

File: [absolute path]
Format: [detected format from pre-flight]
Total lines: [approximate count]
Severity filter: [errors-only | warnings+errors | all-anomalies]
Time range: [if specified, otherwise "all"]
Focus area: [if specified, otherwise "none"]

Instructions:
1. Read the entire file (use offset/limit for files over 2000 lines — read in chunks).
2. Identify every distinct error and warning type. Group by normalized message (strip variable parts like IDs, timestamps, paths).
3. For each distinct error/warning, collect:
   - Exact error message template (with variables replaced by placeholders)
   - Severity level (FATAL/ERROR/WARN/INFO-anomaly)
   - Total occurrences
   - First and last occurrence timestamps (if timestamps exist)
   - Distribution pattern: "bursty" (clustered in time), "steady" (spread evenly), "single" (one-off)
   - 1-2 representative raw log lines (verbatim)
   - Co-occurring errors (errors that always appear near this one)
4. Calculate percentage of total entries for each error type.
5. For each error, provide:
   - Possible root causes (grounded in the log context, not generic)
   - Actionable recommendations to resolve or mitigate
   - Impact assessment: High (service down/data loss), Medium (degraded functionality), Low (cosmetic/noise)

Return your findings as structured markdown using the exact template below. Do NOT add commentary outside the template.

## File: [filename]
- **Format**: [detected format]
- **Total entries**: [count]
- **Error entries**: [count] ([percentage]%)
- **Warning entries**: [count] ([percentage]%)
- **Analysis period**: [first timestamp] to [last timestamp]

### [SEVERITY] [Error message template]
- **Impact**: High | Medium | Low
- **Occurrences**: [number] ([percentage]% of total)
- **Time range**: [first] — [last]
- **Pattern**: bursty | steady | single
- **Sample lines**:
  ```
  [raw line 1]
  [raw line 2]
  ```
- **Co-occurring**: [related error types, or "none observed"]
- **Probable causes**:
  - [cause grounded in log context]
- **Recommended actions**:
  - [specific, actionable step]
```

Spawn all file-analysis agents **in parallel** using the Task tool.

## Synthesis

After all sub-agents return, produce the final report:

### 1. Executive Summary
- Total files analyzed, total entries scanned, total distinct error types found
- Overall health assessment: Healthy / Degraded / Critical
- Top 3 errors by impact (considering severity x frequency)

### 2. Priority Action Items
Numbered list of the most impactful fixes, ordered by:
1. High-severity + high-frequency first
2. Bursty patterns (indicating active incidents) over steady patterns
3. Errors with co-occurring cascades

### 3. Per-File Analysis
Include each sub-agent's report verbatim, in order of most-errors-first.

### 4. Cross-File Correlations
- Errors that appear across multiple files (shared root cause?)
- Temporal correlations (error in file A triggers error in file B?)
- Services/components that appear in multiple error chains

### 5. Noise Candidates
Errors that are likely low-value and could be:
- Downgraded to debug level
- Filtered from alerting
- Addressed with a single config change

## Output

Write the full report to: `thoughts/shared/analysis/YYYY-MM-DD_log-analysis_<descriptive-slug>.md`

Also print a concise summary to the conversation:
- Health assessment
- Top 3 action items
- Link to the full report file

## Notes
- If a file has zero errors/warnings, say so explicitly — don't skip it.
- For files over 10,000 lines, instruct the sub-agent to sample strategically (first 1000, last 1000, plus random chunks from the middle) and note that sampling was used.
- Never fabricate log lines. Every sample must be verbatim from the file.
- If log format is ambiguous, note the assumption and proceed.
