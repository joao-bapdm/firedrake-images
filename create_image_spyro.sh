#!/bin/bash

# This file creates a spyro image featuring the cplex optimizer.
# In order to build it, the executable for (proprietary) CPLEX version 20.10
# is needed, besides the corresponding installation config file.

# Build the base computational environment image
docker build --file Dockerfile.env --tag spyro-env:latest .
# Add firedrake instalation
docker build --file Dockerfile.firedrake --tag spyro-firedrake:Firedrake_20220223.1 .
# Add spyro
docker build --file Dockerfile.spyro --tag spyro-vanilla:87629a1 .
# Add CPLEX optimizer
docker build --file Dockerfile.cplex --tag spyro-cplex:20.10 .

# Remove intermediary images
docker rmi spyro-env:latest
docker rmi spyro-firedrake:Firedrake_20220223.1
docker rmi spyro-vanilla:87629a1

