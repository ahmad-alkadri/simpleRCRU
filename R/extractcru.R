#' Function for extracting climate data from CRU datasets
#'
#' @description A wrapper for raster() function,
#' useful for extracting climate date from CRU datasets in a very straightforward way.
#' All you need to do is put in the CRU dataset file, choose the variable that you want,
#' enter the year and the month, and you will get a dataframe
#' with the desired variable for the given time.
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
#' library(simpleRCRU)
#' library(R.utils)
#'
#' # Download the climate dataset
#' download.file("https://crudata.uea.ac.uk/cru/data/hrg/cru_ts_4.02/cruts.1811131722.v4.02/pre/cru_ts4.02.1991.2000.pre.dat.nc.gz",
#'               destfile = "cru_ts4.02.1991.2000.pre.dat.nc.gz")
#'
#' # Unzipping the dataset
#' gunzip("cru_ts4.02.1991.2000.pre.dat.nc.gz",
#' remove = TRUE, overwrite = TRUE)
#'
#' year <- 2000
#'
#' month <- "December"
#'
#' file <- ("cru_ts4.02.1991.2000.pre.dat.nc")
#'
#' # Climate parameter (precipitation)
#' var <- "pre"
#'
#' lon <- 2.4
#'
#' lat <- 48.9
#'
#' datres <- extractcru(file, lon, lat, var, year, month)
#'
#' file.remove("cru_ts4.02.1991.2000.pre.dat.nc")

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

      if(all(month %in% Months_num) & all(year %in% years)) {

        tmp.res <- subset(tmp.sites[tmp.sites$Year %in% year & tmp.sites$Month_num %in% month,], select = -c(Month_num,date))

        #tmp.res <- subset(subset(tmp.sites, (Month_num == month & Year == year)), select = -c(Month, date))

        row.names(tmp.res) <- c(1:nrow(tmp.res))

        return(tmp.res)

      } else {

        return("Sorry, the month and/or the year that you put are not in the dataset")

      }

    } else {

      if(all(month %in% Months) & all(year %in% years)) {

        tmp.res <- subset(tmp.sites[tmp.sites$Year %in% year & tmp.sites$Month %in% month,], select = -c(Month_num,date))

        #tmp.res <- (subset(subset(tmp.sites, (Month == month & Year == year)), select = -c(Month, date)))

        row.names(tmp.res) <- c(1:nrow(tmp.res))

        return(tmp.res)

      } else {

        return("Sorry, the month and/or the year that you put are not in the dataset")

      }

    }

  } else {

    if(missing(month) == FALSE & missing(year) == TRUE){

      if(class(month) == "character"){

        if(all(month %in% Months)) {

          tmp.res <- subset((tmp.sites[tmp.sites$Month %in% month,]), select = -c(Month_num,date))

          #tmp.res <- (subset(subset(tmp.sites, Month == month), select = -c(Month_num, date)))

          row.names(tmp.res) <- c(1:nrow(tmp.res))

          return(tmp.res)

        } else {

          return("Sorry, the month that you put in is not in the Gregorian calendar")

        }

      } else {

        if(class(month) == "numeric"){

          if(all(month %in% Months_num)) {

            tmp.res <- subset(tmp.sites[tmp.sites$Month %in% month,], select = -c(Month_num,date))

            #tmp.res <- (subset(subset(tmp.sites, Month_num == month), select = -c(Month_num, date)))

            row.names(tmp.res) <- c(1:nrow(tmp.res))

            return(tmp.res)

          } else {

            return("Sorry, the month that you put in is not in the Gregorian calendar")

          }

        }

      }

    } else {

      if(missing(month) == TRUE & missing(year) == FALSE){

        if(all(year %in% years)) {

          tmp.res <- subset(tmp.sites[tmp.sites$Year %in% year,], select = -c(Month_num,date))

          #tmp.res <- (subset(subset(tmp.sites, Year == year), select = -c(Month_num, date)))

          row.names(tmp.res) <- c(1:nrow(tmp.res))

          return(tmp.res)

        } else {

          return("Sorry, the year that you put in is not available in the dataset")

        }

      } else {

        tmp.res <- subset(tmp.sites, select = -c(Month_num,date))

        #tmp.res <- (subset(tmp.sites, select = -c(Month_num,date)))

        row.names(tmp.res) <- c(1:nrow(tmp.res))

        return(tmp.res)

      }

    }

  }

}
