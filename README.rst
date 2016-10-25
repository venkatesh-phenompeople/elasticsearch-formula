=============
elasticsearch
=============

SaltStack formula for building an Elasticsearch node with a focus on clustered deployments.

.. note::

    See the full `Salt Formulas installation and usage instructions
    <http://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html>`_.


Available states
================

.. contents::
    :local:

``elasticsearch``
-----------------

Install and configure Elasticsearch.

``elasticsearch.repository``
----------------------

Set up the Elasticsearch package repository on the host.

``elasticsearch.cluster``
----------------------

Update elasticsearch config to set the unicast hosts with the other Elasticsearch nodes.

``elasticsearch.plugins``
----------------------

Install Elasticsearch plugins specified by Pillar

``elasticsearch.kibana``
------------------------

Install and configure Kibana for use with Elasticsearch. Proxied by Nginx

``elasticsearch.elastalert``
----------------------------

Install and configure `Elastalert<http://elastalert.readthedocs.io/en/latest/>_` for generating alerts from Elasticsearch data.

``elasticsearch.elastalert.config``
-----------------------------------

Update the configuration and rules for Elastalert and restart the service.

Template
========

This formula was created from a cookiecutter template.

See https://github.com/mitodl/saltstack-formula-cookiecutter.
