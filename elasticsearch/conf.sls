{% from "elasticsearch/map.jinja" import elasticsearch with context %}

include:
  - elasticsearch

elasticsearch-config:
  file.managed:
    - name: {{ elasticsearch.conf_file }}
    - contents: |
        {{ elasticsearch.configuration_settings | yaml(False) | indent(8) }}
    - makedirs: True
    - watch_in:
      - service: elasticsearch
    - require:
      - pkg: elasticsearch
