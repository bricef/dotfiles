set nocp
set number
set mouse=a

set t_Co=256
syntax on

if has('gui_running')
  colorscheme BusyBee  
else
  colorscheme BusyBee
endif

"Tab and indent
set autoindent
set smartindent
set tabstop=2
set shiftwidth=2
set expandtab

autocmd FileType python set nocindent
autocmd FileType python set nosmartindent 


"various settings
set showmode
set showmatch
set ignorecase
set smartcase
setlocal wrap linebreak nolist
setlocal display+=lastline
set nowrap

" Turn backup off 
set nobackup
set nowb
set noswapfile


"Pasting stuff
nnoremap <F2> :set invpaste paste?<CR>
set pastetoggle=<F2>
set showmode


"moving between buffers
set autowrite " writes buffer on next/previous
nnoremap <C-Left> :bprevious<CR>
nnoremap <C-Right> :bnext<CR>



"search highlighting
set hlsearch
"Ctrl-l removes highlighting
nnoremap <silent> <C-l> :nohl<CR><C-l>
inoremap <silent> <C-l> <Esc>:nohl<CR>i

set ic        " ignorecase
set is        " incsearch
set scs       " smartcase: override the 'ic' when searching
              " if search pattern contains uppercase char

" Settings for VimClojure
let vimclojure#HighlightBuiltins=1      " Highlight Clojure's builtins
let vimclojure#ParenRainbow=1           " Rainbow parentheses'!

"allow up down to play well with wrapped lines
set whichwrap+=<,>,h,l 

"play well with makefiles
autocmd FileType make setlocal noexpandtab

"play well with ctags
set tags=./tags,./../tags,./../../tags,./../../../tags,tags

"make the home key behave well
imap <Home> <Esc>^i


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
command! DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis | wincmd p | diffthis

"folding settings
set foldmethod=syntax   "fold based on
set foldnestmax=1       "deepest fold is 1 levels
set nofoldenable        "dont fold by default

"Folding shortcuts
inoremap <C-f> <C-O>za
nnoremap <C-f> za
onoremap <C-f> <C-C>za
vnoremap <C-f> zf



"C code refactoring commands
command! Remiden s/\(\s*\).\{-}\*/\1/
command! Reminit s/=.*;/;/


"status line wrangling

function! HasPaste()
    if &paste
        return ',paste'
    else
        return ''
    endif
endfunction


set statusline=[>\ %{getcwd()}\ ]               " [> /working/path ]
set statusline+=\ %t                            " filename
set statusline+=\ [%n%M%R%H%W%{HasPaste()}]     " [2,+,paste]
set statusline+=\ [%{strlen(&ft)?&ft:'none'},   " [vim,
set statusline+=%{strlen(&fenc)?&fenc:&enc},    " utf8,
set statusline+=%{&fileformat}]                 " unix]
if version >= 700
  set statusline+=\ %{fugitive#statusline()}
endif
set statusline+=%=                              " <space>
set statusline+=\ L:%04l/%04v                   " L:0135/0057
set statusline+=\ (%p%%)                        " (82%)
set laststatus=2
if version >= 700
    au InsertEnter * hi StatusLine ctermfg=white ctermbg=88 cterm=bold
    au InsertLeave * hi StatusLine ctermfg=white ctermbg=0 cterm=bold
endif
hi StatusLine ctermfg=white ctermbg=0 cterm=bold

"80 character linewidth
"highlight OverLength ctermbg=darkred ctermfg=white guibg=#592929
"match OverLength '\%>80v.\+'
