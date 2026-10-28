# Glance para iPad — estado real

O aplicativo macOS deste repositório **não instala no iPad**. Ele utiliza AppKit, APIs de tela de bloqueio do macOS e distribuição `.dmg`.

## Para instalar no iPad

É necessário desenvolver um **target iPadOS próprio**, compilar e assinar o aplicativo para o dispositivo (por Xcode/macOS ou outro fluxo oficial de distribuição Apple). Não existe `.ipa` funcional nem link TestFlight publicado neste repositório neste momento.

O Swift Playgrounds no iPad pode servir para criar e testar um protótipo SwiftUI local, mas abrir o repositório macOS nele **não** o converte em app iPadOS. Scriptable executa JavaScript, não o aplicativo Swift original.

## Limites do sistema

- Pode usar a câmera e recursos de autenticação suportados para controlar acesso **dentro do próprio aplicativo**, mediante permissões.
- Não pode substituir Face ID, desbloquear a tela de bloqueio do iPad ou inserir a senha do sistema.
- Não migrar senha do Mac ou embeddings biométricos para um aplicativo iPad sem análise de segurança e consentimento.

## Entrega necessária

1. Target iPadOS em SwiftUI independente dos módulos AppKit/SkyLight/Sparkle.
2. Fluxo de câmera, permissão, cadastro e autenticação local com finalidade definida.
3. Testes em iPad físico, assinatura e distribuição por TestFlight ou outro método permitido.
4. Instruções de instalação só após existir build assinado e verificável.
