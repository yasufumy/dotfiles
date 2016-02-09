if 0 | endif

if has('vim_starting')
    if &compatible
        set nocompatible
    endif
    " vimrc encoding
    " scriptencoding utf-8
    " initialize runtimepath
    set runtimepath&
endif

" variables
let $DOTVIM = expand('~/.vim')
let $MYVIMRC = expand('~/.vimrc')
let $VIMBUNDLE = $DOTVIM . '/bundle'
let $NEOBUNDLEPATH = $VIMBUNDLE . '/neobundle.vim'

" Add neobundle to runtimepath.
if has('vim_starting') && isdirectory($NEOBUNDLEPATH)
    set runtimepath+=$NEOBUNDLEPATH
endif

" neobundle
if stridx(&runtimepath, $NEOBUNDLEPATH) != -1
    call neobundle#begin($VIMBUNDLE)
    NeoBundleFetch 'Shougo/neobundle.vim'

    NeoBundle "Shougo/vimproc", {
      \ "build": {
      \   "windows"  : "make -f make_mingw32.mak",
      \   "cygwin"   : "make -f make_cygwin.mak",
      \   "mac"      : "make -f make_mac.mak",
      \   "unix"     : "make -f make_unix.mak",
      \ }}

    " filer
    NeoBundleLazy "Shougo/vimfiler", {
          \ "depends": ["Shougo/unite.vim"],
          \ "autoload": {
          \ "commands": ["VimFilerTab", "VimFiler", "VimFilerExplorer"],
          \ "explorer": 1,
          \ }}
    let g:vimfiler_safe_mode_by_default = 0

    " git
    NeoBundle "tpope/vim-fugitive"
    NeoBundleLazy "gregsexton/gitv", {
      \ "depends": ["tpope/vim-fugitive"],
      \ "autoload": {
      \   "commands": ["Gitv"],
      \ }}

    " support for edting
    NeoBundle 'tpope/vim-surround'
    NeoBundle 'vim-scripts/Align'
    NeoBundle 'vim-scripts/YankRing.vim'
    if has('lua') && v:version >= 703 && has('patch885')
        NeoBundleLazy 'Shougo/neocomplete.vim', {
            \ 'autoload': {
            \   'insert': 1,
            \ }}
        let g:neocomplete#enable_at_startup = 1
        let s:hooks = neobundle#get_hooks("neocomplete.vim")
        function! s:hooks.on_source(bundle)
            let g:acp_enableAtStartup = 0
            let g:neocomplet#enable_smart_case = 1
        endfunction
    else
        NeoBundleLazy 'Shougo/neocomplcache.vim', {
            \ 'autoload': {
            \   'insert': 1,
            \ }}
        let g:neocomplcache_enable_at_startup = 1
        let s:hooks = neobundle#get_hooks("neocomplcache.vim")
        function! s:hooks.on_source(bundle)
            let g:acp_enableAtStartup = 0
            let g:neocomplcache_enable_smart_case = 1
        endfunction
    endif
    NeoBundleLazy "davidhalter/jedi-vim", {
      \ "autoload": {
      \   "filetypes": ["python", "python3"],
      \ },
      \ "build": {
      \   "mac": "pip install jedi",
      \   "unix": "pip install jedi",
      \ }}
    let s:hooks = neobundle#get_hooks('jedi-vim')
    function! s:hooks.on_source(bundle)
        let g:jedi#popup_select_first = 0
        let g:jedi#show_call_signatures = 0
    endfunction

    " colorscheme
    NeoBundle 'altercation/vim-colors-solarized'

    " statusline
    NeoBundle 'vim-airline/vim-airline'
        let g:airline_theme = 'powerlineish'
        " if mac, use powerline font
        if has('mac') || has('macunix')
            let g:airline_powerline_fonts = 1
        else
            if !exists('g:airline_symbols')
                let g:airline_symbols = {}
            endif
            " unicode symbols
            let g:airline_left_sep = '»'
            let g:airline_left_sep = '▶'
            let g:airline_right_sep = '«'
            let g:airline_right_sep = '◀'
            let g:airline_symbols.crypt = '🔒'
            let g:airline_symbols.linenr = '␊'
            let g:airline_symbols.linenr = '␤'
            let g:airline_symbols.linenr = '¶'
            let g:airline_symbols.branch = '⎇'
            let g:airline_symbols.paste = 'ρ'
            let g:airline_symbols.paste = 'Þ'
            let g:airline_symbols.paste = '∥'
            let g:airline_symbols.whitespace = 'Ξ'
        endif
        " use airline-tab
        let g:airline#extensions#tabline#enabled = 1
        " display tabline if tab exists
        let g:airline#extensions#tabline#show_tabs = 0
        let g:airline#extensions#tabline#show_buffers = 0
        let g:airline#extensions#tabline#tab_min_count = 1
        let g:airline#extensions#tabline#buffer_min_count = 1

    NeoBundle 'vim-airline/vim-airline-themes'

    call neobundle#end()

    NeoBundleCheck
else
    " no neobundle
    command! NeoBundleInit try | call s:neobundle_init()
                \| catch /^neobundleinit:/
                    \|   echohl ErrorMsg
                    \|   echomsg v:exception
                    \|   echohl None
                    \| endtry

    function! s:neobundle_init()
        redraw | echo "Installing neobundle.vim..."
        if !isdirectory($VIMBUNDLE)
            call mkdir($VIMBUNDLE, 'p')
            echo printf("Creating '%s'.", $VIMBUNDLE)
        endif
        cd $VIMBUNDLE

        if executable('git')
            call system('git clone git://github.com/Shougo/neobundle.vim')
            if v:shell_error
                throw 'neobundleinit: Git error.'
            endif
        endif

        set runtimepath& runtimepath+=$NEOBUNDLEPATH
        call neobundle#rc($VIMBUNDLE)
        try
            echo printf("Reloading '%s'", $MYVIMRC)
            source $MYVIMRC
        catch
            echohl ErrorMsg
            echomsg 'neobundleinit: $MYVIMRC: could not source.'
            echohl None
            return 0
        finally
            echomsg 'Installed neobundle.vim'
        endtry

        echomsg 'Finish!'
    endfunction

    autocmd! VimEnter * redraw
                \ | echohl WarningMsg
                \ | echo "You should do ':NeoBundleInit' at first!"
                \ | echohl None
endif

filetype plugin indent on

function! s:has_plugin(name)
      " Check {name} plugin whether there is in the runtime path
      let nosuffix = a:name =~? '\.vim$' ? a:name[:-5] : a:name
      let suffix   = a:name =~? '\.vim$' ? a:name      : a:name . '.vim'
      return &rtp =~# '\c\<' . nosuffix . '\>'
            \   || globpath(&rtp, suffix, 1) != ''
            \   || globpath(&rtp, nosuffix, 1) != ''
            \   || globpath(&rtp, 'autoload/' . suffix, 1) != ''
            \   || globpath(&rtp, 'autoload/' . tolower(suffix),1) != ''
endfunction

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
set softtabstop=4
" use 4 spaces for indent
set shiftwidth=4
" use multiple of shiftwidth for indent
set shiftround
" don't case uppercase or lowercase when autocomplete
set infercase
" enable to move area on which theare are no letters
set virtualedit=all
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
" clipboard settings
if has('unnamedplus')
    set clipboard& clipboard+=unnamedplus,unnamed
else
    set clipboard& clipboard+=unnamed
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
" wrap long text
set wrap
" disable auto newline
set textwidth=0
" display line on the 80 letters
set colorcolumn=80
" display cursor
set ruler
" hightlight cursor line
set cursorline
" display command autocomplete on statusline
set wildmenu
" display statusline
set laststatus=2
" enable syntax highlight
syntax enable
" dark background
set background=dark
if s:has_plugin('vim-colors-solarized')
    " set colorscheme solarized
    colorscheme solarized
endif
" no visualbell
set novisualbell t_vb=
" use these letters below for invisuable letters
set listchars=tab:»-,trail:-,extends:»,precedes:«,nbsp:%,eol:↲
if $TERM == 'screen'
    "use 256 color
    set t_Co=256
    set term=xterm-256color
    set termencoding=utf-8
endif
" setting for macvim
if has('gui_macvim')
    set guifont=Meslo\ LG\ M\ for\ Powerline:h14
    set guioptions-=T "no toolbar
    set guioptions-=m "no menubar
    "no right scrollbar
    set guioptions-=r
    set guioptions-=R
    "no left scrollbar
    set guioptions-=l
    set guioptions-=L
    "no bottom scrollbar
    set guioptions-=b
endif
