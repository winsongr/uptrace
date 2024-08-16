# Use the official PostgreSQL image as a base
FROM postgres:14

# Set environment variables
ENV POSTGRES_DB=uptrace
ENV POSTGRES_USER=uptrace
ENV POSTGRES_PASSWORD=uptrace

# Install necessary dependencies
RUN apt-get update && apt-get install -y \
    wget \
    gnupg2 \
    lsb-release \
    && rm -rf /var/lib/apt/lists/*

# Add ClickHouse repository
RUN wget -O - https://apt.clickhouse.com/CLICKHOUSE-KEY.GPG | apt-key add -
RUN echo "deb https://apt.clickhouse.com/deb/stable/ main/" | tee /etc/apt/sources.list.d/clickhouse.list

# Install ClickHouse
RUN apt-get update && apt-get install -y \
    clickhouse-server \
    clickhouse-client \
    && rm -rf /var/lib/apt/lists/*

# Download and install Uptrace
RUN wget -O uptrace https://github.com/uptrace/uptrace/releases/latest/download/uptrace-linux-amd64
RUN chmod +x uptrace && mv uptrace /usr/local/bin/

# Copy configuration files (you need to create these)
COPY uptrace.yml /etc/uptrace/uptrace.yml
COPY clickhouse-config.xml /etc/clickhouse-server/config.xml

# Expose necessary ports
EXPOSE 5432 8080 8123 9000

# Start PostgreSQL, ClickHouse, and Uptrace
CMD service postgresql start && \
    service clickhouse-server start && \
    uptrace migrate && \
    uptrace serve
