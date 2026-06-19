# ELK-Host-Based-Intrusion-Detection-System-Using-The-stack-Suricata
A Host-Based Intrusion Detection System (HIDS) built using Suricata and the ELK Stack, enriched with VirusTotal and AlienVault OTX threat intelligence for real-time network monitoring, threat detection, and visualizatio

Overview

This project integrates Suricata (network IDS/IPS) with the ELK Stack (Elasticsearch, Logstash, Kibana) and Filebeat to build a complete security monitoring pipeline. Detected threats are enriched with real-world threat intelligence from VirusTotal and AlienVault OTX, then visualized through interactive Kibana dashboards.

Architecture:

Network Traffic
      |
      v
  Suricata (IDS)
      |
      v
  eve.json logs
      |
      v
  Filebeat (Log Shipper)
      |
      v
  Logstash (Filter + Enrich) <--- VirusTotal API
      |                      <--- AlienVault OTX API
      v
  Elasticsearch (Storage)
      |
      v
  Kibana (Dashboard)
  
The system runs on two logical components:

Component              Services
Hostsystem             Suricata, Filebeat
Monitoring system      Elasticsearch, Logstash, Kibana


Features


Real-time network traffic monitoring with Suricata

Custom rule-based detection for ICMP ping sweeps, SSH brute-force attacks, and Nmap port scans

Automated log shipping via Filebeat

Log enrichment with VirusTotal and AlienVault OTX threat intelligence APIs

Centralized log storage and indexing with Elasticsearch

Interactive security dashboards built in Kibana

Fully encrypted pipeline using HTTPS and CA certificate authentication


Tech Stack


Suricata -Network Intrusion Detection System
Elasticsearch -Log storage and indexing
Logstash- Log processing and enrichment
Kibana -Data visualization and dashboards
Filebeat - Log shipping
VirusTotal API -IP/file reputation checking
AlienVault OTX- Threat intelligence (IOCs)
Kali Linux- Operating system

Installation

1. Elasticsearch

wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-9.4.2-amd64.deb
sudo dpkg -i elasticsearch-9.4.2-amd64.deb
sudo systemctl enable elasticsearch
sudo systemctl start elasticsearch

2. Logstash

wget https://artifacts.elastic.co/downloads/logstash/logstash-9.4.2-amd64.deb
sudo dpkg -i logstash-9.4.2-amd64.deb
sudo systemctl enable logstash
sudo systemctl start logstash

3.kibana
wget https://artifacts.elastic.co/downloads/kibana/kibana-9.4.2-amd64.deb
sudo dpkg -i kibana-9.4.2-amd64.deb
sudo systemctl enable kibana
sudo systemctl start kibana

4.Filebeat
wget https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-9.4.2-amd64.deb
sudo dpkg -i filebeat-9.4.2-amd64.deb
sudo systemctl enable filebeat
sudo systemctl start filebeat

5.suricata

sudo add-apt-repository ppa:oisf/suricata-stable
sudo apt update
sudo apt install suricata -y
sudo systemctl enable suricata
sudo systemctl start suricata

Configuration

Detailed configuration steps for each component (Elasticsearch, Kibana, Logstash, Suricata, and Filebeat) are documented in docs/CONFIGURATION.md, including:


Enabling HTTPS and CA certificate authentication
Setting up service account tokens for Kibana
Building the Logstash pipeline with VirusTotal and AlienVault OTX enrichment
Writing custom Suricata detection rules
Configuring Filebeat to ship logs to Logstash

Dashboard

The Kibana dashboard includes the following visualizations:

Visualization                              Description

ICMP ping detection                        Area chart of ping attempts over time, broken down by source IP
