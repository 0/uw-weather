# What?

Fetches the latest data from the [University of Waterloo Weather Station](http://weather.uwaterloo.ca/), and displays them in a compact format.

# Why?

For displaying using some other means. For example, `perl fetch.pl | xmessage -default okay -center -file -` can be mapped to a key combination in the window manager.

# How?

There are a few self-explanatory configuration values at the top of the script, but they need not be changed.

The script takes no arguments and outputs values in the following format:

    current time (age of cache)
    current temperature (humidex/windchill)
    wind speed & direction
    relative humidity
    pressure value & trend