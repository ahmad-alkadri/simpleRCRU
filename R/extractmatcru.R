#' Function for extracting the climate data of an area from CRU datasets
#'
#' @description A wrapper for extractcru() function,
#' useful for extracting climate date of
#' a rectangular area from CRU datasets.
#'
#' @usage extractareacru(file, lonmin, lonmax, latmin, latmax, var, year, month, precision)
#'
#' @param file The CRU dataset file, usually with "dat.nc" extension
#'
#' @param lonmin The minimum longitude value of the rectangular area
#'
#' @param lonmax The maximum longitude value of the rectangular area
#'
#' @param latmin The minimum latitude value of the rectangular area
#'
#' @param latmax The maximum latitude value of the rectangular area
#'
#' @param var The variable from the CRU dataset that we would like to obtain,
#' could be "tmp" for temperature, "pre" for precipitation, and so on.
#'
#' @param year A single given year, must be within the span measured in the CRU dataset
#'
#' @param month A single given month, must be from the Gregorian calendar and can be written either in English ("January", "February", etc.) or number (1, 2, 3, etc.).
#'
#' @return A matrix with the desired climate values (precipitation, temperature, etc.) of
#' the rectangular region on the requested year and month. Rows refer to latitude and columns
#' refer to longitude.
#'
#' @examples
#' # Selected time
#' year <- 2010
#' month <- "December"
#'
#' # Selected area: a rectangular region of the Central Java island, Indonesia
#' lonmin = 109.0
#' lonmax = 109.2
#' latmin = -7.4
#' latmax = -6.9
#'
#' # Climate parameter
#' var = "pre"
#'
#' # Coordinate precision of 1 digit behind decimal
#' precision = 1
#'
#' # Matrix with results
#' matReg <- extractareacru(file, lonmin, lonmax, latmin, latmax,
#'           var, year, month, precision)

extractareacru <- function(file, lonmin, lonmax, latmin, latmax, var, year, month, precision){

  mat_area <- matrix(0,
                     ncol = 1+(10^precision)*round(abs(lonmin-lonmax), digits = precision),
                     nrow = 1+(10^precision)*round(abs(latmin-latmax), digits = precision))

  if(length(year) == 1 & length(month) == 1){

    # Longitudinal vectors, for rows
    lon_vec <- seq(from = lonmin, to = lonmax, by = 1/(10^precision))

    lat_vec <- seq(from = latmin, to = latmax, by = 1/(10^precision))

    # Loop extraction
    for (i in 1:nrow(mat_area)) {

      for (j in 1:ncol(mat_area)) {

        mat_area[i,j] <- extractcru(file = file,
                                    lon = lon_vec[j],
                                    lat = lat_vec[i],
                                    var = var,
                                    year = year,
                                    month = month)[1,1]

      }

    }

    rownames(mat_area) <- lat_vec

    colnames(mat_area) <- lon_vec

    return(mat_area)

  } else {

    print("ERROR: area data extraction only works for a combination of 1 year and 1 month, such as: September 2012")

  }

}
