{% from "elasticsearch/map.jinja" import elasticsearch with context %}

include:
  - elasticsearch

{% for plugin in salt.pillar.get('elasticsearch:plugins', {}) %}
{% if elasticsearch.version == '5.x' %}
install_{{ plugin.name }}_plugin:
  cmd.run:
    - name: /usr/share/elasticsearch/bin/elasticsearch-plugin install {{ plugin.get('location', plugin.name) }}
    - unless: "[ $(/usr/share/elasticsearch/bin/elasticsearch-plugin list | grep {{ plugin.name }} | wc -l) -eq 1 ]"
    - watch_in:
        - service: elasticsearch
{% else %}
install_{{ plugin.name }}_plugin:
    - name: /usr/share/elasticsearch/bin/plugin install {{ plugin.get('location', plugin.name) }}
    - unless: "[ $(/usr/share/elasticsearch/bin/plugin list | grep {{ plugin.name }} | wc -l) -eq 1 ]"
    - watch_in:
        - service: elasticsearch
{% endif %}

{% if plugin.get('config') %}
plugin_configuration_for_{{ plugin.name }}:
  file.append:
    - name: /etc/elasticsearch/elasticsearch.yml
    - text: |
        {{ plugin.config | yaml(False) | indent(8) }}
    - watch_in:
        - service: elasticsearch
{% endif %}
{% endfor %}
