set nocp
set number
set mouse=a

colorscheme darkblue

set autoindent
set cindent
set tabstop=2
set shiftwidth=2
set expandtab

"play well with makefiles
autocmd FileType make setlocal noexpandtab

"play well with ctags
set tags=./tags,./../tags,./../../tags,./../../../tags,tags

"make the home key behave well
imap <Home> <Esc>^i

set ic        " ignorecase
set is        " incsearch
set scs       " smartcase: override the 'ic' when searching
              " if search pattern contains uppercase char


"Font setup for gui
let &guifont = "Monospace 11"

"change fontsize shortcuts
nnoremap <C-Up> :silent! let &guifont = substitute(&guifont, '\zs\d\+','\=eval(submatch(0)+1)','')<CR>
nnoremap <C-Down> :silent! let &guifont = substitute(&guifont, '\zs\d\+', '\=eval(submatch(0)-1)', '')<CR>

"Command to see the difference with the original file.
command DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis | wincmd p | diffthis

"folding settings
set foldmethod=syntax   "fold based on indent
set foldnestmax=1       "deepest fold is 1 levels
set nofoldenable        "dont fold by default

"Folding shortcuts
inoremap <C-f> <C-O>za
nnoremap <C-f> za
onoremap <C-f> <C-C>za
vnoremap <C-f> zf 
