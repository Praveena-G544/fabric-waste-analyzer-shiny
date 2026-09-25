# =========================================================
# piece_calculator.R
#
# Turns customer body measurements into APPROXIMATE garment
# piece dimensions. These are simplified EDUCATIONAL formulas,
# not professional pattern-drafting standards -- always verify
# real pattern dimensions before cutting actual fabric.
#
# All measurements are expected in centimeters.
# =========================================================

calculate_shirt_pieces <- function(m, quantity) {
  ease <- 5

  list(
    list(name = "Front", length = m$shirtLength, width = (m$chest / 2) + ease,
         quantity = quantity, rotationAllowed = FALSE),
    list(name = "Back", length = m$shirtLength, width = (m$chest / 2) + ease,
         quantity = quantity, rotationAllowed = FALSE),
    list(name = "Sleeve", length = m$sleeveLength, width = (m$armCirc / 2) + 3,
         quantity = quantity * 2, rotationAllowed = TRUE),
    list(name = "Collar", length = m$neck + 5, width = 8,
         quantity = quantity, rotationAllowed = TRUE),
    list(name = "Cuff", length = (m$armCirc / 2) + 2, width = 6,
         quantity = quantity * 2, rotationAllowed = TRUE)
  )
}

calculate_pant_pieces <- function(m, quantity) {
  list(
    list(name = "Front", length = m$pantLength, width = (m$waist / 4) + 5,
         quantity = quantity * 2, rotationAllowed = FALSE),
    list(name = "Back", length = m$pantLength, width = (m$hip / 4) + 6,
         quantity = quantity * 2, rotationAllowed = FALSE),
    list(name = "Pocket", length = 15, width = 12,
         quantity = quantity * 2, rotationAllowed = TRUE),
    list(name = "Waistband", length = m$waist + 5, width = 6,
         quantity = quantity, rotationAllowed = TRUE)
  )
}

#' Main dispatcher used by the app: picks the right calculator
#' based on garment type.
calculate_pieces_for_garment <- function(garment_type, quantity, measurements) {
  if (garment_type == "shirt") {
    calculate_shirt_pieces(measurements, quantity)
  } else if (garment_type == "pant") {
    calculate_pant_pieces(measurements, quantity)
  } else {
    stop(paste0("Unsupported garment type: ", garment_type))
  }
}
