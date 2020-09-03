# REF: https://github.com/ngi644/datadog_nvml
FROM datadog/agent:7.20.2
RUN /opt/datadog-agent/embedded/bin/pip install nvidia-ml-py3==7.352.0 \
    && rm -rf /root/.cache/pip

COPY ./configs/nvml.py /etc/datadog-agent/checks.d/
COPY ./configs/nvml.yaml.default /etc/datadog-agent/conf.d/
