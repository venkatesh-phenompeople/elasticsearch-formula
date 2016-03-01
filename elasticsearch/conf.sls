{% from "elasticsearch/map.jinja" import elasticsearch, elasticsearch_config with context %}

include:
  - elasticsearch

elasticsearch-config:
  file.managed:
    - name: {{ elasticsearch.conf_file }}
    - source: salt://elasticsearch/templates/conf.jinja
    - template: jinja
    - context:
      config: {{ elasticsearch_config }}
    - watch_in:
      - service: elasticsearch
    - require:
      - pkg: elasticsearch
