" Git
au BufNewFile,BufRead *.git/COMMIT_EDITMSG 	setf gitcommit
au BufNewFile,BufRead *.git/config,.gitconfig,.gitmodules setf gitconfig
au BufNewFile,BufRead *.git/modules/**/COMMIT_EDITMSG setf gitcommit
au BufNewFile,BufRead *.git/modules/**/config 	setf gitconfig
au BufNewFile,BufRead git-rebase-todo      	setf gitrebase
au BufNewFile,BufRead .msg.[0-9]*
      \ if getline(1) =~ '^From.*# This line is ignored.$' |
      \   setf gitsendemail |
      \ endif
au BufNewFile,BufRead *.git/**
      \ if getline(1) =~ '^\x\{40\}\>\|^ref: ' |
      \   setf git |
      \ endif

