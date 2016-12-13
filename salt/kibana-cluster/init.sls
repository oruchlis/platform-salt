{% set kibana_version = salt['pillar.get']('kibana-cluster:version', '5.1.1-linux-x64') %}
{% set kibana_directory = salt['pillar.get']('kibana-cluster:directory', '/opt/pnda') %}

kibana-kibana:
  group.present:
    - name: kibana
  user.present:
    - name: kibana
    - gid_from_name: True
    - groups:
      - kibana

kibana-create_kibana_dir:
  file.directory:
    - name: {{kibana_directory}}
    - user: kibana
    - group: kibana
    - dir_mode: 777
    - makedirs: True

kibana-dl_and_extract_kibana:
  archive.extracted:
    - name: {{kibana_directory}}
    - source: https://artifacts.elastic.co/downloads/kibana/kibana-{{ kibana_version }}.tar.gz
    - source_hash: https://artifacts.elastic.co/downloads/kibana/kibana-{{ kibana_version }}.tar.gz.sha1
    - archive_format: tar
    - if_missing: {{kibana_directory}}/kibana-{{kibana_version }}

kibana-copy_configuration_kibana:
  file.managed:
    - name: {{kibana_directory}}/kibana-{{ kibana_version }}/config/kibana.yml
    - source: salt://kibana/files/kibana.yml
    - user: kibana
    - group: kibana

kibana-copy_kibana_upstart:
  file.managed:
    - source: salt://kibana/templates/kibana.init.conf.tpl
    - name: /etc/init/kibana.conf
    - mode: 644
    - template: jinja
    - context:
      installdir: {{kibana_directory}}/kibana-{{ kibana_version }}

kibana-service:
  service.running:
    - name: kibana
    - enable: True
    - watch:
      - file: kibana-copy_kibana_upstart
      - file: {{kibana_directory}}/kibana-{{ kibana_version }}/config/kibana.yml
