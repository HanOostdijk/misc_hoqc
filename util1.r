# util1.r

my_F_test <- function (modu,modr,g,k) {
  ru  = summary(modu)$r.squared # unrestricted
  rr  = summary(modr)$r.squared # restricted
  #g   = 4                       # number of restrictions 
  n   = length(modu$residuals)  # number of observations
  #k   = 6                       # number of regressors in unrestricted model
  Fs   = ((ru-rr)/g) / ((1-ru)/ (n-k)) # test statistic
  p   = 1- pf(Fs,g,n-k)     # prob restricted model holds
  list(Fs=Fs,p=p,g=g,k=k,n=n)
}

fit_stats <- function (myfit,stats=NULL) {
  s1 <- summary(myfit)
  f1 <- s1$fstatistic
  if (is.null(f1)) {
    fdata = rep(NaN,4)
  } else {
    fdata = c(f1[1],f1[2],f1[3], 1 - pf(f1[1],f1[2],f1[3]))
  }
  df <-
    data.frame(
      v = c(   length(s1$residuals),s1$sigma,s1$df,s1$r.squared,
        s1$adj.r.squared,fdata, AIC(myfit),BIC(myfit) )  )
  rownames(df) <-   c(  'n','res. std. err.', 'df1','df2','df3', 'r2', 'adj.r2', 'F-value', 'num.df', 'den.df', 'p-value','AIC', 'BIC'   )
  if (!is.null(stats)) {
    df =subset(df,rownames(df) %in% stats)
  }
  return(df)
}

regress_and_print <- function (df,f,cap1,cap2,ls,print_stats=F,stats=NULL,save_stats=NULL,digits=3) {
  # do a regression with formula f on data.frame df and print coefficients and statistics
  lm1=lm( as.formula(f),data=df) # use string f as formula for regression on data.frame df
  ls1 = paste0('lbltab',ls,'1') # label for first result table
  ls2 = paste0('lbltab',ls,'2') # label for second result table
  print(xtable(coef(summary(lm1)),caption=def_tab(ls1,cap1),digits=digits),
    table.placement='!htbp') # table with coefs
  if (print_stats) { # only statistics if requested
    print(xtable(fit_stats(lm1,stats),caption=def_tab(ls2,cap2),digits=digits), # table with stats
      include.colnames=F,table.placement='!htbp')
  }
  if (!is.null(save_stats)) { # save stats in global environment
    assign(save_stats,fit_stats(lm1,stats),envir = .GlobalEnv) 
  }
  invisible(lm1)
}

create_xtable<- function (df,filename,digits=3,rownames=F,table.placement='!htbp') {
  print(xtable(df,row.names=rownames, digits=digits),
   include.rownames=rownames,
    file=paste0(filename,'.tex'),floating=FALSE,table.placement=table.placement)
}

print_table_sbs <- function (files,label,cap,caps,scalebox=0.85) {
  # print xtables saved in files side-by-side
  # derived from Marcin Kosiński
  # http://stackoverflow.com/questions/23926671/side-by-side-xtables-in-rmarkdown
  cat('\\begin{table}[ht]\n')
  cat('\\centering\n')  
  for (i in 1:length(files)) {
    tc  = caps[[i]]
    tci = paste0(label,letters[i])
    f   = files[[i]]
    c = '\\subfloat[%s]{\\label{table:%s}\\scalebox{%.3f}{\\input{./%s}}}\\quad\n'
    cat(sprintf(c,tc,tci,scalebox,f))
  }
  cat(sprintf('\\caption{%s}\n',cap))
  cat(sprintf('\\label{table:%s}\n',label))
  cat('\\end{table}') 
}

example_print_table_sbs <- function () {
  create_xtable(summary(lm1)$coef,filename='lm1') 
  create_xtable(summary(lm3)$coef,filename='lm3') 
  
  files = c('lm1','lm3') # filenames (without suffix tex)
  label = 'lm13' # label (sublabels have suffix a,b, ...)
  cap   = 'comparison full and restricted model'
  caps  = c('full model', 'restricted model')
  print_table_sbs(files,label,cap,caps,scalebox=0.8) 
  
}

