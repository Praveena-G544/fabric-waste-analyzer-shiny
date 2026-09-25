# =========================================================
# reuse_suggestions.R
#
# Simple, rule-based (NOT AI/ML) suggestions for what the
# leftover fabric strip might be reused for, based only on its
# approximate length and width. Illustrative, not a guarantee.
# =========================================================

suggest_leftover_reuse <- function(leftover_length_cm, leftover_width_cm) {
  suggestions <- c()

  if (leftover_length_cm >= 80 && leftover_width_cm >= 30) {
    suggestions <- c(suggestions, "Small accessory bag or apron panel")
  }
  if (leftover_length_cm >= 30 && leftover_width_cm >= 20) {
    suggestions <- c(suggestions, "Pocket")
  }
  if (leftover_length_cm >= 20 && leftover_width_cm >= 15) {
    suggestions <- c(suggestions, "Collar or cuff patch")
  }
  if (leftover_length_cm >= 10 && leftover_width_cm >= 5) {
    suggestions <- c(suggestions, "Belt loop")
  }
  if (leftover_length_cm >= 5 && leftover_width_cm >= 5) {
    suggestions <- c(suggestions, "Fabric patch / applique")
  }

  if (length(suggestions) == 0) {
    suggestions <- c("Scrap too small for the suggestions in this project; consider composting or textile recycling.")
  }

  list(
    leftoverLengthCm = round(leftover_length_cm, 1),
    leftoverWidthCm = round(leftover_width_cm, 1),
    suggestions = as.list(suggestions)
  )
}
