# vim:set ft=dockerfile:
FROM continuumio/miniconda3:latest
LABEL maintainer="https://github.com/cehbrecht/shearwater"
LABEL Description="ShearWater WPS" Vendor="Birdhouse" Version="0.1.0"
    
# Update Debian system
RUN apt-get update && apt-get install -y \
    build-essential \
&& rm -rf /var/lib/apt/lists/*

# Update conda
RUN conda update -n base conda

COPY . /opt/wps

WORKDIR /opt/wps

# Create conda environment with PyWPS
RUN ["conda", "env", "create", "-n", "wps", "-f", "environment.yml"]

# Install WPS
RUN ["/bin/bash", "-c", "source activate wps && pip install -e ."]

RUN echo "source activate wps" > ~/.bashrc
ENV PATH /opt/conda/envs/wps/bin:$PATH

