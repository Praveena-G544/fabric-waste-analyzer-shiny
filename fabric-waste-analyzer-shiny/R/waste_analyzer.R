# =========================================================
# waste_analyzer.R
#
# Produces the numbers shown on the "Waste Analysis" tab:
# available area, used area, leftover area, utilization %,
# waste %, and the project-defined efficiency category.
# =========================================================

analyze_waste <- function(total_area_m2, used_area_m2) {
  leftover_m2 <- round(total_area_m2 - used_area_m2, 3)
  utilization_pct <- utilization_percent(used_area_m2, total_area_m2)
  waste_pct <- waste_percent(leftover_m2, total_area_m2)
  category <- efficiency_category(utilization_pct)

  list(
    availableM2 = round(total_area_m2, 3),
    usedM2 = round(used_area_m2, 3),
    leftoverM2 = leftover_m2,
    utilizationPercent = utilization_pct,
    wastePercent = waste_pct,
    category = category
  )
}
