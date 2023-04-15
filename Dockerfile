FROM mubox/base

# Create directories
RUN mkdir -p \
  /var/log/gomicro \
  /var/microbox \
  /opt/microbox/hooks

# Don't use apt-get to install influx until 1.0 gets to the main repo

# Install influxdb and rsync
# RUN apt-get update -qq && \
#     apt-get install -y apt-transport-https && \
#     curl -sL https://repos.influxdata.com/influxdb.key | apt-key add - && \
#     echo "deb https://repos.influxdata.com/ubuntu trusty stable" \
#       > /etc/apt/sources.list.d/influxdb.list && \
#     apt-get update -qq && \
#     apt-get install -y rsync influxdb && \
#     apt-get clean all && \
#     rm -rf /var/lib/apt/lists/*

RUN apt-get update -qq && \
    apt-get install -y rsync && \
    apt-get clean all && \
    rm -rf /var/lib/apt/lists/*

RUN wget -O /tmp/influxdb_1.1.1_amd64.deb https://dl.influxdata.com/influxdb/releases/influxdb_1.1.1_amd64.deb && \
    dpkg -i /tmp/influxdb_1.1.1_amd64.deb && \
    rm /tmp/influxdb_1.1.1_amd64.deb

# Download pulse
RUN curl \
      -f \
      -k \
      -o /usr/local/bin/pulse \
      https://s3.amazonaws.com/tools.microbox.cloud/pulse/linux/amd64/pulse && \
    chmod 755 /usr/local/bin/pulse

# Download md5 (used to perform updates in hooks)
RUN curl \
      -f \
      -k \
      -o /var/microbox/pulse.md5 \
      https://s3.amazonaws.com/tools.microbox.cloud/pulse/linux/amd64/pulse.md5

# Install hooks
RUN curl \
      -f \
      -k \
      https://s3.amazonaws.com/tools.microbox.cloud/hooks/pulse-stable.tgz \
        | tar -xz -C /opt/microbox/hooks

# Download hooks md5 (used to perform updates)
RUN curl \
      -f \
      -k \
      -o /var/microbox/hooks.md5 \
      https://s3.amazonaws.com/tools.microbox.cloud/hooks/pulse-stable.md5

WORKDIR /data

# Run runit automatically
CMD [ "/opt/gomicro/bin/microinit" ]
