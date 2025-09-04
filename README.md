# Desperdício Zero 🍎

Aplicativo para combate ao desperdício de alimentos, permitindo o gerenciamento de produtos, receitas e notificações de validade. Desenvolvido em Flutter com integração ao Supabase e Spoonacular API.

## 🚀 Funcionalidades

- **Autenticação de Usuários**
  - Cadastro e login com e-mail/senha
  - Recuperação de senha
  - Gerenciamento de perfil

- **Gerenciamento de Produtos**
  - Cadastro de produtos com data de validade
  - Notificações de vencimento
  - Leitura de código de barras

- **Receitas Inteligentes**
  - Sugestões de receitas baseadas nos produtos próximos do vencimento
  - Integração com a API Spoonacular
  - Favoritar receitas

- **Notificações**
  - Alertas de produtos próximos do vencimento
  - Lembretes personalizáveis

## 🛠️ Tecnologias Utilizadas

- **Frontend**: Flutter
- **Backend**: Supabase (Auth, Database, Storage)
- **API Externa**: Spoonacular (receitas)
- **Outras Bibliotecas**:
  - flutter_riverpod: Gerenciamento de estado
  - intl: Formatação de datas
  - barcode_scan2: Leitura de códigos de barras
  - flutter_local_notifications: Notificações locais
  - url_launcher: Abertura de links externos
  - shared_preferences: Armazenamento local de preferências
  - http: Requisições HTTP
  - flutter_dotenv: Gerenciamento de variáveis de ambiente

## 📋 Pré-requisitos

- Flutter SDK (versão ^3.9.0)
- Dart SDK (versão ^3.9.0)
- Conta no [Supabase](https://supabase.com/)
- Chave de API do [Spoonacular](https://spoonacular.com/food-api)
- Android Studio / Xcode (para desenvolvimento nativo)
- Git (para controle de versão)

## 🚀 Como Executar

1. Clone o repositório:
   ```bash
   git clone https://github.com/seu-usuario/desperdicio-zero.git
   cd desperdicio_zero
   ```

2. Instale as dependências:
   ```bash
   flutter pub get
   ```

3. Configure as variáveis de ambiente:
   ```bash
   cp .env.example .env
   ```
   
   Edite o arquivo `.env` com suas credenciais:
   ```
   SUPABASE_URL=https://buuzrnplodxzzmcgstxw.supabase.co
   SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ1dXpybnBsb2R4enptY2dzdHh3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTYzODk5ODEsImV4cCI6MjA3MTk2NTk4MX0.6ze2FEZ74cDKAbNFp7ra_lrkO4uIwZxwNBCPp42OVEE
   SPOONACULAR_API_KEY=b268027a246e40be80cedc49ecae990f
   ```

4. Execute o aplicativo:
   ```bash
   flutter run
   ```

## 🏗️ Estrutura do Projeto

```
lib/
├── config/           # Configurações do aplicativo
├── models/           # Modelos de dados
├── providers/        # Gerenciamento de estado
├── screens/          # Telas do aplicativo
│   ├── auth/         # Autenticação
│   └── ...
├── services/         # Serviços e APIs
└── widgets/          # Componentes reutilizáveis
```

##  Configuração de Ambiente

1. Crie um projeto no [Supabase](https://supabase.com/)
2. Configure o esquema do banco de dados (ver `supabase/migrations`)
3. Obtenha uma chave de API do [Spoonacular](https://spoonacular.com/food-api)
4. Configure as URLs de redirecionamento no painel do Supabase

##  Testes

Para executar os testes:
```bash
flutter test
```

##  Build

Para gerar APK de release:
```bash
flutter build apk --split-per-abi
```

##  Contribuição

1. Faça um fork do projeto
2. Crie uma branch para sua feature (`git checkout -b feature/nova-feature`)
3. Faça commit das alterações (`git commit -m 'Adiciona nova feature'`)
4. Faça push para a branch (`git push origin feature/nova-feature`)
5. Abra um Pull Request

##  Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

##  Agradecimentos

- [Flutter](https://flutter.dev/)
- [Supabase](https://supabase.com/)
- [Spoonacular](https://spoonacular.com/food-api)
- E todos os mantenedores das bibliotecas utilizadas

## 📧 Contato

Seu Nome - [@seu_twitter](https://twitter.com/seu_twitter)

Link do Projeto: [https://github.com/seu-usuario/desperdicio-zero](https://github.com/seu-usuario/desperdicio-zero)
