# IndependentFaceID — aplicativo iPadOS autoral

Este módulo será independente do Glance para Mac. Objetivo: reconhecimento facial local para acesso apenas a funcionalidades do próprio aplicativo. Não substitui Touch ID nem desbloqueia a tela do iPad.

## Entrega incremental

- Captura pela câmera frontal com permissão explícita.
- Cadastro facial consentido, armazenamento criptografado e exclusão.
- Verificação local com avaliação de qualidade e vivacidade; não liberar conteúdo sensível sem validação de segurança.
- Interface SwiftUI e projeto Swift Playgrounds executável no iPad.
- Teste em hardware antes de homologar.

## Situação

Ainda não existe aplicativo compilado, IPA, TestFlight ou projeto Swift Playgrounds verificado. A base inicial em `ipad/GlancePad` apenas detecta rostos, sem verificar identidade. Não considerar isso um desbloqueio biométrico.
