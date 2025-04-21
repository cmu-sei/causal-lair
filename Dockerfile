# AIR Tool
#
# Copyright 2024 Carnegie Mellon University.
#
# NO WARRANTY. THIS CARNEGIE MELLON UNIVERSITY AND SOFTWARE ENGINEERING INSTITUTE
# MATERIAL IS FURNISHED ON AN "AS-IS" BASIS. CARNEGIE MELLON UNIVERSITY MAKES NO
# WARRANTIES OF ANY KIND, EITHER EXPRESSED OR IMPLIED, AS TO ANY MATTER
# INCLUDING, BUT NOT LIMITED TO, WARRANTY OF FITNESS FOR PURPOSE OR
# MERCHANTABILITY, EXCLUSIVITY, OR RESULTS OBTAINED FROM USE OF THE MATERIAL.
# CARNEGIE MELLON UNIVERSITY DOES NOT MAKE ANY WARRANTY OF ANY KIND WITH RESPECT
# TO FREEDOM FROM PATENT, TRADEMARK, OR COPYRIGHT INFRINGEMENT.
#
# Licensed under a MIT (SEI)-style license, please see license.txt or contact
# permission_at_sei.cmu.edu for full terms.
#
# [DISTRIBUTION STATEMENT A] This material has been approved for public release
# and unlimited distribution.  Please see Copyright notice for non-US Government
# use and distribution.
#
# This Software includes and/or makes use of Third-Party Software each subject to
# its own license.
#
# DM24-1686

# Use a specific Ubuntu version for reproducibility
FROM ubuntu:22.04

# Set environment variable to non-interactive to suppress prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Set Quarto version as a build argument for easy updates
ARG QUARTO_VERSION=1.5.57

# Install essential system packages and add CRAN repository
RUN apt-get update && apt-get install -y --no-install-recommends \
        bash \
        build-essential \
        ca-certificates \
        cargo \
        curl \
        dirmngr \
        gfortran \
        git \
        gnupg \
        libavfilter-dev \
        libcurl4-openssl-dev \
        libfontconfig1-dev \
        libfreetype6-dev \
        libfribidi-dev \
        libgif-dev \
        libgit2-dev \
        libharfbuzz-dev \
        libjpeg-dev \
        liblapack-dev \
        libmagick++-dev \
        libmariadb-dev \
        libmariadb-dev-compat \
        libopenblas-dev \
        libpng-dev \
        libpoppler-cpp-dev \
        librsvg2-dev \
        libsodium-dev \
        libssl-dev \
        libtiff5-dev \
        libudunits2-dev \
        libwebp-dev \
        libxml2-dev \
        lsb-release \
        iproute2 \
        pkg-config \
        software-properties-common \
        wget \
        zlib1g-dev && \
    # Add CRAN GPG key
    wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | \
    gpg --dearmor | tee /usr/share/keyrings/cran_ubuntu_keyring.gpg > /dev/null && \
    # Add CRAN repository
    echo "deb [signed-by=/usr/share/keyrings/cran_ubuntu_keyring.gpg] https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/" | \
    tee /etc/apt/sources.list.d/cran.list && \
    # Update package lists to include CRAN repository and upgrade existing packages
    apt-get update && apt-get upgrade -y && \
    # Install OpenJDK 17 from Ubuntu packages
    apt-get install -y --no-install-recommends \
        openjdk-17-jdk \
        r-base \
        build-essential \
        pandoc \
        libtirpc-dev && \
    # Set JAVA_HOME and update PATH
    echo "export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64" >> /etc/profile.d/java.sh && \
    export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64 && \
    export PATH=$JAVA_HOME/bin:$PATH && \
    ln -s /usr/lib/jvm/java-17-openjdk-amd64 /usr/lib/jvm/default-java && \
    # Install Quarto
    wget https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/quarto-${QUARTO_VERSION}-linux-amd64.deb && \
    dpkg -i quarto-${QUARTO_VERSION}-linux-amd64.deb || apt-get install -y -f && \
    rm quarto-${QUARTO_VERSION}-linux-amd64.deb && \
    # Clean up APT caches and remove unnecessary packages to reduce image size
    apt-get purge -y --auto-remove wget gnupg software-properties-common dirmngr && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Set JAVA_HOME and update PATH for subsequent layers
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH=$JAVA_HOME/bin:$PATH

# Set the working directory inside the container
WORKDIR /app

COPY . /app

RUN mkdir -p /app/inst && \
    cd /app/inst && \
    curl -fsSLO "https://s01.oss.sonatype.org/content/repositories/releases/io/github/cmu-phil/tetrad-gui/7.6.5/tetrad-gui-7.6.5-launch.jar" && \
    cd /

# Install R dependencies using the provided R script
RUN Rscript scripts/install_dependencies.R

# Create a non-root user for running the application
RUN useradd -m appuser && chown -R appuser /app

# Switch to the non-root user
USER appuser

# Expose the port that Quarto will use
EXPOSE 4173

# Define the default command to run the Quarto preview server
CMD ["sh", "/app/scripts/run_quarto.sh"]
