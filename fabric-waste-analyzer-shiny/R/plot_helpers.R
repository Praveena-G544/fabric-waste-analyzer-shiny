# =========================================================
# plot_helpers.R
#
# Draws the cutting-layout diagram using BASE R graphics
# (no extra plotting package needed). This is the visual
# equivalent of the fabric boundary + garment pieces +
# leftover-area diagram described in the project brief -- but
# drawn with rect()/text() instead of SVG, since we're inside
# an R Shiny app now.
#
# Coordinate note: the packing algorithm in layout_generator.R
# places pieces with y = 0 at the START of the fabric (top of
# the roll) and y increasing as rows are added. Base R plots
# put y = 0 at the BOTTOM of the plot, so we flip the y-axis
# here purely for drawing purposes.
# =========================================================

draw_layout_diagram <- function(layout, fabric_width, fabric_length) {
  # Blank plot with the fabric's real-world proportions (asp = 1
  # keeps 1 cm the same visual size horizontally and vertically,
  # so the diagram isn't stretched/misleading).
  plot(
    NA, NA,
    xlim = c(0, fabric_width), ylim = c(0, fabric_length), asp = 1,
    xlab = "Fabric Width (cm)", ylab = "Fabric Length (cm)",
    main = layout$name
  )

  # 1. Leftover fabric region (drawn first, as a background strip)
  used_height <- layout$usedHeightCm
  if (used_height < fabric_length) {
    leftover_height <- fabric_length - used_height
    rect(0, 0, fabric_width, leftover_height, col = "#f6e6d5", border = "#d98e3c", lty = 2)
    text(fabric_width / 2, leftover_height / 2, "LEFTOVER FABRIC AREA", cex = 0.75, col = "#6b5019")
  }

  # 2. Fabric outer boundary
  rect(0, 0, fabric_width, fabric_length, border = "#234f38", lwd = 2)

  # 3. Each placed garment piece
  for (p in layout$placements) {
    y_bottom <- fabric_length - (p$y + p$l) # flip to plot coordinates
    y_top <- fabric_length - p$y

    is_rotated <- identical(p$orientation, "rotated")
    fill_col <- if (is_rotated) "#d8e8f0" else "#cfe3d6"
    border_col <- if (is_rotated) "#3b7ea1" else "#2f6f4f"

    rect(p$x, y_bottom, p$x + p$w, y_top, col = fill_col, border = border_col)

    if (p$w > 12 && p$l > 8) {
      label <- paste0(p$name, "\n", p$l, "x", p$w)
      text(p$x + p$w / 2, y_bottom + p$l / 2, labels = label, cex = 0.6)
    }
  }

  # 4. Note how many pieces (if any) could not be fitted
  if (layout$unfittedCount > 0) {
    mtext(paste0(layout$unfittedCount, " piece(s) could not be fitted on this fabric size"),
          side = 1, line = 4, col = "#c0392b", cex = 0.8)
  }
}
