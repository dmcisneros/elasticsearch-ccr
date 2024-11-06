#!/usr/bin/env bash
set -e

source .elastic-version

# Start metrics store
#docker compose -f ./metricstore-docker-compose.yml up -d 

# Start Elasticsearch
docker compose up -d

printf "Waiting for clusters to get ready "

# Wait until ES is up
ALL_CLUSTERS_READY=false

while ! $ALL_CLUSTERS_READY; do
    curl -s http://localhost:39201 -o /dev/null && curl -s http://localhost:39202 -o /dev/null && ALL_CLUSTERS_READY=true || (printf "." && sleep 5)
done

echo
echo "Accepting trial license on clusters"
curl -sS -o /dev/null -XPOST localhost:39201/_xpack/license/start_trial?acknowledge=true
curl -sS -o /dev/null -XPOST localhost:39202/_xpack/license/start_trial?acknowledge=true

# Configure leader remote on the following cluster
#echo "Configure remotes on follower"
#curl -sS -o /dev/null -H 'Content-Type: application/json' -X PUT localhost:39202/_cluster/settings -d @- <<-EOF
#    {
#    "persistent" : {
#        "cluster" : {
#        "remote" : {
#            "CPD1" : {
#            "seeds" : [
#                "CPD1-node01:9300"
#            ]
#            }
#        }
#        }
#    }
#    }
#EOF

#echo "Set auto-follow pattern on follower for every index on leader"
#curl -sS -o /dev/null -H 'Content-Type: application/json' -X PUT localhost:39202/_ccr/auto_follow/geonames -d @- <<-EOF
#    {
#        "remote_cluster" : "leader",
#        "leader_index_patterns" :
#        [
#        "*"
#        ],
#        "follow_index_pattern" : "{{leader_index}}"
#    }
#EOF

# Create target-hosts file for Rally
#cat >ccr-target-hosts.json <<'EOF'
#{
#  "default": [
#    "127.0.0.1:39201"
#  ],
#  "cluster_a": [
#    "127.0.0.1:39202"
#  ]
#}
#EOF
