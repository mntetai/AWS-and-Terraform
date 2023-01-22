#!/bin/bash
  sudo amazon-linux-extras install -y nginx1
  sudo service nginx start
  sudo rm /usr/share/nginx/html/index.html
  echo "<html><head><title>Grandpa's Whiskey</title></head><body>Welcome to Grandpa's Whiskey</body></html>" | sudo tee /usr/share/nginx/html/index.html