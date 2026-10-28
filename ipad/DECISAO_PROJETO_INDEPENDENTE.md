# Projeto iPadOS independente — decisão de produto

Data: 28/10/2026.

## Objetivo
Construir um aplicativo iPadOS próprio, sem dependência do Glance para Mac, com câmera frontal e reconhecimento facial local para acesso a recursos do próprio aplicativo. A experiência deve ser simples, privativa e utilizável diretamente no iPad.

## Limite do sistema operacional
Apps de terceiros não podem substituir Touch ID/Face ID para desbloquear a tela do iPad ou liberar outros apps. A versão própria não terá essa capacidade.

## Arquitetura pretendida
SwiftUI, AVFoundation, Vision, armazenamento protegido em Keychain/CryptoKit e processamento local. Não copiar código, modelos ou credenciais do Glance. Não enviar fotos ou referências faciais a servidores. Verificar licença de qualquer modelo externo.

## Entregas
1. Protótipo nativo com permissão da câmera e detecção de rosto.
2. Cadastro e comparação de referência facial local, com consentimento e exclusão.
3. Testes de robustez, proteção contra apresentação de fotos/vídeos, políticas de falha e privacidade.
4. Projeto instalável no Swift Playgrounds ou Xcode, testes em iPad real e distribuição assinada.

## Aceite e status
A etapa 1 tem código inicial em ipad/GlancePad, mas ainda não há build validado. Etapas 2 a 4 não foram homologadas. Não existe .ipa ou TestFlight publicado. O projeto Mac permanece preservado. Não afirmar que a solução desbloqueia o iPad.

## Continuidade
Trabalhar em um módulo independente, sem regressões no Mac. Validar build e câmera no dispositivo antes de declarar pronto. Priorizar o fluxo que possa ser executado no iPad, sem GitHub Actions desnecessárias.
