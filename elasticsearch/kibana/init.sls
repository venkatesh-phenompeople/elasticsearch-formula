{% from "elasticsearch/map.jinja" import elasticsearch with context %}

{% if elasticsearch.use_elastic_stack %}
include:
  - .install
  - .configure
  - .service
{% endif %}