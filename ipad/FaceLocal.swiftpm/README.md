# FaceLocal — protótipo iPadOS independente

Projeto Swift Playgrounds App (.swiftpm), sem dependências do Glance macOS.

## Testar no iPad

1. Instale Swift Playgrounds (Apple) no iPad.
2. No GitHub, abra `ipad/FaceLocal.swiftpm` e obtenha a pasta inteira usando **Code → Download ZIP** do repositório. No app Arquivos, descompacte e localize `ipad/FaceLocal.swiftpm`.
3. Abra o pacote `.swiftpm` pelo app Arquivos/Swift Playgrounds. Caso a importação não esteja disponível na versão instalada, crie um novo **App** no Swift Playgrounds e adicione o código de `Sources/FaceLocalApp.swift`, configurando a permissão de câmera.
4. Execute no iPad físico, autorize a câmera, toque em **Cadastrar meu rosto** e depois em **Comparar meu rosto**.
5. Se o Playgrounds pedir assinatura, use sua conta Apple e as opções disponíveis no próprio app.

## Limites e privacidade

- O código usa Vision `VNGenerateImageFeaturePrintRequest` para descritores de imagens, **não um modelo de reconhecimento biométrico validado**.
- Uma menor distância sugere semelhança visual, mas não é uma prova de identidade. O aplicativo **não libera nenhum recurso sensível**.
- Sem análise de vivacidade, fotos ou vídeos podem enganar o sistema.
- A referência é criptografada com AES-GCM; chave local no Keychain. Nenhuma foto é persistida pelo código do aplicativo ou enviada à rede.
- A interface do seletor de câmera pode manter dados temporários administrados pelo iPadOS.
- O iPad continua exigindo Touch ID/senha para o desbloqueio do sistema.
- **Build em iPad real ainda não executado**: esta é uma entrega de código para homologação, não um aplicativo assinado/TestFlight.

## Próximas validações

Compilação no Swift Playgrounds; captura frontal; uma face vs. múltiplas; persistência após reiniciar; exclusão; dispositivo sem câmera; permissão negada; proteção contra replay; modelo facial licenciado e calibrado.
