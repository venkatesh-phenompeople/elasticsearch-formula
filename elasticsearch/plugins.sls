{% for plugin in salt.pillar.get('elasticsearch:plugins', {}) %}
install_{{ plugin.name }}_plugin:
  cmd.run:
    - name: /usr/share/elasticsearch/bin/plugin install {{ plugin.get('location', plugin.name) }}
    - unless: "[ $(/usr/share/elasticsearch/bin/plugin list | grep {{ plugin.name }} | wc -l) -eq 1 ]"

{% if plugin.get('config') %}
plugin_configuration_for_{{ plugin.name }}:
  file.append:
    - name: /etc/elasticsearch/elasticsearch.yml
    - text: |
        {{ plugin.config | yaml(False) | indent(8) }}
{% endif %}
{% endfor %}
