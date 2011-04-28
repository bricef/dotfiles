set nocp
set number
set mouse=a

syntax on

colorscheme darkblue

"Tab and indent
set autoindent
set cindent
set tabstop=2
set shiftwidth=2
set expandtab

"various settings
set showmode
set showmatch
set ignorecase
set smartcase
setlocal wrap linebreak nolist
setlocal display+=lastline

"Pasting stuff
nnoremap <F2> :set invpaste paste?<CR>
set pastetoggle=<F2>
set showmode

"search highlighting
set hlsearch
nnoremap <silent> <C-l> :nohl<CR><C-l>
inoremap <silent> <C-l> :nohl<CR><C-l>

"status line wrangling
"set statusline=%F%m%r%h%w\ %y\ L:%04l/%04v\ (%p%%)\ buffer:%n
"set laststatus=2
"if version >= 700
"    au InsertEnter * hi StatusLine ctermfg=white ctermbg=red cterm=bold
"    au InsertLeave * hi StatusLine ctermfg=white ctermbg=blue cterm=bold
"endif
"hi StatusLine ctermfg=white ctermbg=blue cterm=bold

"allow up down to play well with wrapped lines
set whichwrap+=<,>,h,l 

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


"play well with wrapped line
nnoremap <Down> gj
nnoremap <Up> gk
nnoremap <End> g<End>
nnoremap <Home> g<Home>
vnoremap <Down> gj
vnoremap <Up> gk
vnoremap <End> g<End>
vnoremap <Home> g<Home>
inoremap <Down> <C-o>gj
inoremap <Up> <C-o>gk
inoremap <End> <C-o>g<End>
inoremap <Home> <C-o>g<Home>

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
