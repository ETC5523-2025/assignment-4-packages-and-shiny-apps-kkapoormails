# Internal helper to declare runtime dependencies so R CMD check
# knows we actually use these packages.
#
# This function is NOT exported, not called by users. It just
# touches symbols from our Imports so that check doesn't complain
# they're "unused".
#
# nocov start
.declare_pkg_dependencies <- function() {
  # dplyr
  dplyr::filter
  dplyr::mutate
  dplyr::select
  dplyr::arrange
  dplyr::slice_max

  # ggplot2
  ggplot2::ggplot
  ggplot2::aes
  ggplot2::geom_line
  ggplot2::geom_point
  ggplot2::labs
  ggplot2::theme_minimal

  # tibble (used for tidy data frames)
  tibble::tibble

  # DT (interactive tables)
  DT::datatable

  # bslib (theming for Shiny)
  bslib::bs_theme

  invisible(NULL)
}
# nocov end
