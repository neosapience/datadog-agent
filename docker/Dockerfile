FROM datadog/agent:7.20.2

COPY ./docker/openssl.cnf /etc/ssl/openssl.cnf

RUN set -xe \
  && echo '#!/bin/sh' > /usr/sbin/policy-rc.d 	\
  && echo 'exit 101' >> /usr/sbin/policy-rc.d 	\
  && chmod +x /usr/sbin/policy-rc.d 		\
  && dpkg-divert --local --rename --add /sbin/initctl 	\
  && cp -a /usr/sbin/policy-rc.d /sbin/initctl 	\
  && sed -i 's/^exit.*/exit 0/' /sbin/initctl 		\
  && echo 'force-unsafe-io' > /etc/dpkg/dpkg.cfg.d/docker-apt-speedup 		\
  && echo 'DPkg::Post-Invoke { "rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true"; };' > /etc/apt/apt.conf.d/docker-clean 	\
  && echo 'APT::Update::Post-Invoke { "rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true"; };' >> /etc/apt/apt.conf.d/docker-clean 	\
  && echo 'Dir::Cache::pkgcache ""; Dir::Cache::srcpkgcache "";' >> /etc/apt/apt.conf.d/docker-clean 		\
  && echo 'Acquire::Languages "none";' > /etc/apt/apt.conf.d/docker-no-languages 		\
  && echo 'Acquire::GzipIndexes "true"; Acquire::CompressionTypes::Order:: "gz";' > /etc/apt/apt.conf.d/docker-gzip-indexes 		\
  && echo 'Apt::AutoRemove::SuggestsImportant "false";' > /etc/apt/apt.conf.d/docker-autoremove-suggests

RUN mkdir -p /run/systemd && echo 'docker' > /run/systemd/container
RUN apt-get update \
  && apt-get install -y --no-install-recommends gnupg2 curl ca-certificates \
  && curl -fsSL https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/7fa2af80.pub | apt-key add - \
  && echo "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64 /" > /etc/apt/sources.list.d/cuda.list &&     echo "deb https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1804/x86_64 /" > /etc/apt/sources.list.d/nvidia-ml.list \
  && apt-get purge --autoremove -y curl \
  && rm -rf /var/lib/apt/lists/* # buildkit

ENV CUDA_VERSION=10.1.243
ENV CUDA_PKG_VERSION=10-1=10.1.243-1
RUN apt-get update \
  && apt-get install -y --no-install-recommends cuda-cudart-$CUDA_PKG_VERSION cuda-compat-10-1 \
  && ln -s cuda-10.1 /usr/local/cuda \
  && rm -rf /var/lib/apt/lists/* # buildkit

RUN echo "/usr/local/nvidia/lib" >> /etc/ld.so.conf.d/nvidia.conf \
  && echo "/usr/local/nvidia/lib64" >> /etc/ld.so.conf.d/nvidia.conf # buildkit

ENV PATH=/usr/local/nvidia/bin:/usr/local/cuda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV LD_LIBRARY_PATH=/usr/local/nvidia/lib:/usr/local/nvidia/lib64
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=utility
ENV NVIDIA_REQUIRE_CUDA=cuda>=10.1 brand=tesla,driver>=384,driver<385 brand=tesla,driver>=396,driver<397 brand=tesla,driver>=410,driver<411

ENV PATH=/opt/datadog-agent/bin/agent/:/opt/datadog-agent/embedded/bin/:$PATH

RUN /opt/datadog-agent/embedded/bin/pip install nvidia-ml-py3==7.352.0 \
    && rm -rf /root/.cache/pip

COPY ./configs/nvml.py /etc/datadog-agent/checks.d/
COPY ./configs/nvml.yaml /etc/datadog-agent/conf.d/
