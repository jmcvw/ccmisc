cc_palette <- c(
  psd_blue = '#1b3445',
  student1 = '#38b0e3',
  students2 = '#50a3cd',
  students3 = '#e8f3f9',
  partners1 = '#fad350',
  partners2 = '#e3c375',
  data1 = '#e9415e',
  data2 = '#fef0f2')

usethis::use_data(cc_palette, overwrite = TRUE)


# Documention -------------------------------------------------------------


#' CC corporate colour palette
#'
#' There seems to be some confusion over students 1 and 2, and partners 1 and 2.
#' My understanding is that v1 are the new ones
#' @format Length 8 named vector
#'
#' @examples
#'
#' scales::show_col(cc_palette)
#'
'cc_palette'
