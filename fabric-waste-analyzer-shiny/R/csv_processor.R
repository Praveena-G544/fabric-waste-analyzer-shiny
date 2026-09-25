# =========================================================
# csv_processor.R
#
# Handles the OPTIONAL CSV upload feature. The main app works
# completely without this -- it's an alternative way to supply
# the garment-piece list.
#
# Expected columns: piece_name, length, width, quantity, rotation_allowed
# =========================================================

REQUIRED_CSV_COLUMNS <- c("piece_name", "length", "width", "quantity", "rotation_allowed")

#' Parse and validate CSV text.
parse_and_validate_csv <- function(csv_text) {
  df <- tryCatch(
    read.csv(text = csv_text, stringsAsFactors = FALSE),
    error = function(e) NULL
  )

  if (is.null(df)) {
    return(list(valid = FALSE, message = "The file could not be read as CSV.", pieces = list()))
  }

  missing_cols <- setdiff(REQUIRED_CSV_COLUMNS, names(df))
  if (length(missing_cols) > 0) {
    return(list(
      valid = FALSE,
      message = paste0("Missing required column(s): ", paste(missing_cols, collapse = ", ")),
      pieces = list()
    ))
  }

  if (nrow(df) == 0) {
    return(list(valid = FALSE, message = "The CSV file has no data rows.", pieces = list()))
  }

  pieces <- list()
  for (i in seq_len(nrow(df))) {
    row <- df[i, ]

    length_val <- suppressWarnings(as.numeric(row$length))
    width_val <- suppressWarnings(as.numeric(row$width))
    qty_val <- suppressWarnings(as.integer(row$quantity))

    if (is.na(length_val) || is.na(width_val) || is.na(qty_val) ||
        length_val <= 0 || width_val <= 0 || qty_val <= 0) {
      return(list(
        valid = FALSE,
        message = paste0("Row ", i, " has an invalid length/width/quantity value."),
        pieces = list()
      ))
    }

    rotation_text <- tolower(trimws(as.character(row$rotation_allowed)))
    rotation_allowed <- rotation_text %in% c("yes", "true", "1")

    pieces[[length(pieces) + 1]] <- list(
      name = as.character(row$piece_name),
      length = length_val,
      width = width_val,
      quantity = qty_val,
      rotationAllowed = rotation_allowed
    )
  }

  list(valid = TRUE, message = "OK", pieces = pieces)
}
