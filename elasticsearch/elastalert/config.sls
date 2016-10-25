{% from "elasticsearch/elastalert/map.jinja" import elastalert, elastalert_init with context %}

include:
  - elasticsearch.elastalert.service

{% set elastalert_addons = salt.pillar.get('elasticsearch:elastalert:addons', []) %}
{% if elastalert_addons %}
install_elastalert_addon_packages:
  pip.installed:
    - pkgs: {{ elastalert_addons }}
    - upgrade: True
{% endif %}

generate_elastalert_config_file:
  file.managed:
    - name: /etc/elastalert/config.yaml
    - makedirs: True
    - contents: |
        {{ elastalert.settings|yaml(False)|indent(8) }}
    - watch_in:
        - service: elastalert_service_running

{% for rule in salt.pillar.get('elasticsearch:elastalert:rules', [])  %}
generate_elastalert_rules_{{ rule.name }}_file:
  file.managed:
    - name: {{ elastalert.settings.rules_folder}}/{{ rule.name }}.yaml
    - makedirs: True
    - contents: |
        {{ rule.settings|yaml(False)|indent(8) }}
    - watch_in:
        - service: elastalert_service_running
{% endfor %}
