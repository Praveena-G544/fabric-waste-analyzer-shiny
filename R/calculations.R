# =========================================================
# calculations.R
#
# Fundamental, reusable math formulas used across the app.
# =========================================================

#' Rectangle area formula: Area = Length x Width
rectangle_area <- function(length, width) {
  length * width
}

#' Convert an area in square centimeters into square meters.
cm2_to_m2 <- function(area_cm2) {
  area_cm2 / 10000
}

#' Utilization % = (Used Area / Available Area) x 100
utilization_percent <- function(used_area, available_area) {
  if (available_area <= 0) return(0)
  round((used_area / available_area) * 100, 2)
}

#' Waste % = (Leftover Area / Available Area) x 100
waste_percent <- function(leftover_area, available_area) {
  if (available_area <= 0) return(0)
  round((leftover_area / available_area) * 100, 2)
}

#' Simplified "arrangement possibilities" statistic.
#' Example: 4 piece groups -> 4! = 24 possible orderings.
#' This is an illustrative educational statistic, not a
#' solution to professional fabric nesting.
factorial_arrangements <- function(n) {
  if (n <= 1) return(1)
  factorial(n)
}

#' Even/Odd quantity statistic across a list of piece
#' quantities. A secondary, non-major statistic.
even_odd_summary <- function(quantities) {
  is_even <- (quantities %% 2 == 0)
  list(
    totalPieceTypes = length(quantities),
    evenQuantities = sum(is_even),
    oddQuantities = sum(!is_even)
  )
}

#' Classify a utilization percentage into a project-defined
#' efficiency category (not an official industry standard).
efficiency_category <- function(utilization_pct) {
  if (utilization_pct >= 90) return("Excellent")
  if (utilization_pct >= 75) return("Good")
  if (utilization_pct >= 50) return("Moderate")
  return("High Waste")
}
