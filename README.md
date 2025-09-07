# foo2zjs-cups-docker
specialized lightweight and amd64-only docker image to run cups with foo2zjs-based printer. **requires foo2zjs hotplug driver functionality to be installed first on the host because Docker can't seem to get the firmware into the printer**.

printer driver is exclusively installed from compiled source linked in an archive the repo. work based on [anujdatar's cups-docker](https://github.com/anujdatar/cups-docker) repo.

## `docker compose` exampless
```yaml
services:
  cups:
    image: ghcr.io/quantrieupcyt/foo2zjs-cups-docker:main
    container_name: cups
    hostname: cups
    ports:
      - 631:631/tcp
      - 5353:5353/udp
    environment:
      - CUPSADMIN=printeruser
      - CUPSPASSWORD=printerpassword
      - TZ=Asia/Ho_Chi_Minh
    devices:
      - /dev/bus/usb:/dev/bus/usb
    volumes:
      - ./cups-config:/etc/cups
      #- /etc/localtime:/etc/localtime:ro
    restart: on-failure
 ```