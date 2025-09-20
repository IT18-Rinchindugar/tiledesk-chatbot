#!/bin/bash

echo "🤖 AI Service асуудлыг засаж байна..."

echo "1️⃣ Одоогийн AI endpoint-ийг шалгаж байна..."
echo "🔍 TiledeskIntentsMachine.js дотор hardcoded URL:"
grep -n "host.docker.internal:3000" tybotRoute/engine/TiledeskIntentsMachine.js

echo ""
echo "2️⃣ AI Service байгаа эсэхийг шалгаж байна..."
echo "📡 Testing AI endpoint..."
curl -s -X POST http://host.docker.internal:3000/model/parse \
  -H "Content-Type: application/json" \
  -d '{"model":"test","text":"hello"}' || echo "❌ AI Service холбогдохгүй байна"

echo ""
echo "3️⃣ Шийдэл сонгох:"
echo ""
echo "🎯 OPTION A: MongoDB NLP ашиглах (Энгийн, ажиллах)"
echo "   - intentsEngine = 'none' эсвэл MongoDB fulltext search"
echo "   - Exact match + fulltext search ашиглана"
echo ""
echo "🎯 OPTION B: External AI Service тохируулах (Төвөгтэй)"
echo "   - Tiledesk AI service эхлүүлэх шаардлагатай"
echo "   - Docker-compose.yml дотор AI service нэмэх"
echo ""

read -p "Аль шийдлийг сонгох вэ? (A/B): " choice

case $choice in
    [Aa]* )
        echo "✅ MongoDB NLP ашиглахаар сонголоо"
        echo ""
        echo "🔧 Bot configuration-ийг MongoDB NLP рүү шилжүүлж байна..."
        
        # MongoDB-д intentsEngine-ийг 'none' болгох
        docker-compose exec mongodb mongosh -u admin -p password123 --eval "
        use tiledesk;
        print('📊 Одоогийн bot configuration:');
        db.faq_kbs.find({name: 'itrader'}).forEach(function(doc) {
            print('Bot ID:', doc._id, 'intentsEngine:', doc.intentsEngine);
        });
        
        print('🔧 intentsEngine-ийг none болгож байна...');
        var result = db.faq_kbs.updateMany(
            {name: 'itrader'},
            {\$set: {intentsEngine: 'none', trashed: false}}
        );
        print('Update result:', result);
        
        print('✅ Шинэчлэгдсэн configuration:');
        db.faq_kbs.find({name: 'itrader'}).forEach(function(doc) {
            print('Bot ID:', doc._id, 'intentsEngine:', doc.intentsEngine);
        });
        "
        
        echo ""
        echo "🧹 Cache цэвэрлэж байна..."
        docker-compose exec redis redis-cli -a redis123 FLUSHALL
        
        echo ""
        echo "🔄 Chatbot restart хийж байна..."
        docker-compose restart tiledesk-chatbot
        
        echo ""
        echo "✅ MongoDB NLP идэвхжлээ!"
        echo "🎯 Одоо fulltext search ашиглана"
        ;;
    [Bb]* )
        echo "🔧 External AI Service тохируулах..."
        echo "⚠️  Энэ нь илүү төвөгтэй, AI service Docker container шаардлагатай"
        echo ""
        echo "📋 Хийх ёстой зүйлс:"
        echo "1. Tiledesk AI service Docker image татах"
        echo "2. docker-compose.yml дотор AI service нэмэх"
        echo "3. AI service port 3000 дээр ажиллуулах"
        echo "4. Model файлууд бэлтгэх"
        echo ""
        echo "💡 Одоогоор MongoDB NLP ашиглахыг зөвлөж байна (Option A)"
        ;;
    * )
        echo "❌ Буруу сонголт. A эсвэл B гэж бичээрэй"
        ;;
esac

