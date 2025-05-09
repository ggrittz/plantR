#' @title Checks if two countries share a border
#'
#' @param country1 First country to check, use spData standard
#' @param country2 Second country to check, use spData standard
#'
#' @importFrom sf st_intersects
#'
#' @author Andrea Sánchez-Tapia, Guilherme S. Grittz & Sara Mortara
#'
#' @encoding UTF-8
#'
#' @keywords internal
#'
shares_border <- function(country1 = "brazil",
                          country2 = "argentina") {

  #Escaping R CMD check notes
  world <- world

  w <- world

  if (!country1 %in% w$name)
    country1 <- prepLoc(prepCountry(country1))

  if (!country2 %in% w$name)
    country2 <- prepLoc(prepCountry(country2))

  if (!country1 %in% w$name | !country2 %in% w$name)
    stop(paste0("Country name(s) '",
               c(country1, country2)[!c(country1, country2) %in% w$name],
               "' not found"))

  v <- w[w$name %in% c(country1),]
  z <- w[w$name %in% c(country2),]

  # y <- suppressWarnings(sf::st_union(v, z))
  #
  # v <- suppressWarnings(sf::st_cast(v, "POLYGON"))
  # z <- suppressWarnings(sf::st_cast(z, "POLYGON"))
  # y <- suppressWarnings(sf::st_cast(y, "POLYGON"))
  # polis <- nrow(v) + nrow(z)
  # poli_u <- nrow(y)
  # if (polis == poli_u) return(FALSE)
  # if (poli_u < polis) return(TRUE)
  return(sf::st_intersects(v, z, sparse = FALSE)[1, 1])

}


#' @title Flag Countries Sharing Borders
#'
#' @description For those records without a match between the country
#'   described in the record and the country obtained from the
#'   geographical coordinates, the function flags if the two countries
#'   share borders. These may be useful to identify coordinates that
#'   are not problematic but that fall in another country due to
#'   rounding or precision of coordinates or to cases when the
#'   collector was not aware that a country border was crossed before
#'   obtaining the coordinate.
#'
#' @param x a data.frame with the results from the coordinate
#'   validation
#' @param geo.check Name of the column with the validation of the
#'   coordinates against country maps. Default to 'geo.check'
#' @param country.shape Name of the column with the country name
#'   obtained from the world map based on the original record
#'   coordinates. Default to 'NAME_0'
#' @param country.gazetteer Name of the column with the country name
#'   obtained from the gazetteer, based on the description of the
#'   record locality. Default to 'loc.correct'
#' @param output a character string with the type of output desired:
#'   'new.col' (new column with the result is added to the input data)
#'   or 'same.col' (results overwritten into column `geo.check`).
#'
#' @return if `output` is 'new.col', a new column named 'border.check'
#'   is added to the data, containing a TRUE/FALSE vector in which
#'   TRUE means countries which share border and FALSE means countries
#'   that do not share borders (country mismatch is not due to
#'   coordinates close to country borders). If `output` is 'same.col',
#'   the column defined by `geo.check` is updated with a suffix
#'   'borders' or 'inverted' added to the validation class inside
#'   brackets.
#'
#' @importFrom dplyr left_join if_else
#'
#' @author Andrea Sánchez-Tapia & Sara Mortara
#'
#' @encoding UTF-8
#'
#' @export checkBorders
#'
checkBorders <- function(x,
                         geo.check = "geo.check",
                         country.shape = "NAME_0",
                         country.gazetteer = "loc.correct",
                         output = "new.col") {

  ## Check input
  if (!inherits(x, "data.frame"))
    stop("Input object needs to be a data frame!")

  if (!all(c(geo.check, country.shape, country.gazetteer) %in% colnames(x)))
    stop("One or more column names declared do not match those of the input object: please rename or specify the correct names")

  ## Check the map country information
  if (any(grepl("_", x[, country.shape], fixed = TRUE))) {

    country.shp <- sapply(
      strsplit(x[, country.shape], "_", fixed = TRUE), function (x) x[1])

  } else {

    country.shp <- x[, country.shape]

  }

  ## Check the gazetteer country information
  if (any(grepl("_", x[, country.gazetteer], fixed = TRUE))) {

    country.gazet <- sapply(
      strsplit(x[, country.gazetteer], "_", fixed = TRUE), function (x) x[1])

  } else {

    country.gazet <- x[, country.gazetteer]

  }

  ## Checking borders for selected records
  check_these <- grepl("bad_country", x[, geo.check], perl = TRUE)
  if (any(check_these)) {
    shares_bord <- Vectorize(shares_border)
    share_border <- suppressMessages(suppressWarnings(
      shares_bord(country.shp[check_these],
                  country.gazet[check_these])))
    # border.check <-
    #   dplyr::if_else(share_border == TRUE,
    #           "check_borders", "check_inverted")

    ## Preparing to return
    if (output == 'new.col') {
      x$border.check <- NA
      x$border.check[check_these] <-
        share_border
    }

    if (output == 'same.col') {
      x[check_these, geo.check][share_border] <-
        "bad_country[border]"
      #paste0(x[check_these, geo.check][share_border],"[border]")
      x[check_these, geo.check][!share_border] <-
        "bad_country[inverted?]"
      #paste0(x[check_these, geo.check][!share_border],"[inverted?]")
    }

  } else {

    if (output == 'new.col')
      x$border.check <- FALSE

  }

  return(x)
}
