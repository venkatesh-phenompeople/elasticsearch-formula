{% from "elasticsearch/map.jinja" import elasticsearch with context %}

include:
  - elasticsearch

elasticsearch-config:
  file.managed:
    - name: {{ elasticsearch.conf_file }}
    - source: salt://elasticsearch/templates/conf.jinja
    - template: jinja
    - context:
        config: {{ elasticsearch.configuration_settings }}
    - watch_in:
      - service: elasticsearch
    - require:
      - pkg: elasticsearch
