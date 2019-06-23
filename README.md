# vol2graylog
## Description
This project can run Volatility against a memory images and output the results to Graylog. The mechanism for parsing and sending the results to Graylog is contained in the `vol2log` folder and was originally obtained from [https://github.com/swelcher/vol2log](https://github.com/swelcher/vol2log).

## Pre-Requisites
- Volatility install
- Graylog with HTTP Gelf Input set up

## Usage
```
vol2graylog -d /path/to/output/directory -i /path/to/image -g 192.168.1.250 -p 12201 -v host
```

- `-d`: path to directory where Volatility results will be outputed and read from.
- `-i`: path to memory images to be analyzed
- `-g`: IP of Graylog instance
- `-p`: Port of listening HTTP Gelf Input in Graylog
- `-v`: Name of the host of mem image (to be assigned as `source` in Graylog)

To be continued...
