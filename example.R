## interactive/manual example

library(rlang)
library(pryr)
library(tibble)
library(jsonlite)
library(cli)
library(plyr)
library(dplyr)
library(purrr)
library(tryCatchLog)
library(magrittr)
library(crayon)

# Initialise a master meta collection
.master <<- meta_master_env()

# define a function
f = function(x) {
  a = sqrt(3)
  b = log(x)
  c = 'fff'
}

# monitor the function

m = monitor(f)

# from here, the function f has been changed in its living environment and start to store values, but wouldnot be able to store the correct
# status as we need to wrap the function in a try to be able to subscribe to a raised error event.

f(2)

# wrap it in the tryCatchMeta
# This is where we are able to track the status of the output 1 for ok and 0 for raised an error.

f_ = try_catch_wrapper(f)


f_(3);f_(5);f_(99);f_('qwerty')

f_('-3')
# to have a function working you need at least one time where the function raised NO error.


# Show data collected by the system for a specific function
collec = .master$get_collection('f')
collec$get('raw')



trace(f, exit=quote(browser()))



# Function that would show green flag for all parameters because they are all correct but the function raised an error
# because it is the combination of parameters that doesnot work
# the system learn the links between parameters.

# for example, x is function of the dim of a dataframe
# try to access values that are not defined.

#x>0, y>0, dim(z) = 0,0

g = function(x, y, z) {
  if(x<0) stop('x should be positive')
  if(y<0) stop('y should be positive')

}


j = function(x, y, data) {
  row = round(sqrt(x))
  column = round(log(y))
  message('Trying access row ', row, ' for a data.frame of dim ', nrow(data), ' ', length(data))

  data = data[row,]
  return(data)
}


## FAIL SAFE g FUNCTION

m = monitor(j)

m_ = try_catch_wrapper(j)

## run the function a couple of times
for(i in seq(1, 2500, 100)) {
  max_row = round(runif(1) * 150)
  data = iris[1:max_row,]
  m_(i,5, data)
}


m_(50000,5, data)


x = sample(10)
dim1 = x + sample(10)
a = data.frame(x = x, dim  = dim1, status = 1)

plot(a$x, a$dim, xlim = c(0,20), ylim = c(0,20))
lines(1:20)


# A function that would work for classes numeric and character for parameter x,
# but when class numeric, parameter y work only if it is of class list

