# =========================================================
# validation.R
#
# Small, reusable input-checking functions used across the
# app. Shiny automatically sources every file in R/ before
# running app.R, so these functions are available everywhere
# without any manual source() calls.
# =========================================================

#' Check that a value is a single positive number.
is_positive_number <- function(x) {
  is.numeric(x) && length(x) == 1 && !is.na(x) && x > 0
}

#' Stop with a clear error message if a value is not a
#' positive number.
require_positive_number <- function(x, label) {
  if (!is_positive_number(x)) {
    stop(paste0("'", label, "' must be a positive number. Received: ", x))
  }
}

#' Convert a length/width value from the given unit into
#' centimeters, so every calculation works in one consistent
#' unit (cm).
convert_to_cm <- function(value, unit) {
  if (unit == "cm") return(value)
  if (unit == "m") return(value * 100)
  if (unit == "inch") return(value * 2.54)
  stop(paste0("Unsupported unit: ", unit))
}
