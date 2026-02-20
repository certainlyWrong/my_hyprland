# Resumo de Dependências (Dependencies Overview) 📦

Este documento detalha todos os pacotes e dependências instalados pelos scripts deste repositório (`setup.sh`, `install_graphics_hybrid.sh`, `install_graphics_vm.sh`, e `install_ly.sh`). A finalidade de cada um é explicada para que você compreenda exatamente o que compõe o seu sistema Arch Linux com Hyprland.

---

## 🛠️ Ferramentas Base e Compilação
Estes pacotes formam a fundação do sistema, permitindo baixar, compilar e gerenciar outros softwares.

*   **`base-devel`**: Um grupo essencial no Arch Linux contendo ferramentas como `gcc`, `make` e `fakeroot`, necessários para compilar pacotes a partir do código fonte (usado extensivamente pelo `makepkg` e `yay`).
*   **`git`**: Sistema de controle de versão. Usado para clonar os repositórios do `yay` e do `ly`.
*   **`curl` & `wget`**: Ferramentas de linha de comando para fazer requisições web e baixar arquivos.
*   **`linux-headers` (e variantes)**: Arquivos de cabeçalho do kernel Linux. São **obrigatórios** para que o sistema de compilação DKMS consiga construir módulos de kernel customizados (como o driver da NVIDIA) para a sua versão exata do kernel.
*   **`zig`**: Compilador da linguagem Zig, exigido exclusivamente para compilar o código fonte do gerenciador de login Ly.
*   **`ncurses`, `pam`, `libxcb`**: Bibliotecas base instaladas no `setup.sh` e garantidas no `install_ly.sh`. O `pam` gerencia a autenticação de senhas no login, o `ncurses` provê a interface de texto, e o `libxcb` lida com o protocolo X.

---

## 🎮 Drivers Gráficos (Base)
Estes pacotes são instalados em ambos os cenários (Híbrido e VM) pois fornecem as APIs gráficas fundamentais usadas pelo Wayland/Linux.

*   **`mesa` & `lib32-mesa`**: A implementação open-source das APIs gráficas (OpenGL, Vulkan). A versão `lib32` é ativada pelo repositório multilib para suportar jogos e programas de 32-bits (ex: Steam, Wine).
*   **`vulkan-icd-loader` & `lib32-vulkan-icd-loader`**: O "carregador" do Vulkan. Ele é responsável por conectar os jogos e aplicativos baseados em Vulkan aos drivers corretos da sua placa de vídeo.

---

## 💻 Gráficos Híbridos (Dell G15: Intel + NVIDIA)
Pacotes específicos instalados pelo `install_graphics_hybrid.sh`.

*   **`vulkan-intel` & `lib32-vulkan-intel`**: O driver Vulkan open-source para o seu chip gráfico integrado da Intel. 
*   **`intel-media-driver` & `libva-intel-driver`**: Permitem a Aceleração de Vídeo por Hardware (VA-API) na Intel, fazendo com que reprodução de vídeos no YouTube ou VLC consumam menos bateria e CPU.
*   **`nvidia-dkms`**: O driver proprietário da NVIDIA na sua versão **DKMS** (Dynamic Kernel Module Support). Escolhemos este em vez do `nvidia-open` porque o DKMS recompila automaticamente o driver a cada atualização de kernel e providencia estabilidade muito maior em arquiteturas Ampere (como sua RTX 3050).
*   **`nvidia-utils` & `lib32-nvidia-utils`**: Bibliotecas essenciais no espaço do usuário (userspace) que acompanham o driver da NVIDIA, vitais para o OpenGL e Vulkan funcionarem na placa dedicada.
*   **`nvidia-settings`**: O painel de controle gráfico da NVIDIA.

---

## 🖥️ Gráficos para VM (Máquinas Virtuais)
Pacotes utilitários instalados pelo `install_graphics_vm.sh` para otimizar o SO convidado.

*   **`virtualbox-guest-utils-nox`**: Utilitário para o VirtualBox (versão sem X11) que facilita o compartilhamento de pastas e o redimensionamento dinâmico da tela.
*   **`open-vm-tools`**: A versão open-source do "VMware Tools", crucial para aceleração gráfica virtual (`vmwgfx`), mouse fluído e clipboard no VMware.
*   **`qemu-guest-agent` & `spice-vdagent`**: Daemons para o ecossistema QEMU/KVM/Libvirt que sincronizam áreas de transferência e melhoram a integração de vídeo.

---

## 🎨 Wayland & Hyprland Core
O coração do seu Ambiente de Desktop.

*   **`hyprland`**: O Compositor Wayland (Window Manager) de mosaico dinâmico. O cérebro da operação.
*   **Aplicações do Ecossistema Hypr:**
    *   **`hyprpaper`**: Utilitário extremamente rápido para definir os papéis de parede (Wallpapers) via Wayland.
    *   **`hyprlock`**: A tela de bloqueio oficial, muito bonita e customizável.
    *   **`hypridle`**: O daemon (serviço) que monitora a ociosidade do teclado/mouse para escurecer a tela ou trancar o PC.
    *   **`hyprcursor`**: Gerenciador moderno para temas do ponteiro do mouse (cursores).
    *   **`hyprpicker`**: Conta-gotas (color picker) de tela criado para Wayland.
*   **`waybar`**: A barra superior/inferior (Status bar) onde ficam o relógio, bateria, workspaces, etc.
*   **`kitty`**: Emulador de terminal absurdamente rápido e acelerado via GPU (Abre muito rápido no Hyprland).
*   **`rofi-wayland`**: O menu principal de aplicativos e lançador de comandos (launcher), num "fork" feito especificamente para rodar bem no Wayland.

---

## 📁 Sistema e Aplicativos
Ferramentas de uso diário.

*   **`dolphin` & `dolphin-plugins`**: O poderoso gerenciador de arquivos do projeto KDE. Os plugins permitem ver miniaturas de vídeos/imagens e repositórios git.
*   **`ark` & `kio-admin`**: `ark` é o gerenciador de arquivos compactados (Zip, RAR, Tar). O `kio-admin` permite que o Dolphin edite arquivos do sistema (root) pedindo a senha polkit, sem precisar de terminal.
*   **`vlc`**: Reprodutor de mídia universal para vídeos e músicas.
*   **Integração Wayland/Qt:**
    *   **`qt5-wayland` & `qt6-wayland`**: Plugins **fundamentais** para que aplicativos desenvolvidos em Qt (como Dolphin, Ark, OBS) consigam rodar nativamente no Wayland em vez de usarem o "emulador" XWayland, evitando borrados.
    *   **`xdg-user-dirs-gtk`**: Cria e traduz as pastas padrão do usuário (Downloads, Documentos, Imagens).
*   **XDG Desktop Portals:** 
    *   **`xdg-desktop-portal`, `xdg-desktop-portal-hyprland`, `xdg-desktop-portal-gtk`**: Canais de comunicação cruciais. Eles permitem que apps isolados (como Flatpaks ou navegadores como o Chrome e OBS) consigam pedir permissão ao Hyprland para compartilhar a tela (captura) ou abrir o gerenciador de arquivos para salvar algo.
*   **`dunst`**: O daemon que desenha e processa as pop-ups de Notificação.
*   **`cliphist`**: Gerenciador do histórico da área de transferência (permite apertar um botão e ver os últimos textos copiados via rofi).
*   **`polkit-kde-agent`**: É a janelinha gráfica que pula na tela pedindo sua senha quando você tenta abrir um app que exige privilégio de Administrador (root).

---

## 🔊 Áudio e Codecs
O Arch Linux vem mudo por padrão. Estes pacotes trazem o som à vida.

*   **`pipewire`**: O servidor multimidia moderno do Linux. Muito superior ao antigo PulseAudio, lida com áudio de baixa latência e captura de vídeo.
*   **`wireplumber`**: O "gerente" do Pipewire. Ele decide para onde o som vai (caixas de som vs. fone bluetooth) e salva suas configurações.
*   **`pipewire-alsa`, `pipewire-jack`, `pipewire-pulse`**: Bibliotecas de compatibilidade. Elas rodam em background e "enganam" programas antigos (que só conhecem pulse, jack ou alsa) fazendo-os tocar som perfeitamente no Pipewire.
*   **`pavucontrol-qt`**: Uma interface gráfica (mixer) para você controlar o volume aba por aba e selecionar microfones.
*   **Vídeo e Codecs (`gstreamer`, `gst-plugins-*`, `ffmpeg`)**: Um arsenal completo gigante de codecs de áudio e vídeo open-source e proprietários. Necessários para tocar vídeos embedded em navegadores, visualizadores de imagem e jogos.

---

## 🔡 Fontes
A ausência dessas fontes faria o sistema renderizar "quadradinhos brancos" () no terminal e barras.

*   **`ttf-jetbrains-mono` & `ttf-jetbrains-mono-nerd`**: Fontes excelentes para leitura e programação. A versão "Nerd" embute centenas de ícones do Linux, FontAwesome, etc. Vitais para o Waybar e Kitty.
*   **`ttf-fira-code`**: Outra fonte de programação popular (focada em ligaturas estéticas de código).
*   **`ttf-font-awesome`**: Pacote focado estritamente em ícones usados na barra e arquivos de configuração.
*   **`ttf-opensans`, `noto-fonts`, `ttf-droid`, `ttf-roboto`**: Fontes de texto padrão e universais para o sistema e navegação web. O `noto-fonts` cobre caracteres de praticamente todos os alfabetos existentes (japonês, emoji, etc).

---

## 🌟 Pacotes do AUR (Instalados via Yay)
Estes são softwares mantidos pela comunidade no Arch User Repository, fora dos espelhos oficiais.

*   **`hyprshot`**: Ferramenta oficial/recomendada (shell script) construída especificamente para tirar Printscreens perfeitas no Hyprland, salvando na clipboard ou no disco.
*   **`wlogout`**: Um menu elegante e leve, que aparece em tela cheia para confirmar ações de "Desligar", "Reiniciar", e "Suspender" compatível com Wayland.
*   **`qview`**: O abridor e visualizador de imagens mais limpo, minimalista e rápido existente no Qt.
*   **`visual-studio-code-bin`**: O famigerado VS Code, mas compilado direto pela Microsoft (a versão "-bin" evita você compilar o Chromium do zero no seu pc).
*   **`google-chrome`**: Navegador oficial do Google empacotado para Arch. 
