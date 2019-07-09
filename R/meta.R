NULL_mc = 'NULL_MC'
class(NULL_mc) = 'NULL'

#' Object that hold all the meta_collection
meta_master_env = function() {
  this_env = env()
  mc_register = read_json('./.failSafer/mc_register.json')

  this = list(
    this_env = this_env,
    get_env = function() {
      return(get("this_env", this_env))
    },
    # get_ = function(.attr) {
    #   return(get(.attr, this_env))
    # },
    set = function(.attr, .value) {
      assign(.attr, .value, this_env)
    },
    add_collection = function(.n, .c) {
      assign(.n, .c, this_env)
    },
    get_collection = function(.n = NULL) {
      if(is.null(.n)) {
        Filter(function(x) 'meta_collection' %in% x, lapply(this_env, class))
      } else {
        get(.n, this_env)
      }
    },
    drop_collection = function() {

    })

  # just to have fancy names
  this = append(this,
                list(show_me = this$get_collection,
                     drop = this$drop_collection,
                     plug = this$add_collection))

  assign('this',this,envir=this_env)

  class(this) = append(class(this), 'meta_master_env')
  return(this)
}

get_collection = function(fun) {
  .master$get_collection(fun)
}

get_raw = function(fun) {
  get_collection(fun)
}

## constructor class meta_collection

#' @param .f A function to be monitor
#' @export
meta_collection = function(f) {

  this_env = environment()
  current_env = NULL
  raw = tibble()
  meta = NULL
  func = f
  env = env()
  status = 1

  this = list(
    this_env = this_env,
    get_current_env = function() {
      return(as.list(get('current_env', this_env)))
    },
    get_status = function() {
      return(get('status', this_env))
    },
    get = function(attr) {
      return(get(attr, this_env))
    },
    set = function(value) {
      return(assign('func', value, this_env))
    },
    set_status = function(value) {
      return(assign('status', value, this_env))
    },
    append = function(.env, .s = status) {
      assign('current_env', .env, envir = this_env)

      raw = format_current_env(.env, .s) %>%
        rbind.fill(raw) %>%
        assign('raw', ., this_env)
    })

  assign('this',this,envir=this_env)

  class(this) = append(class(this), "meta_collection")
  return(this)
}



#' @export
show_meta = function(.f) {
  .f = paste0(as.character(enexpr(.f)))
  # as.list(as.list(as.list(.master$this_env)[[.f]]$this_env)$current_env)
  .master$get_collection(.f)$get('meta')
}

#' @export
show_raw = function(.f) {
  .f = paste0(as.character(enexpr(.f)))
  .master$get_collection(.f)$get('raw')
}



#' Init a meta collection
#'
#' Initialisation of a mc means :
#' 1. upgrading the functions listed in  mc_register to be able to track those.
#' 2. telling the system to save the meta when R session is stopped.
#'
# .onLoad = function() {
#   # Create a new environement if no meta_master_env already exist
#   .master <<- meta_master_env()
#
#   # save meta_master_env on exit
#   # .Last <<- function() {
#   #
#   # }
# }

#' Add a patch to a function to be able to track it and update the mc_register
#'
#'
#' @param .func a function
#' @return a meta_collection object. The meta_collection associated with the function passed as argument
#'
#' @usage
#'
monitor = function(.func) {
  # Check where the function lives
  .mc_name = as.character(enexpr(.func))
  env = where(.mc_name)

  # Case to handle if the function come from a package or not
  if(startsWith(environmentName(env), 'package')) {

  } else {
    # TODO take into account the case where the meta colleciton already exist,
    c = meta_collection(.func)
    e = exprs(
      #This bit a code has been add by the failSafeR package to be able to track this function,
      # put in a try so it would never been a suspicious bit of code
      # on.exit(assign('current_env', current_env(), envir = c$get('this_env')), add = TRUE))
      # on.exit(store(current_env(), c), add = TRUE))
      base::on.exit({
        .c = .master$get_collection(.mc_name)
        .c$append(current_env())
        if(.c$get_status() == 0) pimp_my_mind(.mc_name)
        .c$set_status(1) # Always set status to 1 after exiting the function (act like a default value, is set to until until a raised error toggle value to 0)
      }, add = TRUE),
      !!body(.func))


    c_cctv = function() {}
    body(c_cctv) = as.call(c(as.name("{"), e))
    formals(c_cctv) = formals(.func)
    c$set(c_cctv)
  }

  .master$add_collection(.mc_name, c)
  assign(.mc_name, c_cctv, env)

  return(c)
}



# g = function(name) {
#   print(name)
#   name = 'f'
#
#   on.exit({
#     print(substitute(name))
#     print(name)
#   })
# }

#' @.fun result of monitor
try_catch_wrapper = function(.fun, ...) {
  name = as.character(enexpr(.fun))

  function(...) {
    tryCatchLog(
      withCallingHandlers({
        # do.call(.fun(), list(...))
        do.call(.fun, list(...))
      },
      error = function(e) {
        print('ERROR')

        c = .master$get_collection(name)
        c$set_status(0)

        # printOutput(fun[[1]], currentContent, metaTable)
        # pimp_my_mind(name)

      },
      warning = function(w) {
        print('WARNING')
        c = .master$get_collection(name)
        c$set_status(0)
        # printOutput(fun[[1]], currentContent, metaTable)
      })
    )
  }
}

#
# tryCatch({print(sqrt('ff'))},
#          finally = {
#            print('finally')
#          },
#          error = function(e) {
#            print('error++')
#          })

#' Turn an environment into a tibble where each element of the environment is a column of the tibble
#'
#' @param .e an environment
#' @param .s a status
format_current_env = function(.e, .s) {
  as.list(.e) %>%
    lapply(list) %>%
    as_tibble() %>%
    mutate(status =  list(.s))
}


# g = function() {
#   on.exit(print('exit'))
#   print(33)
#   sqrt('444')
# }
#
#
# f = function(x) {
#   print(3)
#   print(sqrt(x))
# }
#
# m = monitor(f)
#
#
# f_ = try_catch_wrapper(f)
#
# f(9)
#
#
# f_('llp')
#
# h = function(x, y = 4) {
#   print(x)
#   a = x
# }





#### META FACTORY

#' @param raw data that lives in raw attritute of a meta_collection
#' @param class String. The class of data to use (numeric, character, data.frame, ...)
#' @param meta_operation A function. Operation to apply on those meta
#'
#' The raw data as stored in the object raw in a meta collection
meta_factory = function(raw, target_class, meta_operation) {
  tibble(variable = colnames(raw)[colnames(raw) != 'status'])  %>%
    mutate(meta =
             purrr::map(variable,
                        function(var) {
                          raw %>%
                            select(var, status) %>%
                            filter_class(var, target_class) %>%
                            meta_operation() %>%
                            mutate_all(function(x) return(unlist(x))) ## warning Unknown or uninitialised column: 'get'. must come from here

                          # mutate_all(funs(unlist(.))) ## warning Unknown or uninitialised column: 'get'. must come from here
                        })
    )
}

extract_meta_factory = function(meta_factory) {
  return(meta_factory$meta[[1]])
}

# a = meta_factory(d, class = NULL, meta_operation = meta_class) # class
# #
# a = meta_factory(d, class = 'numeric', meta_operation = meta_numeric_sign) # numeric sign
#
# a = meta_factory(d, class = 'numeric', meta_operation = meta_numeric_length) # numeric sign
#
# a = meta_factory(d, target_class = 'character', meta_operation = meta_character_distinct) # numeric sign
#

a = meta_factory(d, NULL, meta_operation = meta_length) # numeric sign

filter_class = function(d, column, .class) {
  if(is.null(.class)) return(d)
  index = which(sapply(d[[column]], class) %in% .class)

  if(length(index) != 0) {
    d[index,] %>%
      select(!!sym(column), status)
  } else {
    return(NULL)
  }
}

# Explain characteristics of meta_* functions

meta_class = function(data) {
  if(is.null(data)) return(tibble())
  data %>% mutate_at(1, funs(sapply(., class)))
}

#' get the numeric sign of a tibble, but first filter the numeric values
meta_numeric_sign = function(data) {
  if(is.null(data)) return(tibble())
  data %>% mutate_at(1, function(x) ifelse(x>0, 'Positive', 'Negative'))
}

meta_numeric_length = function(data) {
  if(is.null(data)) return(tibble())
  data %>% rowwise() %>% mutate_at(1, function(x) length(x)) %>% ungroup()
}

# return identity as no specific operation is needed to get the character, as the meta_* functions only role is to provide the
# very first step. getting the meta.
meta_character_distinct = function(data) {
  if(is.null(data)) return(tibble())
  identity(data)
}


meta_length = function(data) {
  if(is.null(data)) return(tibble())
  data %>% rowwise() %>% mutate_at(1, function(x) length(x)) %>% ungroup()
}

meta_dim = function(data) {
  if(is.null(data)) return(tibble())
  data %>% rowwise() %>% mutate_at(1, function(x) dim(x)) %>% ungroup()
  # data %>% rowwise() %>% mutate_at(1, function(x) if(is.null(dim(x))) 'NA_MC' else dim(x)) %>% ungroup()
}



# PIMP META



# IA ON PIMP META

#' @param data List of dataframe, usually the result of pimp_contingency
beta_rules = function(data) {
  map(data, function(x) {
    if(nrow(x) == 0) return(data.frame())
    res = x %>%
      mutate(total = sum(Freq)) %>%
      rowwise() %>%
      mutate(p = mean(rbeta(1000, 1 + Freq, 1 + (total - Freq)))) %>%
      select_at(vars(1, p)) %>%
      arrange(desc(p)) %>%
      mutate(ptemp = paste0(100 * signif(p,2), '%'),
             level = ifelse(p> 0.5, 1, 0),
             p = ptemp) %>% select(-ptemp)
  })
}


# OUTPUT

#' Actual output of meta collection.
pimp_my_mind = function(.fun) {
  print(rule(center = " * DEBUG META COLLECTION * "))

  mc = .master$get_collection(.fun)
  d = mc$get('raw')

  column = colnames(d)[colnames(d) != 'status']

  arg_class = meta_factory(d, NULL, meta_operation = meta_class) %>% meta_proba() %>% rename('class' = 'meta')
  arg_numeric_sign = meta_factory(d, 'numeric', meta_operation = meta_numeric_sign) %>% meta_proba() %>% rename('numeric_sign' = 'meta')
  arg_length = meta_factory(d, NULL, meta_operation = meta_length) %>% meta_proba() %>% rename('length' = 'meta')
  arg_dim = meta_factory(d, 'data.frame', meta_operation = meta_dim) %>% meta_proba() %>% rename('dim' = 'meta')
  arg_character_distinct = meta_factory(d, 'character', meta_operation = meta_character_distinct) %>% meta_proba() %>% rename('character_distinct' = 'meta')
  meta_var = reduce(list(arg_class, arg_length, arg_dim, arg_numeric_sign, arg_character_distinct), full_join, by = 'variable')

  current = mc$get_current_env()

  meta_current = tibble(variable = names(mc$get_current_env())) %>%
    mutate(value = current,
           class = lapply(value, class),
           length = lapply(value, length),
           dim = lapply(value, dim),
           numeric_sign = lapply(value, function(x) if(is.numeric(x)) {
             ifelse(x>0, 'Positive', 'Negative')
           }),
           character_distinct = lapply(value, function(x) if(is.character(x)) x else NULL)) %>%
    select(-value)

  for(var in meta_var$variable) {
    if(!(current %>% has_name(var))) next

    # cat_input(var, current[[var]], green)

    meta_var_temp = meta_var %>% filter(variable == var)
    meta_current_temp = meta_current %>% filter(variable == var) %>% unlist()

    l = map(meta_var_temp, ~ data.frame(extract2(., 1))) %>%
      Filter(Negate(is_empty), .) %>%
      extract(-1)

    cat_input(var, current[[var]], green)

    for(meta in names(l)) {
      level = get_level(l[[meta]], 1)
      status = meta_current_temp[meta] %in% level
      if(status)
        cat('   ', green(symbol$tick), underline(meta))
      else
        cat('   ', red(symbol$cross), underline(meta), red(meta_current_temp[meta]), red('Unprobable'), green(paste('Probable', meta)), green(as.character(level[1])))

      print_shift(l[[meta]] %>% select(-level), shift = 5, row.names = FALSE,right = F)
    }
  }
}


get_level = function(data, .level) {
 data %>% filter(level == .level) %>% extract2(1) %>% unique()
}

print.fs = function(data, shift = 10, ...) {
  data$space = paste0(rep(' ', shift), collapse = '')
  data = data %>% select(space, everything())
  colnames(data) = c('', colnames(data)[-1])
  print.data.frame(data, row.names = FALSE, ...)
}

print_shift = function(data, shift = 10, ...) {
  data$space = paste0(rep(' ', shift), collapse = '')
  data = data %>% select(space, everything())
  # colnames(data) = c('', colnames(data)[-1])
  colnames(data) = rep('', length(data))

  print.data.frame(data, ...)
}


# Filter(~(nrow(.x) == 0), l)
#
#
#
# Filter(function(x) {print('kk');print(nrow(x));nrow(x) != 0}, l)
# a = Filter(function(x) {print('kk');print(nrow(x) != 0);print(nrow(x));nrow(x) != 0}, l)
#
#
# a = Filter(function(x) {nrow(x) == 0}, l)
#


# meta_current_temp = unlist(meta_current_temp[-1])
#
#
# meta_var_temp %>% mutate()
#
# map2(meta_var_temp, meta_current_temp, .f = function(x,y) {
#   x = data.frame(x)
#
#   if(nrow(x) == 0) return(x)
#
#   index = which(x[,1] == unlist(y))
#   if(length(index) > 0) {
#     x[index, 'win'] = 1
#   } else {
#     x[index, 'win'] = NA
#   }
#   return(x)
# })


# proba = get_proba(arg_class, i)
# if(class(current[[i]]) != proba[1,1]) {
#   cat_input(i, current[[i]])
#   # cat(red(symbol$bullet), 'Input Class', red(class(current[[i]])), symbol$play, 'Probable Class', green(data[1,1]), '\n')
#   # cat_mc(NULL, proba)
#   bgRed2 <- make_style(rgb(238/256, 132/256, 138/256), bg = TRUE)
#
#   cat(bgRed2(black(red(symbol$cross), 'Input Class', class(current[[i]]), symbol$play, 'Probable Class', data[1,1], '\n')))
#
# } else {
#
#   bgGreen2 <- make_style(rgb(166/256, 233/256, 144/256), bg = TRUE)
#   cat_input(i, current[[i]])
#   cat(bgGreen2(black(green(symbol$tick), 'Input Class', class(current[[i]]), symbol$play, 'Probable Class', data[1,1], '\n')))
#
#   # cat(green(symbol$tick), 'Input Class', green(class(current[[i]])), symbol$play, 'Probable Class', green(data[1,1]), '\n')
#   cat(white('      Here is what the system learn from x'), '\n')
# }



get_winner = function(meta_var) {
  meta_var %>% rowwise() %>% mutate_at(vars(-1), function(x) {
    max = x %>% data.frame() %>% filter(p == max(p))
    return(list(max))
  })
}



show_properties = function(input_class) {

}

meta_proba = function(.meta_factory) {
  .meta_factory %>%
    mutate(meta = pimp_contingency(meta)) %>%
    mutate(meta = map(meta, ~ filter(., status == 1))) %>%
    mutate(meta = beta_rules(meta))
}

#' return the probability table for each meta
get_proba = function(arg_class, i) {
  arg_class %>% filter(variable == i) %>% extract2('meta') %>% data.frame()
}

cat_mc = function(input, ...) {
  UseMethod('cat_mc', input)
}

cat_input = function(name, input, color_f) {
  if(is.data.frame(input)) {
    cat(bold('Input \n'), name, '=')
    print(head(input))
  } else if(is.character(input)) {
    cat(color_f(symbol$square), name, '=', paste0('"', input, '"'), '\n')
  } else {
    cat(color_f(symbol$square, name), '=', input, '\n')
  }
}


# cat_mc(3, data)

cat_mc.numeric = function(input, proba) {
  proba_value = proba[1, 'p']
  print('numeric')
  inputSign = ifelse(input>0, 'Positive', 'Negative')
  if(inputSign != as.character(proba_value)) {
    cat(ifelse(inputSign == proba[1,1], green(symbol$tick), red(symbol$cross)),
        bold('Numeric Sign: '),
        ifelse(inputSign == proba[1,1], green(inputSign), red(inputSign)),
        italic(symbol$arrow_right, 'Probable Sign :',  bold(green(proba[1,1]))),
        '\n')
    print(unname(data.frame(prob)), row.names = F, right = F)
  }
}

cat_mc.character = function(input, proba) {
  proba_value = proba[1, 'p']
  print('character')
}

cat_mc.NULL = function(input, proba) {
  print('NULL')
}


#' @param data A list of dataframes of metatables, usually result of meta_factory$meta
pimp_contingency = function(data) {
  map(data, function(x) {
    if(nrow(x) == 0) return(tibble())
    data.frame(table(x[[1]], x$status, dnn = c(names(x)[1], 'status')))
  })
}

#
# atomic_output = function() {
#
# }



#
# h = function(x, y = 4) {
#   print(x)
#   a = x
# }
#
# a = monitor(h)
#
# h(4, 8)
#


# show_raw(f)

#' Store an environment in an object meta collection
# store = function(env, c) {
#   assign('current_env', env, envir = c$get('this_env'))
# }


#
#
# h = function(d =3) {
#   a = 8
#   print('jjj')
#   b = 5
#
# }

# myFunc = function(x) {
#   print(x)
# }
#
#
# myFunc(77)
#
#
# f = function(){
#   print("ddd")
#   print(current_env())
#   return(.Primitive("(")(func))
# }
#
#
#
# unlockEnv('where', as.environment('package:pryr'))
# unlockBinding('where', as.environment('package:pryr'))
# assign("where ", f , as.environment('package:pryr'))
#
#
# environmentIsLocked(as.environment('package:pryr'))
#
#
# env_binding_unlock(as.environment('package:pryr'), 'where')
# env_binding_are_locked(as.environment('package:pryr'), 'where')
#
#
#
# unlockEnvironment <- function (env) {
#   return (new.env(parent=env))
# }
#
# e <- unlockEnvironment(as.environment('package:pryr'))

# when monitoring data from package can I load the entire package in globalenv
# eval the funciton in the envirnment of the package
# if you want to track a function from a package


#eval the local where function in the package environment.
# eval(where('dim'), envir = as.environment('package:pryr'))



where = function(x) {
  pryr::where(x)
}




# ################# change variable inside package #################
#
# library(snapCGH)
# my.genomePlot <- function (...)
# {
#
#   ## your custom code goes here
#   message("in my genomePlot")
# }
#
# unlockBinding("genomePlot", as.environment("package:snapCGH"))
# assign("genomePlot ", my.genomePlot , as.environment("package:snapCGH"))
# lockBinding("genomePlot ", as.environment("package:snapCGH"))
#
# #################################################
#
# `{` = function() {
#   # args = as.list(...)
#   # print('ddd')
#   .Primitive("{")
# }
#
# `{` = function(...) .Primitive("{")(print(as.list(...)), .Primitive("{")(...))
#
#
# `{` = function(...) .Primitive("{")(.Primitive("{")(...))
#
#
#
# `{` = function(...) do.call(.Primitive("{"), as.list(...))
#
#
# #if h belong to meta_collection class then use that specific function call.
# h(3)
#
#
# `{`()
#
# .Primitive("{")(a =4, print('8'), sqrt(4))
#
#
# .Primitive("{")(a =4, print('8'), sqrt(4))
#
# do.call()
#
#
# do.call()
#
#
# `{` = function() {
#   .Primitive("{")
# }
#
# `{` = identity(`{`)
# h()
#
# modif = function(func) {.Primitive("(")(func)}
#
# `(` = function(func) {
#   print('ddd')
#   return(.Primitive("(")(func))
# }
#
#
# `{` = function(code) {
#   print('dddsds')
#   .Primitive("{")(body(code))
# }
#
#
# do <- get("{")
#
#
# do = function(x) {
#   print('ssss')
#   return(.Primitive("{")(x))
# }
#
# `(` = function(x) x*x
#
#
# # Create function
# # function(arg1, arg2) {body} (`function`(alist(arg1, arg2), body, env)



#
# meta_character_distinct = function(.meta_class, .d) {
#   tibble(variable = colnames(.meta_class)[-length(.meta_class)])  %>%
#     mutate(character_distinct =
#              purrr::map(variable,
#                         function(.variable) {
#                           data = filter_class(c('factor', 'character'), .variable, .meta_class, .d) %>%
#                             select(.variable, status)
#                         })
#     )
# }
#
# meta_numeric_length = function(.meta_class, .d) {
#   tibble(variable = colnames(.meta_class)[-length(.meta_class)])  %>%
#     mutate(numeric_sign =
#              purrr::map(variable,
#                         function(.variable) {
#                           data = filter_class('numeric', .variable, .meta_class, .d) %>%
#                             select(.variable, status) %>%
#                             mutate_at(1, function(x) length(x))
#                         })
#     )
# }

