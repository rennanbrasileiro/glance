# Glance — plano de evolução Mac + iPad

## Baseline preservada

Origem: https://github.com/jonnyoo/glance
Baseline upstream: `b97f521397ec1197ba17768ba797cae1e628848d` (v1.2.0).
A licença MIT original deve permanecer. Não substituir arquivos originais nem remover funcionalidades existentes sem testes e aprovação.

## Plataforma

- macOS 15+: aplicativo original em Swift/SwiftUI, Core ML, Vision, AppKit, Keychain e Sparkle.
- iPadOS: futuro alvo separado no mesmo repositório, usando SwiftUI, Vision/Core ML e LocalAuthentication conforme compatibilidade. **Não** prometer desbloquear a tela de bloqueio do iPad nem executar código Swift no Scriptable.
- Scriptable: apenas automações JavaScript opcionais; não substitui o aplicativo nativo.

## Pendências prioritárias (não homologadas)

1. **Resultado de desbloqueio:** `FaceUnlockCoordinator.observeScanWindow` chama `POCController.injectStoredPassword`, que registra falha em `statusMessage`, mas não retorna resultado; o coordenador retorna `.matched` independentemente do sucesso da injeção. Introduzir resultado tipado e evitar animação de sucesso quando a injeção falhar. Testar erros de Accessibility, Keychain e estado de bloqueio.
2. **Segurança:** o código declara que replay de vídeo pode superar vivacidade. Não apresentar o produto como equivalente ao Face ID. Avaliar defaults conservadores, janela de sessão e proteção contra spoofing antes de liberar desbloqueio real.
3. **Distribuição independente:** `glance/Info.plist` usa `https://tryglance.app/appcast.xml`, assinatura Sparkle do autor e `com.jonathan.glance` no projeto. Isolar atualizações, assinatura, bundle ID, Keychain access group e URLs de suporte em release própria; não mudar IDs sem plano de migração de dados.
4. **Compatibilidade:** `NotchSkyLight.swift` utiliza API privada do macOS; verificar comportamento em versões novas, ausência de notch, câmeras USB e Mac em modo clamshell.
5. **Licenças:** verificar direitos comerciais dos pesos ArcFace/InsightFace separadamente da licença MIT do código.
6. **Testes:** executar `tools/liveness_selftest.swift` e build Xcode no Mac, ampliar testes de erro, regressão, segurança, onboarding e câmera. Não consumir GitHub Actions sem necessidade.

## Critérios de aceite

- Build local macOS aprovado em Xcode compatível.
- Fluxos de cadastro, câmera, reconhecimento, Keychain, bloqueio e configurações sem regressões.
- Nenhuma injeção de senha sinalizada como sucesso sem confirmação de execução; distinguir injeção de desbloqueio efetivo.
- Release e updater próprios, sem apontar para o feed do upstream.
- Alvo iPadOS com funcionalidades explicitamente delimitadas e testadas em dispositivo real.
- Registro de evidências e limitações; não declarar homologação antes dos testes.
