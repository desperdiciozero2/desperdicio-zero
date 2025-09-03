# Desperdício Zero 🍎

Aplicativo para combate ao desperdício de alimentos, permitindo o gerenciamento de produtos, receitas e notificações de validade.

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
  - flutter_riverpod para gerenciamento de estado
  - intl para formatação de datas
  - barcode_scan2 para leitura de códigos de barras
  - flutter_local_notifications para notificações locais

## 📋 Pré-requisitos

- Flutter SDK (versão ^3.9.0)
- Dart SDK (versão ^3.9.0)
- Conta no Supabase
- Chave de API do Spoonacular

## 🚀 Como Executar

1. Clone o repositório:
   ```bash
   git clone [URL_DO_REPOSITÓRIO]
   cd desperdicio_zero
   ```

2. Instale as dependências:
   ```bash
   flutter pub get
   ```

3. Crie um arquivo `.env` na raiz do projeto com as seguintes variáveis:
   ```
   SUPABASE_URL=sua_url_do_supabase
   SUPABASE_ANON_KEY=sua_chave_anonima_do_supabase
   SPOONACULAR_API_KEY=sua_chave_da_api_spoonacular
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
├── providers/        # Gerenciamento de estado com Riverpod
├── screens/          # Telas do aplicativo
├── services/         # Serviços e lógica de negócios
└── utils/            # Utilitários e helpers
```

## 📝 Licença

Este projeto está licenciado sob a licença MIT - veja o arquivo [LICENSE](LICENSE) para detalhes.

## 🤝 Como Contribuir

1. Faça um Fork do projeto
2. Crie uma Branch para sua Feature (`git checkout -b feature/AmazingFeature`)
3. Adicione suas mudanças (`git add .`)
4. Comite suas mudanças (`git commit -m 'Add some AmazingFeature'`)
5. Faça o Push da Branch (`git push origin feature/AmazingFeature`)
6. Abra um Pull Request

## 📧 Contato

Seu Nome - [@seu_twitter](https://twitter.com/seu_twitter)

Link do Projeto: [https://github.com/seu-usuario/desperdicio_zero](https://github.com/seu-usuario/desperdicio_zero)
