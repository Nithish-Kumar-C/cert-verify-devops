#!/bin/bash
# Run this ONCE after first docker-compose up
# It sets up the database and creates demo data

echo "⏳ Waiting for backend to be ready..."
sleep 10

echo "📦 Running Django migrations..."
docker exec certverify-backend python manage.py migrate

echo "👤 Creating superadmin..."
docker exec -it certverify-backend python manage.py createsuperuser

echo "🌱 Seeding demo data..."
docker exec certverify-backend python manage.py seed_demo

echo "✅ Setup complete!"
echo ""
echo "🌐 Frontend  → http://localhost"
echo "🔧 Backend   → http://localhost:8000"
echo "⚙️  Admin     → http://localhost:8000/admin"
echo ""
echo "Login: demo_admin / demo1234"
