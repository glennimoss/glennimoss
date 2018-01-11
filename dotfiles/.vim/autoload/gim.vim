" My personal library of VimL utils

if !exists("g:gim_project_root_files")
  let g:gim_project_root_files = []
endif

let g:gim_project_root_files += [ ".vimproject",
                                \ "build.xml",
                                \ "build.gradle",
                                \ "Makefile",
                                \ "Rakefile",
                                \ "pom.xml",
                                \]

let s:projects = {}

function! gim#_projects ()
  return s:projects
endfunction

function! gim#project_root ()
  if exists('b:project_root_dir')
    return b:project_root_dir
  endif

  let root=""
  for cmd in [ "git rev-parse --show-toplevel",
             \ "svn info | grep -oP '^Working Copy Root Path: \\K.*$'",
             \]
    let root = system(cmd)
    if v:shell_error == 0
      let root = gim#trim(root)
      let b:project_root_dir = root
      break
    endif
  endfor

  if exists("b:project_root_dir")
    return root
  endif

  let root = fnamemodify(gim#search_parents_for(g:gim_project_root_files), ":h")
  if root != "."
    let b:project_root_dir = root
    return root
  endif

  return ""
endfunction

function! gim#search_parents_for (files)
  let l:path = expand("%:p:h") . ";"
  let l:files = uniq(sort(copy(a:files)))
  for fn in l:files
    let found = findfile(fn, l:path)
    if !empty(found)
      return found
    endif
  endfor
  return ""
endfunction


function! gim#project_settings ()
  let root = gim#project_root()
  let vimproject_file = root . "/.vimproject"

  if has_key(s:projects, root)
    let [mtime, config] = s:projects[root]
  else
    let mtime = -1
    let config = {}
  endif

  if getftime(vimproject_file) > mtime
    let s:projects[root] = gim#parse_vimproject(vimproject_file)
    let config = s:projects[root][1]
  endif

  return config
endfunction

function! gim#parse_vimproject (filename)
  let mtime = getftime(a:filename)

  " Parse it
  let config = {}

  py3 << ENDPY
import json

fname = vim.eval('a:filename')
try:
  with open(fname) as f:
    parsed = json.load(f)

  config = vim.bindeval('config')
  config.update(parsed)
except ValueError as e:
  pass
ENDPY

  return [mtime, config]
endfunction


function! gim#trim (s)
  return substitute(a:s, '^\_s*\(.\{-}\)\_s*$', '\1', '')
endfunction

