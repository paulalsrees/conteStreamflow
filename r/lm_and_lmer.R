## ------------------------------------------------------------------------
char.to.formula<-function(x,y="log(flow.mean)") {
     formula(paste0(y,"~",
                      paste(x,collapse="+")))
}

