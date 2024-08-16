[[ $- != *i* ]] && return

export VISUAL=nvim
export EDITOR="$VISUAL"
export PATH="~/.local/bin:$PATH"

alias ls='ls --color=auto'
alias vi='nvim'
alias py='python'

PS1='[\u@\h \W]\$ '

vm() {
  disk="$1"
  shift
  qemu-system-x86_64                                                          \
    -m 4G                                                                     \
    -cpu host                                                                 \
    -smp 2                                                                    \
    -parallel none                                                            \
    -machine type=pc,accel=kvm                                                \
    -monitor stdio                                                            \
    -drive file="$disk",format=raw,if=virtio,cache=none,aio=native            \
    -net user,smb="$HOME"                                                     \
    -net nic                                                                  \
    -display sdl                                                              \
    -usb                                                                      \
    -device usb-tablet                                                        \
    "$@"
}

vmu() {
  disk="$1"
  shift

  if [ ! -f /tmp/ovmf_vars.bin ] ; then
    cp /usr/share/ovmf/x64/OVMF_VARS.fd /tmp/ovmf_vars.bin
  fi

  vm "$disk"                                                                   \
    -drive if=pflash,format=raw,readonly,file=/usr/share/ovmf/x64/OVMF_CODE.fd \
    -drive if=pflash,format=raw,file=/tmp/ovmf_vars.bin                        \
    "$@"
}

#if command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ]; then
#  exec tmux
#fi

pre_exec() {
  if grep -q ".u$" <<< "$BASH_COMMAND"; then
    echo -e "\033[0;31mMEU PAU NO TEU CU! \033[0m"
    sleep 2
  fi
}

trap pre_exec DEBUG
