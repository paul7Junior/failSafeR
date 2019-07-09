t = function(x) {
  # log(-4)
  f = iris %>% group_by(309) %>% summarise(Species)
  # meta_factory('dd')

  x=y # a bad line


  return(x)
}


j = function(x) {
  a = t(x)
  s = ln(-4)
  print(dim('d'))
}


j(3)


badfunc <- function(x) {
  x=y # a bad line
}

badfunc(1)


badderfunc <- function(x) {
  badfunc(x)
}

badfunc <- function(x) {
  # x=y # a bad line
  j(x)
}

badderfunc(1)



data <- data.frame(
  stringsAsFactors = FALSE,
  package = c("processx", "backports", "assertthat", "Matrix",
              "magrittr", "rprojroot", "clisymbols", "prettyunits", "withr",
              "desc", "igraph", "R6", "crayon", "debugme", "digest", "irlba",
              "rcmdcheck", "callr", "pkgconfig", "lattice"),
  dependencies = I(list(
    c("assertthat", "crayon", "debugme", "R6"), character(0),
    character(0), "lattice", character(0), "backports", character(0),
    c("magrittr", "assertthat"), character(0),
    c("assertthat", "R6", "crayon", "rprojroot"),
    c("irlba", "magrittr", "Matrix", "pkgconfig"), character(0),
    character(0), "crayon", character(0), "Matrix",
    c("callr", "clisymbols", "crayon", "desc", "digest", "prettyunits",
      "R6", "rprojroot", "withr"),
    c("processx", "R6"), character(0), character(0)
  ))
)
tree(data, root = "rcmdcheck")



data$label <- paste(data$package,
                    style_dim(paste0("(", c("2.0.0.1", "1.1.1", "0.2.0", "1.2-11",
                                            "1.5", "1.2", "1.2.0", "1.0.2", "2.0.0", "1.1.1.9000", "1.1.2",
                                            "2.2.2", "1.3.4", "1.0.2", "0.6.12", "2.2.1", "1.2.1.9002",
                                            "1.0.0.9000", "2.0.1", "0.20-35"), ")"))
)
roots <- ! data$package %in% unlist(data$dependencies)
data$label[roots] <- col_cyan(style_italic(data$label[roots]))
tree(data, root = "rcmdcheck")



eee = function (left = "", center = "", right = "", line = 1, col = NULL,
          line_col = col, background_col = NULL, width = console_width())
{
  assert_that(is_string(left), is_string(center), is_string(right),
              is_string(line) || line == 1 || line == 2, is_col(col),
              is_col(line_col), is_count(width))
  left <- apply_style(left, col)
  center <- apply_style(center, col)
  right <- apply_style(right, col)
  options <- as.list(environment())
  options$line <- get_line_char(options$line)
  res <- if (nchar(center)) {
    if (nchar(left) || nchar(right)) {
      stop(sQuote("center"), " cannot be specified with ",
           sQuote("left"), " or ", sQuote("right"))
    }
    rule_center(options)
  }
  else if (nchar(left) && nchar(right)) {
    rule_left_right(options)
  }
  else if (nchar(left)) {
    rule_left(options)
  }
  else if (nchar(right)) {
    rule_right(options)
  }
  else {
    rule_line(options)
  }
  res <- col_substr(res, 1, width)
  res <- apply_style(res, background_col, bg = TRUE)
  class(res) <- unique(c("rule", class(res), "character"))
  res
}



