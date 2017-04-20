{% from "elasticsearch/map.jinja" import elasticsearch with context %}
{% if elasticsearch.elastic_stack %}
{% set elasticsearch_plugin_bin = 'elasticsearch-plugin' %}
{% else %}
{% set elasticsearch_plugin_bin = 'plugin' %}
{% endif %}

include:
  - elasticsearch

{% for plugin in salt.pillar.get('elasticsearch:plugins', {}) %}
install_{{ plugin.name }}_plugin:
  cmd.run:
    - name: /usr/share/elasticsearch/bin/{{ elasticsearch_plugin_bin }} install {{ plugin.get('location', plugin.name) }}
    - unless: "[ $(/usr/share/elasticsearch/bin/{{ elasticsearch_plugin_bin }} list | grep {{ plugin.name }} | wc -l) -eq 1 ]"
    - watch_in:
        - service: elasticsearch_service

{% if plugin.get('config') %}
plugin_configuration_for_{{ plugin.name }}:
  file.append:
    - name: /etc/elasticsearch/elasticsearch.yml
    - text: |
        {{ plugin.config | yaml(False) | indent(8) }}
    - watch_in:
        - service: elasticsearch_service
{% endif %}
{% endfor %}
