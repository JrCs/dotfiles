" An example for a vimrc file.
"
" Maintainer:	Bram Moolenaar <Bram@vim.org>
" Last change:	2002 Sep 19
"
" To use it, copy it to
"     for Unix and OS/2:  ~/.vimrc
"	      for Amiga:  s:.vimrc
"  for MS-DOS and Win32:  $VIM\_vimrc
"	    for OpenVMS:  sys$login:.vimrc

" When started as "evim", evim.vim will already have done these settings.
if v:progname =~? "evim"
  finish
endif

" Use Vim settings, rather then Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

if has("vms")
  set nobackup		" do not keep a backup file, use versions instead
else
  set backup		" keep a backup file
  " Backup dans ~/.vim/backup
  if filewritable(expand("~/.autosave")) == 2
    " comme le répertoire est accessible en écriture,
    " on va l'utiliser.
    set backupdir=$HOME/.autosave
  else
    if has("unix") || has("win32unix")
        " C'est un système compatible UNIX, on
        " va créer le répertoire et l'utiliser.
        call system("mkdir -p $HOME/.autosave")
        set backupdir=$HOME/.autosave
    endif
  endif
endif

set history=50		" keep 50 lines of command line history
set ruler			" show the cursor position all the time
set showcmd			" display incomplete commands
set incsearch		" do incremental searching

" undo, pour revenir en arrière
set undolevels=150

" Suffixes à cacher
set suffixes=.jpg,.png,.jpeg,.gif,.bak,~,.swp,.swo,.o,.info,.aux,.log,.dvi,.bbl,.blg,.brf,.cb,.ind,.idx,.ilg,.inx,.out,.toc,.pyc,.pyo

" For Win32 GUI: remove 't' flag from 'guioptions': no tearoff menu entries
" let &guioptions = substitute(&guioptions, "t", "", "g")

" Don't use Ex mode, use Q for formatting
map Q gq

" This is an alternative that also works in block mode, but the deleted
" text is lost and it only works for putting the current register.
"vnoremap p "_dp

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
endif

" Quand un fichier est changé en dehors de Vim, il est relu automatiquement
set autoread

" Only do this part when compiled with support for autocommands.
if has("autocmd")

  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  filetype plugin indent on

  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
  au!

  " For all text files set 'textwidth' to 78 characters.
  autocmd FileType text setlocal textwidth=78

  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  autocmd BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal g`\"" |
    \ endif

  " DetectIndent for automatically detecting indent settings
  " URL=https://github.com/ciaranm/detectindent
  "
  " uncomment to have verbose messages
  " let g:detectindent_verbosity=1
  autocmd BufReadPost * :DetectIndent

  augroup END

else

  set autoindent		" always set autoindenting on

endif " has("autocmd")

"
" PERSONAL SETTINGS
"

" If using a dark background within the editing area and syntax highlighting
" " turn on this option as well
set background=dark

" Search be case insensitive by default
set ignorecase
" but only if the search string in ALL lower case
set smartcase

" My Statusline
set statusline=%F%(\ %m%h%w%r%)\ \ L%l/%L\ C%v\ (%P)\ [%{&ff}]\ [%{(&fenc==\"\"?&enc:&fenc)}]\ %y
set laststatus=2

" Tabs
" number of space characters that will be inserted when the tab key is pressed
set tabstop=4
" number of space characters inserted for indentation
set shiftwidth=4
" insert space characters whenever the tab key is pressed
set expandtab
" makes the backspace key treat the spaces like a tab
set softtabstop=4

" DetectIndent plugin
" prefer expand tab when detection is impossible
let g:detectindent_preferred_expandtab = 1
" preferred indent level when detection is impossible
let g:detectindent_preferred_indent = &shiftwidth

" That awful mixed mode with the half-tabs-are-spaces:
map \M <Esc>:set tabstop=8 shiftwidth=8 softtabstop=8<CR>

" Mini tabs, small "m":
map \m <Esc>:set tabstop=2 shiftwidth=2 softtabstop=2<CR>

" Normal tabs:
map \t <Esc>:set tabstop=4 shiftwidth=4 softtabstop=4<CR>
