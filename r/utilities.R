## ------------------------------------------------------------------------

#' @title Customization of summary function
#' @description Customization of summary function that includes a summary of the number of values that are na, infinite, or not numeric.  Also reports n records, min, mean, max, and several quantiles. 
#' @param  v \code{numeric vector} values to summarize
#' @param  hist \code{boolean} if TRUE, will plot a histogram, as well as output text to console
#' @keywords summary
#' @export

summary.na<-function(v, hist=F) {
     print(data.frame(num.records=length(v)))
     print(data.frame(min=min(v,na.rm=T),mean=mean(v,na.rm=T),max=max(v,na.rm=T)))
     print(quantile(v,na.rm = T,probs = c(.1,.25,.5,.75,.9)))
     print(d<-data.frame(num.records.na=sum(is.na(v)),  num.records.infinite=sum(is.infinite(v)),  num.records.not.numeric=sum(!is.numeric(v))))
     if (hist) {
          o<-par()
          layout(matrix(c(1,1,2),ncol = 3,nrow = 1, byrow = TRUE),widths=c(2,1))
          hist(v)
          barplot(as.matrix(d),horiz = F)
          par<-o
     }
}

## ------------------------------------------------------------------------
#' @title Customization of ls function
#' @description Customization of ls function, that includes size (memory) of all objects or data in current session environment.
#' @keywords ls
#' @export

ls.objects <- function (pos = 1, pattern, alpha=F,head=FALSE, n=10) {
     napply <- function(names, fn) sapply(names, function(x)
          fn(get(x, pos = pos)))
     names <- ls(pos = pos, pattern = pattern)
     obj.class <- napply(names, function(x) as.character(class(x))[1])
     obj.mode <- napply(names, mode)
     obj.type <- ifelse(is.na(obj.class), obj.mode, obj.class)
     obj.size <- napply(names, object.size)
     obj.prettysize <- sapply(obj.size, function(r) prettyNum(r, big.mark = ",") )
     obj.dim <- t(napply(names, function(x)
          as.numeric(dim(x))[1:2]))
     vec <- is.na(obj.dim)[, 1] & (obj.type != "function")
     obj.dim[vec, 1] <- napply(names, length)[vec]
     out <- data.frame(names,obj.type, obj.size,obj.prettysize, obj.dim)
     names(out) <- c("Name","Type", "Size", "PrettySize", "Rows", "Columns")
     if (!alpha)
          out <- out[order(out[["Size"]], decreasing=T), ]
     else
          out <- out[order(out[["Name"]], decreasing=F), ]
     out <- out[c("Name","Type", "PrettySize", "Rows", "Columns")]
     names(out) <- c("Name","Type", "Size", "Rows", "Columns")
     row.names(out)<-NULL
     if (head)
          out <- head(out, n)
     out
}

## ------------------------------------------------------------------------
#' @title Simple capitalization function
#' @description Simple function to capitalize first letter or string, for prettying up plot titles, legends, axes, etc.
#' @param  string \code{character} string to capitalize
#' @return character
#' @export

#borrowed from Hmisc package
capitalize<-function (string) 
{
     capped <- grep("^[^A-Z]*$", string, perl = TRUE)
     substr(string[capped], 1, 1) <- toupper(substr(string[capped], 
                                                    1, 1))
     return(string)
}

## ------------------------------------------------------------------------
#' @title internal, temporary replication of merge function to explicitly indicate merging of spatial object with a data.frame
#' @description perhaps remove?
# no export

merge.sp<-function(x, y, by=intersect(names(x), names(y)), by.x=by, 
     	by.y=by, all.x=TRUE, suffixes = c(".old",""), 
		incomparables = NULL, ...) {
	if (!('data' %in% slotNames(x)))
		stop('x has no attributes')
	d <- x@data
	d$donotusethisvariablename976 <- 1:nrow(d)
	
	y <- unique(y)
# email, RJH, 12/24/13, replace:
#	i <- apply(y[, by.y, drop=FALSE], 1, paste) %in% 
#			apply(x@data[, by.x, drop=FALSE], 1, paste)
# by the following block:

	i <- apply(y[, by.y, drop=FALSE], 1, 
		function(x) paste(x, collapse='_')) %in% 
		apply(x@data[, by.x, drop=FALSE], 1, 
			function(x) paste(x, collapse='_'))
	if (all(!i))
		warning("none of the records in y can be matched to x")
# 	else if (sum(!i) > 0)
# 		warning(paste(sum(!i), "records in y cannot be matched to x"))

	y <- y[i, ,drop=FALSE]
	if (isTRUE(any(table(y[, by.y]) > 1)))
		stop("'y' has multiple records for one or more 'by.y' key(s)")
	
	if (!all.x)
		y$donotusethisvariablename679 <- 1
	
	d <- merge(d, y, by=by, by.x=by.x, by.y=by.y, suffixes=suffixes, 
		incomparables=incomparables, all.x=TRUE, all.y=FALSE)
	d <- d[order(d$donotusethisvariablename976), ]
	d$donotusethisvariablename976 <- NULL
	rownames(d) <- row.names(x)
	x@data <- d

	if (! all.x) {
		x <- x[!is.na(x@data$donotusethisvariablename679), ,drop=FALSE] 
		x@data$donotusethisvariablename679 <- NULL
	}
	x
}

## ------------------------------------------------------------------------
#' @title internal function to save log file
#' @description saves log file in directory specified.  uses specified prefix.  reads names of existing logs in the directory to specify a number, incrementing it from the largest number of that file type.
#' @param text  \code{character} text for writeLines 
#' @param dir  \code{character} name of directory location 
#' @param filename  \code{character} file name prefix 
#' @return ext \code{character} file extension
# no export

save.log <- function(text, filename, ext="txt") {
     #rough draft... to clean up
     
     #      ext="txt"
#      filename="file"
#      boo<-c("file001.txt","file002.txt","file005.txt","file011.txt","otherfile.txt")

     cache.check()
     
     orig.dir <- getwd()
     setwd(file.path(cache.dir.global,"logs"))
     x<-list.files()
     if ( length(x)==0 )
          x6<-paste( filename, "001", ".", ext, collapse="", sep="" )
     else {
               
          x2<-sapply(x, FUN=function(n) substr(n, start=1, stop=(nchar(n)-nchar(ext)-1-3)))
          x3<-x[x2==filename]

          if ( length(x3)==0 )
                    x6<-paste( filename, "001", ".", ext, collapse="", sep="" )
          else {
               
               x4<-sapply(X = x3, FUN = function(n) {
                    start <- nchar(n) - (nchar(ext)+1) -3 +1
                    as.numeric( substr( x=n, start=start, stop=(start+3-1)) ) }
                    )
               x5<-max(x4)+1
               x6<-paste( filename, zeropad(x5, LEN = 3), ".", ext, collapse="", sep="" )
          }
     }

     {
     if ( is.data.frame(text) | is.matrix(text) )
          write.csv( text, file=x6, row.names=F )
     else                     #if (is.vector)
          writeLines( text=text, con=x6 )
     }
     
     setwd(orig.dir)
}

## ------------------------------------------------------------------------
#' @title non zero approximation
#' @export

non.zero<-function(x) {
     vapply(x,FUN.VALUE=1,FUN=function(x1) {
          if (is.na(x1) || is.nan(x1) || x1<=0)  
               return(10^-6)
          else return(x1)
     })
}

## ------------------------------------------------------------------------
#' @title y or n to logical
# no export

as.logical.y.n <- function( x ) {
     
     if (  sum( !(x %in% c("y","n")) )>0  )
          stop("Please only include values \'y\' or \'n\'")
     x[x=="y"] <- T
     x[x=="n"] <- F
     return(x)
}


## ------------------------------------------------------------------------
#' @title Multiplot (for ggplot)
#' @description Function for combining multiple ggplots, without using facet. From R Cookbook for Graphics, http://www.cookbook-r.com/Graphs/Multiple_graphs_on_one_page_(ggplot2); and published at http://peterhaschke.com/Code/multiplot.R
#' @param ... \code{ggplot objects}
#' @param plotlist \code{list of ggplot objections} (optional)
#' @param cols \code{numeric} number of columns, defaults to 1
#' @export

multiplot <- function(..., plotlist=NULL, file, cols=1, layout=NULL) {
  require(grid)

  plots <- c(list(...), plotlist)

  numPlots = length(plots)

  if (is.null(layout)) {
    layout <- matrix(seq(1, cols * ceiling(numPlots/cols)),
                    ncol = cols, nrow = ceiling(numPlots/cols))
  }

 if (numPlots==1) {
    print(plots[[1]])

  } else {
    grid.newpage()
    pushViewport(viewport(layout = grid.layout(nrow(layout), ncol(layout))))

    for (i in 1:numPlots) {
      matchidx <- as.data.frame(which(layout == i, arr.ind = TRUE))

      print(plots[[i]], vp = viewport(layout.pos.row = matchidx$row,
                                      layout.pos.col = matchidx$col))
    }
  }
}



## ------------------------------------------------------------------------
#' @title see.missing
#' @export

see.missing <- function(x) {
     if ( !is.null(attr(class(x),"package")) && attr(class(x),"package") == "sp")    
          apply(x@data, MARGIN=2, FUN=function(x) sum(is.na(x)))
     else 
          apply(x, MARGIN=2, FUN=function(x) sum(is.na(x)))
}


## ------------------------------------------------------------------------
#' @title cols.change.name
#' @export
col.change.name <- function( df, col.old, col.new ) {
     i<-which(names(df)==col.old)
     names(df)[i]<-col.new
     return(df)
}

## ------------------------------------------------------------------------
#' @title cols.remove
#' @export
cols.remove <- function( df, cols ) {
     df<-df[,!(names(df) %in% cols)]
     return(df)
}


