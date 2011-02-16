# What?

Fetches the latest data from the [University of Waterloo Weather Station](http://weather.uwaterloo.ca/), and displays them in a compact format.

# Why?

For displaying using some other means. For example, `perl fetch.pl | xmessage -default okay -center -file -` can be mapped to a key combination in the window manager, producing:

![an informative window](http://0.github.com/uw-weather/screenshot.png).

# How?

There are a few self-explanatory configuration values at the top of the script, but they need not be changed.

The script takes no arguments and outputs values in the following format:

    current time (age of cache)
    current temperature (humidex/windchill)
    24 hour max / min temperature
    wind speed & direction
    precipitation per 1 hour / 24 hours
    relative humidity
    pressure value & trend
