#' @noRd
mod_cooking_ui <- function(id) {
  ns <- NS(id)
  tags$div(
    id = "pane-cooking",
    class = "content-pane cooking-mode",
    uiOutput(ns("cooking_mode_ui"))
  )
}

#' @noRd
mod_cooking_server <- function(id, rv) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    output$cooking_mode_ui <- renderUI({
      r <- rv$cooking_recipe
      if (is.null(r)) {
        return(tags$p(class = "text-muted", "No recipe selected for cooking."))
      }
      step <- rv$cooking_step
      steps <- r$instructions
      n_steps <- length(steps)
      step_text <- if (step <= n_steps) steps[[step]]$instruction_text else ""
      is_last <- step >= n_steps

      prev_btn <- actionButton(
        ns("cook_prev"),
        "<- Previous",
        class = "btn btn-secondary btn-lg"
      )

      tags$div(
        class = "cooking-wrapper",
        tags$div(
          class = "cooking-header",
          actionButton(
            ns("cook_exit"),
            tagList(tags$i(class = "fas fa-times"), " Exit"),
            class = "btn btn-secondary btn-sm"
          ),
          tags$div(class = "cooking-recipe-title", r$title),
          tags$div(
            class = "cooking-step-badge",
            paste0("Step ", step, " of ", n_steps)
          )
        ),
        tags$div(
          class = "cooking-progress",
          tags$div(
            class = "cooking-progress-fill",
            style = paste0("width:", round(step / n_steps * 100), "%;")
          )
        ),
        tags$div(
          class = "cooking-step-content",
          tags$div(class = "cooking-step-number", paste0("Step ", step)),
          tags$div(class = "cooking-step-text", step_text)
        ),
        tags$div(
          class = "cooking-ingredients",
          tags$ul(
            class = "cooking-ing-list",
            lapply(r$ingredients, function(i) {
              tags$li(
                if (!is.null(i$raw_text) && nzchar(i$raw_text)) i$raw_text else i$ingredient_name
              )
            })
          )
        ),
        tags$div(
          class = "cooking-nav",
          if (step == 1L) shinyjs::disabled(prev_btn) else prev_btn,
          tags$span(class = "cooking-nav-counter", paste0(step, " / ", n_steps)),
          actionButton(
            ns("cook_next"),
            if (is_last) "Done! Finish" else "Next ->",
            class = if (is_last) "btn btn-success btn-lg" else "btn btn-primary btn-lg"
          )
        )
      )
    })

    observeEvent(input$cook_exit, {
      rv$cooking_recipe <- NULL
      rv$cooking_step <- 1L
      shinyjs::runjs("window.recipeR_navigate('browse')")
    })

    observeEvent(input$cook_prev, {
      rv$cooking_step <- max(1L, rv$cooking_step - 1L)
    })

    observeEvent(input$cook_next, {
      r <- rv$cooking_recipe
      if (is.null(r)) return()
      n_steps <- length(r$instructions)
      if (rv$cooking_step >= n_steps) {
        showNotification(
          paste0("You finished cooking '", r$title, "'! Done!"),
          type = "message"
        )
        rv$cooking_recipe <- NULL
        rv$cooking_step <- 1L
        shinyjs::runjs("window.recipeR_navigate('browse')")
      } else {
        rv$cooking_step <- rv$cooking_step + 1L
      }
    })
  })
}
