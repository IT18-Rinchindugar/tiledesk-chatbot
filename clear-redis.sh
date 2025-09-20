#!/bin/bash

echo "🗑️ Redis data бүгдийг цэвэрлэж байна..."

# Check if Redis service exists in docker-compose
if ! docker-compose config --services | grep -q redis; then
    echo "❌ Redis service docker-compose.yml дотор байхгүй байна"
    echo "📋 Одоогийн services:"
    docker-compose config --services
    echo ""
    echo "💡 Redis service нэмэх бол:"
    echo "   1. docker-compose.yml файлд Redis service нэмэх"
    echo "   2. Эсвэл external Redis ашиглаж байвал тэр Redis-д холбогдох"
    exit 1
fi

echo "1️⃣ Redis service эхлүүлж байна..."
docker-compose up -d redis

echo "2️⃣ Redis эхлэхийг хүлээж байна..."
sleep 5

echo "3️⃣ Redis connection шалгаж байна..."
if docker-compose exec redis redis-cli -a redis123 ping; then
    echo "✅ Redis холбогдлоо"
    
    echo "4️⃣ Бүх Redis data устгаж байна..."
    docker-compose exec redis redis-cli -a redis123 FLUSHALL
    
    echo "5️⃣ Redis info харах..."
    docker-compose exec redis redis-cli -a redis123 INFO keyspace
    
    echo "✅ Redis data амжилттай цэвэрлэгдлээ!"
else
    echo "❌ Redis-д холбогдож чадсангүй"
    echo "🔍 Redis logs шалгах:"
    docker-compose logs redis --tail=20
fi

