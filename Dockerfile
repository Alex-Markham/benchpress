FROM continuumio/miniconda3

WORKDIR /myappdir

RUN conda update -n base -c defaults conda

RUN conda install -c bioconda bioconductor-rgraphviz
RUN conda install -c bioconda bioconductor-graph
RUN conda install -c bioconda bioconductor-rbgl

RUN echo "install.packages(\"gRbase\", dependencies=TRUE, repos=\"https://cran.rstudio.com\");" | R --no-save
RUN echo "install.packages(\"pcalg\", repos=\"https://cran.rstudio.com\")" | R --no-save
RUN echo "install.packages(\"BiDAG\", repos=\"https://cran.rstudio.com\")" | R --no-save
RUN echo "install.packages(\"bnlearn\", repos=\"https://cran.rstudio.com\")" | R --no-save
RUN echo "install.packages(\"r.blip\", repos=\"https://cran.rstudio.com\")" | R --no-save
# For the R version of GOBNILP
RUN echo "install.packages(\"reticulate\", repos=\"https://cran.rstudio.com\")" | R --no-save
# Tidyvese may be replaced by r-ggplot2 since it is very big
RUN echo "install.packages(\"tidyverse\", repos=\"https://cran.rstudio.com\")" | R --no-save 
RUN echo "install.packages(\"stringr\", repos=\"https://cran.rstudio.com\")" | R --no-save
RUN echo "install.packages(\"reshape\", repos=\"https://cran.rstudio.com\")" | R --no-save
RUN echo "install.packages(\"gridExtra\", repos=\"https://cran.rstudio.com\")" | R --no-save
RUN echo "install.packages(\"argparser\", repos=\"https://cran.rstudio.com\")" | R --no-save

# For the Python version of GOBNILP needed for the R version. Obs a licence is needed for theis. 
# Register on the Gurobi webpage and send a mail to the support since it does not work by default with Docker.
# A so called floating licence is needed.
RUN conda install -c http://conda.anaconda.org/gurobi gurobi
RUN conda install -c numba numba
RUN conda install -c anaconda scipy
RUN conda install -c bioconda pygraphviz
RUN conda install -c anaconda scikit-learn networkx pandas 
RUN conda install -c conda-forge matplotlib

RUN git clone https://bitbucket.org/jamescussens/pygobnilp.git

#
# Installing the C version of the GOBNILP library
#
COPY scipoptsuite-6.0.1.tgz .
RUN tar xvf scipoptsuite-6.0.1.tgz
RUN rm scipoptsuite-6.0.1.tgz
RUN apt update
# needed for gcc
RUN apt install -y build-essential 

# SCIP Optimization Suite needs the following external libraries:
# - the Z Compression Library (ZLIB: `libz.a` or `libz.so` on Unix systems)
#   Lets you read in `.gz` compressed data files.
# - the GNU Multi Precision Library (GMP: `libgmp.a` or `libgmp.so` on Unix systems)
#   Allows ZIMPL to perform calculations in exact arithmetic.
# - the Readline Library (READLINE: `libreadline.a` or `libreadline.so` on Unix systems)
#   Enables cursor keys and file name completion in the SCIP shell.
RUN apt install -y libgmp3-dev
RUN apt install -y zlib1g-dev
RUN apt install -y libreadline-dev
WORKDIR /myappdir/scipoptsuite-6.0.1
RUN make

# Installing GOBNILP (instructions from https://bitbucket.org/jamescussens/gobnilp/src/master)
WORKDIR /myappdir/
RUN git clone https://bitbucket.org/jamescussens/gobnilp.git
WORKDIR /myappdir/gobnilp/
RUN ./configure.sh /myappdir/scipoptsuite-6.0.1/scip
RUN make
WORKDIR /myappdir/

RUN echo "Checking that it works"
RUN gobnilp/bin/gobnilp pygobnilp/data/asia_10000.dat


# Install java-jdk
RUN mkdir -p /usr/share/man/man1
RUN apt install -y default-jdk

# Running R-banchmarks
RUN mkdir /myappdir/benchmark
WORKDIR /myappdir/benchmark

ADD scripts scripts
ADD lib lib
# # Set R workdir some where
#RUN Rscript scripts/sample_dags.R --filename dags.rds --nodes 20 --parents 2 --samples 4 --seed 1
#RUN Rscript scripts/sample_bayesian_network_for_dag.R --input_filename dags.rds --filename bns.rds --seed 1
#RUN Rscript scripts/sample_data.R --filename data2n.rds --filename_bn bns.rds --samples 40 --seed 1
#RUN Rscript scripts/sample_data.R --filename data10n.rds --filename_bn bns.rds --samples 200 --seed 1
#RUN Rscript scripts/run_simulations.R --filename_dags dags.rds --filename_datas data2n.rds data10n.rds --timesvec 4 5 6
#RUN Rscript scripts/plot_results.R