## ------------------------------------------------------------------------
#' @title char.columns.retrieve
#' @export
char.columns.retrieve <- function(id=F,impoundment=F) {     
     # placeholder function until basin characteristics are available through rest api
     # returns list of available columns, or the name of the id column

     if ( id ) 
          return("FEATUREID")
     else if ( impoundment==T )
          return( c("TNC_DamCount", "deg_barr_1", "deg_barr_2", "deg_barr_3", "deg_barr_4", "deg_barr_6", "deg_barr_7", 
                  "OnChannelWaterSqKM", "OnChannelWetlandSqKM", "OffChannelWaterSqKM", "OffChannelWetlandSqKM") )
     else 
          return( c("NHDplusTotDASqKM", "NHDplusTotDASqMI", "ReachLengthKM",         
               "Forest", "Herbacious","Agriculture","Developed","DevelopedNotOpen", "Impervious",  
               "CONUSOpenWater","CONUSWetland",
               "DrainageClass","HydrologicGroupA","HydrologicGroupAB","HydrologicGroupCD","HydrologicGroupD4","HydrologicGroupD1",
               "SurficialCoarseA","SurficialCoarseB", "SurficialCoarseC","SurficialCoarseD","PercentSandy", 
               "AnnualTmaxC","AnnualTminC","AnnualPrcpMM",
               "JanPrcpMM","FebPrcpMM","MarPrcpMM","AprPrcpMM","MayPrcpMM","JunPrcpMM",
               "JulPrcpMM","AugPrcpMM","SepPrcpMM","OctPrcpMM","NovPrcpMM","DecPrcpMM",
               "AtmDepositionNO3","AtmDepositionSO4",
               "ReachElevationM","BasinElevationM","ReachSlopePCNT","BasinSlopePCNT") )
     
}


## ------------------------------------------------------------------------
#' @title char columns select
#' @export
char.columns.select <- function(impoundment=F) {
     # placeholder function until basin characteristics are available through rest api
     # interactive selection of columns to include
     # clunky, but at least provides an option to make it a little easier for the user

#      if ( !impoundment ) 
#           col=char.columns.retrieve()
#      else 
#           col=char.columns.retrieve(impoundment=T)
     col=char.columns.retrieve(impoundment=impoundment)
          
     
     all <- data.frame( col=col, include=rep(x=NA, times=length(col)), stringsAsFactors=F ) 
     for ( i in 1:nrow(all) ) {
          all[i,"include"] <- readline( paste0("\'", all[i,"col"], "\': ","Include this variable? (y/n)  ") ) 
     }
     all[,"include"] <- as.logical.y.n(all[,"include"])
     
     return(c( char.columns.retrieve(id=T), all[ all$include==T, "col" ] ))
}


## ------------------------------------------------------------------------
#' @title retrieve basin characteristics 
#' @description Get basin characteristics associated with each gage, or more precisely, with the NHDplus stream reach each gage is plotted to.
#' @param gages.spatial \code{SpatialPointsDataFrame} of gage info from plot.gages.nhdplus()
#' @param basin.char.file \code{character} location andname of .rdata file that contains UpstreamStats, by NHDplus FEATUREID
#' @return \code{SpatialPointsDataFrame} of gage info including upstream basin characteristics
#' @seealso plot.gages.nhdplus, load.gage.impound
#' @export

char.retrieve<-function(gages.spatial, cols=NULL, 
                        log.cols=NULL, std.cols=NULL, log.std.cols=NULL, return.scaling=F, 
                        impound=F, server.url="http://felek.cns.umass.edu:9283") {
     
     cache.check()

     if ( !("FEATUREID" %in% names(gages.spatial)) )
          stop("Please first place gages in NHDplus catchments")
     
     #ensure all columns indicated for transformation are included in full set of selected columns
     cols <- unique(c(cols, log.cols, std.cols, log.std.cols ))
     
     ### retrieve data from server
     # this is temporary until basin characteristics are available through rest api
     # just loads rdata w/ data.frame's given to me by kyle
     
     if ( !impound ) {
          cache.load.data( object="UpstreamStats", dir="basin_char", file="NENY_CovariateData_2014-01-23_upstream.rdata", quiet=T)
          all.char<-get("UpstreamStats")
          names(all.char)[names(all.char)=="TotDASqKM"]<-"NHDplusTotDASqKM"
          names(all.char)[names(all.char)=="TotDASqMI"]<-"NHDplusTotDASqMI"
     }

     else { 
          cache.load.data( object="UpstreamStats", dir="basin_char", file="NENY_Impound_renamed_2014-01-23.rdata", quiet=T)
          all.char<-get("UpstreamStats")          
     }
     
     # selects only needed features (also temporary until rest api)
     all.char <- all.char[all.char$FEATUREID %in% gages.spatial$FEATUREID,]
     
     if ( !return.scaling ) {
          # selects only desired columns
          if ( !is.null(cols) ) #(also temporary until rest api)
               all.char <- all.char[,unique(c("FEATUREID",cols))]
          # Standardize and/or log transform options
          if (!is.null(log.cols) & length(log.cols)>0 )
               all.char <- char.transform( char=all.char, cols=log.cols, trans="log" )
          if (!is.null(std.cols) & length(std.cols)>0 )
               all.char <- char.transform( char=all.char, cols=std.cols, trans="std" )
          if (!is.null(log.std.cols) & length(log.std.cols)>0 )
               all.char <- char.transform( char=all.char, cols=log.std.cols, trans="log.std" )

          # merge and return     
          # merges w/ spatial.gages object 
          gages.spatial.char<-merge.sp( gages.spatial, all.char, by="FEATUREID", all.x=T, all.y=F, sort=F)
     
          return(gages.spatial.char)
     }
     
     else if (return.scaling) {
          scaling <- data.frame(matrix(nrow=2, ncol=0))
          if (!is.null(std.cols) & length(std.cols)>0 )
               scaling <- cbind( char.transform( return.scaling=T, char=all.char, cols=std.cols, trans="std" ) )
          if (!is.null(log.std.cols) & length(log.std.cols)>0 )
               scaling <- cbind( char.transform( return.scaling=T, char=all.char, cols=log.std.cols, trans="log.std" ) )
          return( scaling )
     }
     


     #to improve later: 
     #also, see if i can find a better solution to sp merge issue

}


## ------------------------------------------------------------------------
#' @title char transform
#' @description x
#' @export

char.transform <- function( char, cols, id.col="FEATUREID", trans="log", return.scaling=F) {
     
     if (trans=="log" | trans=="log.std") {
          char2 <- apply( char[,cols], MARGIN=c(1,2), FUN=function(x) log(non.zero(x)) )
          char2 <- as.data.frame( cbind( char[,id.col], char2 ), stringsAsFactors=F )
#           cols2 <- paste0("log",".",cols)
          names(char2)[[1]] <- id.col
     }
     else {
          char2<-char
#           cols2<-cols
     }
     
     
     if ( trans=="std" | trans=="log.std" ) {
          char3 <- scale( char2[,cols], center=T, scale=T )
#           print("center")
#           print( attr(char3, "scaled:center") )
#           print("scale")
#           print( attr(char3, "scaled:scale") )
          char2 <- as.data.frame( cbind( char2[,id.col], char3 ), stringsAsFactors=F )
     }

     
     if ( !return.scaling ) {
          names(char2) <- c( id.col, paste0(trans,".",cols) )
          char4 <- merge( char, char2, by=id.col, all.x=T, all.y=F, sort=F )
          return( char4 )
     }

     else {
          if (trans=="log")
               stop( "Cannot return scaling on non-standardization transformation" )
          scaling <- as.data.frame( rbind(attr(char3, "scaled:center"),attr(char3, "scaled:scale")) )  
          row.names(scaling) <- c("mean","sd")
          return(scaling)
     }
}


## ------------------------------------------------------------------------
#' @title impound retrieve
#' @description wrapper function for char.retrieve
#' @export
impound.retrieve <- function(gages.spatial, server.url="http://felek.cns.umass.edu:9283", cols=NULL) {

     char.retrieve( gages.spatial=gages.spatial, impound=T, server.url=server.url, cols=cols )                    
}


## ------------------------------------------------------------------------
#' @title default char columns 
#' @export
char.columns.default <- function( impound=F ) {
     if ( !impound ) 
          return( c( char.columns.retrieve(id=T), 
               "ReachLengthKM",         
               "Forest", "Herbacious","Agriculture","Developed","DevelopedNotOpen", "Impervious",  
               "CONUSOpenWater","CONUSWetland",
               "DrainageClass","HydrologicGroupAB","SurficialCoarseC","PercentSandy", 
               "BasinElevationM","BasinSlopePCNT","NHDplusTotDASqKM") )
     else 
          return( c( char.columns.retrieve(id=T), 
                      "TNC_DamCount", "OnChannelWaterSqKM", "OnChannelWetlandSqKM"))
}
     

## ------------------------------------------------------------------------
#' @title col transform
#' @description x
#' @export

col.transform <- function(x, log.cols, id.col="FEATUREID") {
          
     if ( sum( !(log.cols %in% names(x)) )>0 )
          stop( "Not all specified columns are in provided data.frame" )
     
     is.spatial <- attr(class(x),"package") == "sp"

     
     if ( is.spatial ) {
          if (length(log.cols)>1)
               x@data[,paste0("log.",log.cols)] <- apply( x@data[,log.cols], MARGIN=c(1,2), FUN=function(x) log(non.zero(x)) )
          else
               x@data[,paste0("log.",log.cols)] <- log(non.zero(x@data[,log.cols]))
     }
     else {
          if (length(log.cols)>1)
               x[,paste0("log.",log.cols)] <- apply( x[,log.cols], MARGIN=c(1,2), FUN=function(x) log(non.zero(x)) )
          else
               x[,paste0("log.",log.cols)] <- log(non.zero(x[,log.cols]))
     }
               
     return( x )     


}


