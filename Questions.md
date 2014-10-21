#Questions 2014/10/21

#Question 1
library(RCurl)
url.exists("http://www.cffex.com.cn/fzjy/mrhq/201410/01/index.xml") 
## Why return TRUE?
## open it in browser,the page turn to  http://www.cffex.com.cn/error_page/error_404.html


#Question 2
library(httr)
http_status(GET("http://www.cffex.com.cn/fzjy/mrhq/201410/19/index.xml"))
url_ok("http://www.cffex.com.cn/fzjy/mrhq/201410/19/index.xml") #F
url_ok("http://www.cffex.com.cn/fzjy/mrhq/201410/20/index.xml") #F

url_success("http://www.cffex.com.cn/fzjy/mrhq/201410/20/index.xml") #T
url_success("http://www.cffex.com.cn/fzjy/mrhq/201410/19/index.xml",.header=T) #T


#Question 3

dat <- readLines(con = "http://www.shfe.com.cn/data/dailydata/kx/kx20140930.dat",
encoding = "UTF-8")
js <- jsonlite::fromJSON(dat)
View(js$o_curinstrument)

xml <- XML::xmlParse("http://www.cffex.com.cn/fzjy/mrhq/201409/30/index.xml",isURL = T)
dt <- XML::xmlToDataFrame(xml,stringsAsFactors = F)