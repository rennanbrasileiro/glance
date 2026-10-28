# GlancePad — primeiro código nativo iPadOS

Esta é uma implementação inicial em SwiftUI + AVFoundation + Vision de **detecção de presença de rosto** na câmera frontal. Não faz reconhecimento de identidade nem desbloqueio do sistema. Não armazena imagens ou modelos biométricos.

## Executar

É necessário criar um projeto **App iPadOS** no Swift Playgrounds ou no Xcode e adicionar os arquivos Swift desta pasta ao target, definindo a descrição de privacidade da câmera `NSCameraUsageDescription` conforme `Info.plist`. O diretório ainda não contém um projeto Swift Playgrounds `.swiftpm` ou Xcode compilável pronto; não há build assinado nem TestFlight.

## Próxima etapa

Adicionar cadastro facial local, comparação de embeddings, avaliação de vivacidade e armazenamento protegido, com consentimento, políticas de segurança e testes em hardware. **Não usar simples detecção de rosto para autorizar acesso.**
