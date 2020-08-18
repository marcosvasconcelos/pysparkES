#/bin/bash
##
####
cd elk
sudo docker-compose up --no-start
cd ../jupyter-notebook
sudo docker-compose build
sudo docker run -d -p 8888:8888 --name pyspark-es --network es-net  jupyter-notebook_pyspark:latest
