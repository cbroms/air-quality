# Air Quality Server

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
WorkingDirectory=/home/cbroms/air-quality/server
ExecStart=/home/cbroms/air-quality/server/.build/release/App serve --env production --hostname 0.0.0.0 --port 5001
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=vapor-air-quality-server

[Install]
WantedBy=multi-user.target
```

Lives in `/etc/systemd/system/air-quality-server.service`

Build the server for production:

```
swift build -c release \
    --static-swift-stdlib
```

```
systemctl daemon-reload
systemctl enable air-quality-server
systemctl start air-quality-server
systemctl stop air-quality-server
systemctl restart air-quality-server
```
