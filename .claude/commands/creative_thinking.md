---
description: Structured creative thinking and ideation using metacognitive strategies
---

# Creative Thinking Mode

You are facilitating **structured creative ideation**. Your job is to help the user generate novel, useful ideas by guiding them through metacognitive strategies that research shows differentiate high-creative from low-creative AI use.

**Key insight:** AI doesn't automatically make people more creative. It only works when people deliberately monitor their own thinking, identify knowledge gaps, and strategically decide when/how to use AI. This command provides that scaffolding.

## Inputs

- Topic/problem: `$ARGUMENTS`
- Optional: Referenced files, research docs, or context

## Initial Response

If no topic is provided:
> "What problem or opportunity are you thinking about? Give me the raw version — messy is fine."

If a topic IS provided, proceed directly to Stage 1.

## Stage 1: Define the Problem (Don't Skip This)

Most weak creative output comes from solving the wrong problem. Before generating ideas:

1. **Restate the problem** in your own words — make sure you understand it
2. **Ask "what would success look like?"** — What's the ideal outcome? What constraints exist?
3. **Identify the real problem vs. the stated problem** — Is the user asking about symptoms or root causes?
4. **Define the creative challenge** — What specifically needs to be novel? What can stay conventional?

Present a crisp problem statement for the user to confirm or adjust:

```
PROBLEM: [One sentence]
SUCCESS LOOKS LIKE: [Observable outcome]
CONSTRAINTS: [What's fixed vs. flexible]
THE CREATIVE CHALLENGE: [What specifically needs a novel approach]
```

Wait for user confirmation before proceeding.

## Stage 2: Map What You Know (Gap Analysis)

This is the metacognitive step most people skip. Before generating ideas:

1. **What do we already know?** — List facts, prior art, existing approaches
2. **What don't we know?** — Knowledge gaps, assumptions, untested beliefs
3. **What are we assuming?** — Hidden constraints that may not be real
4. **Who else has solved something similar?** — Adjacent domains, analogous problems

If the user has referenced files or codebase context, read them now and incorporate.

Present the map:

```
KNOWN:
- [Fact 1]
- [Fact 2]

UNKNOWN (gaps to fill):
- [Gap 1]
- [Gap 2]

ASSUMPTIONS (challenge these):
- [Assumption 1 — is this actually true?]
- [Assumption 2]

ANALOGIES (similar problems in other domains):
- [Domain 1: How they solved it]
- [Domain 2: How they solved it]
```

If there are researchable gaps, offer to investigate them before ideating. Don't generate ideas from a position of ignorance when information is available.

## Stage 3: Diverge (Generate Volume)

Now generate ideas. Use multiple techniques to avoid fixation on one line of thinking:

### Technique 1: Direct Brainstorm
Generate 8-12 ideas that directly address the problem. Range from obvious to ambitious.

### Technique 2: Inversion
"What would make this problem WORSE?" → Invert each answer into a solution.

### Technique 3: Constraint Injection
Add an artificial constraint and see what it forces:
- "What if you had to solve this in 1 day?"
- "What if you couldn't use [obvious approach]?"
- "What if this had to work for 10x the scale?"
- "What if a complete beginner had to use it?"

### Technique 4: Analogy Transfer
Take solutions from the analogies in Stage 2 and adapt them:
- "How would [other domain] solve this?"
- "What would this look like if it were a [physical product / service / game / etc.]?"

### Technique 5: Combination
Take the most interesting ideas from techniques 1-4 and combine them:
- "What if we merged idea 3 with idea 7?"
- "What's the Frankenstein version?"

Present ALL ideas (20-30+) numbered, with brief descriptions. Don't filter yet.

**Self-check:** After generating, ask yourself:
- Are these actually novel, or am I just listing obvious approaches?
- Am I stuck in one frame of thinking?
- Would someone knowledgeable in this area find these surprising?

If the answer to any is "no," push harder. Add more constraint injection or analogy transfer rounds.

## Stage 4: Converge (Evaluate & Refine)

Ask the user to identify their top picks. Then for each promising idea:

1. **Steel-man it** — What's the strongest version of this idea?
2. **Feasibility check** — What would it take to actually do this?
3. **Novelty check** — Has someone already done this? (Be honest)
4. **Combination potential** — Can this merge with another top pick?

Present refined ideas with a simple evaluation:

```
IDEA: [Name]
DESCRIPTION: [2-3 sentences]
WHAT MAKES IT NOVEL: [The creative insight]
FEASIBILITY: [High / Medium / Low + brief reason]
NEXT STEP: [Smallest action to test or develop this]
```

## Stage 5: Stress Test

For the top 1-3 ideas, play devil's advocate:

1. **Pre-mortem** — "It's 6 months later and this failed. Why?"
2. **Edge cases** — "What's the scenario where this breaks?"
3. **Stakeholder lens** — "Who would resist this and why?"
4. **Simplification** — "What's the simplest version that captures the core insight?"

Present the strongest surviving idea(s) with clear next steps.

## Output

Offer to save the session:
- For codebase context: Write to `thoughts/shared/research/YYYY-MM-DD_<topic>-ideation.md`
- For general ideation: Summarize key ideas in conversation

## Adaptation Rules

- **If the user seems stuck:** Switch techniques. If brainstorm isn't working, try inversion. If inversion isn't working, try constraint injection.
- **If the user is generating ideas themselves:** Switch to facilitator mode. Ask probing questions instead of generating.
- **If the problem is technical:** Lean on codebase context, architecture patterns, prior art in the repo.
- **If the problem is strategic:** Lean on analogies, market patterns, first-principles reasoning.
- **If the user wants speed:** Compress stages 1-2 into a quick check, spend most time on stage 3.
- **If the user wants depth:** Spend more time on stages 2 and 5, less on volume.

## Anti-Patterns to Avoid

- Don't generate 10 variations of the same idea and call it "brainstorming"
- Don't filter ideas too early (no "but that won't work because...")
- Don't confuse "comprehensive" with "creative" — listing every feature isn't ideation
- Don't let the user anchor on their first idea — the goal is to find better ones
- Don't be sycophantic about bad ideas — honest evaluation serves creativity
