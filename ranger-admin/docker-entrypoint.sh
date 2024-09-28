#!/bin/bash

# Proceed with the rest of the script
RANGER_VERSION=3.0.0-SNAPSHOT
TAR_FILE=ranger-${RANGER_VERSION}-admin.tar.gz
DOWNLOAD_URL=https://github.com/aakashnand/trino-ranger-demo/releases/download/trino-ranger-demo-v1.0/${TAR_FILE}

# Check if the tar file already exists
if [ -f "$TAR_FILE" ]; then
    echo "Tar file $TAR_FILE already exists."
else
    echo "Tar file $TAR_FILE does not exist. Downloading from $DOWNLOAD_URL..."
    wget $DOWNLOAD_URL -O $TAR_FILE
    echo "Download completed."
fi

# Extract the tar file and perform installation steps
tar xvf ranger-${RANGER_VERSION}-admin.tar.gz && \
cd /root/ranger-${RANGER_VERSION}-admin/ && \
cp /root/ranger-admin/install.properties /root/ranger-${RANGER_VERSION}-admin/ && \
sed -i 's|^SQL_CONNECTOR_JAR=.*|SQL_CONNECTOR_JAR=/root/postgresql.jar|' /root/ranger-${RANGER_VERSION}-admin/install.properties && \
echo "Verifying install.properties content..." && \
cat /root/ranger-${RANGER_VERSION}-admin/install.properties && \

# Make setup.sh executable and run it
chmod +x /root/ranger-${RANGER_VERSION}-admin/setup.sh && \
./setup.sh && \

# Start ranger-admin
ranger-admin start && \

# Set up Python virtual environment
python -m venv /root/ranger-admin/.env && \
. /root/ranger-admin/.env/bin/activate && \
pip install -r /root/ranger-admin/requirement.txt && \

# Run trino_service_setup.py
python /root/ranger-admin/trino_service_setup.py && \

# Tail the log files for monitoring
tail -f /root/ranger-${RANGER_VERSION}-admin/ews/logs/ranger-admin-*-.log
