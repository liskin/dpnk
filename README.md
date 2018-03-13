# DPNK uploader in perl

## Manual upload

Usage: `dpnk_upload.pl <date> <from|to> <file.gpx|https://www.strava.com/activities/NNNNN>`

## Strava sync

Mark your activities as Commute and use hashtags `#dpnk_to` and `#dpnk_from`
in acitivity name. Then just run `dpnk_strava_sync.pl`

## Configuration

`~/.netrc`:

```
machine dpnk.dopracenakole.cz
    login your@e.mail
    password ...

machine www.strava.com
    account "_strava3_session=...; _strava4_session=..."
```

(Grab the cookies from your browser, e.g. via F12 and
looking into any HTTP request made to www.strava.com.)
