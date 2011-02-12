#!/usr/bin/perl

use strict;
use warnings;

use Class::Date qw(now);
use HTTP::Request;
use LWP::UserAgent;
use XML::Simple;

### Config
my $url = 'http://weather.uwaterloo.ca/waterloo_weather_station_data.xml';
my $cache = '/tmp/uw-weather-cache';
my $cache_timeout = 20 * 60; # 20 minutes

### Trim whitespace.
sub trim {
	my $s = shift;
	$s =~ s/^\s+//;
	$s =~ s/\s+$//;
	return $s;
}

### Extract the date from the XML data.
sub xml_date {
	my $data = shift;

	my $date = sprintf("%04d-%02d-%02d %02d:%02d", @{$data}{qw(
		observation_year
		observation_month_number
		observation_day
		observation_hour
		observation_minute
	)});

	return Class::Date->new($date);
}

my $data;
my $cache_avail = 0;
my $do_fetch = 0;

my $xs = XML::Simple->new();

### Determine if there is a cache and if it is up to date.
my $cache_data = eval { $xs->XMLin($cache) };
if ($@) {
	$do_fetch = 1;
} else {
	$cache_avail = 1;

	if (now() - xml_date($cache_data) > $cache_timeout) {
		$do_fetch = 1;
	} else {
		$data = $cache_data;
	}
}

### Fetch updated data.
if ($do_fetch) {
	my $request = HTTP::Request->new(GET => $url);
	my $ua = LWP::UserAgent->new;
	my $response = $ua->request($request);

	if ($response->code() != 200) {
		print $response->status_line(), "\n\n";
		warn $response->status_line();
	}

	my $xml = $response->decoded_content();

	$data = eval { $xs->XMLin($xml) };
	if ($@) {
		if ($cache_avail) {
			$data = $cache_data;
		} else {
			my $msg = "No data to display";
			print "$msg\n";
			die $msg;
		}
	} else {
		if (open(my $cache_, '>', $cache)) {
			print { $cache_ } $xml;
			close($cache_);
		} else {
			my $msg = "Cannot open cache for writing";
			print $msg, "\n\n";
			warn $msg;
		}
	}
}

### Display data.
## Time
my ($hr, $min) = (localtime(time()))[2,1];
printf("%02d:%02d", $hr, $min);
my $age = now() - xml_date($data);
if ($age > $cache_timeout) {
	printf(" (%d s)\n", $age);
}
printf("\n");
## Temperature
printf("%.1f C", $data->{temperature_current_C});
if ($data->{humidex_C} =~ /^[-.\d ]+$/) {
	printf(" (%.1f C)", $data->{humidex_C});
} elsif ($data->{windchill_C} =~ /^[-.\d ]+$/) {
	printf(" (%.1f C)", $data->{windchill_C});
}
printf("\n");
## Precipitation
# TODO
## Wind
printf("%.1f km/h %s\n", $data->{wind_speed_kph}, trim($data->{wind_direction}));
## Max/min temp
# TODO
## Humidity
printf("%.1f %%RH\n", $data->{relative_humidity_percent});
## Pressure
printf("%d kPa %s\n", $data->{pressure_kpa}, lc(trim($data->{pressure_trend})));
