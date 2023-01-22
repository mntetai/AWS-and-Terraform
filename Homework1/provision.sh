#!/bin/bash
  sudo amazon-linux-extras install -y nginx1
  sudo service nginx start
  sudo rm /usr/share/nginx/html/index.html
  echo "Welcome to Grandpa's Whiskey" | sudo tee /usr/share/nginx/html/index.html