FROM continuumio/miniconda3:latest

# Add conda to path
ENV PATH /opt/conda/bin:$PATH

# Install requirements into the root environment
ADD environment.yml /environment.yml
RUN conda env update -n root -f /environment.yml && \
    conda clean -y -t


