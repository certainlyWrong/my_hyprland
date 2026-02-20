# My Hyprland Setup 🚀

Este repositório contém um conjunto de scripts modulares e automatizados para a instalação e configuração do **Hyprland** no Arch Linux. Ele foi projetado para ser flexível, suportando tanto instalações diretas em hardware moderno (como notebooks híbridos com placa NVIDIA) quanto em Máquinas Virtuais.

## 📦 Estrutura dos Scripts

A instalação foi dividida em módulos para facilitar a manutenção e adaptar o processo a diferentes cenários de uso:

### 1. `setup.sh` (O Script Principal)
Este é o ponto de entrada da sua instalação. O que ele faz:
- Verifica e impede que você rode o script inteiro como `root` (uma medida de segurança para o `makepkg`).
- Habilita o repositório `[multilib]` se necessário (essencial para bibliotecas 32-bits e Steam).
- Instala pacotes base e ferramentas (`base-devel`, `git`, pacotes de áudio/vídeo).
- **Interatividade:** Pergunta de forma interativa qual é o seu ambiente (Notebook Híbrido ou Máquina Virtual) e executa o script de vídeo correspondente.
- Instala o AUR helper `yay` compilando do zero.
- Instala o núcleo do **Hyprland**, Waybar, Kitty, Rofi e pacotes relacionados.
- Instala fontes (JetBrains Mono, Nerd Fonts, etc).
- Chama o script secundário para instalar o gerenciador de login (Ly).
- Habilita os serviços do Pipewire.

### 2. `install_graphics_hybrid.sh` (Para Hardware Nativo / Dell G15)
Este script é acionado quando você escolhe a opção *Hybrid Graphics* no menu do `setup.sh`. O que ele faz:
- Detecta o kernel em uso (ex: `linux`, `linux-lts`) e instala o pacote `*-headers` correto.
- Instala os drivers de vídeo para sistemas híbridos Intel + NVIDIA (`nvidia-dkms`, drivers da Intel e Vulkan). *Nota: O driver DKMS é o recomendado para estabilidade em placas Ampere como a RTX 3050.*
- Força a compilação local dos módulos NVIDIA via `dkms autoinstall`.
- Configura as variáveis de ambiente (`/etc/environment`) necessárias para fazer a NVIDIA se comportar bem com o Wayland (`GBM_BACKEND=nvidia-drm`, melhora no backend com `NVD_BACKEND=direct`, etc).
- Configura o **Early KMS** editando o `mkinitcpio.conf` e regerando o initramfs para carregar os drivers no boot.
- Avisa para usar `cursor { no_hardware_cursors = true }` no seu `hyprland.conf`.

### 3. `install_graphics_vm.sh` (Para Máquinas Virtuais)
Este script é acionado quando você escolhe a opção *Virtual Machine*. O que ele faz:
- Foca em instalar drivers abertos (`mesa`, `vulkan-icd-loader`).
- Instala utilitários de convidado universais para que a VM funcione bem (`virtualbox-guest-utils-nox`, `open-vm-tools`, `qemu-guest-agent`, `spice-vdagent`).
- Habilita os serviços do sistema para esses utilitários em background.
- Inclui variáveis de fallback de software (`WLR_RENDERER_ALLOW_SOFTWARE=1`) caso falte aceleração na VM.
- **Aviso Importante:** O script avisa que você DEVE ativar a Aceleração 3D nas configurações do hipervisor e possivelmente desativar animações no `hyprland.conf` para o Hyprland rodar ou ficar usável.

### 4. `install_ly.sh` (Gerenciador de Login)
Instala o adorado e leve TUI Display Manager **Ly**, focado em ser rápido e em modo texto:
- Instala as dependências para compilação (`zig`, `ncurses`, `pam`, `libxcb`).
- Clona o código-fonte diretamente do Codeberg.
- Compila a ferramenta através do comando da linguagem Zig (`sudo zig build installexe -Dinit_system=systemd`).
- Desabilita os prompts padrão de TTY para habilitar o serviço systemd do próprio Ly.

---

## 🚀 Como Usar

1. Clone o repositório ou navegue até a pasta:
   ```bash
   cd ~/Documents/my_hyprland
   ```

2. Certifique-se de que os scripts sejam executáveis:
   ```bash
   chmod +x setup.sh install_graphics_hybrid.sh install_graphics_vm.sh install_ly.sh
   ```

3. Execute o script principal ( **NÃO** use `sudo`):
   ```bash
   ./setup.sh
   ```

4. O script pausará para pedir a sua senha interativamente apenas quando necessário.
5. No menu de seleção de **Graphics Setup**, digite `1` se estiver formatando seu notebook híbrido (Dell G15 RT3050) ou `2` se estiver instalando em uma máquina virtual.
6. Ao final do script, basta confirmar o reinício automático da máquina!

---

## ⚠️ Guias e Resolução de Problemas

- **Para documentação compelta dos pacotes:** Consulte o arquivo `DEPENDENCIES.md` gerado.
- **Module Not Found no mkinitcpio:** O `install_graphics_hybrid.sh` lida com isso instalando os headers corretos e rodando `dkms autoinstall`.
- **Tela preta / Crash no Hyprland em VM:** O Hyprland usa renderização gráfica intensa. Verifique se as configurações da sua Virtual Machine permitem VRAM suficiente e se a "Aceleração 3D" está estritamente ligada. Se ainda houver lentidão com os fallbacks habilitados pelo script, desligue as opções de animação do *hyprland.conf*.
