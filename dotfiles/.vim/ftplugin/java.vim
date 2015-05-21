" Save, compile and run java file
command! RunJava w|!javac -cp '*:.' % && java -cp '*:.' %:r

