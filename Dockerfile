# Use the official Ubuntu image as a base
FROM ubuntu:22.04

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary dependencies including sudo
RUN apt-get update && apt-get install -y \
    wget \
    gnupg2 \
    lsb-release \
    postgresql \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Add ClickHouse repository and install ClickHouse
RUN apt-get update && \
    apt-get install -y apt-transport-https ca-certificates dirmngr && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 8919F6BD2B48D754 && \
    echo "deb https://packages.clickhouse.com/deb stable main" | tee /etc/apt/sources.list.d/clickhouse.list && \
    apt-get update && \
    apt-get install -y clickhouse-server clickhouse-client && \
    rm -rf /var/lib/apt/lists/*

# Download and install Uptrace (verify the URL and command)
RUN wget -O uptrace https://github.com/uptrace/uptrace/releases/download/v1.7.7/uptrace-linux-amd64 && \
    chmod +x uptrace && \
    mv uptrace /usr/local/bin/

# Create necessary directories
RUN mkdir -p /etc/uptrace /etc/clickhouse-server

# Create a basic Uptrace configuration
RUN echo "ch:\n\
  addr: localhost:9000\n\
  user: default\n\
  password: ''\n\
  database: uptrace\n\
\n\
listen: 0.0.0.0:14317\n\
\n\
projects:\n\
  - id: 1\n\
    name: myproject\n\
    token: secret" > /etc/uptrace/uptrace.yml

# Expose necessary ports
EXPOSE 5432 8080 8123 9000 14317

# Start PostgreSQL, ClickHouse, and Uptrace (adjust the Uptrace command)
CMD service postgresql start && \
    service clickhouse-server start && \
    uptrace serve
