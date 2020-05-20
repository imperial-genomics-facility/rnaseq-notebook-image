FROM imperialgenomicsfacility/base-notebook-image:release-v0.0.3
LABEL maintainer="imperialgenomicsfacility"
LABEL version="0.0.1"
LABEL description="Docker image for running RNA-Seq analysis"
ENV NB_USER vmuser
ENV NB_UID 1000
USER root
WORKDIR /
RUN apt-get -y update &&   \
    apt-get install --no-install-recommends -y \
      gcc \
      g++ \
      make \
      libgcc-5-dev \
      gfortran \
      libncurses5-dev \
      libbz2-1.0 \
      libbz2-dev \
      liblzma5  \
      liblzma-dev \
      git  && \
    apt-get purge -y --auto-remove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
USER $NB_USER
WORKDIR /home/$NB_USER
ENV TMPDIR=/home/$NB_USER/.tmp
ENV PATH=$PATH:/home/$NB_USER/miniconda3/bin/
RUN rm -f /home/$NB_USER/environment.yml && \
    rm -f /home/$NB_USER/Dockerfile
COPY environment.yml /home/$NB_USER/environment.yml
COPY Dockerfile /home/$NB_USER/Dockerfile
COPY examples /home/$NB_USER/examples
USER root
RUN chown ${NB_UID} /home/$NB_USER/environment.yml && \
    chown ${NB_UID} /home/$NB_USER/Dockerfile && \
    chown -R ${NB_UID} /home/$NB_USER/examples
USER $NB_USER
WORKDIR /home/$NB_USER
RUN . /home/$NB_USER/miniconda3/etc/profile.d/conda.sh && \
    conda env update -q -n notebook-env --file /home/$NB_USER/environment.yml && \
    jupyter serverextension enable --sys-prefix jupyter_server_proxy && \
    conda clean -a -y && \
    rm -rf /home/$NB_USER/.cache && \
    rm -rf /tmp/* && \
    rm -rf ${TMPDIR} && \
    mkdir -p ${TMPDIR} && \
    mkdir -p /home/$NB_USER/.cache && \
    find miniconda3/ -type f -name *.pyc -exec rm -f {} \;
RUN mkdir -p /home/$NB_USER/bin && \
    wget -q -O /home/$NB_USER/bin/fastp http://opengene.org/fastp/fastp && \
    chmod a+x /home/$NB_USER/bin/fastp && \
    wget -q -O /tmp/samtools-1.10.tar.bz2 https://github.com/samtools/samtools/releases/download/1.10/samtools-1.10.tar.bz2 && \
    cd /tmp && \
    tar -jxf /tmp/samtools-1.10.tar.bz2 && \
    cd samtools-1.10/ && \
    ./configure --prefix=/home/vmuser/bin/samtools && \
    make && \
    make install && \
    cd /home/$NB_USER/ && \
    rm -rf /tmp/samtools-1.10 && \
    wget -O /tmp/fastqc_v0.11.9.zip https://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.11.9.zip && \
    cd /tmp && \
    unzip fastqc_v0.11.9.zip && \
    mv /tmp/FastQC /home/$NB_USER/bin && \
    chmod a+x /home/$NB_USER/bin/FastQC/fastqc && \
    cd /home/$NB_USER/ && \
    rm -rf /tmp/fastqc_v0.11.9.zip && \
    wget -O /tmp/2.7.3a.tar.gz https://github.com/alexdobin/STAR/archive/2.7.3a.tar.gz && \
    cd /tmp && \
    tar -xzf 2.7.3a.tar.gz && \
    mv STAR-2.7.3a /home/$NB_USER/bin && \
    cd /home/$NB_USER/ && \
    rm -rf /tmp/2.7.3a.tar.gz && \
    wget -O /tmp/0.6.5.tar.gz https://github.com/FelixKrueger/TrimGalore/archive/0.6.5.tar.gz && \
    cd /tmp && \
    tar -xzf 0.6.5.tar.gz && \
    mv TrimGalore-0.6.5 /home/$NB_USER/bin && \
    cd /home/$NB_USER/ && \
    rm -rf /tmp/0.6.5.tar.gz && \
    git clone https://github.com/igvteam/igv.js.git && \
    cd igv.js;npm install;npm run build
ENV PATH /home/$NB_USER/bin:${PATH}
ENV PATH /home/$NB_USER/bin/samtools/bin/:${PATH}
ENV PATH /home/$NB_USER/bin/FastQC/:${PATH}
ENV PATH /home/$NB_USER/bin/STAR-2.7.3a/bin/Linux_x86_64_static/:${PATH}
ENV PATH /home/$NB_USER/bin/TrimGalore-0.6.5:${PATH}
EXPOSE 8888
EXPOSE 8080
CMD [ "notebook" ]
