# =========================================================
# recommendation_engine.R
#
# Combines the outputs of the other modules (layouts, waste,
# reuse) into the single summary shown on the final
# Recommendation tab.
# =========================================================

build_final_recommendation <- function(layouts, recommended_layout_id, waste_result, reuse_result) {
  best_layout <- find_layout_by_id(layouts, recommended_layout_id)
  reason <- build_comparison_reason(layouts, recommended_layout_id)

  reuse_summary <- paste0(
    "The remaining fabric (approximately ", reuse_result$leftoverLengthCm, " x ",
    reuse_result$leftoverWidthCm, " cm) may be suitable for: ",
    paste(unlist(reuse_result$suggestions), collapse = ", "), "."
  )

  list(
    availableM2 = waste_result$availableM2,
    usedM2 = waste_result$usedM2,
    leftoverM2 = waste_result$leftoverM2,
    utilizationPercent = waste_result$utilizationPercent,
    wastePercent = waste_result$wastePercent,
    category = waste_result$category,
    recommendedLayoutId = best_layout$id,
    recommendedLayoutName = best_layout$name,
    reason = reason,
    reuseSummary = reuse_summary,
    disclaimer = paste(
      "This system provides an approximate educational cutting-layout",
      "analysis and decision-support recommendation. Verify the actual",
      "pattern and fabric-grain direction before cutting."
    )
  )
}
