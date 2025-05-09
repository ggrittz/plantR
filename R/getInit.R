#' @title Create Name Initials
#'
#' @description Convert or standardize a vector of containing people's
#'   names or their initials.
#'
#' @param x the character string or vector to be standardized
#' @param upper logical. Should initials be capitalized? Default to
#'   TRUE.
#' @param rm.spaces logical. Should spaces between initials be
#'   removed? Default to TRUE.
#' @param max.initials numerical. Upper limit of number of letter for
#'   a single word to be considered as initials and not as a name.
#'   Default to 5.
#'
#' @return the character string with the initials of each name
#'   separated by points, without spaces. By default, initials are
#'   returned capitalized.
#'
#' @details The function has some basic assumptions in order to get
#'   initials for the most type of cases.
#'
#'   For multiple names/abbreviations separated by a space and/or an
#'   abbreviation point, the function takes the first letter of each
#'   name/abbreviation as the initials.
#'
#'   For single names or one-string initials the output depends on the
#'   presence of abbreviation points, if names are provided in all
#'   caps and in the number of letters. If the number of capital
#'   letters exceeds the value in the argument `max.initials`, then it
#'   is taken as a name and not initials (see Examples).
#'
#'   The output is relatively stable regarding different name formats
#'   and notation standards, but it doe not work for all of them (see
#'   Examples).
#'
#' @author Renato A. F. de Lima
#'
#' @keywords internal
#'
#' @examples
#' \dontrun{
#'   # Full names and both full and abbreviated names
#'   getInit("Alwyn")
#'   getInit("Alwyn Howard Gentry")
#'   getInit("Alwyn H. Gentry")
#'   getInit("A. Gentry")
#'   getInit("A. H. Gentry")
#'   getInit("A.H.Gentry")
#'
#'   # Abbreviations
#'   getInit("A")
#'   getInit("A H G")
#'   getInit("A. H. G.")
#'
#'   # Capitalized and lower-case names
#'   getInit("ALWYN HOWARD GENTRY")
#'   getInit("AHG")
#'   getInit("a.h. gentry")
#'   getInit("alwyn") # assumes as name
#'   getInit("ALWYN") # assumes as name
#'
#'   # Other formats
#'   getInit("Auguste Saint-Hilaire")
#'   getInit("John MacDonald")
#'   getInit("John McDonald")
#'   getInit("John O'Brien")
#'
#'   # Some problematic (unresolved) examples
#'   getInit("AL") # assumes as initials (n. letters < default `max.initials`)
#'   getInit("AL", max.initials = 2) # assumes as name (by changing the default)
#'   getInit("Carl F. P. von Martius") #takes name preposition as name
#'   getInit("AH gentry") # assumes initials as first name
#'   getInit("Gentry, A.") # ignores comma
#'   getInit("G., Alwyn") # ignores comma
#'   getInit("Ah. Gentry") # discard the lower-case initial
#'  }
#'
getInit <- function(x,
                    upper = TRUE,
                    rm.spaces = TRUE,
                    max.initials = 5) {

  #Preparing the vector of names
  pts <- grepl("\\.", x, perl = TRUE)
  x[pts] <- gsub("[.]", ". ", x[pts], perl = TRUE)
  x[pts] <- squish(x[pts])

  #Detecting the some general types of name formats: full, abbreviated or both
  words <- grepl(" ", x, fixed = TRUE)
  abrev <- grepl('(\\p{L}\\.)(\\p{L}\\.)+',
                 x, perl = TRUE)

  types <- rep(NA, length(x))
  types[words] <- "1"
  types[!words & abrev] <- "2"
  types[!words & !abrev] <- "3"

  #Identifying some particular cases
  hyphen <- grepl("-", x, fixed = TRUE)
  if (any(hyphen))
    x[hyphen] <- gsub("-", " - ", x[hyphen], fixed = TRUE)

  oa <- grepl("O'", x, fixed = TRUE)
  if (any(oa))
    x[oa] <- gsub("O'", "O ' ", x[oa], fixed = TRUE)

  mac <- grepl('(Mac)([A-Z])', x, perl = TRUE)
  if (any(mac))
    x[mac] <- gsub("(Mac)([A-Z])", "\\1 \\2", x[mac], perl = TRUE)

  mc <- grepl('(Mc)([A-Z])', x, perl = TRUE)
  if (any(mc))
    x[mc] <- gsub("(Mc)([A-Z])", "\\1 \\2", x[mc], perl = TRUE)

  #Extracting the initials for each type of format
  initials <- x

  #types 1: first letter of each word
  type1 <- types %in% "1"
  if (any(type1)) {

    check_these <- grepl("\\p{Lu}\\p{Lu}", initials[type1], perl = TRUE) &
      grepl("\\p{Lu}\\p{Ll}", initials[type1], perl = TRUE)
    if (any(check_these))
      initials[type1][check_these] <-
        squish(gsub("(\\p{Lu})", " \\1",
             initials[type1][check_these], perl = TRUE))


    initials[type1] <-
      gsub("(*UCP)[^;\\&\\-\\\\'\\s](?<!\\b\\p{L})",
           # gsub("(*UCP)[^;\\&\\-\\\\'](?<!\\b\\p{L})",
           "", initials[type1], perl=TRUE)
  }

  #type 2: single words, with abbreviations
  type2 <- types %in% "2"
  if (any(type2)) {
    initials[type2] <-
      gsub("(*UCP)[^;\\&\\-\\\\'\\s](?<!\\b\\p{L})",
           # gsub("(*UCP)[^;\\&\\-\\\\'](?<!\\b\\p{L})",
           "", initials[type2], perl=TRUE)
  }

  #type 3: single words, no abbreviations
  type3 <- types %in% "3"
  if (any(type3)) {
    any.caps <- grepl('\\p{Lu}', x[type3], perl = TRUE)
    all.caps <- x[type3] == toupper(x[type3])
    all.low <- !all.caps & !any.caps

    initials[type3][!all.low] <-
          gsub("(*UCP)[^;\\&\\-\\\\'\\s](?<![A-Z])", "",
           # gsub("(*UCP)[^;\\&\\-\\\\'](?<![A-Z])", "",
           initials[type3][!all.low], perl=TRUE)
    initials[type3][all.low] <-
          gsub("(*UCP)[^;\\&\\-\\\\'\\s](?<!\\b\\p{L})", "",
           # gsub("(*UCP)[^;\\&\\-\\\\'](?<!\\b\\p{L})", "",
           initials[type3][all.low], perl = TRUE)

    not.inits <- nchar(initials[type3]) >= max.initials
    if (any(not.inits))
      initials[type3][not.inits] <-
          gsub("(*UCP)[^;\\&\\-\\\\'\\s](?<!\\b\\p{L})", "",
           # gsub("(*UCP)[^;\\&\\-\\\\'](?<!\\b\\p{L})", "",
           initials[type3][not.inits], perl = TRUE)

  }

  # Final edits
  if (upper) {
    x <- toupper(initials)
  } else {
    x <- initials
  }

  x <- gsub("(\\p{L})", "\\1.", x, perl = TRUE)
  x <- gsub("\\.,\\.", ".", x, perl = TRUE)

  if (any(grepl("-\\.", x, perl = TRUE)))
    x[grepl("-\\.", x, perl = TRUE)] <-
      gsub("-\\.", "-", x[grepl("-\\.", x, perl = TRUE)])

  if (rm.spaces) {
    x <- gsub(" ", "", x, fixed = TRUE)
  } else {
    x <- squish(x)
    check_these <- grepl("\\p{L}\\.\\s-\\s\\p{L}\\.", x, perl = TRUE)
    x[check_these] <-
      gsub("\\.\\s-\\s", ".-", x[check_these], perl = TRUE)
  }

  if (any(oa)) {
    if (rm.spaces) {
      x[oa] <- gsub("O\\.'", "O'", x[oa], perl = TRUE)
    } else {
      x[oa] <- gsub("O\\.\\s'\\s", "O'", x[oa], perl = TRUE)
    }
  }

  if (any(mac))
    if (rm.spaces) {
      x[mac] <- gsub("(M)(\\.)", "\\Mac", x[mac], perl = TRUE)
    } else {
      x[mac] <- gsub("(M)(\\.\\s)", "\\Mac", x[mac], perl = TRUE)
    }

  if (any(mc))
    if (rm.spaces) {
      x[mc] <- gsub("(M)(\\.)", "\\Mc", x[mc], perl = TRUE)
    } else {
      x[mc] <- gsub("(M)(\\.\\s)", "\\Mc", x[mc], perl = TRUE)
    }

  return(x)
}
