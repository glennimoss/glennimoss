" Save, compile and run java file
command! RunJava up|!javac -cp '*:.' % && java -cp '*:.' %:r

