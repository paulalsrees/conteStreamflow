## ------------------------------------------------------------------------
#' @title Create monster list of 3d weather matrices
#' @description used to store aggregated weather metrics
# no export

create.w.matrices<-function( weather.filenames, 
                             template.date, template.period, cols.weather ) {

     w.matrices<-list()
     for ( j in template.period$name ) {
          if ( j %in% periods ) {
               w.matrices[[j]]<-array(dim=c(  nrow(template.date[[j]]), 
                                         length(weather.filenames), 
                                         length(cols.weather))  ) 
               dimnames(   w.matrices[[j]]   )[[1]]<-template.date[[j]][,1]
               dimnames(   w.matrices[[j]]    )[[2]]<-weather.filenames
               dimnames(   w.matrices[[j]]   )[[3]]<-cols.weather
          }
          else 
               w.matrices[[j]] <- NA
     }
          
     return(w.matrices)
}




## ------------------------------------------------------------------------
#' @title retrieve weather, based on specified set
#' @description placeholder
#' @export

weather.sets.retrieve <- function( set="mauer_1949_2010" ) {
#       cache.load.data( file="weather_cols.txt", dir=paste0("weather_sets/",set) )
     
     print("boo")
}



