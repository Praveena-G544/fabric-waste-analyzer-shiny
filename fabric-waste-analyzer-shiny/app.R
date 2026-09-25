# =========================================================
# app.R
#
# This is the ONLY file you need to click "Run App" on.
#
# Shiny automatically sources every .R file inside the R/
# folder before this file runs, so all the calculation
# functions (calculate_pieces_for_garment, generate_layout_
# options, analyze_waste, suggest_leftover_reuse,
# build_final_recommendation, etc.) are already available here
# -- this file only handles the USER INTERFACE and wires
# button clicks to those functions.
#
# HOW TO RUN:
#   Open this file in RStudio and click the "Run App" button
#   that appears at the top of the editor (or run
#   shiny::runApp() from the console).
# =========================================================

library(shiny)

# The fixed order of wizard "pages" (tabPanel values), used
# for the progress bar and Next/Previous navigation.
STEP_ORDER <- c("fabric", "measurements", "pieces", "layouts", "waste", "reuse", "recommendation")
STEP_LABELS <- c("Fabric", "Measurements", "Pieces", "Layouts", "Waste", "Reuse", "Recommendation")

# ---------------------------------------------------------
# UI
# ---------------------------------------------------------
ui <- fluidPage(
  tags$head(tags$style(HTML("
    body { background-color: #f6f7f5; }
    .app-title { color: #234f38; font-weight: 700; }
    .app-title span { color: #d98e3c; }
    .notice-box {
      background: #fff7e8; border: 1px solid #f0d9a8; border-radius: 8px;
      padding: 12px 16px; font-size: 0.88rem; color: #6b5019; margin-bottom: 16px;
    }
    .stat-box {
      background: #f2f6f3; border-radius: 8px; padding: 12px; text-align: center; margin-bottom: 8px;
    }
    .stat-box .value { font-size: 1.3rem; font-weight: 700; color: #234f38; }
    .stat-box .label { font-size: 0.78rem; color: #6b7a72; }
    .progress-track { display:flex; gap:4px; margin-bottom:6px; }
    .progress-step { flex:1; height:6px; border-radius:4px; background:#dfe6e1; }
    .progress-step.done { background:#2f6f4f; }
    .progress-step.current { background:#d98e3c; }
    .category-badge {
      display:inline-block; padding:4px 14px; border-radius:999px; color:#fff; font-weight:700;
    }
    .btn-primary { background-color:#2f6f4f !important; border-color:#2f6f4f !important; }
    .btn-primary:hover { background-color:#234f38 !important; border-color:#234f38 !important; }
    .hero { text-align:center; padding:30px 10px 10px; }
    .hero h1 { font-size:1.9rem; color:#234f38; margin-bottom:10px; font-weight:700; }
    .hero p { color:#6b7a72; max-width:620px; margin:0 auto 22px; font-size:0.98rem; }
    .card {
      background:#fff; border:1px solid #dfe6e1; border-radius:10px;
      box-shadow:0 2px 10px rgba(0,0,0,0.06); padding:20px 22px; margin-bottom:20px;
    }
    .card h2 { margin-top:0; font-size:1.15rem; color:#234f38; }
    .card-grid { display:grid; grid-template-columns:repeat(auto-fit, minmax(220px,1fr)); gap:18px; margin-top:10px; }
    .feature-item strong { color:#234f38; }
    .feature-item p { font-size:0.88rem; color:#6b7a72; margin:4px 0 0; }
    .btn-row { display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:10px; margin-top:6px; }
  "))),

  titlePanel(div(class = "app-title", HTML("🧵 Fabric<span>Waste</span>Analyzer"))),

  fluidRow(
    column(12,
      actionLink("navHome", "Home", style = "margin-right:16px;"),
      actionLink("navAbout", "Help / About")
    )
  ),
  br(),

  uiOutput("progressBar"),

  tabsetPanel(
    id = "wizard", type = "hidden",

    # ---------------- HOME ----------------
    tabPanel("home",
      div(class = "hero",
        h1("Smart Fabric Cutting & Waste Reduction System"),
        p("A decision-support tool for tailors and small clothing businesses. Enter your fabric size ",
          "and customer measurements, and this system will estimate garment piece sizes, generate ",
          "simplified cutting layouts, compare them, and recommend the option with the best estimated ",
          "fabric utilization."),
        actionButton("startBtn", "Start New Analysis \u2192", class = "btn-primary"),
        actionButton("goAboutBtn", "How does this work?")
      ),

      div(class = "notice-box",
        strong("Important: "),
        "This tool provides an approximate, educational cutting-layout analysis. It does not replace ",
        "a professional tailor's pattern-making, and does not account for fabric grain direction, seam ",
        "allowance nuances, or industrial nesting software. Always verify the actual pattern before cutting."
      ),

      div(class = "card",
        h2("What this system does"),
        div(class = "card-grid",
          div(class = "feature-item", strong("1. Fabric Details"),
              p("Enter the length, width and unit of the fabric you have available.")),
          div(class = "feature-item", strong("2. Measurements & Pieces"),
              p("Enter customer measurements; the system derives approximate garment piece sizes.")),
          div(class = "feature-item", strong("3. Layout Generation"),
              p("Three simplified cutting layouts are generated dynamically from your actual numbers, with a rotation comparison.")),
          div(class = "feature-item", strong("4. Waste, Reuse & Recommendation"),
              p("See utilization/waste percentages, leftover-fabric reuse ideas, and the final recommended layout."))
        )
      ),

      div(class = "card",
        h2("Ready to begin?"),
        p("Your progress is kept as you move through the steps in this session. You can go back and edit any step at any time.",
          style = "color:#6b7a72;font-size:0.9rem;"),
        div(class = "btn-row",
          actionButton("resetBtn", "Start Over / Clear Saved Data"),
          actionButton("startBtn2", "Next: Fabric Details \u2192", class = "btn-primary")
        )
      )
    ),

    # ---------------- FABRIC ----------------
    tabPanel("fabric",
      h3("Step 1 \u2014 Fabric Details"),
      p("Enter the dimensions of the fabric piece/roll you actually have."),
      fluidRow(
        column(3, numericInput("fabricLength", "Fabric Length", value = 300, min = 1)),
        column(3, numericInput("fabricWidth", "Fabric Width", value = 150, min = 1)),
        column(3, selectInput("fabricUnit", "Unit", choices = c("cm", "m", "inch"))),
        column(3, numericInput("fabricRolls", "Number of Pieces/Rolls", value = 1, min = 1))
      ),
      textOutput("fabricError"),
      uiOutput("fabricResultUI"),
      fluidRow(
        column(6, actionButton("fabricPrev", "\u2190 Back to Home")),
        column(6, div(style = "text-align:right;", actionButton("fabricNext", "Next: Measurements \u2192", class = "btn-primary")))
      )
    ),

    # ---------------- MEASUREMENTS ----------------
    tabPanel("measurements",
      h3("Step 2 \u2014 Garment & Customer Measurements"),
      p("Choose the garment type first; only the relevant fields are shown."),
      fluidRow(
        column(4, selectInput("garmentType", "Garment Type", choices = c("shirt", "pant"))),
        column(4, numericInput("quantity", "Quantity", value = 1, min = 1))
      ),
      conditionalPanel(condition = "input.garmentType == 'shirt'",
        fluidRow(
          column(4, numericInput("m_chest", "Chest (cm)", value = 90, min = 1)),
          column(4, numericInput("m_shoulder", "Shoulder (cm)", value = 45, min = 1)),
          column(4, numericInput("m_shirtLength", "Shirt Length (cm)", value = 70, min = 1))
        ),
        fluidRow(
          column(4, numericInput("m_sleeveLength", "Sleeve Length (cm)", value = 60, min = 1)),
          column(4, numericInput("m_armCirc", "Arm Circumference (cm)", value = 30, min = 1)),
          column(4, numericInput("m_neck", "Neck (cm)", value = 38, min = 1))
        )
      ),
      conditionalPanel(condition = "input.garmentType == 'pant'",
        fluidRow(
          column(4, numericInput("m_waist", "Waist (cm)", value = 80, min = 1)),
          column(4, numericInput("m_hip", "Hip (cm)", value = 95, min = 1)),
          column(4, numericInput("m_pantLength", "Pant Length (cm)", value = 100, min = 1))
        ),
        fluidRow(
          column(4, numericInput("m_inseam", "Inseam (cm)", value = 75, min = 1)),
          column(4, numericInput("m_thigh", "Thigh Circumference (cm)", value = 55, min = 1))
        )
      ),
      div(class = "notice-box",
        "These measurement-to-pattern formulas are simplified educational project ",
        "formulas, not professional tailoring standards."
      ),
      fluidRow(
        column(6, actionButton("measurementsPrev", "\u2190 Back")),
        column(6, div(style = "text-align:right;", actionButton("measurementsNext", "Next: Garment Pieces \u2192", class = "btn-primary")))
      )
    ),

    # ---------------- PIECES ----------------
    tabPanel("pieces",
      h3("Step 3 \u2014 Approximate Garment Pieces"),
      p("Derived automatically from your measurements. Edit any value below if needed."),
      actionButton("recalcPiecesBtn", "Recalculate from Measurements"),
      br(), br(),
      uiOutput("pieceEditorUI"),
      actionButton("addPieceBtn", "+ Add Blank Piece"),
      hr(),
      h4("Optional: Upload CSV Instead"),
      p("Columns required: piece_name, length, width, quantity, rotation_allowed"),
      fileInput("csvFile", "Choose CSV file", accept = ".csv"),
      textOutput("csvMessage"),
      hr(),
      h4("Secondary Piece Statistics"),
      uiOutput("pieceStatsUI"),
      fluidRow(
        column(6, actionButton("piecesPrev", "\u2190 Back")),
        column(6, div(style = "text-align:right;", actionButton("piecesNext", "Next: Generate Layouts \u2192", class = "btn-primary")))
      )
    ),

    # ---------------- LAYOUTS ----------------
    tabPanel("layouts",
      h3("Step 4 \u2014 Cutting Layout Options"),
      actionButton("generateLayoutsBtn", "Generate Layouts", class = "btn-primary"),
      textOutput("layoutsError"),
      br(),
      uiOutput("layoutChoiceUI"),
      plotOutput("layoutPlot", height = "420px"),
      uiOutput("layoutStatsUI"),
      hr(),
      h4("Rotation Analysis"),
      tableOutput("rotationTable"),
      textOutput("rotationConclusion"),
      fluidRow(
        column(6, actionButton("layoutsPrev", "\u2190 Back")),
        column(6, div(style = "text-align:right;", actionButton("layoutsNext", "Next: Waste Analysis \u2192", class = "btn-primary")))
      )
    ),

    # ---------------- WASTE ----------------
    tabPanel("waste",
      h3("Step 5 \u2014 Waste & Utilization Analysis"),
      p("This uses the recommended layout from the previous step."),
      actionButton("analyzeWasteBtn", "Analyze Waste", class = "btn-primary"),
      textOutput("wasteError"),
      br(),
      uiOutput("wasteStatsUI"),
      tags$table(class = "table",
        tags$thead(tags$tr(tags$th("Category"), tags$th("Utilization Range"))),
        tags$tbody(
          tags$tr(tags$td("Excellent"), tags$td("90% \u2013 100%")),
          tags$tr(tags$td("Good"), tags$td("75% \u2013 89%")),
          tags$tr(tags$td("Moderate"), tags$td("50% \u2013 74%")),
          tags$tr(tags$td("High Waste"), tags$td("Below 50%"))
        )
      ),
      p(em("These categories are project-defined, not official industry standards.")),
      fluidRow(
        column(6, actionButton("wastePrev", "\u2190 Back")),
        column(6, div(style = "text-align:right;", actionButton("wasteNext", "Next: Reuse Suggestions \u2192", class = "btn-primary")))
      )
    ),

    # ---------------- REUSE ----------------
    tabPanel("reuse",
      h3("Step 6 \u2014 Leftover Fabric Reuse Suggestions"),
      actionButton("reuseBtn", "Get Reuse Suggestions", class = "btn-primary"),
      textOutput("reuseError"),
      br(),
      uiOutput("reuseStatsUI"),
      uiOutput("reuseListUI"),
      p(em("Possible reuse suggestions based on approximate dimensions only \u2014 not a guarantee.")),
      fluidRow(
        column(6, actionButton("reusePrev", "\u2190 Back")),
        column(6, div(style = "text-align:right;", actionButton("reuseNext", "Next: Final Recommendation \u2192", class = "btn-primary")))
      )
    ),

    # ---------------- RECOMMENDATION ----------------
    tabPanel("recommendation",
      h3("Step 7 \u2014 Final Fabric Cutting Recommendation"),
      actionButton("recommendBtn", "Generate Final Recommendation", class = "btn-primary"),
      textOutput("recError"),
      br(),
      uiOutput("recStatsUI"),
      uiOutput("recSummaryUI"),
      plotOutput("recPlot", height = "420px"),
      div(class = "notice-box",
        "This system provides an approximate educational cutting-layout analysis and ",
        "decision-support recommendation. Verify the actual pattern and fabric-grain ",
        "direction before cutting."
      ),
      fluidRow(
        column(6, actionButton("recPrev", "\u2190 Back")),
        column(6, div(style = "text-align:right;", actionButton("recHome", "Finish / Back to Home")))
      )
    ),

    # ---------------- ABOUT ----------------
    tabPanel("about",
      h3("About This Project"),
      p("Fabric Waste Analyzer is a decision-support Shiny app built for a college ",
        "Advanced Mini Project. It helps tailors and small clothing businesses estimate ",
        "how efficiently a piece of fabric can be cut into garment pieces."),
      h4("Limitations (read before your viva)"),
      tags$ul(
        tags$li("Piece-size formulas are simplified educational approximations."),
        tags$li("The layout algorithm is a simplified shelf-packing method, not industrial nesting software."),
        tags$li("Fabric grain, stretch, and pattern matching are not modeled."),
        tags$li("Factorial 'arrangement possibilities' is an illustrative statistic only."),
        tags$li("Efficiency categories are project-defined, not official standards.")
      ),
      actionButton("aboutBackBtn", "\u2190 Back")
    )
  )
)

# ---------------------------------------------------------
# SERVER
# ---------------------------------------------------------
server <- function(input, output, session) {

  # rv holds everything computed so far, so later steps can use
  # results from earlier steps (this replaces the browser
  # localStorage used in the HTML/JS version).
  rv <- reactiveValues(
    fabric = NULL,       # list(lengthCm, widthCm, rolls, areaPerPieceM2, totalAreaM2)
    pieces = list(),      # list of piece lists
    layoutData = NULL,    # list(fabricWidth, fabricLength, layouts, recommendedLayoutId)
    wasteResult = NULL,
    reuseResult = NULL
  )

  # ---------- Navigation helpers ----------
  go_to <- function(step) updateTabsetPanel(session, "wizard", selected = step)

  observeEvent(input$navHome, go_to("home"))
  observeEvent(input$navAbout, go_to("about"))
  observeEvent(input$aboutBackBtn, go_to("home"))
  observeEvent(input$startBtn, go_to("fabric"))
  observeEvent(input$startBtn2, go_to("fabric"))
  observeEvent(input$goAboutBtn, go_to("about"))
  observeEvent(input$resetBtn, {
    rv$fabric <- NULL
    rv$pieces <- list()
    rv$layoutData <- NULL
    rv$wasteResult <- NULL
    rv$reuseResult <- NULL
    rv$recommendation <- NULL
    showNotification("Cleared. Ready to start a fresh analysis.", type = "message")
  })
  observeEvent(input$fabricPrev, go_to("home"))
  observeEvent(input$measurementsPrev, go_to("fabric"))
  observeEvent(input$piecesPrev, go_to("measurements"))
  observeEvent(input$layoutsPrev, go_to("pieces"))
  observeEvent(input$wastePrev, go_to("layouts"))
  observeEvent(input$reusePrev, go_to("waste"))
  observeEvent(input$recPrev, go_to("reuse"))
  observeEvent(input$recHome, go_to("home"))

  output$progressBar <- renderUI({
    current <- input$wizard
    if (!(current %in% STEP_ORDER)) return(NULL)
    idx <- match(current, STEP_ORDER)
    steps <- lapply(seq_along(STEP_ORDER), function(i) {
      cls <- "progress-step"
      if (i < idx) cls <- paste(cls, "done")
      if (i == idx) cls <- paste(cls, "current")
      div(class = cls)
    })
    tagList(
      div(class = "progress-track", steps),
      div(style = "font-size:0.8rem;color:#6b7a72;",
          paste0("Step ", idx, " of ", length(STEP_ORDER), ": ", STEP_LABELS[idx]))
    )
  })

  # ---------- STEP 1: Fabric ----------
  observeEvent(input$fabricNext, {
    output$fabricError <- renderText("")
    result <- tryCatch({
      length_cm <- convert_to_cm(input$fabricLength, input$fabricUnit)
      width_cm <- convert_to_cm(input$fabricWidth, input$fabricUnit)
      require_positive_number(length_cm, "fabric length")
      require_positive_number(width_cm, "fabric width")

      area_cm2 <- rectangle_area(length_cm, width_cm)
      area_per_piece_m2 <- round(cm2_to_m2(area_cm2), 3)
      total_area_m2 <- round(area_per_piece_m2 * input$fabricRolls, 3)

      list(lengthCm = length_cm, widthCm = width_cm, rolls = input$fabricRolls,
           areaPerPieceM2 = area_per_piece_m2, totalAreaM2 = total_area_m2)
    }, error = function(e) e)

    if (inherits(result, "error")) {
      output$fabricError <- renderText(paste("Error:", conditionMessage(result)))
      return()
    }
    rv$fabric <- result
    output$fabricResultUI <- renderUI({
      fluidRow(
        column(6, div(class = "stat-box", div(class = "value", result$areaPerPieceM2), div(class = "label", "Area per piece (m\u00b2)"))),
        column(6, div(class = "stat-box", div(class = "value", result$totalAreaM2), div(class = "label", "Total available area (m\u00b2)")))
      )
    })
    go_to("measurements")
  })

  # ---------- STEP 2: Measurements ----------
  observeEvent(input$measurementsNext, {
    if (input$garmentType == "shirt") {
      values <- list(chest = input$m_chest, shoulder = input$m_shoulder, shirtLength = input$m_shirtLength,
                      sleeveLength = input$m_sleeveLength, armCirc = input$m_armCirc, neck = input$m_neck)
    } else {
      values <- list(waist = input$m_waist, hip = input$m_hip, pantLength = input$m_pantLength,
                      inseam = input$m_inseam, thigh = input$m_thigh)
    }
    rv$measurements <- list(garmentType = input$garmentType, quantity = input$quantity, values = values)
    go_to("pieces")
  })

  # ---------- STEP 3: Pieces ----------
  recalc_pieces_from_measurements <- function() {
    req(rv$measurements)
    pieces <- calculate_pieces_for_garment(rv$measurements$garmentType, rv$measurements$quantity, rv$measurements$values)
    pieces <- lapply(pieces, function(p) { p$length <- round(p$length, 1); p$width <- round(p$width, 1); p })
    rv$pieces <- pieces
  }

  observeEvent(input$wizard, {
    if (input$wizard == "pieces" && length(rv$pieces) == 0) recalc_pieces_from_measurements()
  })
  observeEvent(input$recalcPiecesBtn, recalc_pieces_from_measurements())

  observeEvent(input$addPieceBtn, {
    rv$pieces[[length(rv$pieces) + 1]] <- list(name = "New Piece", length = 10, width = 10, quantity = 1, rotationAllowed = TRUE)
  })

  observeEvent(input$csvFile, {
    file <- input$csvFile
    req(file)
    csv_text <- paste(readLines(file$datapath), collapse = "\n")
    result <- parse_and_validate_csv(csv_text)
    if (!result$valid) {
      output$csvMessage <- renderText(paste("CSV problem:", result$message))
    } else {
      rv$pieces <- result$pieces
      output$csvMessage <- renderText(paste("CSV loaded:", length(result$pieces), "piece type(s)"))
    }
  })

  output$pieceEditorUI <- renderUI({
    pieces <- rv$pieces
    if (length(pieces) == 0) return(p("No pieces yet. Click 'Recalculate from Measurements' above."))

    rows <- lapply(seq_along(pieces), function(i) {
      p <- pieces[[i]]
      fluidRow(
        column(3, textInput(paste0("piece_name_", i), NULL, value = p$name)),
        column(2, numericInput(paste0("piece_length_", i), NULL, value = p$length, min = 0.1, step = 0.1)),
        column(2, numericInput(paste0("piece_width_", i), NULL, value = p$width, min = 0.1, step = 0.1)),
        column(2, numericInput(paste0("piece_qty_", i), NULL, value = p$quantity, min = 1, step = 1)),
        column(3, selectInput(paste0("piece_rot_", i), NULL, choices = c("Yes", "No"),
                               selected = if (isTRUE(p$rotationAllowed)) "Yes" else "No"))
      )
    })
    tagList(
      fluidRow(column(3, strong("Name")), column(2, strong("Length")), column(2, strong("Width")),
               column(2, strong("Qty")), column(3, strong("Rotation?"))),
      rows
    )
  })

  # Read the current values out of the dynamic inputs back into rv$pieces.
  save_piece_edits <- function() {
    n <- length(rv$pieces)
    if (n == 0) return(invisible())
    updated <- lapply(seq_len(n), function(i) {
      list(
        name = input[[paste0("piece_name_", i)]],
        length = input[[paste0("piece_length_", i)]],
        width = input[[paste0("piece_width_", i)]],
        quantity = as.integer(input[[paste0("piece_qty_", i)]]),
        rotationAllowed = identical(input[[paste0("piece_rot_", i)]], "Yes")
      )
    })
    rv$pieces <- updated
  }

  output$pieceStatsUI <- renderUI({
    pieces <- rv$pieces
    if (length(pieces) == 0) return(NULL)
    quantities <- sapply(pieces, function(p) p$quantity)
    stats <- even_odd_summary(quantities)
    arrangements <- factorial_arrangements(stats$totalPieceTypes)
    fluidRow(
      column(3, div(class = "stat-box", div(class = "value", stats$totalPieceTypes), div(class = "label", "Total piece types"))),
      column(3, div(class = "stat-box", div(class = "value", stats$evenQuantities), div(class = "label", "Even quantities"))),
      column(3, div(class = "stat-box", div(class = "value", stats$oddQuantities), div(class = "label", "Odd quantities"))),
      column(3, div(class = "stat-box", div(class = "value", arrangements), div(class = "label", "Arrangements (n!)")))
    )
  })

  observeEvent(input$piecesNext, {
    save_piece_edits()
    if (length(rv$pieces) == 0) return()
    go_to("layouts")
  })

  # ---------- STEP 4: Layouts ----------
  layoutChoiceIndex <- reactiveVal(1)

  observeEvent(input$generateLayoutsBtn, {
    output$layoutsError <- renderText("")
    result <- tryCatch({
      if (is.null(rv$fabric)) stop("Please complete the Fabric Details step first.")
      if (length(rv$pieces) == 0) stop("Please add at least one garment piece first.")
      generate_layout_options(rv$pieces, rv$fabric$widthCm, rv$fabric$lengthCm)
    }, error = function(e) e)

    if (inherits(result, "error")) {
      output$layoutsError <- renderText(paste("Error:", conditionMessage(result)))
      return()
    }
    rv$layoutData <- result
    layoutChoiceIndex(1)
  })

  # Auto-generate the first time the user reaches this tab, if not done yet.
  observeEvent(input$wizard, {
    if (input$wizard == "layouts" && is.null(rv$layoutData) && length(rv$pieces) > 0) {
      rv$layoutData <- generate_layout_options(rv$pieces, rv$fabric$widthCm, rv$fabric$lengthCm)
    }
  })

  output$layoutChoiceUI <- renderUI({
    req(rv$layoutData)
    labels <- sapply(rv$layoutData$layouts, function(l) {
      star <- if (l$id == rv$layoutData$recommendedLayoutId) " \u2605" else ""
      paste0(l$name, star)
    })
    radioButtons("layoutChoice", "View Layout:", choices = setNames(seq_along(labels), labels), inline = TRUE)
  })

  output$layoutPlot <- renderPlot({
    req(rv$layoutData, input$layoutChoice)
    layout <- rv$layoutData$layouts[[as.integer(input$layoutChoice)]]
    draw_layout_diagram(layout, rv$layoutData$fabricWidth, rv$layoutData$fabricLength)
  })

  output$layoutStatsUI <- renderUI({
    req(rv$layoutData, input$layoutChoice)
    layout <- rv$layoutData$layouts[[as.integer(input$layoutChoice)]]
    fluidRow(
      column(2, div(class = "stat-box", div(class = "value", layout$usedAreaM2), div(class = "label", "Used (m\u00b2)"))),
      column(2, div(class = "stat-box", div(class = "value", layout$leftoverAreaM2), div(class = "label", "Leftover (m\u00b2)"))),
      column(3, div(class = "stat-box", div(class = "value", paste0(layout$utilizationPercent, "%")), div(class = "label", "Utilization"))),
      column(3, div(class = "stat-box", div(class = "value", paste0(layout$wastePercent, "%")), div(class = "label", "Waste"))),
      column(2, div(class = "stat-box", div(class = "value", layout$unfittedCount), div(class = "label", "Didn't fit")))
    )
  })

  output$rotationTable <- renderTable({
    req(rv$layoutData)
    do.call(rbind, lapply(rv$layoutData$layouts, function(l) {
      data.frame(
        Layout = paste0(l$name, if (l$id == rv$layoutData$recommendedLayoutId) " (recommended)" else ""),
        Utilization = paste0(l$utilizationPercent, "%"),
        Waste = paste0(l$wastePercent, "%")
      )
    }))
  })

  output$rotationConclusion <- renderText({
    req(rv$layoutData)
    best <- find_layout_by_id(rv$layoutData$layouts, rv$layoutData$recommendedLayoutId)
    paste0(best$name, " gives the best estimated utilization (", best$utilizationPercent, "%).")
  })

  observeEvent(input$layoutsNext, {
    req(rv$layoutData)
    go_to("waste")
  })

  # ---------- STEP 5: Waste ----------
  run_waste_analysis <- function() {
    req(rv$layoutData, rv$fabric)
    recommended <- find_layout_by_id(rv$layoutData$layouts, rv$layoutData$recommendedLayoutId)
    rv$wasteResult <- analyze_waste(rv$fabric$totalAreaM2, recommended$usedAreaM2)
  }

  observeEvent(input$analyzeWasteBtn, run_waste_analysis())
  observeEvent(input$wizard, {
    if (input$wizard == "waste" && is.null(rv$wasteResult) && !is.null(rv$layoutData)) run_waste_analysis()
  })

  output$wasteStatsUI <- renderUI({
    req(rv$wasteResult)
    w <- rv$wasteResult
    badge_color <- switch(w$category, "Excellent" = "#2f6f4f", "Good" = "#4c8c66",
                           "Moderate" = "#d98e3c", "High Waste" = "#c0392b", "#6b7a72")
    tagList(
      fluidRow(
        column(2, div(class = "stat-box", div(class = "value", w$availableM2), div(class = "label", "Available (m\u00b2)"))),
        column(2, div(class = "stat-box", div(class = "value", w$usedM2), div(class = "label", "Used (m\u00b2)"))),
        column(2, div(class = "stat-box", div(class = "value", w$leftoverM2), div(class = "label", "Leftover (m\u00b2)"))),
        column(3, div(class = "stat-box", div(class = "value", paste0(w$utilizationPercent, "%")), div(class = "label", "Utilization"))),
        column(3, div(class = "stat-box", div(class = "value", paste0(w$wastePercent, "%")), div(class = "label", "Waste")))
      ),
      span(class = "category-badge", style = paste0("background:", badge_color, ";"), toupper(w$category))
    )
  })

  observeEvent(input$wasteNext, { req(rv$wasteResult); go_to("reuse") })

  # ---------- STEP 6: Reuse ----------
  run_reuse_suggestions <- function() {
    req(rv$layoutData)
    recommended <- find_layout_by_id(rv$layoutData$layouts, rv$layoutData$recommendedLayoutId)
    leftover_length <- max(0, rv$layoutData$fabricLength - recommended$usedHeightCm)
    leftover_width <- rv$layoutData$fabricWidth
    rv$reuseResult <- suggest_leftover_reuse(leftover_length, leftover_width)
  }

  observeEvent(input$reuseBtn, run_reuse_suggestions())
  observeEvent(input$wizard, {
    if (input$wizard == "reuse" && is.null(rv$reuseResult) && !is.null(rv$layoutData)) run_reuse_suggestions()
  })

  output$reuseStatsUI <- renderUI({
    req(rv$reuseResult)
    r <- rv$reuseResult
    fluidRow(
      column(6, div(class = "stat-box", div(class = "value", paste0(r$leftoverLengthCm, " cm")), div(class = "label", "Leftover Length"))),
      column(6, div(class = "stat-box", div(class = "value", paste0(r$leftoverWidthCm, " cm")), div(class = "label", "Leftover Width")))
    )
  })

  output$reuseListUI <- renderUI({
    req(rv$reuseResult)
    tags$ul(lapply(rv$reuseResult$suggestions, tags$li))
  })

  observeEvent(input$reuseNext, { req(rv$reuseResult); go_to("recommendation") })

  # ---------- STEP 7: Recommendation ----------
  run_recommendation <- function() {
    req(rv$layoutData, rv$wasteResult, rv$reuseResult)
    rv$recommendation <- build_final_recommendation(
      rv$layoutData$layouts, rv$layoutData$recommendedLayoutId, rv$wasteResult, rv$reuseResult
    )
  }

  observeEvent(input$recommendBtn, run_recommendation())
  observeEvent(input$wizard, {
    if (input$wizard == "recommendation" && !is.null(rv$layoutData) && !is.null(rv$wasteResult) && !is.null(rv$reuseResult)) {
      run_recommendation()
    }
  })

  output$recStatsUI <- renderUI({
    req(rv$recommendation)
    r <- rv$recommendation
    fluidRow(
      column(2, div(class = "stat-box", div(class = "value", r$availableM2), div(class = "label", "Available (m\u00b2)"))),
      column(2, div(class = "stat-box", div(class = "value", r$usedM2), div(class = "label", "Used (m\u00b2)"))),
      column(2, div(class = "stat-box", div(class = "value", r$leftoverM2), div(class = "label", "Leftover (m\u00b2)"))),
      column(3, div(class = "stat-box", div(class = "value", paste0(r$utilizationPercent, "%")), div(class = "label", "Utilization"))),
      column(3, div(class = "stat-box", div(class = "value", paste0(r$wastePercent, "%")), div(class = "label", "Waste")))
    )
  })

  output$recSummaryUI <- renderUI({
    req(rv$recommendation)
    r <- rv$recommendation
    tagList(
      h4(paste("Recommended Layout:", r$recommendedLayoutName)),
      p(r$reason),
      div(class = "notice-box", strong("Leftover Fabric Suggestion: "), r$reuseSummary)
    )
  })

  output$recPlot <- renderPlot({
    req(rv$layoutData, rv$recommendation)
    layout <- find_layout_by_id(rv$layoutData$layouts, rv$recommendation$recommendedLayoutId)
    draw_layout_diagram(layout, rv$layoutData$fabricWidth, rv$layoutData$fabricLength)
  })
}

shinyApp(ui, server)
