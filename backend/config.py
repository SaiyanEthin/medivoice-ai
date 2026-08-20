"""
Centralized, tunable configuration for the prediction pipeline.
Kept separate so thresholds can be adjusted during validation/testing
without hunting through service code.
"""

# Minimum number of confirmed-present symptoms required before the model
# is allowed to present a named condition. Below this, the pipeline enters
# the follow-up flow instead of guessing from very sparse evidence.
MIN_SYMPTOMS_FOR_PREDICTION = 3

# If the top prediction's probability is below this, the result is reported
# as uncertain ("symptoms unclear") rather than naming a condition.
CONFIDENCE_THRESHOLD = 0.65

# Maximum follow-up rounds before we stop asking and report whatever we have
# (possibly as an uncertain result). Mirrors AppConfig.maxFollowUpRounds.
MAX_FOLLOWUP_ROUNDS = 2

# How many yes/no questions to ask per follow-up round.
QUESTIONS_PER_ROUND = 3
