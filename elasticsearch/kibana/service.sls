{% from "elasticsearch/map.jinja" import elasticsearch with context %}

{% if elasticsearch.use_elastic_stack %}
kibana_service:
  service.running:
    - name: kibana
    - enable: True
    - watch:
        - file: configure_kibana

kibana_nginx_service:
  service.running:
    - name: nginx
    - enable: True
    - watch:
        - file: configure_kibana_nginx
{% endif %}