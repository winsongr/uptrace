# Use the official Docker image for Uptrace
FROM uptrace/uptrace:latest

# Set environment variables for Uptrace
ENV UPTRACE_DSN=your_uptrace_dsn_here
ENV UPTRACE_LOG_LEVEL=debug

# Copy the Uptrace configuration file if you have one
COPY uptrace-config.yaml /etc/uptrace/uptrace-config.yaml

# Expose the necessary ports
EXPOSE 14318

# Run Uptrace by default
CMD ["uptrace", "run"]
