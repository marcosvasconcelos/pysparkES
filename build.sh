#/bin/bash
##
####
cd elk
sudo docker network create es-net -d "bridge"
sudo docker-compose up --no-start
cd ../jupyter-notebook
sudo docker-compose build 
sudo docker run -d -p 8888:8888 -e JUPYTER_TOKEN="jpt@teste" --name pyspark-es --network es-net  jupyter-notebook_pyspark:latest
sudo docker container start grafana
sudo docker container start kibana
sudo docker container start elastic-node1
