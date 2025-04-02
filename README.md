# 🌙 Significado dos Sonhos – App Flutter

Um aplicativo feito com Flutter que interpreta os sonhos dos usuários com ajuda de inteligência artificial e armazena um histórico de interpretações. A proposta é oferecer uma experiência acolhedora, simples e funcional, onde o usuário pode registrar seus sonhos e refletir sobre eles.

---

## 📱 Funcionalidades

- ✅ Entrada de texto para o usuário contar seu sonho
- 🤖 Interpretação automática do sonho (via IA ou mock)
- ☁️ Armazenamento no Firebase Firestore
- 🧾 Histórico com data e hora de cada sonho interpretado
- 🔐 Autenticação anônima com Firebase Auth

---

## 🚀 Tecnologias Utilizadas

- [Flutter](https://flutter.dev/) (Web e Android)
- [Firebase Auth](https://firebase.google.com/products/auth) (login anônimo)
- [Cloud Firestore](https://firebase.google.com/products/firestore)
- [OpenAI API](https://platform.openai.com) ou [Gemini API (Google AI)](https://ai.google.dev/)
- [Node.js + Express](https://expressjs.com/) (servidor intermediário de IA)

---

## 💻 Como Rodar o Projeto

### 1. Clone o repositório

### 2. Instale as dependências
flutter pub get

### 3. Configure o Firebase
Crie um projeto no Firebase Console
Ative Authentication > Login Anônimo
Ative o Cloud Firestore
Baixe o google-services.json e coloque em android/app/
Gere o arquivo firebase_options.dart com flutterfire configure

### 4. Rode o app
flutter run -d chrome

🌐 Back-end (opcional)
Caso utilize IA real, configure o servidor Node.js com a OpenAI ou Gemini API.

Comando para iniciar:
node index.mjs
Certifique-se de colocar sua chave da API no código com segurança.

✨ Autor
- LuandxAguiar
