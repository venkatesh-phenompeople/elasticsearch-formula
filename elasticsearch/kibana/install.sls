{% from "elasticsearch/kibana/map.jinja" import kibana with context %}
{% from "elasticsearch/map.jinja" import elasticsearch with context %}

include:
  - elasticsearch.repository

install_kibana:
  pkg.installed:
    - pkgs: {{ kibana.pkgs }}
    - reload_modules: True
    - update: True
    - require:
    {% if elasticsearch.elastic_stack %}
      - pkgrepo: configure_elasticsearch_package_repo
    {% else %}
    {% for name, version in elasticsearch.products.items() %}
      - pkgrepo: configure_{{ name }}_package_repo
    {% endfor %}
    {% endif %}