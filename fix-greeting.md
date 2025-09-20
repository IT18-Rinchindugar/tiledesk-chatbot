# Fix Greeting Issue - Мэндчилгээний асуудлыг засах

## Асуудал
Chatbot "Hello" гэсэн мэндчилгээг ойлгохгүй, defaultFallback ашиглаж байна.

## Шийдэл

### 1. Tiledesk Design Studio ашиглан (Хамгийн сайн арга)

1. **Design Studio руу нэвтрэх**: http://localhost:8081
2. **Bot засах**: "itrader" bot-ыг сонгох
3. **Greeting Intent нэмэх**:
   - Intent name: "greeting"
   - Training phrases: "Hello", "Hi", "Hey", "Good morning"
   - Response: "Hello! How can I help you today?"
4. **Bot-ыг train хийх**
5. **NLP Engine идэвхжүүлэх**: Settings -> intentsEngine = "tiledesk-ai"

### 2. Database-д шууд засах (Түргэн шийдэл)

```bash
# MongoDB container руу нэвтрэх
docker-compose exec mongodb mongosh -u admin -p password123

# Database сонгох
use tiledesk

# Greeting intent нэмэх
db.faqs.insertOne({
  "id_faq_kb": "68c2cd1d026c400013cd66a1",
  "intent_display_name": "greeting",
  "intent_id": "greeting-001",
  "question": "Hello",
  "answer": "Hello! How can I help you today?",
  "actions": [{
    "_tdActionType": "reply",
    "text": "Hello! How can I help you today? 😊"
  }],
  "language": "en",
  "enabled": true,
  "status": "live",
  "webhook_enabled": false
})

# Bot configuration шинэчлэх - NLP engine идэвхжүүлэх
db.faq_kbs.updateOne(
  {"_id": ObjectId("68c2cd1d026c400013cd66a1")},
  {"$set": {"intentsEngine": "tiledesk-ai"}}
)
```

### 3. Exact Match нэмэх (Хурдан шийдэл)

Bot configuration-д exact match rules нэмэх:

```javascript
// MongoDB-д энэ command ажиллуулах
db.faq_kbs.updateOne(
  {"_id": ObjectId("68c2cd1d026c400013cd66a1")},
  {"$set": {
    "questions_intent": {
      "Hello": "greeting",
      "Hi": "greeting",
      "Hey": "greeting",
      "Good morning": "greeting"
    }
  }}
)
```

### 4. Container restart хийх

```bash
# Chatbot container restart
docker-compose restart tiledesk-chatbot

# Cache цэвэрлэх
docker-compose exec redis redis-cli -a redis123 FLUSHALL
```

## Шалгах

1. Browser-ээр widget руу орох: http://localhost:8081/widget/assets/twp/chatbot-panel.html...
2. "Hello" гэж бичих
3. Зөв хариулт авах ёстой

## Logs шалгах

```bash
# Real-time logs харах
docker-compose logs -f tiledesk-chatbot

# "exact match" эсвэл "NLP" гэсэн үгийг хайх
docker-compose logs tiledesk-chatbot | grep -i "exact match\|nlp"
```

## Анхаарах зүйлс

- NLP engine идэвхжүүлсний дараа bot дахин train хийх шаардлагатай
- Cache цэвэрлэх шаардлагатай байж болно
- Training data олон байх тусам илүү сайн ажиллана

