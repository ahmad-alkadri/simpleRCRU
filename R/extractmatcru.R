#' Function for extracting the climate data of an area from CRU datasets
#'
#' @description A wrapper for raster() function,
#' useful for extracting climate date of
#' a rectangular area from CRU datasets.
#'
#' @usage extractareacru(file, lonmin, lonmax,
#' latmin, latmax, var, year, month, precision)
#'
#' @param file The CRU dataset file, usually with ".dat.nc" extension
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
#' @param year A single given year, must be within the span measured in the CRU dataset.
#'
#' @param month A given month, must be from the Gregorian calendar and can be written either in English ("January", "February", etc.) or number (1, 2, 3, etc.).
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
#' # Selected area: a rectangular region
#' # from the Central Java island, Indonesia
#' lonmin <- 104.0
#' lonmax <- 118.0
#' latmin <- -9.0
#' latmax <- -5.0
#'
#' # Climate parameter
#' var <- "pre"
#'
#' # CRU dataset
#' file <- "cru_ts4.02.1901.2017.pre.dat.nc"
#'
#' # Coordinate precision of 1 digit behind decimal
#' precision <- 1
#'
#' # Matrix with results
#' matReg <- extractareacru(file, lonmin, lonmax, latmin, latmax,
#'           var, year, month, precision)

extractareacru <- function(file, lonmin, lonmax, latmin, latmax, var, year, month, precision){

  if(length(year) == 1 & length(month) == 1){

    pre <- raster::brick(file, varname = var)

    precision <- precision

    areapart <- raster::extent(lonmin,lonmax,latmin,latmax)

    areagrid <- raster::crop(pre,areapart)

    matarea <- matrix(0, nrow = abs(latmax-latmin)*10^precision+1, ncol = abs(lonmax-lonmin)*10^precision+1)

    colnames(matarea) <- seq(lonmin,lonmax,by=10^-precision)

    rownames(matarea) <- seq(latmin,latmax,by=10^-precision)

    sitecoord <- data.frame(reshape2::melt(matarea))

    rm(matarea)

    sitecoord$value <- NULL

    sitecoord[3] <- sitecoord[1]

    sitecoord[1] <- NULL

    names(sitecoord) <- c("lon","lat")

    presites <- data.frame(raster::extract(areagrid, sitecoord, ncol = 2))

    rm(areagrid) ; rm(pre)

    first_year <- as.numeric(substr(colnames(presites[1]),2,5))

    last_year <- as.numeric(substr(colnames(presites[ncol(presites)]),2,5))

    years <- first_year:last_year

    months_char <- c("January","February","March","April","May","June","July",
                "August","September","October","November","December")

    months_num <- 1:12

    if(year %in% years == FALSE){

      stop(paste("The year that you put in is not within the span of the dataset.
                 The dataset only contains data from", first_year, "to", last_year, sep = " "))

    } else {

      if(month %in% months_char == TRUE | month %in% months_num == TRUE){

        names(presites) <- paste(rep(years, each = 12), rep(months_char, times = last_year-first_year+1), sep = "_")

        if(class(month) == "numeric"){

          presites_target <- presites[paste(year,months_char[month], sep="_")]

        } else {

          presites_target <- presites[paste(year,month, sep="_")]

        }

        rm(presites)

        siteres <- cbind(sitecoord,presites_target)

        rm(sitecoord) ; rm(presites_target)

        siteres <- dplyr::arrange(siteres, lat)

        siteres <- dplyr::arrange(siteres, lon)

        matres <- reshape2::dcast(siteres, lat ~ lon)

        rm(siteres)

        rownames(matres) <- matres$lat

        matres$lat <- NULL

        matres <- as.matrix(matres)

        return(matres)

      } else {

        stop("Month not written in the Gregorian calendar or falsely written.")

      }

    }

  } else {

    print("ERROR: area extraction only works for a combination of one year and one month, such as: September 2012")

  }

}



