#' Function for extracting climate data from CRU datasets
#'
#' @description A wrapper for raster() function, useful for extracting climate date from CRU datasets in a very straightforward way. All you need to do is put in the CRU dataset file, choose the variable that you want, enter the year and the month, and you will get a dataframe with the desired variable for the given time.
#'
#' @usage extractcru(file, lon, lat, var, year, month)
#'
#' @param file The CRU dataset file, usually with "dat.nc" extension
#' @param lon Longitude value of the coordinate of a given place
#' @param lat Latitude value of the coordinate of a given place
#' @param var The variable from the CRU dataset that we would like to obtain, could be "tmp" for temperature, "pre" for precipitation, and so on.
#' @param year A given year, must be within the span measured in the CRU dataset
#' @param month A given month, must be from the Gregorian calendar and can be written either in English ("January", "February", etc.) or number (1, 2, 3, etc.).
#'
#' @return A dataframe with the desired climate parameter (precipitation, temperature, etc.) of a particular place with the given latitude and longitude on the requested year and month.
#'
#' @examples
#' year <- 2010
#' month <- "December"
#' file <- "cru_ts4.02.1901.2017.tmp.dat.nc"
#' var <- "tmp"
#' lon <- 2.4
#' lat <- 48.9
#' datres <- extractcru(file = "cru_ts4.02.1901.2017.tmp.dat.nc", lat = 48.9, lon = 2.4, var = "tmp", month = "December", year = 2010)

extractcru <- function(file, lon, lat, var, year, month){

  dat.tmp <- raster::brick(file, varname = var)

  nom.lieux <- var
  lon.lieux <- lon
  lat.lieux <- lat

  lieux <- data.frame(lon,lat)

  names(lieux) <- c("lon","lat")

  row.names(lieux) <- nom.lieux

  tmp.sites <- data.frame(raster::extract(dat.tmp, lieux, ncol = 2))

  row.names(tmp.sites) <- row.names(lieux)

  tmp.sites <- data.frame(t(tmp.sites))

  tmp.sites$date <- substr(row.names(tmp.sites),2,nchar(row.names(tmp.sites))-1)

  startyear <- min(as.numeric(substr(tmp.sites$date,1,4)))

  endyear <- max(as.numeric(substr(tmp.sites$date,1,4)))

  years <- startyear:endyear

  Months <- c("January","February","March","April","May","June",
              "July","August","September","October","November","December")

  Months_num <- 1:12

  tmp.sites$date <- paste(rep(years,
                              each = 12),
                          rep(Months,
                              times = endyear-(startyear-1)),sep="_")

  tmp.sites$Year <- rep(years, each = 12)

  tmp.sites$Month <- rep(Months, times = endyear-(startyear-1))

  tmp.sites$Month_num <- rep(Months_num, times = endyear-(startyear-1))

  row.names(tmp.sites) <- 1:nrow(tmp.sites)

  tmp.sites$lon <- lon

  tmp.sites$lat <- lat

  if(missing(month) == FALSE & missing(year) == FALSE){

    if(class(month) == "numeric"){

      if(month %in% Months_num & year %in% years) {

        return(subset(subset(tmp.sites, (Month_num == month & Year == year)), select = -c(Month_num, date)))

      } else {

        return("Sorry, the month and/or the year that you put are not in the dataset")

      }

    } else {

      if(month %in% Months & year %in% years) {

        return(subset(subset(tmp.sites, (Month == month & Year == year)), select = -c(Month_num, date)))

      } else {

        return("Sorry, the month and/or the year that you put are not in the dataset")

      }

    }

  } else {

    if(missing(month) == FALSE & missing(year) == TRUE){

      if(class(month) == "character"){

        if(month %in% Months) {

          return(subset(subset(tmp.sites, Month == month), select = -c(Month_num, date)))

        } else {

          return("Sorry, the month that you put in is not in the Gregorian calendar")

        }

      } else {

        if(class(month) == "numeric"){

          if(month %in% Months_num) {

            return(subset(subset(tmp.sites, Month_num == month), select = -c(Month_num, date)))

          } else {

            return("Sorry, the month that you put in is not in the Gregorian calendar")

          }

        }

      }

    } else {

      if(missing(month) == TRUE & missing(year) == FALSE){

        if(year %in% years) {

          return(subset(subset(tmp.sites, Year == year), select = -c(Month_num, date)))

        } else {

          return("Sorry, the year that you put in is not available in the dataset")

        }

      } else {

        return(subset(tmp.sites, select = -c(Month_num,date)))

      }

    }

  }

}