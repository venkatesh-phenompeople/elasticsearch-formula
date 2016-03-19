{% from "elasticsearch/map.jinja" import elasticsearch with context %}

include:
  - elasticsearch

elasticsearch-config:
  file.managed:
    - name: {{ elasticsearch.conf_file }}
    - text: |
        {{ elasticsearch.configuration_settings | yaml(False) | indent(8) }}
    - watch_in:
      - service: elasticsearch
    - require:
      - pkg: elasticsearch
