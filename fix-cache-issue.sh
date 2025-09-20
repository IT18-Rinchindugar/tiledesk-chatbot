#!/bin/bash

echo "🔧 Cache болон Bot configuration засаж байна..."

echo "1️⃣ MongoDB-д bot configuration шинэчлэж байна..."
docker-compose exec mongodb mongosh -u admin -p password123 --eval "
use tiledesk;

// Бүх bot-уудыг харах
print('📋 Одоогийн bot-ууд:');
db.faq_kbs.find({name: 'itrader'}, {_id: 1, name: 1, intentsEngine: 1, trashed: 1}).forEach(printjson);

// Trashed bot-уудыг засах
print('🗑️ Trashed bot-уудыг сэргээж байна...');
db.faq_kbs.updateMany(
  {name: 'itrader', trashed: true},
  {\$set: {trashed: false, intentsEngine: 'tiledesk-ai'}}
);

// Бүх itrader bot-уудад NLP engine идэвхжүүлэх
print('🤖 NLP engine идэвхжүүлж байна...');
var result = db.faq_kbs.updateMany(
  {name: 'itrader'},
  {\$set: {intentsEngine: 'tiledesk-ai', trashed: false}}
);

print('✅ Update result:', result);

// Шинэчлэгдсэн bot-уудыг харах
print('🔍 Шинэчлэгдсэн bot-ууд:');
db.faq_kbs.find({name: 'itrader'}, {_id: 1, name: 1, intentsEngine: 1, trashed: 1}).forEach(printjson);
"

echo ""
echo "2️⃣ Cache бүрэн цэвэрлэж байна..."
docker-compose exec redis redis-cli -a redis123 FLUSHALL

echo ""
echo "3️⃣ Chatbot container restart хийж байна..."
docker-compose restart tiledesk-chatbot

echo ""
echo "4️⃣ 10 секунд хүлээж байна..."
sleep 10

echo ""
echo "5️⃣ Logs шалгаж байна..."
echo "🔍 IntentsEngine configuration:"
docker-compose logs --tail=50 tiledesk-chatbot | grep -i "intentsEngine\|tiledesk-ai\|MongodbIntentsMachine" | tail -5

echo ""
echo "✅ Бүгд дууслаа! Одоо 'what is the expert trader?' гэж туршиж үзээрэй."

