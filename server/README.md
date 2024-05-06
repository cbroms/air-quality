# Air Quality Server

A [vapor server](https://docs.vapor.codes/) that takes updates from the AirGradient sensor and saves them in a database. It provides routes to query the saved data over a given time range.

## Routes

```
+------+--------------------------------------------------+------------------------------------------------------------------------+
| GET  | /                                                |                                                                        |
+------+--------------------------------------------------+------------------------------------------------------------------------+
| POST | /sensors/:sensorName/measures                    | Post new measures for a sensor                                         |
+------+--------------------------------------------------+------------------------------------------------------------------------+
| GET  | /sensors/:sensorName/measures/:start/:end/simple | Get AQI, temp, CO2, and humidity measures for a sensor in a time range |
+------+--------------------------------------------------+------------------------------------------------------------------------+
| GET  | /sensors/:sensorName/measures/:start/:end/full   | Get all measures for a sensor in a time range                          |
+------+--------------------------------------------------+------------------------------------------------------------------------+
```

## Develop

To run the server:

```
swift run App
```

Specify a custom hostname and/or port:

```
swift run App --hostname 0.0.0.0 --port 5001
```

View all the routes:

```
swift run App routes
```

## Install as systemctl service

First, build the server for production:

```
swift build -c release \
    --static-swift-stdlib
```

Create a new service in `/etc/systemd/system/air-quality-server.service` with the following content, replacing `[path]` with the path to the directory containing the built sever:

```
[Unit]
Description=Air Quality Server
Requires=network.target
After=network.target

[Service]
Type=simple
User=cbroms
Group=cbroms
Restart=always
RestartSec=3
WorkingDirectory=/[path]/air-quality/server
ExecStart=/[path]/air-quality/server/.build/release/App serve --env production --hostname 0.0.0.0 --port 5001
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=vapor-air-quality-server

[Install]
WantedBy=multi-user.target
```

Apply the changes:

```
systemctl daemon-reload
```

Now you can control the server with standard `systemctl` commands:

```
systemctl enable air-quality-server
systemctl start air-quality-server
systemctl stop air-quality-server
systemctl restart air-quality-server
```
