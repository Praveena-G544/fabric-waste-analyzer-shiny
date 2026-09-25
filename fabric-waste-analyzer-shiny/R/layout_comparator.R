# =========================================================
# layout_comparator.R
#
# Kept separate from layout_generator.R so the "packing" logic
# and the "comparison" logic can be explained independently in
# the viva.
# =========================================================

rank_layouts_by_utilization <- function(layouts) {
  utilizations <- sapply(layouts, function(l) l$utilizationPercent)
  layouts[order(-utilizations)]
}

find_layout_by_id <- function(layouts, layout_id) {
  for (layout in layouts) {
    if (layout$id == layout_id) return(layout)
  }
  stop(paste0("Layout id not found: ", layout_id))
}

#' Build a short, human-readable comparison sentence.
build_comparison_reason <- function(layouts, best_id) {
  best <- find_layout_by_id(layouts, best_id)
  others <- Filter(function(l) l$id != best_id, layouts)
  other_summary <- paste(
    sapply(others, function(l) paste0(l$name, ": ", l$utilizationPercent, "%")),
    collapse = "; "
  )
  paste0(
    best$name, " provides the highest estimated utilization (",
    best$utilizationPercent, "%) among the tested simplified layouts. ",
    "For comparison, ", other_summary, "."
  )
}
