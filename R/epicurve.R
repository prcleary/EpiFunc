#' Create epicurve
#'
#' @import ggplot2
#' @import ISOweek
#' @import scales
#' @author Daniel Gardiner (daniel.gardiner@@phe.gov.uk)
#'
#' @param x a data.frame
#' @param date.col a character specifying the column containing dates
#' @param time.period a character of the desired time period for the epicurve, this can either be day, year, month, year.month, iso.year, iso.week, iso.year.week, use.date.col.as.is NOTE: if time.period = use.date.col.as.is the date.col will be treated as a factor and will be used as the x-axis
#' @param fill.by a character specifying the column to stratify by using colour
#' @param split.by a character specifying the column to facet by
#' @param shade.by a character specifying the column to stratify by using shading
#' @param start.at a character in the format "yyyy-mm-dd" to specify the start date for the epicurve
#' @param stop.at a character in the format "yyyy-mm-dd" to specify the stop date for the epicurve
#' @param xlab a character specifying the x-axis label for the epicurve
#' @param ylab a character specifying the y-axis label for the epicurve
#' @param fill.by.legend.title a character specifying the fill legend title
#' @param shade.by.legend.title a character specifying the shade legend title
#' @param angle a numeric to specify the x-axis label angel for the epicurve
#' @param col.pal a numeric specifying the colour palette  (range 1-8 inclusive) OR a character stating 'phe' to use the phe colour palette
#' @param label.breaks a numeric specifying the interval for x-axis label breaks
#' @param epi.squares a logical  specifying if episquares should be used on the epicurve
#' @param blank.background a logical  specifying if the figure background should be blank
#' @param na.rm a logical  specifying if missing dates should be removed from the epicurve
#'
#' @return an epicurve
#'
#' @examples
#' # set dummy data
#'
#' set.seed(2)
#'
#' data = data.frame(dates = sample(seq(as.Date('2014-01-01'), as.Date('2016-04-01'), by="day"), 200, replace = TRUE),
#'                   sex = c("Male", "Female"),
#'                   conf = sample(c("Confirmed", "Probable", "possible"), 200, replace = TRUE),
#'                   status = sample(c("Student", "Staff"), 200, replace = TRUE))
#'
#'
#' # use function
#'
#' epicurve(data,
#'          date.col = "dates")
#'
#' epicurve(data,
#'          date.col = "dates",
#'          start.at = "2015-01-01",
#'          stop.at = "2016-05-15")
#'
#' epicurve(data,
#'          date.col = "dates",
#'          start.at = "2015-01-01",
#'          stop.at = "2016-05-15",
#'          time.period = "iso.year.week",
#'          label.breaks = 2)
#'
#' epicurve(data,
#'          date.col = "dates",
#'          time.period = "month",
#'          xlab = "Month",
#'          angle = 0)
#'
#' epicurve(data,
#'          date.col = "dates",
#'          time.period = "month",
#'          shade.by = "sex",
#'          xlab = "Month",
#'          angle = 0)
#'
#' epicurve(data,
#'          date.col = "dates",
#'          time.period = "month",
#'          fill.by = "sex",
#'          xlab = "month",
#'          angle = 0)
#'
#' epicurve(data,
#'          date.col = "dates",
#'          fill.by = "conf",
#'          split.by = "sex")
#'
#' epicurve(data,
#'          date.col = "dates",
#'          time.period = "month",
#'          start.at = "2014-01-01",
#'          stop.at = "2016-04-20",
#'          fill.by = "sex",
#'          split.by = NULL,
#'          shade.by = "conf",
#'          xlab=NULL,
#'          ylab="Count",
#'          fill.by.legend.title = "Sex",
#'          shade.by.legend.title = NULL,
#'          angle = 0 ,
#'          col.pal = 6,
#'          label.breaks = 0,
#'          epi.squares = FALSE,
#'          na.rm = TRUE)
#'
#' data$dates.year.month = factor(format(data$dates, "%Y_%m"),
#'                                levels = unique(format(seq(min(data$dates),
#'                                                           max(data$dates), 1), "%Y_%m")))
#'
#' epicurve(x = data,
#'          date.col = "dates.year.month",
#'          time.period = "use.date.col.as.is",
#'          start.at = "2015-02-01",
#'          stop.at = "2015-06-22",
#'          fill.by ="status",
#'          split.by = NULL,
#'          shade.by = NULL,
#'          xlab = "Year_week",
#'          ylab="Count",
#'          fill.by.legend.title = "",
#'          shade.by.legend.title = NULL,
#'          angle = 90,
#'          col.pal = 1,
#'          label.breaks = 0,
#'          epi.squares = TRUE,
#'          na.rm = TRUE)
#'
#' @export
epicurve <- function(x,
                     date.col,
                     time.period = NULL,
                     start.at = NULL,
                     stop.at = NULL,
                     fill.by = NULL,
                     split.by = NULL,
                     shade.by = NULL,
                     xlab = NULL,
                     ylab = "Number of cases",
                     fill.by.legend.title = NULL,
                     shade.by.legend.title = NULL,
                     angle = 90,
                     col.pal = "phe",
                     label.breaks = 0,
                     epi.squares = TRUE,
                     blank.background = TRUE,
                     na.rm = TRUE) {

  # make sure x is a data.frame

  x = as.data.frame(x)

  # check values supplied to col.pal argument

  if(!(col.pal == "phe" | (col.pal >= 0 & col.pal <= 8))) {

    col.pal = "phe"

    warning("col.pal must either be an integer from 1 to 8 or 'phe',
            setting col.pal='phe'")
  }

  # check values supplied to time.period  argument

  if(is.null(time.period)){

    NULL

  } else if(!(time.period %in% c("day", "year", "month", "quarter", "year.month",
                                 "year.quarter", "iso.year", "iso.week",
                                 "iso.year.week", "use.date.col.as.is"))){

    stop("time.period must be either: day, year, quarter, month, year.quarter, year.month, iso.year, iso.week, iso.year.week, use.date.col.as.is, NULL")

  } else {

    NULL

  }


  ##############################################################################
  # Define factor column (date.col.temp) to be used along the x-axis

  # if time.period argument is use.date.col.as.is then use date.col along the x-axis

  time.period = ifelse(is.null(time.period), "NULL", time.period)

  if (time.period == "use.date.col.as.is") {

    x$date.col.temp = x[, date.col]

    # otherwise convert the date provided in date.col to the time period specified
    # in the time.period argument

  } else {

    # load get.dates function

    get.dates = function(x){

      if(class(x) == "Date"){

        NULL

      } else {

        stop("x is not a date")
      }

      df = data.frame(day = as.character(x),
                      year = format(x, "%Y"),
                      month = format(x, "%m"))

      df$year.month = paste0(df$year, df$month)

      df$iso.year = sapply(strsplit(ISOweek(x), "-W"), function(x) x[1])

      df$iso.week = sapply(strsplit(ISOweek(x), "-W"), function(x) x[2])

      df$iso.year.week = gsub("-W", "", ISOweek(x))

      df$quarter = NA

      df$quarter[!is.na(df$day)] = sprintf("%02d", ceiling(as.numeric(as.character(df$month[!is.na(df$day)]))/3))

      df$year.quarter = paste0(df$year, df$quarter)

      df[is.na(df$day), ] = NA

      df
    }

    # append the get.dates data.frame to the data.frame provided

    x = data.frame(x, get.dates(x[, date.col]))

    # create a new factor column for the x-axis (levels of the factor contain
    # dates ranging from start.at to stop.at)
    # if start.at and stop.at are not defined by user (i.e. are NULL) then
    # auto generate start.at/stop.at

    if(is.null(start.at)){

      start.at = min(x[, date.col]) - 5

    } else {

      start.at = as.Date(start.at)

    }

    if(is.null(stop.at)){

      stop.at = max(x[, date.col]) + 5

    } else {

      stop.at = as.Date(stop.at)

    }

    # if time.period are not defined by user (i.e. is NULL) then auto generate
    # time.period

    if(time.period == "NULL"){

      n.days = length(seq(start.at, stop.at, 1))

      if(n.days < 31*2){

        time.period = "day"

        if(is.null(xlab)) xlab = "Day"

      } else if (n.days < 365) {

        time.period = "iso.year.week"

        if(is.null(xlab)) xlab = "ISO Year Week"

      } else {

        time.period = "year.month"

        if(is.null(xlab)) xlab = "Year - Month"

      }

    } else {

      NULL

    }


    all.dates = get.dates(seq(start.at, stop.at, 1))

    all.dates = unique(all.dates[, time.period])

    x$date.col.temp = factor(x[, time.period],
                             levels = all.dates)


    # recode dates that fall outside of start.at/stop.at to NA

    x[!(as.character(x[, date.col]) %in%
          as.character(get.dates(seq(start.at, stop.at, 1))$day)), "date.col.temp"] = NA

    ## REMOVE MISSING DATES ##

    message(paste(sum(is.na(x$date.col.temp)), "rows have missing dates OR dates outside of the start/stop period"))

    if(na.rm) x = x[!is.na(x$date.col.temp), ]


    # order the levels of the date.col.temp column

    x$date.col.temp = factor(x$date.col.temp,
                             levels = sort(levels(x$date.col.temp)))

  }
  # we have now defined the factor column (date.col.temp) to be used along the x-axis
  ##############################################################################

  # order data for plotting

  if(!is.null(fill.by) & !is.null(shade.by)){

    x = x[order(x[, fill.by], x[, shade.by]), ]

  } else if(!is.null(fill.by)){

    x = x[order(x[, fill.by]), ]

  } else if(!is.null(shade.by)){

    x = x[order(x[, shade.by]), ]

  } else{

    NULL

  }

  # add dummy fill.by column if fill.by = NULL

  if(is.null(fill.by)){

    fill.by = ".dummy"

    x$.dummy = "dummy"

  } else {

    NULL

  }

  # create blocks column (this is to allow for epi squares to be added)

  x$blocks = 1:nrow(x)

  ##############################################################################
  # generate plot

  # generate main body of plot

  p = ggplot(x)

  # add geom_bar layer with either epi-squares  or no epi-squares

  if(epi.squares){

    p = p + geom_bar(aes_string(x = "date.col.temp", fill = fill.by, alpha = shade.by, group = "blocks"),
                     colour = "black")

  } else {

    p = p + geom_bar(aes_string(x = "date.col.temp", fill = fill.by, alpha = shade.by),
                     colour = "black")

  }

  # add labs

  p = p + labs(x = xlab, y = ylab)

  # add x-axis label breaks

  p = p + scale_x_discrete(breaks = levels(x$date.col.temp)[c(T, rep(F, label.breaks))],
                           drop = FALSE)

  # format y-axis breaks

  p = p + scale_y_continuous(breaks = function(x) unique(floor(pretty(seq(0, (max(x) + 1)*1.1)))),
                             expand = c(0,0))

  # add a solid line running across the bottom of the figure

  p = p + geom_hline(aes(yintercept = 0))

  # add theme aesthetics

  p = p + theme(title = element_text(size = 11, colour = "black", face = "bold"),
                axis.title.x = element_text(size = 13, face = "bold", margin = margin(t = 20, r = 0, b = 0, l = 0)),
                axis.title.y = element_text(size = 13, face = "bold", margin = margin(t = 0, r = 20, b = 0, l = 0)),
                axis.text.x = element_text(angle = angle, hjust = 0.5, vjust = 0, size = 11, face = "plain", colour = "black"),
                axis.text.y = element_text(hjust = 0, vjust = 0.5, size = 11, face = "plain", colour = "black"),
                legend.title = element_text(size = 11, face = "bold", colour = "black"),
                legend.text= element_text(hjust = 1, size = 11, face = "plain", colour = "black"),
                legend.position = "right",
                legend.justification = c(0.018,0.975),
                legend.text.align = 0,
                strip.text.y = element_text(hjust = 1, size = 13, colour = "black", face = "bold"),
                plot.margin = (unit(c(0.5, 0.5, 0.5, 0.5), "cm")))


  # remove background if specified in blank.background argument

  if (blank.background) {

    p = p + theme(panel.background = element_blank())

  } else {

    NULL

  }

  # add labels for the fill.by and shade.by legends

  p = p + labs(fill = fill.by.legend.title,
               alpha = shade.by.legend.title)

  # specify a range for the shady.by level

  p = p + scale_alpha_discrete(range = c(0.35, 1))

  # facet using split.by

  if (!is.null(split.by)) p = p + facet_grid(paste(split.by, ".", sep = "~"),
                                             drop = FALSE)

  # add the phe colour palette or a generic colour palette

  if (col.pal == "phe") {

    phe.cols = c("#822433", "#00B092", "#002776", "#EAAB00", "#8CB8C6",
                 "#E9994A",  "#00A551", "#A4AEB5", "#00549F", "#DAD7CB")

    p = p + scale_fill_manual(values = phe.cols, drop = FALSE)

  } else if (!is.null(col.pal)) {

    p = p + scale_fill_brewer(type = "qual",
                              palette = col.pal, drop = FALSE)

  } else {

    NULL

  }

  # remove dummy legend if fill.by = NULL

  if(fill.by == ".dummy"){

    p = p + theme(legend.position = "none")

  } else {

    NULL
  }

  # return the final output

  p

}
