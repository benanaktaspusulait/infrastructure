#!/bin/bash
echo "⚠️ WARNING: This will remove ALL Docker containers, images, volumes, and networks!"
read -p "Type 'yes' to proceed: " confirm
if [[ "$confirm" == "yes" ]]; then
  docker stop $(docker ps -aq)
  docker rm -f $(docker ps -aq)
  docker rmi -f $(docker images -aq)
  docker volume rm -f $(docker volume ls -q)
  docker network rm $(docker network ls | grep -v "bridge\|host\|none" | awk '{print $1}' | tail -n +2)
  docker system prune -a --volumes -f
  docker builder prune -a -f
  echo "✅ Docker environment cleaned!"
else
  echo "❌ Cancelled."
fi
