" fugitive.vim - A Git wrapper so awesome, it should be illegal
" Maintainer:   Tim Pope <vimNOSPAM@tpope.org>
" Version:      1.2
" GetLatestVimScripts: 2975 1 :AutoInstall: fugitive.vim

if v:version < 700
    echoerr "fugitive.vim requires vim > 7. "
    finish
endif

if exists('g:loaded_fugitive') || &cp
  finish
endif
let g:loaded_fugitive = 1

if !exists('g:fugitive_git_executable')
  let g:fugitive_git_executable = 'git'
endif

" Utility {{{1

function! s:function(name) abort
  return function(substitute(a:name,'^s:',matchstr(expand('<sfile>'), '<SNR>\d\+_'),''))
endfunction

function! s:sub(str,pat,rep) abort
  return substitute(a:str,'\v\C'.a:pat,a:rep,'')
endfunction

function! s:gsub(str,pat,rep) abort
  return substitute(a:str,'\v\C'.a:pat,a:rep,'g')
endfunction

function! s:shellesc(arg) abort
  if a:arg =~ '^[A-Za-z0-9_/.-]\+$'
    return a:arg
  elseif &shell =~# 'cmd' && a:arg !~# '"'
    return '"'.a:arg.'"'
  else
    return shellescape(a:arg)
  endif
endfunction

function! s:fnameescape(file) abort
  if exists('*fnameescape')
    return fnameescape(a:file)
  else
    return escape(a:file," \t\n*?[{`$\\%#'\"|!<")
  endif
endfunction

function! s:throw(string) abort
  let v:errmsg = 'fugitive: '.a:string
  throw v:errmsg
endfunction

function! s:warn(str)
  echohl WarningMsg
  echomsg a:str
  echohl None
  let v:warningmsg = a:str
endfunction

function! s:shellslash(path)
  if exists('+shellslash') && !&shellslash
    return s:gsub(a:path,'\\','/')
  else
    return a:path
  endif
endfunction

function! s:add_methods(namespace, method_names) abort
  for name in a:method_names
    let s:{a:namespace}_prototype[name] = s:function('s:'.a:namespace.'_'.name)
  endfor
endfunction

let s:commands = []
function! s:command(definition) abort
  let s:commands += [a:definition]
endfunction

function! s:define_commands()
  for command in s:commands
    exe 'command! -buffer '.command
  endfor
endfunction

function! s:compatibility_check()
  if exists('b:git_dir') && exists('*GitBranchInfoCheckGitDir') && !exists('g:fugitive_did_compatibility_warning')
    let g:fugitive_did_compatibility_warning = 1
    call s:warn("See http://github.com/tpope/vim-fugitive/issues#issue/1 for why you should remove git-branch-info.vim")
  endif
endfunction

augroup fugitive_utility
  autocmd!
  autocmd User Fugitive call s:define_commands()
  autocmd VimEnter * call s:compatibility_check()
augroup END

let s:abstract_prototype = {}

" }}}1
" Initialization {{{1

function! s:ExtractGitDir(path) abort
  let path = s:shellslash(a:path)
  if path =~? '^fugitive://.*//'
    return matchstr(path,'fugitive://\zs.\{-\}\ze//')
  endif
  let fn = fnamemodify(path,':s?[\/]$??')
  let ofn = ""
  let nfn = fn
  while fn != ofn
    if filereadable(fn . '/.git/HEAD')
      return s:sub(simplify(fnamemodify(fn . '/.git',':p')),'\W$','')
    elseif fn =~ '\.git$' && filereadable(fn . '/HEAD')
      return s:sub(simplify(fnamemodify(fn,':p')),'\W$','')
    endif
    let ofn = fn
    let fn = fnamemodify(ofn,':h')
  endwhile
  return ''
endfunction

function! s:Detect(path)
  if exists('b:git_dir') && b:git_dir ==# ''
    unlet b:git_dir
  endif
  if !exists('b:git_dir')
    let dir = s:ExtractGitDir(a:path)
    if dir != ''
      let b:git_dir = dir
    endif
  endif
  if exists('b:git_dir')
    silent doautocmd User Fugitive
    cnoremap <expr> <buffer> <C-R><C-G> fugitive#buffer().rev()
    let buffer = fugitive#buffer()
    if expand('%:p') =~# '//'
      call buffer.setvar('&path',s:sub(buffer.getvar('&path'),'^\.%(,|$)',''))
    endif
    if b:git_dir !~# ',' && stridx(buffer.getvar('&tags'),b:git_dir.'/tags') == -1
      if &filetype != ''
        call buffer.setvar('&tags',buffer.getvar('&tags').','.b:git_dir.'/'.&filetype.'.tags')
      endif
      call buffer.setvar('&tags',buffer.getvar('&tags').','.b:git_dir.'/tags')
    endif
  endif
endfunction

augroup fugitive
  autocmd!
  autocmd BufNewFile,BufReadPost * call s:Detect(expand('<amatch>:p'))
  autocmd FileType           netrw call s:Detect(expand('<afile>:p'))
  autocmd VimEnter * if expand('<amatch>')==''|call s:Detect(getcwd())|endif
  autocmd BufWinLeave * execute getwinvar(+winnr(), 'fugitive_restore')
augroup END

" }}}1
" Repository {{{1

let s:repo_prototype = {}
let s:repos = {}

function! s:repo(...) abort
  let dir = a:0 ? a:1 : (exists('b:git_dir') && b:git_dir !=# '' ? b:git_dir : s:ExtractGitDir(expand('%:p')))
  if dir !=# ''
    if has_key(s:repos,dir)
      let repo = get(s:repos,dir)
    else
      let repo = {'git_dir': dir}
      let s:repos[dir] = repo
    endif
    return extend(extend(repo,s:repo_prototype,'keep'),s:abstract_prototype,'keep')
  endif
  call s:throw('not a git repository: '.expand('%:p'))
endfunction

function! s:repo_dir(...) dict abort
  return join([self.git_dir]+a:000,'/')
endfunction

function! s:repo_tree(...) dict abort
  if !self.bare()
    let dir = fnamemodify(self.git_dir,':h')
    return join([dir]+a:000,'/')
  endif
  call s:throw('no work tree')
endfunction

function! s:repo_bare() dict abort
  return self.dir() !~# '/\.git$'
endfunction

function! s:repo_translate(spec) dict abort
  if a:spec ==# '.' || a:spec ==# '/.'
    return self.bare() ? self.dir() : self.tree()
  elseif a:spec =~# '^/'
    return fnamemodify(self.dir(),':h').a:spec
  elseif a:spec =~# '^:[0-3]:'
    return 'fugitive://'.self.dir().'//'.a:spec[1].'/'.a:spec[3:-1]
  elseif a:spec ==# ':'
    if $GIT_INDEX_FILE =~# '/[^/]*index[^/]*\.lock$' && fnamemodify($GIT_INDEX_FILE,':p')[0:strlen(s:repo().dir())] ==# s:repo().dir('') && filereadable($GIT_INDEX_FILE)
      return fnamemodify($GIT_INDEX_FILE,':p')
    else
      return self.dir('index')
    endif
  elseif a:spec =~# '^:/'
    let ref = self.rev_parse(matchstr(a:spec,'.[^:]*'))
    return 'fugitive://'.self.dir().'//'.ref
  elseif a:spec =~# '^:'
    return 'fugitive://'.self.dir().'//0/'.a:spec[1:-1]
  elseif a:spec =~# 'HEAD\|^refs/' && a:spec !~ ':' && filereadable(self.dir(a:spec))
    return self.dir(a:spec)
  elseif filereadable(s:repo().dir('refs/'.a:spec))
    return self.dir('refs/'.a:spec)
  elseif filereadable(s:repo().dir('refs/tags/'.a:spec))
    return self.dir('refs/tags/'.a:spec)
  elseif filereadable(s:repo().dir('refs/heads/'.a:spec))
    return self.dir('refs/heads/'.a:spec)
  elseif filereadable(s:repo().dir('refs/remotes/'.a:spec))
    return self.dir('refs/remotes/'.a:spec)
  elseif filereadable(s:repo().dir('refs/remotes/'.a:spec.'/HEAD'))
    return self.dir('refs/remotes/'.a:spec,'/HEAD')
  else
    try
      let ref = self.rev_parse(matchstr(a:spec,'[^:]*'))
      let path = s:sub(matchstr(a:spec,':.*'),'^:','/')
      return 'fugitive://'.self.dir().'//'.ref.path
    catch /^fugitive:/
      return self.tree(a:spec)
    endtry
  endif
endfunction

call s:add_methods('repo',['dir','tree','bare','translate'])

function! s:repo_git_command(...) dict abort
  let git = g:fugitive_git_executable . ' --git-dir='.s:shellesc(self.git_dir)
  return git.join(map(copy(a:000),'" ".s:shellesc(v:val)'),'')
endfunction

function! s:repo_git_chomp(...) dict abort
  return s:sub(system(call(self.git_command,a:000,self)),'\n$','')
endfunction

function! s:repo_git_chomp_in_tree(...) dict abort
  let cd = exists('*haslocaldir') && haslocaldir() ? 'lcd ' : 'cd '
  let dir = getcwd()
  try
    execute cd.'`=s:repo().tree()`'
    return call(s:repo().git_chomp, a:000, s:repo())
  finally
    execute cd.'`=dir`'
  endtry
endfunction

function! s:repo_rev_parse(rev) dict abort
  let hash = self.git_chomp('rev-parse','--verify',a:rev)
  if hash =~ '\<\x\{40\}$'
    return matchstr(hash,'\<\x\{40\}$')
  endif
  call s:throw('rev-parse '.a:rev.': '.hash)
endfunction

call s:add_methods('repo',['git_command','git_chomp','git_chomp_in_tree','rev_parse'])

function! s:repo_dirglob(base) dict abort
  let base = s:sub(a:base,'^/','')
  let matches = split(glob(self.tree(s:gsub(base,'/','*&').'*/')),"\n")
  call map(matches,'v:val[ strlen(self.tree())+(a:base !~ "^/") : -1 ]')
  return matches
endfunction

function! s:repo_superglob(base) dict abort
  if a:base =~# '^/' || a:base !~# ':'
    let results = []
    if a:base !~# '^/'
      let heads = ["HEAD","ORIG_HEAD","FETCH_HEAD","MERGE_HEAD"]
      let heads += sort(split(s:repo().git_chomp("rev-parse","--symbolic","--branches","--tags","--remotes"),"\n"))
      call filter(heads,'v:val[ 0 : strlen(a:base)-1 ] ==# a:base')
      let results += heads
    endif
    if !self.bare()
      let base = s:sub(a:base,'^/','')
      let matches = split(glob(self.tree(s:gsub(base,'/','*&').'*')),"\n")
      call map(matches,'s:shellslash(v:val)')
      call map(matches,'v:val !~ "/$" && isdirectory(v:val) ? v:val."/" : v:val')
      call map(matches,'v:val[ strlen(self.tree())+(a:base !~ "^/") : -1 ]')
      let results += matches
    endif
    return results

  elseif a:base =~# '^:'
    let entries = split(self.git_chomp('ls-files','--stage'),"\n")
    call map(entries,'s:sub(v:val,".*(\\d)\\t(.*)",":\\1:\\2")')
    if a:base !~# '^:[0-3]\%(:\|$\)'
      call filter(entries,'v:val[1] == "0"')
      call map(entries,'v:val[2:-1]')
    endif
    call filter(entries,'v:val[ 0 : strlen(a:base)-1 ] ==# a:base')
    return entries

  else
    let tree = matchstr(a:base,'.*[:/]')
    let entries = split(self.git_chomp('ls-tree',tree),"\n")
    call map(entries,'s:sub(v:val,"^04.*\\zs$","/")')
    call map(entries,'tree.s:sub(v:val,".*\t","")')
    return filter(entries,'v:val[ 0 : strlen(a:base)-1 ] ==# a:base')
  endif
endfunction

call s:add_methods('repo',['dirglob','superglob'])

function! s:repo_keywordprg() dict abort
  let args = ' --git-dir='.escape(self.dir(),"\\\"' ").' show'
  if has('gui_running') && !has('win32')
    return g:fugitive_git_executable . ' --no-pager' . args
  else
    return g:fugitive_git_executable . args
  endif
endfunction

call s:add_methods('repo',['keywordprg'])

" }}}1
" Buffer {{{1

let s:buffer_prototype = {}

function! s:buffer(...) abort
  let buffer = {'#': bufnr(a:0 ? a:1 : '%')}
  call extend(extend(buffer,s:buffer_prototype,'keep'),s:abstract_prototype,'keep')
  if buffer.getvar('git_dir') !=# ''
    return buffer
  endif
  call s:throw('not a git repository: '.expand('%:p'))
endfunction

function! fugitive#buffer(...) abort
  return s:buffer(a:0 ? a:1 : '%')
endfunction

function! s:buffer_getvar(var) dict abort
  return getbufvar(self['#'],a:var)
endfunction

function! s:buffer_setvar(var,value) dict abort
  return setbufvar(self['#'],a:var,a:value)
endfunction

function! s:buffer_getline(lnum) dict abort
  return getbufline(self['#'],a:lnum)[0]
endfunction

function! s:buffer_repo() dict abort
  return s:repo(self.getvar('git_dir'))
endfunction

function! s:buffer_type(...) dict abort
  if self.getvar('fugitive_type') != ''
    let type = self.getvar('fugitive_type')
  elseif fnamemodify(self.spec(),':p') =~# '.\git/refs/\|\.git/\w*HEAD$'
    let type = 'head'
  elseif self.getline(1) =~ '^tree \x\{40\}$' && self.getline(2) == ''
    let type = 'tree'
  elseif self.getline(1) =~ '^\d\{6\} \w\{4\} \x\{40\}\>\t'
    let type = 'tree'
  elseif self.getline(1) =~ '^\d\{6\} \x\{40\}\> \d\t'
    let type = 'index'
  elseif isdirectory(self.spec())
    let type = 'directory'
  elseif self.spec() == ''
    let type = 'null'
  elseif filereadable(self.spec())
    let type = 'file'
  else
    let type = ''
  endif
  if a:0
    return !empty(filter(copy(a:000),'v:val ==# type'))
  else
    return type
  endif
endfunction

if has('win32')

  function! s:buffer_spec() dict abort
    let bufname = bufname(self['#'])
    let retval = ''
    for i in split(bufname,'[^:]\zs\\')
      let retval = fnamemodify((retval==''?'':retval.'\').i,':.')
    endfor
    return s:shellslash(fnamemodify(retval,':p'))
  endfunction

else

  function! s:buffer_spec() dict abort
    let bufname = bufname(self['#'])
    return s:shellslash(bufname == '' ? '' : fnamemodify(bufname,':p'))
  endfunction

endif

function! s:buffer_name() dict abort
  return self.spec()
endfunction

function! s:buffer_commit() dict abort
  return matchstr(self.spec(),'^fugitive://.\{-\}//\zs\w*')
endfunction

function! s:buffer_path(...) dict abort
  let rev = matchstr(self.spec(),'^fugitive://.\{-\}//\zs.*')
  if rev != ''
    let rev = s:sub(rev,'\w*','')
  else
    let rev = self.spec()[strlen(self.repo().tree()) : -1]
  endif
  return s:sub(s:sub(rev,'.\zs/$',''),'^/',a:0 ? a:1 : '')
endfunction

function! s:buffer_rev() dict abort
  let rev = matchstr(self.spec(),'^fugitive://.\{-\}//\zs.*')
  if rev =~ '^\x/'
    return ':'.rev[0].':'.rev[2:-1]
  elseif rev =~ '.'
    return s:sub(rev,'/',':')
  elseif self.spec() =~ '\.git/index$'
    return ':'
  elseif self.spec() =~ '\.git/refs/\|\.git/.*HEAD$'
    return self.spec()[strlen(self.repo().dir())+1 : -1]
  else
    return self.path()
  endif
endfunction

function! s:buffer_sha1() dict abort
  if self.spec() =~ '^fugitive://' || self.spec() =~ '\.git/refs/\|\.git/.*HEAD$'
    return self.repo().rev_parse(self.rev())
  else
    return ''
  endif
endfunction

function! s:buffer_expand(rev) dict abort
  if a:rev =~# '^:[0-3]$'
    let file = a:rev.self.path(':')
  elseif a:rev =~# '^[-:]/$'
    let file = '/'.self.path()
  elseif a:rev =~# '^-'
    let file = 'HEAD^{}'.a:rev[1:-1].self.path(':')
  elseif a:rev =~# '^@{'
    let file = 'HEAD'.a:rev.self.path(':')
  elseif a:rev =~# '^[~^]'
    let commit = s:sub(self.commit(),'^\d=$','HEAD')
    let file = commit.a:rev.self.path(':')
  else
    let file = a:rev
  endif
  return s:sub(s:sub(file,'\%$',self.path()),'\.\@<=/$','')
endfunction

function! s:buffer_containing_commit() dict abort
  if self.commit() =~# '^\d$'
    return ':'
  elseif self.commit() =~# '.'
    return self.commit()
  else
    return 'HEAD'
  endif
endfunction

call s:add_methods('buffer',['getvar','setvar','getline','repo','type','spec','name','commit','path','rev','sha1','expand','containing_commit'])

" }}}1
" Git {{{1

call s:command("-bang -nargs=? -complete=customlist,s:GitComplete Git :execute s:Git(<bang>0,<q-args>)")

function! s:ExecuteInTree(cmd) abort
  let cd = exists('*haslocaldir') && haslocaldir() ? 'lcd ' : 'cd '
  let dir = getcwd()
  try
    execute cd.'`=s:repo().tree()`'
    execute a:cmd
  finally
    execute cd.'`=dir`'
  endtry
endfunction

function! s:Git(bang,cmd) abort
  let git = s:repo().git_command()
  if has('gui_running') && !has('win32')
    let git .= ' --no-pager'
  endif
  let cmd = matchstr(a:cmd,'\v\C.{-}%($|\\@<!%(\\\\)*\|)@=')
  call s:ExecuteInTree('!'.git.' '.cmd)
  call fugitive#reload_status()
  return matchstr(a:cmd,'\v\C\\@<!%(\\\\)*\|\zs.*')
endfunction

function! s:GitComplete(A,L,P) abort
  if !exists('s:exec_path')
    let s:exec_path = s:sub(system(g:fugitive_git_executable.' --exec-path'),'\n$','')
  endif
  let cmds = map(split(glob(s:exec_path.'/git-*'),"\n"),'s:sub(v:val[strlen(s:exec_path)+5 : -1],"\\.exe$","")')
  if a:L =~ ' [[:alnum:]-]\+ '
    return s:repo().superglob(a:A)
  elseif a:A == ''
    return cmds
  else
    return filter(cmds,'v:val[0 : strlen(a:A)-1] ==# a:A')
  endif
endfunction

" }}}1
" Gcd, Glcd {{{1

function! s:DirComplete(A,L,P) abort
  let matches = s:repo().dirglob(a:A)
  return matches
endfunction

call s:command("-bar -bang -nargs=? -complete=customlist,s:DirComplete Gcd  :cd<bang>  `=s:repo().bare() ? s:repo().dir(<q-args>) : s:repo().tree(<q-args>)`")
call s:command("-bar -bang -nargs=? -complete=customlist,s:DirComplete Glcd :lcd<bang> `=s:repo().bare() ? s:repo().dir(<q-args>) : s:repo().tree(<q-args>)`")

" }}}1
" Gstatus {{{1

call s:command("-bar Gstatus :execute s:Status()")

function! s:Status() abort
  try
    Gpedit :
    wincmd P
    nnoremap <buffer> <silent> q    :<C-U>bdelete<CR>
  catch /^fugitive:/
    return 'echoerr v:errmsg'
  endtry
  return ''
endfunction

function! fugitive#reload_status() abort
  let mytab = tabpagenr()
  for tab in [mytab] + range(1,tabpagenr('$'))
    for winnr in range(1,tabpagewinnr(tab,'$'))
      if getbufvar(tabpagebuflist(tab)[winnr-1],'fugitive_type') ==# 'index'
        execute 'tabnext '.tab
        if winnr != winnr()
          execute winnr.'wincmd w'
          let restorewinnr = 1
        endif
        try
          if !&modified
            call s:BufReadIndex()
          endif
        finally
          if exists('restorewinnr')
            wincmd p
          endif
          execute 'tabnext '.mytab
        endtry
      endif
    endfor
  endfor
endfunction

function! s:StageDiff(...) abort
  let cmd = a:0 ? a:1 : 'Gdiff'
  let section = getline(search('^# .*:$','bnW'))
  let line = getline('.')
  let filename = matchstr(line,'^#\t\%([[:alpha:] ]\+: *\)\=\zs.\{-\}\ze\%( (new commits)\)\=$')
  if filename ==# '' && section == '# Changes to be committed:'
    return 'Git diff --cached'
  elseif filename ==# ''
    return 'Git diff'
  elseif line =~# '^#\trenamed:' && filename =~ ' -> '
    let [old, new] = split(filename,' -> ')
    execute 'Gedit '.s:fnameescape(':0:'.new)
    return cmd.' HEAD:'.s:fnameescape(old)
  elseif section == '# Changes to be committed:'
    execute 'Gedit '.s:fnameescape(':0:'.filename)
    return cmd.' -'
  else
    execute 'Gedit '.s:fnameescape('/'.filename)
    return cmd
  endif
endfunction

function! s:StageToggle(lnum1,lnum2) abort
  try
    let output = ''
    for lnum in range(a:lnum1,a:lnum2)
      let line = getline(lnum)
      let repo = s:repo()
      if line ==# '# Changes to be committed:'
        call repo.git_chomp_in_tree('reset','-q')
        silent! edit!
        1
        if !search('^# Untracked files:$','W')
          call search('^# Change','W')
        endif
        return ''
      elseif line =~# '^# Change\%(d but not updated\|s not staged for commit\):$'
        call repo.git_chomp_in_tree('add','-u')
        silent! edit!
        1
        if !search('^# Untracked files:$','W')
          call search('^# Change','W')
        endif
        return ''
      elseif line ==# '# Untracked files:'
        " Work around Vim parser idiosyncrasy
        call repo.git_chomp_in_tree('add','-N','.')
        silent! edit!
        1
        if !search('^# Change\%(d but not updated\|s not staged for commit\):$','W')
          call search('^# Change','W')
        endif
        return ''
      endif
      let filename = matchstr(line,'^#\t\%([[:alpha:] ]\+: *\)\=\zs.\{-\}\ze\%( (\a\+ [[:alpha:], ]\+)\)\=$')
      if filename ==# ''
        continue
      endif
      if !exists('first_filename')
        let first_filename = filename
      endif
      execute lnum
      let section = getline(search('^# .*:$','bnW'))
      if line =~# '^#\trenamed:' && filename =~ ' -> '
        let cmd = ['mv','--'] + reverse(split(filename,' -> '))
        let filename = cmd[-1]
      elseif section =~? ' to be '
        let cmd = ['reset','-q','--',filename]
      elseif line =~# '^#\tdeleted:'
        let cmd = ['rm','--',filename]
      else
        let cmd = ['add','--',filename]
      endif
      let output .= call(repo.git_chomp_in_tree,cmd,s:repo())."\n"
    endfor
    if exists('first_filename')
      let jump = first_filename
      let f = matchstr(getline(a:lnum1-1),'^#\t\%([[:alpha:] ]\+: *\)\=\zs.*')
      if f !=# '' | let jump = f | endif
      let f = matchstr(getline(a:lnum2+1),'^#\t\%([[:alpha:] ]\+: *\)\=\zs.*')
      if f !=# '' | let jump = f | endif
      silent! edit!
      1
      redraw
      call search('^#\t\%([[:alpha:] ]\+: *\)\=\V'.jump.'\%( (new commits)\)\=\$','W')
    endif
    echo s:sub(s:gsub(output,'\n+','\n'),'\n$','')
  catch /^fugitive:/
    return 'echoerr v:errmsg'
  endtry
  return 'checktime'
endfunction

function! s:StagePatch(lnum1,lnum2) abort
  let add = []
  let reset = []

  for lnum in range(a:lnum1,a:lnum2)
    let line = getline(lnum)
    if line ==# '# Changes to be committed:'
      return 'Git reset --patch'
    elseif line =~# '^# Change\%(d but not updated\|s not staged for commit\):$'
      return 'Git add --patch'
    endif
    let filename = matchstr(line,'^#\t\%([[:alpha:] ]\+: *\)\=\zs.\{-\}\ze\%( (new commits)\)\=$')
    if filename ==# ''
      continue
    endif
    if !exists('first_filename')
      let first_filename = filename
    endif
    execute lnum
    let section = getline(search('^# .*:$','bnW'))
    if line =~# '^#\trenamed:' && filename =~ ' -> '
      let reset += [split(filename,' -> ')[1]]
    elseif section =~? ' to be '
      let reset += [filename]
    elseif line !~# '^#\tdeleted:'
      let add += [filename]
    endif
  endfor
  try
    if !empty(add)
      execute "Git add --patch -- ".join(map(add,'s:shellesc(v:val)'))
    endif
    if !empty(reset)
      execute "Git reset --patch -- ".join(map(add,'s:shellesc(v:val)'))
    endif
    if exists('first_filename')
      silent! edit!
      1
      redraw
      call search('^#\t\%([[:alpha:] ]\+: *\)\=\V'.first_filename.'\%( (new commits)\)\=\$','W')
    endif
  catch /^fugitive:/
    return 'echoerr v:errmsg'
  endtry
  return 'checktime'
endfunction

" }}}1
" Gcommit {{{1

call s:command("-nargs=? -complete=customlist,s:CommitComplete Gcommit :execute s:Commit(<q-args>)")

function! s:Commit(args) abort
  let old_type = s:buffer().type()
  let cd = exists('*haslocaldir') && haslocaldir() ? 'lcd ' : 'cd '
  let dir = getcwd()
  let msgfile = s:repo().dir('COMMIT_EDITMSG')
  let outfile = tempname()
  let errorfile = tempname()
  try
    execute cd.'`=s:repo().tree()`'
    if &shell =~# 'cmd'
      let command = ''
      let old_editor = $GIT_EDITOR
      let $GIT_EDITOR = 'false'
    else
      let command = 'env GIT_EDITOR=false '
    endif
    let command .= s:repo().git_command('commit').' '.a:args
    if &shell =~# 'csh'
      silent execute '!('.command.' > '.outfile.') >& '.errorfile
    elseif a:args =~# '\%(^\| \)--interactive\>'
      execute '!'.command.' 2> '.errorfile
    else
      silent execute '!'.command.' > '.outfile.' 2> '.errorfile
    endif
    if !v:shell_error
      if filereadable(outfile)
        for line in readfile(outfile)
          echo line
        endfor
      endif
      return ''
    else
      let errors = readfile(errorfile)
      let error = get(errors,-2,get(errors,-1,'!'))
      if error =~# '\<false''\=\.$'
        let args = a:args
        let args = s:gsub(args,'%(%(^| )-- )@<!%(^| )@<=%(-[se]|--edit|--interactive)%($| )','')
        let args = s:gsub(args,'%(%(^| )-- )@<!%(^| )@<=%(-F|--file|-m|--message)%(\s+|\=)%(''[^'']*''|"%(\\.|[^"])*"|\\.|\S)*','')
        let args = s:gsub(args,'%(^| )@<=[%#]%(:\w)*','\=expand(submatch(0))')
        let args = '-F '.s:shellesc(msgfile).' '.args
        if args !~# '\%(^\| \)--cleanup\>'
          let args = '--cleanup=strip '.args
        endif
        let old_nr = bufnr('')
        if bufname('%') == '' && line('$') == 1 && getline(1) == '' && !&mod
          edit `=msgfile`
        else
          keepalt split `=msgfile`
        endif
        if old_type ==# 'index'
          execute 'bdelete '.old_nr
        endif
        let b:fugitive_commit_arguments = args
        setlocal bufhidden=delete filetype=gitcommit
        return '1'
      elseif error ==# '!'
        return s:Status()
      else
        call s:throw(error)
      endif
    endif
  catch /^fugitive:/
    return 'echoerr v:errmsg'
  finally
    if exists('old_editor')
      let $GIT_EDITOR = old_editor
    endif
    call delete(outfile)
    call delete(errorfile)
    execute cd.'`=dir`'
    call fugitive#reload_status()
  endtry
endfunction

function! s:CommitComplete(A,L,P) abort
  if a:A =~ '^-' || type(a:A) == type(0) " a:A is 0 on :Gcommit -<Tab>
    let args = ['-C', '-F', '-a', '-c', '-e', '-i', '-m', '-n', '-o', '-q', '-s', '-t', '-u', '-v', '--all', '--allow-empty', '--amend', '--author=', '--cleanup=', '--dry-run', '--edit', '--file=', '--include', '--interactive', '--message=', '--no-verify', '--only', '--quiet', '--reedit-message=', '--reuse-message=', '--signoff', '--template=', '--untracked-files', '--verbose']
    return filter(args,'v:val[0 : strlen(a:A)-1] ==# a:A')
  else
    return s:repo().superglob(a:A)
  endif
endfunction

function! s:FinishCommit()
  let args = getbufvar(+expand('<abuf>'),'fugitive_commit_arguments')
  if !empty(args)
    call setbufvar(+expand('<abuf>'),'fugitive_commit_arguments','')
    return s:Commit(args)
  endif
  return ''
endfunction

augroup fugitive_commit
  autocmd!
  autocmd VimLeavePre,BufDelete *.git/COMMIT_EDITMSG execute s:sub(s:FinishCommit(), '^echoerr (.*)', 'echohl ErrorMsg|echo \1|echohl NONE')
augroup END

" }}}1
" Ggrep, Glog {{{1

if !exists('g:fugitive_summary_format')
  let g:fugitive_summary_format = '%s'
endif

call s:command("-bang -nargs=? -complete=customlist,s:EditComplete Ggrep :execute s:Grep(<bang>0,<q-args>)")
call s:command("-bar -bang -nargs=* -complete=customlist,s:EditComplete Glog :execute s:Log('grep<bang>',<f-args>)")

function! s:Grep(bang,arg) abort
  let grepprg = &grepprg
  let grepformat = &grepformat
  let cd = exists('*haslocaldir') && haslocaldir() ? 'lcd ' : 'cd '
  let dir = getcwd()
  try
    execute cd.'`=s:repo().tree()`'
    let &grepprg = s:repo().git_command('--no-pager', 'grep', '-n')
    let &grepformat = '%f:%l:%m'
    exe 'grep! '.escape(matchstr(a:arg,'\v\C.{-}%($|[''" ]\@=\|)@='),'|')
    let list = getqflist()
    for entry in list
      if bufname(entry.bufnr) =~ ':'
        let entry.filename = s:repo().translate(bufname(entry.bufnr))
        unlet! entry.bufnr
      elseif a:arg =~# '\%(^\| \)--cached\>'
        let entry.filename = s:repo().translate(':0:'.bufname(entry.bufnr))
        unlet! entry.bufnr
      endif
    endfor
    call setqflist(list,'r')
    if !a:bang && !empty(list)
      return 'cfirst'.matchstr(a:arg,'\v\C[''" ]\zs\|.*')
    else
      return matchstr(a:arg,'\v\C[''" ]\|\zs.*')
    endif
  finally
    let &grepprg = grepprg
    let &grepformat = grepformat
    execute cd.'`=dir`'
  endtry
endfunction

function! s:Log(cmd,...)
  let path = s:buffer().path('/')
  if path =~# '^/\.git\%(/\|$\)' || index(a:000,'--') != -1
    let path = ''
  endif
  let cmd = ['--no-pager', 'log', '--no-color']
  let cmd += [escape('--pretty=format:fugitive://'.s:repo().dir().'//%H'.path.'::'.g:fugitive_summary_format,'%')]
  if empty(filter(a:000[0 : index(a:000,'--')],'v:val !~# "^-"'))
    if s:buffer().commit() =~# '\x\{40\}'
      let cmd += [s:buffer().commit()]
    elseif s:buffer().path() =~# '^\.git/refs/\|^\.git/.*HEAD$'
      let cmd += [s:buffer().path()[5:-1]]
    endif
  end
  let cmd += map(copy(a:000),'s:sub(v:val,"^\\%(%(:\\w)*)","\\=fnamemodify(s:buffer().path(),submatch(1))")')
  if path =~# '/.'
    let cmd += ['--',path[1:-1]]
  endif
  let grepformat = &grepformat
  let grepprg = &grepprg
  let cd = exists('*haslocaldir') && haslocaldir() ? 'lcd ' : 'cd '
  let dir = getcwd()
  try
    execute cd.'`=s:repo().tree()`'
    let &grepprg = call(s:repo().git_command,cmd,s:repo())
    let &grepformat = '%f::%m'
    exe a:cmd
  finally
    let &grepformat = grepformat
    let &grepprg = grepprg
    execute cd.'`=dir`'
  endtry
endfunction

" }}}1
" Gedit, Gpedit, Gsplit, Gvsplit, Gtabedit, Gread {{{1

function! s:Edit(cmd,...) abort
  if a:0 && a:1 == ''
    return ''
  elseif a:0
    let file = s:buffer().expand(a:1)
  elseif s:buffer().commit() ==# '' && s:buffer().path('/') !~# '^/.git\>'
    let file = s:buffer().path(':')
  else
    let file = s:buffer().path('/')
  endif
  try
    let file = s:repo().translate(file)
  catch /^fugitive:/
    return 'echoerr v:errmsg'
  endtry
  if a:cmd ==# 'read'
    return 'silent %delete_|read '.s:fnameescape(file).'|silent 1delete_|diffupdate|'.line('.')
  else
    if &previewwindow && getbufvar('','fugitive_type') ==# 'index'
      wincmd p
    endif
    return a:cmd.' '.s:fnameescape(file)
  endif
endfunction

function! s:EditComplete(A,L,P) abort
  return s:repo().superglob(a:A)
endfunction

call s:command("-bar -bang -nargs=? -complete=customlist,s:EditComplete Ge       :execute s:Edit('edit<bang>',<f-args>)")
call s:command("-bar -bang -nargs=? -complete=customlist,s:EditComplete Gedit    :execute s:Edit('edit<bang>',<f-args>)")
call s:command("-bar -bang -nargs=? -complete=customlist,s:EditComplete Gpedit   :execute s:Edit('pedit<bang>',<f-args>)")
call s:command("-bar -bang -nargs=? -complete=customlist,s:EditComplete Gsplit   :execute s:Edit('split<bang>',<f-args>)")
call s:command("-bar -bang -nargs=? -complete=customlist,s:EditComplete Gvsplit  :execute s:Edit('vsplit<bang>',<f-args>)")
call s:command("-bar -bang -nargs=? -complete=customlist,s:EditComplete Gtabedit :execute s:Edit('tabedit<bang>',<f-args>)")
call s:command("-bar -bang -nargs=? -count -complete=customlist,s:EditComplete Gread :execute s:Edit((!<count> && <line1> ? '' : <count>).'read<bang>',<f-args>)")

" }}}1
" Gwrite, Gwq {{{1

call s:command("-bar -bang -nargs=? -complete=customlist,s:EditComplete Gwrite :execute s:Write(<bang>0,<f-args>)")
call s:command("-bar -bang -nargs=? -complete=customlist,s:EditComplete Gw :execute s:Write(<bang>0,<f-args>)")
call s:command("-bar -bang -nargs=? -complete=customlist,s:EditComplete Gwq :execute s:Wq(<bang>0,<f-args>)")

function! s:Write(force,...) abort
  if exists('b:fugitive_commit_arguments')
    return 'write|bdelete'
  elseif expand('%:t') == 'COMMIT_EDITMSG' && $GIT_INDEX_FILE != ''
    return 'wq'
  elseif s:buffer().type() == 'index'
    return 'Gcommit'
  endif
  let mytab = tabpagenr()
  let mybufnr = bufnr('')
  let path = a:0 ? a:1 : s:buffer().path()
  if path =~# '^:\d\>'
    return 'write'.(a:force ? '! ' : ' ').s:fnameescape(s:repo().translate(s:buffer().expand(path)))
  endif
  let always_permitted = (s:buffer().path() ==# path && s:buffer().commit() =~# '^0\=$')
  if !always_permitted && !a:force && s:repo().git_chomp_in_tree('diff','--name-status','HEAD','--',path) . s:repo().git_chomp_in_tree('ls-files','--others','--',path) !=# ''
    let v:errmsg = 'fugitive: file has uncommitted changes (use ! to override)'
    return 'echoerr v:errmsg'
  endif
  let file = s:repo().translate(path)
  let treebufnr = 0
  for nr in range(1,bufnr('$'))
    if fnamemodify(bufname(nr),':p') ==# file
      let treebufnr = nr
    endif
  endfor

  if treebufnr > 0 && treebufnr != bufnr('')
    let temp = tempname()
    silent execute '%write '.temp
    for tab in [mytab] + range(1,tabpagenr('$'))
      for winnr in range(1,tabpagewinnr(tab,'$'))
        if tabpagebuflist(tab)[winnr-1] == treebufnr
          execute 'tabnext '.tab
          if winnr != winnr()
            execute winnr.'wincmd w'
            let restorewinnr = 1
          endif
          try
            let lnum = line('.')
            let last = line('$')
            silent execute '$read '.temp
            silent execute '1,'.last.'delete_'
            silent write!
            silent execute lnum
            let did = 1
          finally
            if exists('restorewinnr')
              wincmd p
            endif
            execute 'tabnext '.mytab
          endtry
        endif
      endfor
    endfor
    if !exists('did')
      call writefile(readfile(temp,'b'),file,'b')
    endif
  else
    execute 'write! '.s:fnameescape(s:repo().translate(path))
  endif

  if a:force
    let error = s:repo().git_chomp_in_tree('add', '--force', file)
  else
    let error = s:repo().git_chomp_in_tree('add', file)
  endif
  if v:shell_error
    let v:errmsg = 'fugitive: '.error
    return 'echoerr v:errmsg'
  endif
  if s:buffer().path() ==# path && s:buffer().commit() =~# '^\d$'
    set nomodified
  endif

  let one = s:repo().translate(':1:'.path)
  let two = s:repo().translate(':2:'.path)
  let three = s:repo().translate(':3:'.path)
  for nr in range(1,bufnr('$'))
    if bufloaded(nr) && !getbufvar(nr,'&modified') && (bufname(nr) == one || bufname(nr) == two || bufname(nr) == three)
      execute nr.'bdelete'
    endif
  endfor

  unlet! restorewinnr
  let zero = s:repo().translate(':0:'.path)
  for tab in range(1,tabpagenr('$'))
    for winnr in range(1,tabpagewinnr(tab,'$'))
      let bufnr = tabpagebuflist(tab)[winnr-1]
      let bufname = bufname(bufnr)
      if bufname ==# zero && bufnr != mybufnr
        execute 'tabnext '.tab
        if winnr != winnr()
          execute winnr.'wincmd w'
          let restorewinnr = 1
        endif
        try
          let lnum = line('.')
          let last = line('$')
          silent $read `=file`
          silent execute '1,'.last.'delete_'
          silent execute lnum
          set nomodified
          diffupdate
        finally
          if exists('restorewinnr')
            wincmd p
          endif
          execute 'tabnext '.mytab
        endtry
        break
      endif
    endfor
  endfor
  call fugitive#reload_status()
  return 'checktime'
endfunction

function! s:Wq(force,...) abort
  let bang = a:force ? '!' : ''
  if exists('b:fugitive_commit_arguments')
    return 'wq'.bang
  endif
  let result = call(s:function('s:Write'),[a:force]+a:000)
  if result =~# '^\%(write\|wq\|echoerr\)'
    return s:sub(result,'^write','wq')
  else
    return result.'|quit'.bang
  endif
endfunction

" }}}1
" Gdiff {{{1

call s:command("-bang -bar -nargs=? -complete=customlist,s:EditComplete Gdiff :execute s:Diff(<bang>0,<f-args>)")
call s:command("-bar -nargs=? -complete=customlist,s:EditComplete Gvdiff :execute s:Diff(0,<f-args>)")
call s:command("-bar -nargs=? -complete=customlist,s:EditComplete Gsdiff :execute s:Diff(1,<f-args>)")

augroup fugitive_diff
  autocmd!
  autocmd BufWinLeave * if s:diff_window_count() == 2 && &diff && getbufvar(+expand('<abuf>'), 'git_dir') !=# '' | call s:diff_off_all(getbufvar(+expand('<abuf>'), 'git_dir')) | endif
  autocmd BufWinEnter * if s:diff_window_count() == 1 && &diff && getbufvar(+expand('<abuf>'), 'git_dir') !=# '' | diffoff | endif
augroup END

function! s:diff_window_count()
  let c = 0
  for nr in range(1,winnr('$'))
    let c += getwinvar(nr,'&diff')
  endfor
  return c
endfunction

function! s:diff_off_all(dir)
  for nr in range(1,winnr('$'))
    if getwinvar(nr,'&diff')
      if nr != winnr()
        execute nr.'wincmd w'
        let restorewinnr = 1
      endif
      if exists('b:git_dir') && b:git_dir ==# a:dir
        diffoff
      endif
      if exists('restorewinnr')
        wincmd p
      endif
    endif
  endfor
endfunction

function! s:buffer_compare_age(commit) dict abort
  let scores = {':0': 1, ':1': 2, ':2': 3, ':': 4, ':3': 5}
  let my_score    = get(scores,':'.self.commit(),0)
  let their_score = get(scores,':'.a:commit,0)
  if my_score || their_score
    return my_score < their_score ? -1 : my_score != their_score
  elseif self.commit() ==# a:commit
    return 0
  endif
  let base = self.repo().git_chomp('merge-base',self.commit(),a:commit)
  if base ==# self.commit()
    return -1
  elseif base ==# a:commit
    return 1
  endif
  let my_time    = +self.repo().git_chomp('log','--max-count=1','--pretty=format:%at',self.commit())
  let their_time = +self.repo().git_chomp('log','--max-count=1','--pretty=format:%at',a:commit)
  return my_time < their_time ? -1 : my_time != their_time
endfunction

call s:add_methods('buffer',['compare_age'])

function! s:Diff(bang,...) abort
  let split = a:bang ? 'split' : 'vsplit'
  if exists(':DiffGitCached')
    return 'DiffGitCached'
  elseif (!a:0 || a:1 == ':') && s:buffer().commit() =~# '^[0-1]\=$' && s:repo().git_chomp_in_tree('ls-files', '--unmerged', '--', s:buffer().path()) !=# ''
    let nr = bufnr('')
    execute 'leftabove '.split.' `=fugitive#buffer().repo().translate(s:buffer().expand('':2''))`'
    execute 'nnoremap <buffer> <silent> dp :diffput '.nr.'<Bar>diffupdate<CR>'
    diffthis
    wincmd p
    execute 'rightbelow '.split.' `=fugitive#buffer().repo().translate(s:buffer().expand('':3''))`'
    execute 'nnoremap <buffer> <silent> dp :diffput '.nr.'<Bar>diffupdate<CR>'
    diffthis
    wincmd p
    diffthis
    return ''
  elseif a:0
    if a:1 ==# ''
      return ''
    elseif a:1 ==# '/'
      let file = s:buffer().path('/')
    elseif a:1 ==# ':'
      let file = s:buffer().path(':0:')
    elseif a:1 =~# '^:/.'
      try
        let file = s:repo().rev_parse(a:1).s:buffer().path(':')
      catch /^fugitive:/
        return 'echoerr v:errmsg'
      endtry
    else
      let file = s:buffer().expand(a:1)
    endif
    if file !~# ':' && file !~# '^/' && s:repo().git_chomp('cat-file','-t',file) =~# '^\%(tag\|commit\)$'
      let file = file.s:buffer().path(':')
    endif
  else
    let file = s:buffer().path(s:buffer().commit() == '' ? ':0:' : '/')
  endif
  try
    let spec = s:repo().translate(file)
    let commit = matchstr(spec,'\C[^:/]//\zs\x\+')
    if s:buffer().compare_age(commit) < 0
      execute 'rightbelow '.split.' `=spec`'
    else
      execute 'leftabove '.split.' `=spec`'
    endif
    diffthis
    wincmd p
    diffthis
    return ''
  catch /^fugitive:/
    return 'echoerr v:errmsg'
  endtry
endfunction

" }}}1
" Gmove, Gremove {{{1

function! s:Move(force,destination)
  if a:destination =~# '^/'
    let destination = a:destination[1:-1]
  else
    let destination = fnamemodify(s:sub(a:destination,'[%#]%(:\w)*','\=expand(submatch(0))'),':p')
    if destination[0:strlen(s:repo().tree())] ==# s:repo().tree('')
      let destination = destination[strlen(s:repo().tree('')):-1]
    endif
  endif
  if isdirectory(s:buffer().name())
    " Work around Vim parser idiosyncrasy
    let discarded = s:buffer().setvar('&swapfile',0)
  endif
  let message = call(s:repo().git_chomp_in_tree,['mv']+(a:force ? ['-f'] : [])+['--', s:buffer().path(), destination], s:repo())
  if v:shell_error
    let v:errmsg = 'fugitive: '.message
    return 'echoerr v:errmsg'
  endif
  let destination = s:repo().tree(destination)
  if isdirectory(destination)
    let destination = fnamemodify(s:sub(destination,'/$','').'/'.expand('%:t'),':.')
  endif
  call fugitive#reload_status()
  if s:buffer().commit() == ''
    if isdirectory(destination)
      return 'edit '.s:fnameescape(destination)
    else
      return 'saveas! '.s:fnameescape(destination)
    endif
  else
    return 'file '.s:fnameescape(s:repo().translate(':0:'.destination)
  endif
endfunction

function! s:MoveComplete(A,L,P)
  if a:A =~ '^/'
    return s:repo().superglob(a:A)
  else
    let matches = split(glob(a:A.'*'),"\n")
    call map(matches,'v:val !~ "/$" && isdirectory(v:val) ? v:val."/" : v:val')
    return matches
  endif
endfunction

function! s:Remove(force)
  if s:buffer().commit() ==# ''
    let cmd = ['rm']
  elseif s:buffer().commit() ==# '0'
    let cmd = ['rm','--cached']
  else
    let v:errmsg = 'fugitive: rm not supported here'
    return 'echoerr v:errmsg'
  endif
  if a:force
    let cmd += ['--force']
  endif
  let message = call(s:repo().git_chomp_in_tree,cmd+['--',s:buffer().path()],s:repo())
  if v:shell_error
    let v:errmsg = 'fugitive: '.s:sub(message,'error:.*\zs\n\(.*-f.*',' (add ! to force)')
    return 'echoerr '.string(v:errmsg)
  else
    call fugitive#reload_status()
    return 'bdelete'.(a:force ? '!' : '')
  endif
endfunction

augroup fugitive_remove
  autocmd!
  autocmd User Fugitive if s:buffer().commit() =~# '^0\=$' |
        \ exe "command! -buffer -bar -bang -nargs=1 -complete=customlist,s:MoveComplete Gmove :execute s:Move(<bang>0,<q-args>)" |
        \ exe "command! -buffer -bar -bang Gremove :execute s:Remove(<bang>0)" |
        \ endif
augroup END

" }}}1
" Gblame {{{1

augroup fugitive_blame
  autocmd!
  autocmd BufReadPost *.fugitiveblame setfiletype fugitiveblame
  autocmd FileType fugitiveblame setlocal nomodeline | if exists('b:git_dir') | let &l:keywordprg = s:repo().keywordprg() | endif
  autocmd Syntax fugitiveblame call s:BlameSyntax()
  autocmd User Fugitive if s:buffer().type('file', 'blob') | exe "command! -buffer -bar -bang -range=0 -nargs=* Gblame :execute s:Blame(<bang>0,<line1>,<line2>,<count>,[<f-args>])" | endif
augroup END

function! s:Blame(bang,line1,line2,count,args) abort
  try
    if s:buffer().path() == ''
      call s:throw('file or blob required')
    endif
    if filter(copy(a:args),'v:val !~# "^\\%(--root\|--show-name\\|-\\=\\%([ltwfs]\\|[MC]\\d*\\)\\+\\)$"') != []
      call s:throw('unsupported option')
    endif
    call map(a:args,'s:sub(v:val,"^\\ze[^-]","-")')
    let git_dir = s:repo().dir()
    let cmd = ['--no-pager', 'blame', '--show-number'] + a:args
    if s:buffer().commit() =~# '\D\|..'
      let cmd += [s:buffer().commit()]
    else
      let cmd += ['--contents', '-']
    endif
    let basecmd = call(s:repo().git_command,cmd+['--',s:buffer().path()],s:repo())
    try
      let cd = exists('*haslocaldir') && haslocaldir() ? 'lcd ' : 'cd '
      if !s:repo().bare()
        let dir = getcwd()
        execute cd.'`=s:repo().tree()`'
      endif
      if a:count
        execute 'write !'.substitute(basecmd,' blame ',' blame -L '.a:line1.','.a:line2.' ','g')
      else
        let error = tempname()
        let temp = error.'.fugitiveblame'
        if &shell =~# 'csh'
          silent! execute '%write !('.basecmd.' > '.temp.') >& '.error
        else
          silent! execute '%write !'.basecmd.' > '.temp.' 2> '.error
        endif
        if exists('l:dir')
          execute cd.'`=dir`'
          unlet dir
        endif
        if v:shell_error
          call s:throw(join(readfile(error),"\n"))
        endif
        let bufnr = bufnr('')
        let restore = 'call setwinvar(bufwinnr('.bufnr.'),"&scrollbind",0)'
        if &l:wrap
          let restore .= '|call setwinvar(bufwinnr('.bufnr.'),"&wrap",1)'
        endif
        if &l:foldenable
          let restore .= '|call setwinvar(bufwinnr('.bufnr.'),"&foldenable",1)'
        endif
        let winnr = winnr()
        windo set noscrollbind
        exe winnr.'wincmd w'
        setlocal scrollbind nowrap nofoldenable
        let top = line('w0') + &scrolloff
        let current = line('.')
        exe 'leftabove vsplit '.temp
        let b:git_dir = git_dir
        let b:fugitive_type = 'blame'
        let b:fugitive_blamed_bufnr = bufnr
        let w:fugitive_restore = restore
        let b:fugitive_blame_arguments = join(a:args,' ')
        call s:Detect(expand('%:p'))
        execute top
        normal! zt
        execute current
        execute "vertical resize ".(match(getline('.'),'\s\+\d\+)')+1)
        setlocal nomodified nomodifiable bufhidden=delete nonumber scrollbind nowrap foldcolumn=0 nofoldenable filetype=fugitiveblame
        nnoremap <buffer> <silent> q    :<C-U>bdelete<CR>
        nnoremap <buffer> <silent> <CR> :<C-U>exe <SID>BlameJump('')<CR>
        nnoremap <buffer> <silent> P    :<C-U>exe <SID>BlameJump('^'.v:count1)<CR>
        nnoremap <buffer> <silent> ~    :<C-U>exe <SID>BlameJump('~'.v:count1)<CR>
        nnoremap <buffer> <silent> o    :<C-U>exe <SID>Edit((&splitbelow ? "botright" : "topleft")." split", matchstr(getline('.'),'\x\+'))<CR>
        nnoremap <buffer> <silent> O    :<C-U>exe <SID>Edit("tabedit", matchstr(getline('.'),'\x\+'))<CR>
        syncbind
      endif
    finally
      if exists('l:dir')
        execute cd.'`=dir`'
      endif
    endtry
    return ''
  catch /^fugitive:/
    return 'echoerr v:errmsg'
  endtry
endfunction

function! s:BlameJump(suffix) abort
  let commit = matchstr(getline('.'),'^\^\=\zs\x\+')
  if commit =~# '^0\+$'
    let commit = ':0'
  endif
  let lnum = matchstr(getline('.'),'\d\+\ze\s\+[([:digit:]]')
  let path = matchstr(getline('.'),'^\^\=\zs\x\+\s\+\zs.\{-\}\ze\s*\d\+ ')
  if path ==# ''
    let path = s:buffer(b:fugitive_blamed_bufnr).path()
  endif
  let args = b:fugitive_blame_arguments
  let offset = line('.') - line('w0')
  let bufnr = bufnr('%')
  let winnr = bufwinnr(b:fugitive_blamed_bufnr)
  if winnr > 0
    exe winnr.'wincmd w'
  endif
  execute s:Edit('edit',commit.a:suffix.':'.path)
  if winnr > 0
    exe bufnr.'bdelete'
  endif
  execute 'Gblame '.args
  execute lnum
  let delta = line('.') - line('w0') - offset
  if delta > 0
    execute 'norm! 'delta."\<C-E>"
  elseif delta < 0
    execute 'norm! '(-delta)."\<C-Y>"
  endif
  syncbind
  return ''
endfunction

function! s:BlameSyntax() abort
  let b:current_syntax = 'fugitiveblame'
  syn match FugitiveblameBoundary "^\^"
  syn match FugitiveblameBlank                      "^\s\+\s\@=" nextgroup=FugitiveblameAnnotation,fugitiveblameOriginalFile,FugitiveblameOriginalLineNumber skipwhite
  syn match FugitiveblameHash       "\%(^\^\=\)\@<=\x\{7,40\}\>" nextgroup=FugitiveblameAnnotation,FugitiveblameOriginalLineNumber,fugitiveblameOriginalFile skipwhite
  syn match FugitiveblameUncommitted "\%(^\^\=\)\@<=0\{7,40\}\>" nextgroup=FugitiveblameAnnotation,FugitiveblameOriginalLineNumber,fugitiveblameOriginalFile skipwhite
  syn region FugitiveblameAnnotation matchgroup=FugitiveblameDelimiter start="(" end="\%( \d\+\)\@<=)" contained keepend oneline
  syn match FugitiveblameTime "[0-9:/+-][0-9:/+ -]*[0-9:/+-]\%( \+\d\+)\)\@=" contained containedin=FugitiveblameAnnotation
  syn match FugitiveblameLineNumber         " \@<=\d\+)\@=" contained containedin=FugitiveblameAnnotation
  syn match FugitiveblameOriginalFile       " \%(\f\+\D\@<=\|\D\@=\f\+\)\%(\%(\s\+\d\+\)\=\s\%((\|\s*\d\+)\)\)\@=" contained nextgroup=FugitiveblameOriginalLineNumber,FugitiveblameAnnotation skipwhite
  syn match FugitiveblameOriginalLineNumber " \@<=\d\+\%(\s(\)\@=" contained nextgroup=FugitiveblameAnnotation skipwhite
  syn match FugitiveblameOriginalLineNumber " \@<=\d\+\%(\s\+\d\+)\)\@=" contained nextgroup=FugitiveblameShort skipwhite
  syn match FugitiveblameShort              "\d\+)" contained contains=FugitiveblameLineNumber
  syn match FugitiveblameNotCommittedYet "(\@<=Not Committed Yet\>" contained containedin=FugitiveblameAnnotation
  hi def link FugitiveblameBoundary           Keyword
  hi def link FugitiveblameHash               Identifier
  hi def link FugitiveblameUncommitted        Function
  hi def link FugitiveblameTime               PreProc
  hi def link FugitiveblameLineNumber         Number
  hi def link FugitiveblameOriginalFile       String
  hi def link FugitiveblameOriginalLineNumber Float
  hi def link FugitiveblameShort              FugitiveblameDelimiter
  hi def link FugitiveblameDelimiter          Delimiter
  hi def link FugitiveblameNotCommittedYet    Comment
endfunction

" }}}1
" Gbrowse {{{1

call s:command("-bar -bang -count=0 -nargs=? -complete=customlist,s:EditComplete Gbrowse :execute s:Browse(<bang>0,<line1>,<count>,<f-args>)")

function! s:Browse(bang,line1,count,...) abort
  try
    let rev = a:0 ? substitute(a:1,'@[[:alnum:]_-]*\%(://.\{-\}\)\=$','','') : ''
    if rev ==# ''
      let expanded = s:buffer().rev()
    elseif rev ==# ':'
      let expanded = s:buffer().path('/')
    else
      let expanded = s:buffer().expand(rev)
    endif
    let full = s:repo().translate(expanded)
    let commit = ''
    if full =~# '^fugitive://'
      let commit = matchstr(full,'://.*//\zs\w\+')
      let path = matchstr(full,'://.*//\w\+\zs/.*')
      if commit =~ '..'
        let type = s:repo().git_chomp('cat-file','-t',commit.s:sub(path,'^/',':'))
      else
        let type = 'blob'
      endif
      let path = path[1:-1]
    elseif s:repo().bare()
      let path = '.git/' . full[strlen(s:repo().dir())+1:-1]
      let type = ''
    else
      let path = full[strlen(s:repo().tree())+1:-1]
      if path =~# '^\.git/'
        let type = ''
      elseif isdirectory(full)
        let type = 'tree'
      else
        let type = 'blob'
      endif
    endif
    if path =~# '^\.git/.*HEAD' && filereadable(s:repo().dir(path[5:-1]))
      let body = readfile(s:repo().dir(path[5:-1]))[0]
      if body =~# '^\x\{40\}$'
        let commit = body
        let type = 'commit'
        let path = ''
      elseif body =~# '^ref: refs/'
        let path = '.git/' . matchstr(body,'ref: \zs.*')
      endif
    endif

    if a:0 && a:1 =~# '@[[:alnum:]_-]*\%(://.\{-\}\)\=$'
      let remote = matchstr(a:1,'@\zs[[:alnum:]_-]\+\%(://.\{-\}\)\=$')
    elseif path =~# '^\.git/refs/remotes/.'
      let remote = matchstr(path,'^\.git/refs/remotes/\zs[^/]\+')
    else
      let remote = 'origin'
      let branch = matchstr(rev,'^[[:alnum:]/._-]\+\ze[:^~@]')
      if branch ==# '' && path =~# '^\.git/refs/\w\+/'
        let branch = s:sub(path,'^\.git/refs/\w+/','')
      endif
      if filereadable(s:repo().dir('refs/remotes/'.branch))
        let remote = matchstr(branch,'[^/]\+')
        let rev = rev[strlen(remote)+1:-1]
      else
        if branch ==# ''
          let branch = matchstr(s:repo().head_ref(),'\<refs/heads/\zs.*')
        endif
        if branch != ''
          let remote = s:repo().git_chomp('config','branch.'.branch.'.remote')
          if remote ==# ''
            let remote = 'origin'
          elseif rev[0:strlen(branch)-1] ==# branch && rev[strlen(branch)] =~# '[:^~@]'
            let rev = s:repo().git_chomp('config','branch.'.branch.'.merge')[11:-1] . rev[strlen(branch):-1]
          endif
        endif
      endif
    endif

    let raw = s:repo().git_chomp('config','remote.'.remote.'.url')
    if raw ==# ''
      let raw = remote
    endif

    let url = s:github_url(s:repo(),raw,rev,commit,path,type,a:line1,a:count)
    if url == ''
      let url = s:instaweb_url(s:repo(),rev,commit,path,type,a:count ? a:line1 : 0)
    endif

    if url == ''
      call s:throw("Instaweb failed to start and '".remote."' is not a GitHub remote")
    endif

    if a:bang
      let @* = url
      return 'echomsg '.string(url)
    else
      return 'echomsg '.string(url).'|silent Git web--browse '.shellescape(url,1)
    endif
  catch /^fugitive:/
    return 'echoerr v:errmsg'
  endtry
endfunction

function! s:github_url(repo,url,rev,commit,path,type,line1,line2) abort
  let path = a:path
  let repo_path = matchstr(a:url,'^\%(https\=://\|git://\|git@\)github\.com[/:]\zs.\{-\}\ze\%(\.git\)\=$')
  if repo_path ==# ''
    return ''
  endif
  let root = 'https://github.com/' . repo_path
  if path =~# '^\.git/refs/heads/'
    let branch = a:repo.git_chomp('config','branch.'.path[16:-1].'.merge')[11:-1]
    if branch ==# ''
      return root . '/commits/' . path[16:-1]
    else
      return root . '/commits/' . branch
    endif
  elseif path =~# '^\.git/refs/.'
    return root . '/commits/' . matchstr(path,'[^/]\+$')
  elseif path =~# '.git/\%(config$\|hooks\>\)'
    return root . '/admin'
  elseif path =~# '^\.git\>'
    return root
  endif
  if a:rev =~# '^[[:alnum:]._-]\+:'
    let commit = matchstr(a:rev,'^[^:]*')
  elseif a:commit =~# '^\d\=$'
    let local = matchstr(a:repo.head_ref(),'\<refs/heads/\zs.*')
    let commit = a:repo.git_chomp('config','branch.'.local.'.merge')[11:-1]
    if commit ==# ''
      let commit = local
    endif
  else
    let commit = a:commit
  endif
  if a:type == 'tree'
    let url = s:sub(root . '/tree/' . commit . '/' . path,'/$','')
  elseif a:type == 'blob'
    let url = root . '/blob/' . commit . '/' . path
    if a:line2 && a:line1 == a:line2
      let url .= '#L' . a:line1
    elseif a:line2
      let url .= '#L' . a:line1 . '-' . a:line2
    endif
  elseif a:type == 'tag'
    let commit = matchstr(getline(3),'^tag \zs.*')
    let url = root . '/tree/' . commit
  else
    let url = root . '/commit/' . commit
  endif
  return url
endfunction

function! s:instaweb_url(repo,rev,commit,path,type,...) abort
  let output = a:repo.git_chomp('instaweb','-b','unknown')
  if output =~# 'http://'
    let root = matchstr(output,'http://.*').'/?p='.fnamemodify(a:repo.dir(),':t')
  else
    return ''
  endif
  if a:path =~# '^\.git/refs/.'
    return root . ';a=shortlog;h=' . matchstr(a:path,'^\.git/\zs.*')
  elseif a:path =~# '^\.git\>'
    return root
  endif
  let url = root
  if a:commit =~# '^\x\{40\}$'
    if a:type ==# 'commit'
      let url .= ';a=commit'
    endif
    let url .= ';h=' . a:repo.rev_parse(a:commit . (a:path == '' ? '' : ':' . a:path))
  else
    if a:type ==# 'blob'
      let tmp = tempname()
      silent execute 'write !'.a:repo.git_command('hash-object','-w','--stdin').' > '.tmp
      let url .= ';h=' . readfile(tmp)[0]
    else
      try
        let url .= ';h=' . a:repo.rev_parse((a:commit == '' ? 'HEAD' : ':' . a:commit) . ':' . a:path)
      catch /^fugitive:/
        call s:throw('fugitive: cannot browse uncommitted file')
      endtry
    endif
    let root .= ';hb=' . matchstr(a:repo.head_ref(),'[^ ]\+$')
  endif
  if a:path !=# ''
    let url .= ';f=' . a:path
  endif
  if a:0 && a:1
    let url .= '#l' . a:1
  endif
  return url
endfunction

" }}}1
" File access {{{1

function! s:ReplaceCmd(cmd,...) abort
  let fn = bufname('')
  let tmp = tempname()
  let aw = &autowrite
  let prefix = ''
  try
    if a:0 && a:1 != ''
      if &shell =~# 'cmd'
        let old_index = $GIT_INDEX_FILE
        let $GIT_INDEX_FILE = a:1
      else
        let prefix = 'env GIT_INDEX_FILE='.s:shellesc(a:1).' '
      endif
    endif
    set noautowrite
    silent exe '!'.escape(prefix.a:cmd,'%#').' > '.tmp
  finally
    let &autowrite = aw
    if exists('old_index')
      let $GIT_INDEX_FILE = old_index
    endif
  endtry
  silent exe 'keepalt file '.tmp
  silent edit!
  silent exe 'keepalt file '.s:fnameescape(fn)
  call delete(tmp)
  silent exe 'doau BufReadPost '.s:fnameescape(fn)
endfunction

function! s:BufReadIndex()
  if !exists('b:fugitive_display_format')
    let b:fugitive_display_format = filereadable(expand('%').'.lock')
  endif
  let b:fugitive_display_format = b:fugitive_display_format % 2
  let b:fugitive_type = 'index'
  try
    let b:git_dir = s:repo().dir()
    setlocal noro ma
    if fnamemodify($GIT_INDEX_FILE !=# '' ? $GIT_INDEX_FILE : b:git_dir . '/index', ':p') ==# expand('%:p')
      let index = ''
    else
      let index = expand('%:p')
    endif
    if b:fugitive_display_format
      call s:ReplaceCmd(s:repo().git_command('ls-files','--stage'),index)
      set ft=git nospell
    else
      let cd = exists('*haslocaldir') && haslocaldir() ? 'lcd ' : 'cd '
      let dir = getcwd()
      try
        execute cd.'`=s:repo().tree()`'
        call s:ReplaceCmd(s:repo().git_command('status'),index)
      finally
        execute cd.'`=dir`'
      endtry
      set ft=gitcommit
    endif
    setlocal ro noma nomod nomodeline bufhidden=delete
    nnoremap <buffer> <silent> a :<C-U>let b:fugitive_display_format += 1<Bar>exe <SID>BufReadIndex()<CR>
    nnoremap <buffer> <silent> i :<C-U>let b:fugitive_display_format -= 1<Bar>exe <SID>BufReadIndex()<CR>
    nnoremap <buffer> <silent> D :<C-U>execute <SID>StageDiff()<CR>
    nnoremap <buffer> <silent> dd :<C-U>execute <SID>StageDiff()<CR>
    nnoremap <buffer> <silent> dh :<C-U>execute <SID>StageDiff('Gsdiff')<CR>
    nnoremap <buffer> <silent> ds :<C-U>execute <SID>StageDiff('Gsdiff')<CR>
    nnoremap <buffer> <silent> dv :<C-U>execute <SID>StageDiff()<CR>
    nnoremap <buffer> <silent> - :<C-U>execute <SID>StageToggle(line('.'),line('.')+v:count1-1)<CR>
    xnoremap <buffer> <silent> - :<C-U>execute <SID>StageToggle(line("'<"),line("'>"))<CR>
    nnoremap <buffer> <silent> p :<C-U>execute <SID>StagePatch(line('.'),line('.')+v:count1-1)<CR>
    xnoremap <buffer> <silent> p :<C-U>execute <SID>StagePatch(line("'<"),line("'>"))<CR>
    nnoremap <buffer> <silent> <C-N> :call search('^#\t.*','W')<Bar>.<CR>
    nnoremap <buffer> <silent> <C-P> :call search('^#\t.*','Wbe')<Bar>.<CR>
    call s:JumpInit()
    nunmap   <buffer>          P
    nunmap   <buffer>          ~
    nnoremap <buffer> <silent> C :<C-U>Gcommit<CR>
  catch /^fugitive:/
    return 'echoerr v:errmsg'
  endtry
endfunction

function! s:FileRead()
  try
    let repo = s:repo(s:ExtractGitDir(expand('<amatch>')))
    let path = s:sub(s:sub(matchstr(expand('<amatch>'),'fugitive://.\{-\}//\zs.*'),'/',':'),'^\d:',':&')
    let hash = repo.rev_parse(path)
    if path =~ '^:'
      let type = 'blob'
    else
      let type = repo.git_chomp('cat-file','-t',hash)
    endif
    " TODO: use count, if possible
    return "read !".escape(repo.git_command('cat-file',type,hash),'%#\')
  catch /^fugitive:/
    return 'echoerr v:errmsg'
  endtry
endfunction

function! s:BufReadIndexFile()
  try
    let b:fugitive_type = 'blob'
    let b:git_dir = s:repo().dir()
    call s:ReplaceCmd(s:repo().git_command('cat-file','blob',s:buffer().sha1()))
    return ''
  catch /^fugitive: rev-parse/
    silent exe 'doau BufNewFile '.s:fnameescape(bufname(''))
    return ''
  catch /^fugitive:/
    return 'echoerr v:errmsg'
  endtry
endfunction

function! s:BufWriteIndexFile()
  let tmp = tempname()
  try
    let path = matchstr(expand('<amatch>'),'//\d/\zs.*')
    let stage = matchstr(expand('<amatch>'),'//\zs\d')
    silent execute 'write !'.s:repo().git_command('hash-object','-w','--stdin').' > '.tmp
    let sha1 = readfile(tmp)[0]
    let old_mode = matchstr(s:repo().git_chomp('ls-files','--stage',path),'^\d\+')
    if old_mode == ''
      let old_mode = executable(s:repo().tree(path)) ? '100755' : '100644'
    endif
    let info = old_mode.' '.sha1.' '.stage."\t".path
    call writefile([info],tmp)
    if has('win32')
      let error = system('type '.tmp.'|'.s:repo().git_command('update-index','--index-info'))
    else
      let error = system(s:repo().git_command('update-index','--index-info').' < '.tmp)
    endif
    if v:shell_error == 0
      setlocal nomodified
      silent execute 'doautocmd BufWritePost '.s:fnameescape(expand('%:p'))
      call fugitive#reload_status()
      return ''
    else
      return 'echoerr '.string('fugitive: '.error)
    endif
  finally
    call delete(tmp)
  endtry
endfunction

function! s:BufReadObject()
  try
    setlocal noro ma
    let b:git_dir = s:repo().dir()
    let hash = s:buffer().sha1()
    if !exists("b:fugitive_type")
      let b:fugitive_type = s:repo().git_chomp('cat-file','-t',hash)
    endif
    if b:fugitive_type !~# '^\%(tag\|commit\|tree\|blob\)$'
      return "echoerr 'fugitive: unrecognized git type'"
    endif
    let firstline = getline('.')
    if !exists('b:fugitive_display_format') && b:fugitive_type != 'blob'
      let b:fugitive_display_format = +getbufvar('#','fugitive_display_format')
    endif

    let pos = getpos('.')
    silent %delete
    setlocal endofline

    if b:fugitive_type == 'tree'
      let b:fugitive_display_format = b:fugitive_display_format % 2
      if b:fugitive_display_format
        call s:ReplaceCmd(s:repo().git_command('ls-tree',hash))
      else
        call s:ReplaceCmd(s:repo().git_command('show',hash))
      endif
    elseif b:fugitive_type == 'tag'
      let b:fugitive_display_format = b:fugitive_display_format % 2
      if b:fugitive_display_format
        call s:ReplaceCmd(s:repo().git_command('cat-file',b:fugitive_type,hash))
      else
        call s:ReplaceCmd(s:repo().git_command('cat-file','-p',hash))
      endif
    elseif b:fugitive_type == 'commit'
      let b:fugitive_display_format = b:fugitive_display_format % 2
      if b:fugitive_display_format
        call s:ReplaceCmd(s:repo().git_command('cat-file',b:fugitive_type,hash))
      else
        call s:ReplaceCmd(s:repo().git_command('show','--pretty=format:tree %T%nparent %P%nauthor %an <%ae> %ad%ncommitter %cn <%ce> %cd%nencoding %e%n%n%s%n%n%b',hash))
        call search('^parent ')
        if getline('.') ==# 'parent '
          silent delete_
        else
          silent s/\%(^parent\)\@<! /\rparent /ge
        endif
        if search('^encoding \%(<unknown>\)\=$','W',line('.')+3)
          silent delete_
        end
        1
      endif
    elseif b:fugitive_type ==# 'blob'
      call s:ReplaceCmd(s:repo().git_command('cat-file',b:fugitive_type,hash))
    endif
    call setpos('.',pos)
    setlocal ro noma nomod nomodeline
    if b:fugitive_type !=# 'blob'
      set filetype=git
      nnoremap <buffer> <silent> a :<C-U>let b:fugitive_display_format += v:count1<Bar>exe <SID>BufReadObject()<CR>
      nnoremap <buffer> <silent> i :<C-U>let b:fugitive_display_format -= v:count1<Bar>exe <SID>BufReadObject()<CR>
    else
      call s:JumpInit()
    endif

    return ''
  catch /^fugitive:/
    return 'echoerr v:errmsg'
  endtry
endfunction

augroup fugitive_files
  autocmd!
  autocmd BufReadCmd  *.git/index                      exe s:BufReadIndex()
  autocmd BufReadCmd  *.git/*index*.lock               exe s:BufReadIndex()
  autocmd FileReadCmd fugitive://**//[0-3]/**          exe s:FileRead()
  autocmd BufReadCmd  fugitive://**//[0-3]/**          exe s:BufReadIndexFile()
  autocmd BufWriteCmd fugitive://**//[0-3]/**          exe s:BufWriteIndexFile()
  autocmd BufReadCmd  fugitive://**//[0-9a-f][0-9a-f]* exe s:BufReadObject()
  autocmd FileReadCmd fugitive://**//[0-9a-f][0-9a-f]* exe s:FileRead()
  autocmd FileType git       call s:JumpInit()
augroup END

" }}}1
" Go to file {{{1

function! s:JumpInit() abort
  nnoremap <buffer> <silent> <CR>    :<C-U>exe <SID>GF("edit")<CR>
  if !&modifiable
    nnoremap <buffer> <silent> o     :<C-U>exe <SID>GF("split")<CR>
    nnoremap <buffer> <silent> O     :<C-U>exe <SID>GF("tabedit")<CR>
    nnoremap <buffer> <silent> P     :<C-U>exe <SID>Edit('edit',<SID>buffer().commit().'^'.v:count1.<SID>buffer().path(':'))<CR>
    nnoremap <buffer> <silent> ~     :<C-U>exe <SID>Edit('edit',<SID>buffer().commit().'~'.v:count1.<SID>buffer().path(':'))<CR>
    nnoremap <buffer> <silent> C     :<C-U>exe <SID>Edit('edit',<SID>buffer().containing_commit())<CR>
    nnoremap <buffer> <silent> cc    :<C-U>exe <SID>Edit('edit',<SID>buffer().containing_commit())<CR>
    nnoremap <buffer> <silent> co    :<C-U>exe <SID>Edit('split',<SID>buffer().containing_commit())<CR>
    nnoremap <buffer> <silent> cO    :<C-U>exe <SID>Edit('tabedit',<SID>buffer().containing_commit())<CR>
    nnoremap <buffer> <silent> cp    :<C-U>exe <SID>Edit('pedit',<SID>buffer().containing_commit())<CR>
  endif
endfunction

function! s:GF(mode) abort
  try
    let buffer = s:buffer()
    let myhash = buffer.sha1()

    if buffer.type('tree')
      let showtree = (getline(1) =~# '^tree ' && getline(2) == "")
      if showtree && line('.') == 1
        return ""
      elseif showtree && line('.') > 2
        return s:Edit(a:mode,buffer.commit().':'.s:buffer().path().(buffer.path() =~# '^$\|/$' ? '' : '/').s:sub(getline('.'),'/$',''))
      elseif getline('.') =~# '^\d\{6\} \l\{3,8\} \x\{40\}\t'
        return s:Edit(a:mode,buffer.commit().':'.s:buffer().path().(buffer.path() =~# '^$\|/$' ? '' : '/').s:sub(matchstr(getline('.'),'\t\zs.*'),'/$',''))
      endif

    elseif buffer.type('blob')
      let ref = expand("<cfile>")
      try
        let sha1 = buffer.repo().rev_parse(ref)
      catch /^fugitive:/
      endtry
      if exists('sha1')
        return s:Edit(a:mode,ref)
      endif

    else

      " Index
      if getline('.') =~# '^\d\{6\} \x\{40\} \d\t'
        let ref = matchstr(getline('.'),'\x\{40\}')
        let file = ':'.s:sub(matchstr(getline('.'),'\d\t.*'),'\t',':')
        return s:Edit(a:mode,file)

      elseif getline('.') =~# '^#\trenamed:.* -> '
        let file = '/'.matchstr(getline('.'),' -> \zs.*')
        return s:Edit(a:mode,file)
      elseif getline('.') =~# '^#\t[[:alpha:] ]\+: *.'
        let file = '/'.matchstr(getline('.'),': *\zs.\{-\}\ze\%( (new commits)\)\=$')
        return s:Edit(a:mode,file)
      elseif getline('.') =~# '^#\t.'
        let file = '/'.matchstr(getline('.'),'#\t\zs.*')
        return s:Edit(a:mode,file)
      elseif getline('.') =~# ': needs merge$'
        let file = '/'.matchstr(getline('.'),'.*\ze: needs merge$')
        return s:Edit(a:mode,file).'|Gdiff'

      elseif getline('.') ==# '# Not currently on any branch.'
        return s:Edit(a:mode,'HEAD')
      elseif getline('.') =~# '^# On branch '
        let file = 'refs/heads/'.getline('.')[12:]
        return s:Edit(a:mode,file)
      elseif getline('.') =~# "^# Your branch .*'"
        let file = matchstr(getline('.'),"'\\zs\\S\\+\\ze'")
        return s:Edit(a:mode,file)
      endif

      let showtree = (getline(1) =~# '^tree ' && getline(2) == "")

      if getline('.') =~# '^ref: '
        let ref = strpart(getline('.'),5)

      elseif getline('.') =~# '^parent \x\{40\}\>'
        let ref = matchstr(getline('.'),'\x\{40\}')
        let line = line('.')
        let parent = 0
        while getline(line) =~# '^parent '
          let parent += 1
          let line -= 1
        endwhile
        return s:Edit(a:mode,ref)

      elseif getline('.') =~ '^tree \x\{40\}$'
        let ref = matchstr(getline('.'),'\x\{40\}')
        if s:repo().rev_parse(myhash.':') == ref
          let ref = myhash.':'
        endif
        return s:Edit(a:mode,ref)

      elseif getline('.') =~# '^object \x\{40\}$' && getline(line('.')+1) =~ '^type \%(commit\|tree\|blob\)$'
        let ref = matchstr(getline('.'),'\x\{40\}')
        let type = matchstr(getline(line('.')+1),'type \zs.*')

      elseif getline('.') =~# '^\l\{3,8\} '.myhash.'$'
        return ''

      elseif getline('.') =~# '^\l\{3,8\} \x\{40\}\>'
        let ref = matchstr(getline('.'),'\x\{40\}')
        echoerr "warning: unknown context ".matchstr(getline('.'),'^\l*')

      elseif getline('.') =~# '^[+-]\{3\} [ab/]'
        let ref = getline('.')[4:]

      elseif getline('.') =~# '^rename from '
        let ref = 'a/'.getline('.')[12:]
      elseif getline('.') =~# '^rename to '
        let ref = 'b/'.getline('.')[10:]

      elseif getline('.') =~# '^diff --git \%(a/.*\|/dev/null\) \%(b/.*\|/dev/null\)'
        let dref = matchstr(getline('.'),'\Cdiff --git \zs\%(a/.*\|/dev/null\)\ze \%(b/.*\|/dev/null\)')
        let ref = matchstr(getline('.'),'\Cdiff --git \%(a/.*\|/dev/null\) \zs\%(b/.*\|/dev/null\)')
        let dcmd = 'Gdiff'

      elseif getline('.') =~# '^index ' && getline(line('.')-1) =~# '^diff --git \%(a/.*\|/dev/null\) \%(b/.*\|/dev/null\)'
        let line = getline(line('.')-1)
        let dref = matchstr(line,'\Cdiff --git \zs\%(a/.*\|/dev/null\)\ze \%(b/.*\|/dev/null\)')
        let ref = matchstr(line,'\Cdiff --git \%(a/.*\|/dev/null\) \zs\%(b/.*\|/dev/null\)')
        let dcmd = 'Gdiff!'

      elseif line('$') == 1 && getline('.') =~ '^\x\{40\}$'
        let ref = getline('.')
      else
        let ref = ''
      endif

      if myhash ==# ''
        let ref = s:sub(ref,'^a/','HEAD:')
        let ref = s:sub(ref,'^b/',':0:')
        if exists('dref')
          let dref = s:sub(dref,'^a/','HEAD:')
        endif
      else
        let ref = s:sub(ref,'^a/',myhash.'^:')
        let ref = s:sub(ref,'^b/',myhash.':')
        if exists('dref')
          let dref = s:sub(dref,'^a/',myhash.'^:')
        endif
      endif

      if ref ==# '/dev/null'
        " Empty blob
        let ref = 'e69de29bb2d1d6434b8b29ae775ad8c2e48c5391'
      endif

      if exists('dref')
        return s:Edit(a:mode,ref) . '|'.dcmd.' '.s:fnameescape(dref)
      elseif ref != ""
        return s:Edit(a:mode,ref)
      endif

    endif
    return ''
  catch /^fugitive:/
    return 'echoerr v:errmsg'
  endtry
endfunction

" }}}1
" Statusline {{{1

function! s:repo_head_ref() dict abort
  return readfile(s:repo().dir('HEAD'))[0]
endfunction

call s:add_methods('repo',['head_ref'])

function! fugitive#statusline(...)
  if !exists('b:git_dir')
    return ''
  endif
  let status = ''
  if s:buffer().commit() != ''
    let status .= ':' . s:buffer().commit()[0:7]
  endif
  let head = s:repo().head_ref()
  if head =~# '^ref: '
    let status .= s:sub(head,'^ref: %(refs/%(heads/|remotes/|tags/)=)=','(').')'
  elseif head =~# '^\x\{40\}$'
    let status .= '('.head[0:7].')'
  endif
  if &statusline =~# '%[MRHWY]' && &statusline !~# '%[mrhwy]'
    return ',GIT'.status
  else
    return '[Git'.status.']'
  endif
endfunction

function! s:repo_config(conf) dict abort
  return matchstr(system(s:repo().git_command('config').' '.a:conf),"[^\r\n]*")
endfun

function! s:repo_user() dict abort
  let username = s:repo().config('user.name')
  let useremail = s:repo().config('user.email')
  return username.' <'.useremail.'>'
endfun

call s:add_methods('repo',['config', 'user'])

" }}}1

" vim:set ft=vim ts=8 sw=2 sts=2:
