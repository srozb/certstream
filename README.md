# certstream

Unofficial certstream library written in Nim. 

## Installation

`nimble install`

## Quickstart

* Subscribe certstream with no filters

`certstream subscribe | jq -C`

* Monitor certificates matching given suffix

`certstream monitor .xyz .example.com .google.com`

* Fuzzy match certificates with given keywords

`certstream fuzzyHunt secure logging authentication password`

* Run as systemd service and dump matching certificates

`certstream daemon -c config.yml` - consult `config.yml.dist` for details

You will probably want to create appropriate service file for systemd.

## Usage

```
certstream -h

Usage:
  certstream {SUBCMD}  [sub-command options & parameters]
where {SUBCMD} is one of:
  help       print comprehensive or per-cmd help
  subscribe  Subscribe and print raw certstream messages to stdout. Output data can be piped to jq or processed further as json.
  fuzzyHunt  Match certstream with given keywords using lavenstein distance.
  monitor    Match certstream with given domain suffix(es).
  daemon     Run daemon based on provided configuration file. (Consult config.yml.dist)

certstream {-h|--help} or with no args at all prints this message.
certstream --help-syntax gives general cligen syntax help.
Run "certstream {help SUBCMD|SUBCMD --help}" to see help for just SUBCMD.
Run "certstream help" to get *comprehensive* help.
```

You can also import this library inside your project.