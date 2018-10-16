if 0 | endif

" when vim was invoked by 'sudo' command
if exists('$SUDO_USER') || exists('$GIT_DIR')
  finish
endif

let s:is_mac = (has('mac') || has('macunix') || has('gui_macvim') ||
            \    (!executable('xdg-open') &&
            \    system('uname') =~? '^darwin'))
let s:is_linux = !s:is_mac && has('unix')

function! s:vimrc_environment()
  let env = {}

  let env.is_starting = has('vim_starting')

  " vim
  let vimpath = expand('~/.vim')

  let env.path = {
        \ 'vim':     vimpath,
        \ }

  return env
endfunction

function! s:mkdir(dir)
    if !exists("*mkdir")
        return s:false
    endif

    let dir = expand(a:dir)
    if isdirectory(dir)
        return s:true
    endif

    return mkdir(dir,  "p")
endfunction

" s:env is an environment variable in vimrc
let s:env   = s:vimrc_environment()
let s:true  = 1
let s:false = 0

if s:env.is_starting
  " Define the entire vimrc encoding
  scriptencoding utf-8
  " Initialize runtimepath
  set runtimepath&

  " Check if there are plugins not to be installed and update
  augroup vimrc-check-plug
    autocmd!
    " VimEnter is fired when vim is excuted with no argument
    autocmd VimEnter * if !argc() | call s:plug.check_installation() | endif
  augroup END
endif

" vim-plug
let s:plug = {
      \ "plug": expand(s:env.path.vim) . "/autoload/plug.vim",
      \ "base": expand(s:env.path.vim) . "/plugged",
      \ "url": "https://raw.github.com/junegunn/vim-plug/master/plug.vim",
      \ }

" check if there is plug.vim
function! s:plug.ready()
  return filereadable(self.plug)
endfunction

if s:plug.ready()
    " start to manage with vim-plug
    call plug#begin(s:plug.base)

    " file and directory
    Plug 'ctrlpvim/ctrlp.vim'

    " compl
    Plug 'davidhalter/jedi-vim', {'for': 'python', 'do': 'pip install jedi'}

    " useful
    Plug 'tpope/vim-surround'
    Plug 'osyo-manga/vim-anzu'
    Plug 'airblade/vim-gitgutter'
    Plug 'easymotion/vim-easymotion'
    Plug 'kana/vim-smartchr', {'on': []}
    if v:version >= 800
        Plug 'w0rp/ale', {'do': 'pip install flake8 autopep8'}
    endif
    Plug 'google/yapf', {'rtp': 'plugins/vim', 'for': 'python', 'do': 'pip install yapf'}

    " colorscheme
    Plug 'altercation/vim-colors-solarized'

    " statusline
    Plug 'vim-airline/vim-airline'
    Plug 'vim-airline/vim-airline-themes'

    augroup load_us_ycm
        autocmd!
        autocmd InsertEnter * call plug#load('vim-smartchr')
                    \ | autocmd! load_us_ycm
    augroup END

    call plug#end()
else
    " install vim-plug
    function! s:plug.init()
        let ret = system(printf("curl -fLo %s --create-dirs %s", self.plug, self.url))
        if v:shell_error
            echomsg 's:plug_init: error occured'
            return 1
        endif
        " Restart vim
        silent! !vim
        quit!
    endfunction

    command! PlugInit call s:plug.init()
    " install vim-plug
    PlugInit
endif

" Add plug's plugins
let s:plug.plugs = get(g:, 'plugs', {})
let s:plug.list = keys(s:plug.plugs)

" plugin helper functions
function! s:plug.is_installed(name)
  return has_key(self.plugs, a:name) ? isdirectory(self.plugs[a:name].dir) : 0
endfunction

function! s:plug.check_installation()
    if empty(self.plugs)
        return
    endif

    let list = []
    for [name, spec] in items(self.plugs)
        if !isdirectory(spec.dir)
            call add(list, spec.uri)
        endif
    endfor

    if len(list) > 0
        let unplugged = map(list, 'substitute(v:val, "^.*github\.com/\\(.*/.*\\)\.git$", "\\1", "g")')
        " Ask whether installing plugs like NeoBundle
        echomsg 'Not installed plugs: ' . string(unplugged)
        if confirm('Install plugs now?', "yes\nNo", 2) == 1
            PlugInstall
            " Close window for vim-plug
            silent! close
             " Restart vim
            silent! !vim
            quit!
        endif
    endif
endfunction

"function! s:plug.check_update()
"    PlugUpdate
"    PlugUpgrade
"    silent! close
"endfunction

"function! s:has_plugin(name)
"  " Check {name} plugin whether there is in the runtime path
"  let nosuffix = a:name =~? '\.vim$' ? a:name[:-5] : a:name
"  let suffix   = a:name =~? '\.vim$' ? a:name      : a:name . '.vim'
"  return &rtp =~# '\c\<' . nosuffix . '\>'
"        \   || globpath(&rtp, suffix, 1) != ''
"        \   || globpath(&rtp, nosuffix, 1) != ''
"        \   || globpath(&rtp, 'autoload/' . suffix, 1) != ''
"        \   || globpath(&rtp, 'autoload/' . tolower(suffix), 1) != ''
"endfunction

" plugins setting
if s:plug.is_installed("vim-plug")
    function! PlugList(A,L,P)
      return join(s:plug.list, "\n")
    endfunction

    command! -nargs=1 -complete=custom,PlugList PlugHas
          \ if s:plug.is_installed('<args>')
          \ | echo s:plug.plugs['<args>'].dir
          \ | endif
endif

if s:plug.is_installed("jedi-vim")
    let g:jedi#popup_select_first = 0
    let g:jedi#show_call_signatures = 0
    let g:jedi#completions_command = "<C-n>"
    if has('python3')
        let g:jedi#force_py_version = 3
        let g:pymode_python = 'python3'
    endif
    set omnifunc=jedi#completions
endif

if s:plug.is_installed("vim-anzu")
    " nmap n <Plug>(anzu-n)
    " nmap N <Plug>(anzu-N)
    " nmap * <Plug>(anzu-star)
    " nmap # <Plug>(anzu-sharp)
    " nmap n <Plug>(anzu-n-with-echo)
    " nmap N <Plug>(anzu-N-with-echo)
    " nmap * <Plug>(anzu-star-with-echo)
    " nmap # <Plug>(anzu-sharp-with-echo)
    let g:airline#extensions#anzu#enabled = 1
    augroup vim-anzu
        autocmd!
        autocmd CursorHold,CursorHoldI,WinLeave,TabLeave * call anzu#clear_search_status()
    augroup END
endif

if s:plug.is_installed("vim-easymotion")
    nmap s <Plug>(easymotion-overwin-f2)
    " let g:EasyMotion_use_upper = 1
    " let g:EasyMotion_smartcase = 1
    " let g:EasyMotion_use_smartsign_us = 1
    let g:EasyMotion_do_mapping = 0
endif

if s:plug.is_installed("vim-smartchr")
    inoremap <buffer> <expr> , smartchr#loop(', ', ',')
endif

if s:plug.is_installed("vim-airline")
    let g:airline_theme = 'powerlineish'
    let g:airline_left_sep = ''
    let g:airline_right_sep = ''
    let g:airline_left_alt_sep = ''
    let g:airline_right_alt_sep = ''
    let g:airline#extensions#tabline#enabled = 1
    let g:airline#extensions#tabline#show_tabs = 0
    let g:airline#extensions#tabline#show_buffers = 0
    let g:airline#extensions#tabline#tab_min_count = 1
    let g:airline#extensions#tabline#buffer_min_count = 1
endif

if s:plug.is_installed("ale")
    " set statusline+=%#warningmsg#
    " set statusline+=%{ALEGetStatusLine(})
    " set statusline+=%*
    let g:airline#extensions#ale#enabled = 1

    " automatically fix syntax
    let g:ale_fix_on_save = 1
    " check when a file is saved
    let g:ale_lint_on_save = 1
    " doesn't check when conding
    let g:ale_lint_on_text_changed = 'never'
    " doesn't check when a file is opend
    let g:ale_lint_on_enter = 0
    " open error/warning window
    let g:ale_open_list = 1
    " Enable completion where available.
    let g:ale_completion_enabled = 1
    " Keep the sign gutter open
    let g:ale_sign_column_always = 1
    " keymapping for jumping next/previous errors
    nmap <silent> <C-k> <Plug>(ale_previous_wrap)
    nmap <silent> <C-j> <Plug>(ale_next_wrap)
    " setup for python
    let g:ale_linters = {'python': ['flake8']}
    let g:ale_fixers = {'python': ['autopep8']}
    let g:ale_python_flake8_options = '--max-line-length=120'
    let g:ale_python_autopep8_options = '--max-line-length 120'
endif

if s:plug.is_installed("yapf")
    map <C-y> :call yapf#YAPF()<cr>
    imap <C-y> <C-o>:call yapf#YAPF()<cr>
endif

if s:plug.is_installed("vim-colors-solarized")
    " set colorscheme solarized
    colorscheme solarized
endif

" key mapping
inoremap [] []<LEFT>
inoremap () ()<LEFT>
inoremap {} {}<LEFT>
inoremap "" ""<LEFT>
inoremap '' ''<LEFT>
inoremap `` ``<LEFT>

" search settings
" don't care about uppercase or lowercase
set ignorecase
" distinguish uppercase between lowercase if there are uppercases
set smartcase
" use incremental search
set incsearch
" highlight matched text
set hlsearch

" edit settings
" use utf-8 for default encoding
set encoding=utf-8
" use space instead of tab
set expandtab
" use 4 spaces as tab
set tabstop=4
set softtabstop=4
" use 4 spaces for indent
set shiftwidth=4
" use multiple of shiftwidth for indent
set shiftround
" don't case uppercase or lowercase when autocomplete
set infercase
" enable to move area on which theare are no letters
set virtualedit=all
" moving curosr will be modern
set whichwrap=b,s,h,l,<,>,[,],~
" hidden buffer instead of closing
set hidden
" open buffer instead of new open
set switchbuf=useopen
" highlight parentheses
set showmatch
" highlight parentheses for 2 sec
set matchtime=2
" enable to delete any white space by backspace
set backspace=indent,eol,start
" spell check
set spell
set spelllang=en,cjk
" reload changed file
set autoread
" save updates when window switches
set autowrite
" save undo
if has('persistent_undo')
    set undofile
    let &undodir = '~/.vim/undo'
    call s:mkdir(&undodir)
endif
" clipboard settings
if has('unnamedplus')
    set clipboard=unnamedplus,unnamed
else
    set clipboard=unnamed
endif
" delete swap file and backup file
set nowritebackup
set nobackup
set noswapfile

" display settings
" display invisuable letters
set list
" display line number
set number
" display line number relative
"set relativenumber
" wrap long text
set wrap
" disable auto newline
set textwidth=0
" display line on the 80 letters
set colorcolumn=80
" display cursor
set ruler
" hightlight cursor line
"set cursorline
" display command autocomplete on statusline
set wildmenu
" Wildmenu mode
set wildmode=longest,full
" display statusline
set laststatus=2
" enable syntax highlight
syntax enable on
" dark background
set background=dark
" no visualbell
set novisualbell t_vb=
set noerrorbells
" use these letters below for invisuable letters
set listchars=tab:>-,trail:-,extends:>,precedes:<,nbsp:%,eol:<
" use 256 color
set t_Co=256

" other settings
" eliminating delays on ESC
set timeoutlen=1000 ttimeoutlen=0
" disable automatic comment insertion
set formatoptions&
set formatoptions-=t
set formatoptions-=c
set formatoptions-=r
set formatoptions-=o
set formatoptions-=v
set formatoptions+=l
" indent
set autoindent
set smartindent
