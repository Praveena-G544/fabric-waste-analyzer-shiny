# =========================================================
# layout_generator.R
#
# The heart of the "dynamic cutting layout" feature.
#
# ALGORITHM: simplified "shelf packing" (row/strip packing).
#   1. Pieces are placed left-to-right in a "row" (a shelf).
#   2. When a piece doesn't fit in the remaining row width, a
#      new row starts.
#   3. Row height = the tallest piece placed in that row.
#   4. If rotation is allowed for a piece AND rotating helps
#      it fit better, the algorithm rotates it.
#   5. If a piece cannot fit anywhere, it is recorded as
#      "not fitted" -- this is what makes utilization differ
#      between Layout A/B/C.
#
# This is NOT industrial nesting software -- it is intentionally
# simple so it can be explained and defended in a college viva.
# =========================================================

expand_pieces <- function(pieces) {
  rows <- list()
  for (piece in pieces) {
    for (i in seq_len(piece$quantity)) {
      rows[[length(rows) + 1]] <- list(
        name = piece$name,
        length = piece$length,
        width = piece$width,
        rotationAllowed = isTRUE(piece$rotationAllowed)
      )
    }
  }
  rows
}

pack_shelf_layout <- function(piece_instances, fabric_width, fabric_length, allow_rotation_globally) {
  x_cursor <- 0
  y_cursor <- 0
  row_height <- 0
  fitted_area <- 0
  unfitted_count <- 0
  placements <- list()

  for (piece in piece_instances) {
    L <- piece$length
    W <- piece$width
    can_rotate <- allow_rotation_globally && piece$rotationAllowed

    fits_normal_in_row <- (x_cursor + W) <= fabric_width
    fits_rotated_in_row <- can_rotate && ((x_cursor + L) <= fabric_width)

    if (!fits_normal_in_row && !fits_rotated_in_row) {
      y_cursor <- y_cursor + row_height
      x_cursor <- 0
      row_height <- 0
      fits_normal_in_row <- W <= fabric_width
      fits_rotated_in_row <- can_rotate && (L <= fabric_width)
    }

    use_rotated <- FALSE
    if (fits_rotated_in_row && fits_normal_in_row) {
      use_rotated <- (L < W)
    } else if (fits_rotated_in_row) {
      use_rotated <- TRUE
    } else if (fits_normal_in_row) {
      use_rotated <- FALSE
    } else {
      unfitted_count <- unfitted_count + 1
      next
    }

    piece_w <- if (use_rotated) L else W
    piece_l <- if (use_rotated) W else L

    if ((y_cursor + piece_l) > fabric_length) {
      unfitted_count <- unfitted_count + 1
      next
    }

    placements[[length(placements) + 1]] <- list(
      name = piece$name,
      x = round(x_cursor, 2),
      y = round(y_cursor, 2),
      w = round(piece_w, 2),
      l = round(piece_l, 2),
      orientation = if (use_rotated) "rotated" else "normal"
    )

    fitted_area <- fitted_area + (piece_w * piece_l)
    x_cursor <- x_cursor + piece_w
    row_height <- max(row_height, piece_l)
  }

  used_height <- y_cursor + row_height

  list(
    placements = placements,
    fittedAreaCm2 = fitted_area,
    unfittedCount = unfitted_count,
    usedHeightCm = round(min(used_height, fabric_length), 2)
  )
}

sort_by_area_desc <- function(piece_instances) {
  areas <- sapply(piece_instances, function(p) p$length * p$width)
  piece_instances[order(-areas)]
}

build_layout_option <- function(id, name, piece_instances, fabric_width, fabric_length, allow_rotation) {
  packed <- pack_shelf_layout(piece_instances, fabric_width, fabric_length, allow_rotation)

  fabric_area <- rectangle_area(fabric_length, fabric_width)
  used_area <- packed$fittedAreaCm2
  leftover_area <- fabric_area - used_area

  list(
    id = id,
    name = name,
    placements = packed$placements,
    unfittedCount = packed$unfittedCount,
    usedHeightCm = packed$usedHeightCm,
    usedAreaM2 = round(cm2_to_m2(used_area), 3),
    leftoverAreaM2 = round(cm2_to_m2(leftover_area), 3),
    utilizationPercent = utilization_percent(used_area, fabric_area),
    wastePercent = waste_percent(leftover_area, fabric_area)
  )
}

#' Generate the three simplified layout options:
#'   Layout A - normal orientation only, original piece order
#'   Layout B - rotation allowed where marked, original order
#'   Layout C - rotation allowed, largest pieces packed first
generate_layout_options <- function(pieces, fabric_width, fabric_length) {
  instances <- expand_pieces(pieces)

  layout_a <- build_layout_option("A", "Layout A (Normal Orientation)", instances, fabric_width, fabric_length, allow_rotation = FALSE)
  layout_b <- build_layout_option("B", "Layout B (Rotation Allowed)", instances, fabric_width, fabric_length, allow_rotation = TRUE)
  layout_c <- build_layout_option("C", "Layout C (Largest-First + Rotation)", sort_by_area_desc(instances), fabric_width, fabric_length, allow_rotation = TRUE)

  layouts <- list(layout_a, layout_b, layout_c)
  utilizations <- sapply(layouts, function(l) l$utilizationPercent)
  best_index <- which.max(utilizations)

  list(
    fabricWidth = fabric_width,
    fabricLength = fabric_length,
    layouts = layouts,
    recommendedLayoutId = layouts[[best_index]]$id
  )
}
