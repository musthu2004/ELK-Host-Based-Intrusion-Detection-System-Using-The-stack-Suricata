#!/bin/bash
# ============================================================
# Host-Based Intrusion Detection System (HIDS)
# Using ELK Stack (Elasticsearch, Logstash, Kibana) + Suricata
# Submitted by: Musthahsina
# ============================================================

# ─────────────────────────────────────────────
# 1) ELASTICSEARCH - INSTALLATION
# ─────────────────────────────────────────────

# Install Elasticsearch (deb package)
sudo dpkg -i elasticsearch-9.4.2-amd64.deb

# Enable and start Elasticsearch
sudo systemctl enable elasticsearch
sudo systemctl start elasticsearch

# Check Elasticsearch service status
sudo systemctl status elasticsearch

# Restart Elasticsearch (after config changes)
sudo systemctl restart elasticsearch

# Reset elastic user password
sudo /usr/share/elasticsearch/bin/elasticsearch-reset-password \
  -u elastic -i --url https://localhost:9200

# Fix permission errors (if any)
sudo chown -R elasticsearch:elasticsearch /etc/elasticsearch
sudo chown -R 750 /etc/elasticsearch

# Edit Elasticsearch config
sudo nano /etc/elasticsearch/elasticsearch.yml
# Inside elasticsearch.yml, set:
#   network.host: "0.0.0.0"
#   http.port: 9200
#   transport.host: "0.0.0.0"

# ─────────────────────────────────────────────
# 2) KIBANA - INSTALLATION & CONFIGURATION
# ─────────────────────────────────────────────

# Install Kibana
sudo dpkg -i kibana-9.4.2-amd64.deb

# Enable and start Kibana
sudo systemctl enable kibana
sudo systemctl start kibana
sudo systemctl status kibana

# Edit Kibana config
sudo nano /etc/kibana/kibana.yml
# Inside kibana.yml, set:
#   server.port: 5601
#   server.host: "0.0.0.0"
#   elasticsearch.hosts: ["https://localhost:9200"]
#   elasticsearch.username: "elastic"
#   elasticsearch.password: "<your_password>"
#   elasticsearch.ssl.certificateAuthorities: ["path/to/your/ca.crt"]
#   elasticsearch.ssl.verificationMode: full

# Generate Elasticsearch service account token for Kibana (alternative to username/password)
sudo /usr/share/elasticsearch/bin/elasticsearch-service-tokens create elastic/kibana kibana-token

# Generate Kibana enrollment token (if Kibana asks for it on first login)
sudo /usr/share/elasticsearch/bin/elasticsearch-create-enrollment-token -s kibana

# Access Kibana in browser:
# http://localhost:5601/login

# ─────────────────────────────────────────────
# 3) LOGSTASH - INSTALLATION & CONFIGURATION
# ─────────────────────────────────────────────

# Install Logstash
sudo dpkg -i logstash-9.4.2-amd64.deb

# Enable and start Logstash
sudo systemctl enable logstash
sudo systemctl start logstash
sudo systemctl status logstash

# Restart Logstash (after config changes)
sudo systemctl restart logstash

# Edit Logstash global config
sudo nano /etc/logstash/logstash.yml
# Inside logstash.yml, set:
#   path.data: "/var/lib/logstash"

# Create Logstash pipeline config (input/filter/output)
sudo nano /etc/logstash/conf.d/pipeline.conf

# Copy Elasticsearch CA certificate to Logstash
sudo mkdir -p /etc/logstash/certs
sudo cp /etc/elasticsearch/certs/http_ca.crt /etc/logstash/certs/
sudo chown -R logstash:logstash /etc/logstash/certs

# ─────────────────────────────────────────────
# 4) SURICATA - INSTALLATION & CONFIGURATION
# ─────────────────────────────────────────────

# Install Suricata
sudo apt install suricata

# Enable and start Suricata
sudo systemctl enable suricata
sudo systemctl start suricata
sudo systemctl status suricata

# Edit main Suricata config
sudo nano /etc/suricata/suricata.yaml
# Inside suricata.yaml:
#   - Set network interface under af-packet (e.g. interface: wlan0)
#   - Ensure eve-log (eve.json) output is enabled
#   - Set default-rule-path: /etc/suricata/rules
#   - Set rule-files:
#       - suricata.rules

# Create/edit custom Suricata rules file
sudo nano /etc/suricata/rules/suricata.rules
# Example rules:
# alert icmp any any -> any any (msg:"ICMP Ping Detected"; sid:1000001; rev:1;)
# alert tcp any any -> any 22 (msg:"SSH Brute-force attempt"; flow:to_server,established; content:"SSH"; depth:4; threshold: type threshold, track by_src, count 5, seconds 60; classtype:attempted-admin; sid:1000002; rev:1;)

# Test Suricata configuration & rules
sudo suricata -T -c /etc/suricata/suricata.yaml -v

# Check generated eve.json logs
ls /var/log/suricata/eve.json

# ─────────────────────────────────────────────
# 5) FILEBEAT - INSTALLATION & CONFIGURATION
# ─────────────────────────────────────────────

# Install Filebeat
sudo dpkg -i filebeat-9.4.2-amd64.deb

# Enable and start Filebeat
sudo systemctl enable filebeat
sudo systemctl start filebeat
sudo systemctl status filebeat

# Edit Filebeat config
sudo nano /etc/filebeat/filebeat.yml
# Inside filebeat.yml:
#   filebeat.inputs:
#     - type: filestream
#       id: my-filestream-id
#       enabled: true
#       paths:
#         - /var/log/auth.log
#         - /var/log/suricata/eve.json
#
#   Comment out output.elasticsearch:
#     #output.elasticsearch:
#     #  hosts: ["localhost:9200"]
#
#   Uncomment output.logstash:
#     output.logstash:
#       hosts: ["localhost:5044"]

# Quick sed example used to switch output config (as seen in terminal)
sudo sed -i '163s/output.elasticsearch:/#output.elasticsearch:/' /etc/filebeat/filebeat.yml

# Verify output config lines
sudo grep -n "output" /etc/filebeat/filebeat.yml

# Test Filebeat -> Logstash connection (Logstash must be running)
sudo filebeat test output

# ─────────────────────────────────────────────
# 6) VERIFY DATA IN KIBANA
# ─────────────────────────────────────────────

# In Kibana:
# 1. Menu → Analytics → Discover
# 2. Create data view
# 3. Index pattern: suricata-*  (or filebeat-*)
# 4. Time field: @timestamp
# 5. Save data view
# 6. Generate traffic to test (e.g. ping the host from another machine)

# Example: trigger ICMP alert by pinging the monitored host
ping <target_ip>

# ─────────────────────────────────────────────
# 7) DASHBOARD SETUP (KIBANA UI STEPS)
# ─────────────────────────────────────────────

# Create Data View:
# 1. Open Kibana → http://localhost:5601
# 2. Menu → Stack Management → Data Views
# 3. Create data view
#    Name: suricata-*
#    Index pattern: suricata-*
#    Timestamp field: @timestamp
# 4. Save data view

# Create Dashboard:
# 1. Menu → Analytics → Dashboards
# 2. Create dashboard
# 3. Save → Name: "HIDS Dashboard"

# Create Visualization (ICMP Ping Detection):
# 1. Create visualization → Lens
# 2. Data view: suricata-*
# 3. Visualization type: Area
# 4. Filter: suricata.eve.alert.signature is "ICMP Ping Detected"
# 5. Horizontal axis: @timestamp
# 6. Vertical axis: Count
# 7. Breakdown: source.ip.keyword
# 8. Save and return
