import pytest


@pytest.mark.plugins
def test_plugin_installed(Command):
    assert 'cloud-aws' in Command.check_output(
        'sudo /usr/share/elasticsearch/bin/plugin list')


@pytest.mark.plugins
def test_plugin_config(File):
    assert File('/etc/elasticsearch/elasticsearch.yml').contains('aws')
