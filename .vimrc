set number
set mouse=a

colorscheme darkblue

set autoindent
set cindent
set tabstop=2
set shiftwidth=2
set expandtab

"play well with ctags
set tags=./tags,./../tags,./../../tags,./../../../tags,tags

"make the home key behave well
imap <Home> <Esc>^i

"change fontsize
nnoremap <C-Up> :silent! let &guifont = substitute(&guifont, '\zs\d\+','\=eval(submatch(0)+1)','')<CR>
nnoremap <C-Down> :silent! let &guifont = substitute(&guifont, '\zs\d\+', '\=eval(submatch(0)-1)', '')<CR>

"Command to see the difference with the original file.
command DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis | wincmd p | diffthis
