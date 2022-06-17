# docker-spyro
Repo containing files for building a spyro docker image.

After cloning the repo, one may build the docker image either by using the Dockerfile

```Docker build -f Dockerfile --tag <tag name>:<tag version> .```

Or by running the shell script

```bash create_image_spyro.sh```

## Caveat
In order to build this image, one needs the [IBM ILOG CPLEX](https://www.ibm.com/products/ilog-cplex-optimization-studio)
executable ```ILOG_COD_EE_V20.10_LINUX_X86_64.bin```, which is proprietary software. This program can also be obtained under an academic licence.
