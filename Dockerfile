# Docker image for spyro's base environment

FROM docker.io/ubuntu:20.04

MAINTAINER Joao Moreira <bapdmdias@usp.com>

USER root

##########   USAGE INSTRUCTIONS   ##########
# Build the image
# > docker build --file Dockerfile --tag spyro-stable:20.10 .
# Run the image
# > docker run --tty --interactive spyro-stable:20.10

##########   BASE CONFIGURATION   ##########
# Most commands in this section are copy pasted from Firedrake's base 
# Dockerfile at https://hub.docker.com/r/firedrakeproject/firedrake/dockerfile.
# We don't build FROM it so that the install command can be customized.

# Install necessary packages
RUN apt-get update \
    && apt-get -y dist-upgrade \
    && DEBIAN_FRONTEND=noninteractive apt-get -y install tzdata \
    && apt-get -y install curl vim \
                 openssh-client build-essential autoconf automake \
                 cmake gfortran git libblas-dev liblapack-dev \
                 libmpich-dev libtool mercurial mpich\
                 python3-dev python3-pip python3-tk python3-venv \
                 zlib1g-dev libboost-dev sudo \
                 # needed for scotch
                 bison flex \ 
                 # needed for seismicmesh
		 libcgal-dev \
                 # needed for cplex
                 default-jre \
    && rm -rf /var/lib/apt/lists/*

# Use supposedly sane locale
ENV LC_ALL C.UTF-8

# Set up user so that we do not run as root
RUN useradd -m -s /bin/bash -G sudo firedrake && \
    echo "firedrake:docker" | chpasswd && \
    echo "firedrake ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    ldconfig

# Change to firedrake user and go to homedir
USER firedrake
WORKDIR /home/firedrake

##########   INSTALL SOFTWARE   ##########
# Install firedrake
RUN curl -O https://raw.githubusercontent.com/firedrakeproject/firedrake/master/scripts/firedrake-install
RUN bash -c "python3 firedrake-install --no-package-manager --disable-ssh \
                                       --minimal-petsc \
                                       --package-branch Firedrake Firedrake_20220223.1 \
                                       --package-branch COFFEE Firedrake_20220223.1 \
                                       --package-branch ufl Firedrake_20220223.1 \
                                       --package-branch fiat Firedrake_20220223.1 \
                                       --package-branch FInAT Firedrake_20220223.1 \
                                       --package-branch tsfc Firedrake_20220223.1 \
                                       --package-branch PyOP2 Firedrake_20220223.1 \
                                       --package-branch loopy Firedrake_20220223.1 \
                                       --package-branch petsc Firedrake_20220223.1 \
                                       --package-branch pyadjoint 2019.1.2 \
                                       --remove-build-files \
                                       --venv-name=firedrake"

# Firedrake complains if this variable is not set
ENV OMP_NUM_THREADS=1

# Activate firedrake environment
ENV VIRTUAL_ENV=/home/firedrake/firedrake
ENV PATH=/home/firedrake/firedrake/bin:$PATH

# Install seismicmesh
RUN python -m pip install SeismicMesh==3.6.2
# Install spyro
RUN git clone --no-checkout https://github.com/NDF-Poli-USP/spyro.git && cd spyro/ \
    && git checkout -b master 87629a1 \
    && python -m pip install -e .
# Install ROL
RUN python -m pip install roltrilinos==0.0.9
RUN python -m pip install ROL==0.0.16

# Fix path so that libteuchosparameterlist.so.12 can be found (see link below)
# https://bitbucket.org/dolfin-adjoint/pyadjoint/issues/83/failed-to-import-rol-with-pyadjoint-201810
ENV LD_LIBRARY_PATH /home/firedrake/firedrake/lib/python3.8/site-packages/roltrilinos/lib/

# Get binary and installation config file for cplex
COPY ILOG_COD_EE_V20.10_LINUX_X86_64.bin cplex/
COPY installer.properties cplex/
# Install cplex
RUN cd cplex/ && bash ILOG_COD_EE_V20.10_LINUX_X86_64.bin -i silent -f installer.properties \
    && cd $HOME && sudo rm --recursive --force cplex/ \
    && python /home/firedrake/CPLEX/python/setup.py install

