" Save, compile and run java file
command! RunJava up|!javac -cp '*:.' % && java -cp '*:.' %:r

finish

" Set up java source paths
let s:config = gim#project_settings()
let s:root = gim#project_root()


let s:source_paths = map(get(s:config, 'sourcepath', []), 's:root . "/" . v:val')
let s:class_paths = map(get(s:config, 'classpath', []), 's:root . "/" . v:val')

let g:ftplugin_java_source_path=join(s:source_paths, ",")

if exists("g:syntastic_java_javac_classpath")
  let s:classpath = split(g:syntastic_java_javac_classpath, ":")
else
  let s:classpath = []
endif
call extend(s:classpath, s:class_paths)
" call extend(s:classpath, s:source_paths)

if !empty(s:classpath)
  let g:syntastic_java_javac_classpath = join(s:classpath, ":")
endif

