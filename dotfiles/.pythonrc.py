# -*- coding: utf-8 -*-
r"""lonetwin's pimped-up pythonrc

A custom pythonrc which provides:
  * colored prompts
  * intelligent tab completion
    (for objects and their attributes/methods in the current namespace as well
     as file-system paths)
  * pretty-printing
  * shortcut to open your $EDITOR with the last executed command
    (the '\e' command)
  * temporary escape to shell or executing a shell command and capturing the
    output (the '!' command)
  * execution history

Some ideas borrowed from:
  * http://eseth.org/2008/pimping-pythonrc.html
    (which co-incidentally reused something I wrote back in 2005 !! Ain't
     sharing great ?)
  * http://igotgenes.blogspot.in/2009/01/tab-completion-and-history-in-python.html

This file will be executed when the Python interactive shell is started if
$PYTHONSTARTUP is in your environment and points to this file.

You could also simply make this file executable and call it directly.

If you have any other good ideas please feel free to leave a comment.
"""
try:
  import builtins
except ImportError:
  import __builtin__ as builtins
import atexit
import enum
import glob
import os
import pprint
import readline
import rlcompleter
import signal
import subprocess
import sys
import traceback
from tempfile import mkstemp
from code import InteractiveConsole


# Intelligent Tab completion support borrowed from
# http://igotgenes.blogspot.in/2009/01/tab-completion-and-history-in-python.html
class IrlCompleter (rlcompleter.Completer):
  """
  This class enables a "tab" insertion if there's no text for
  completion.

  The default "tab" is two spaces. You can initialize with '\t' as
  the tab if you wish to use a genuine tab.
  """

  def __init__ (self, tab='  ', namespace = None):
    self.tab = tab
    # - remove / from the delimiters to enable path completion
    readline.set_completer_delims(
        readline.get_completer_delims().replace('/', ''))
    rlcompleter.Completer.__init__(self, namespace)

  def complete (self, text, state):
    if text == '':
      return None if state > 0 else self.tab
    else:
      matches = rlcompleter.Completer.complete(self, text, state)
      if matches is None:
        if '/' in text:
          try:
            matches = glob.glob(text+'*')[state]
          except IndexError:
            return None
    return matches


# Enable History
HISTFILE="%s/.pyhistory" % os.environ["HOME"]

# Read the existing history if there is one
if os.path.exists(HISTFILE):
  readline.read_history_file(HISTFILE)

# Set maximum number of items that will be written to the history file
readline.set_history_length(300)

atexit.register(lambda :readline.write_history_file(HISTFILE))

Intensity = enum.Enum('Intensity', 'Bright Dim')

# Enable Color Prompts
# - borrowed from fabric (also used in botosh)
def _color_fn (code, intensity=None, invert=False):
  def inner (text, intensity=intensity, invert=invert, readline_workaround=False):
    # - reason for readline_workaround: http://bugs.python.org/issue20359
    codes = []
    if intensity:
      codes.append(str(intensity.value))
    if invert:
      codes.append('7')
    codes.append(str(code))

    if readline_workaround:
      #return "\001\033[%sm\002%s\001\033[0m\002" % ('1;%d' % code if bright else str(code), text)
      fmt = "\001\033[{}m\002{}\001\033[0m\002"
    else:
      #return "\033[%sm%s\033[0m" % ('1;%d' % code if bright else str(code), text)
      fmt = "\033[{}m{}\033[0m"
    return fmt.format(';'.join(codes), text)
  return inner


# add any colors you might need.
_red   = _color_fn(31)
_green = _color_fn('38;5;28')
_cyan  = _color_fn(36)
_blue  = _color_fn(34)

# - if we are a remote connection, modify the ps1
if os.environ.get('SSH_CONNECTION'):
  this_host = os.environ['SSH_CONNECTION'].split()[-2]
  sys.ps1 = _green('[%s]>>> ' % this_host, readline_workaround=True)
  sys.ps2 = _red('[%s]... '   % this_host, readline_workaround=True)
else:
  sys.ps1 = _green('>>> ', readline_workaround=True)
  sys.ps2 = _red('... ', readline_workaround=True)

# Enable Pretty Printing for stdout
# - get terminal size for passing width param to pprint. Queried just once at
# startup
try:
  _rows, _cols = subprocess.check_output('stty size', shell=True).strip().split()
except:
  _cols = 80

def my_displayhook (value):
  import re
  if value is not None:
    builtins._ = value

    formatted = pprint.pformat(value, width=_cols)
    if issubclass(type(value), dict):
      keys = r'|'.join(repr(i) for i in value.keys())
      formatted = re.sub(keys, lambda match: _red(match.group(0)), formatted)
      print(formatted)
    else:
      print(_blue(formatted))

sys.displayhook = my_displayhook

EDITOR   = os.environ.get('EDITOR', 'vi')
SHELL    = os.environ.get('SHELL', '/bin/bash')
EDIT_CMD = r'\e'
SH_EXEC  = '!'
DOC_CMD  = '?'
SOURCE_CMD = '.'

class EditableBufferInteractiveConsole(InteractiveConsole, object):
  def __init__ (self, *args, **kwargs):
    self.last_buffer = [] # This holds the last executed statements
    super(EditableBufferInteractiveConsole, self).__init__(*args, **kwargs)
    self.resetbuffer = self._resetbuffer

  def _resetbuffer (self):
    self.last_buffer.extend(self.buffer)
    return super(EditableBufferInteractiveConsole, self).resetbuffer()

  def _process_edit_cmd (self):
    # - setup the edit buffer
    fd, tmpfl = mkstemp('.py')
    lines = '\n'.join(line.strip('\n') for line in self.last_buffer)
    os.write(fd, lines.encode('utf-8'))
    os.close(fd)

    self.last_buffer.clear()

    # - shell out to the editor
    os.system('%s %s' % (EDITOR, tmpfl))

    # - process commands
    self.last_buffer.append(self._source_file(tmpfl, temp=True))
    os.unlink(tmpfl)
    return ''

  def _source_file (self, filename, temp=False):
    with open(filename) as f:
      source = f.read()

      sourcelines = source.splitlines()
      fmt = "{{:0{}}}... {{}}\n".format(len(str(len(sourcelines))))
      for lineno, line in enumerate(sourcelines, 1):
        self.write(fmt.format(lineno, line), _cyan)
      try:
        code = compile(source, '<temp>' if temp else filename, 'exec')

        self.runcode(code)
      except SyntaxError as se:
        self.showsyntaxerror()

    if temp:
      return source
    return ''

  def _process_sh_cmd (self, cmd):
    if cmd:
      """
      out, err = subprocess.Popen([SHELL, '-c', cmd],
          stdout=subprocess.PIPE,
          stderr=subprocess.PIPE).communicate()
      print((err and _red(err)) or (out and _green(out)))
      builtins._ = (out, err)
      """
      os.system(cmd)
    else:
      if os.environ.get('SSH_CONNECTION'):
        # I use the bash function below in my .bashrc to directly open
        # a python prompt on remote systems I log on to.
        #   function rpython { ssh -t $1 -- "python" }
        # Unfortunately, suspending this ssh session, does not place me
        # in a shell, so I need to create one:
        os.system(SHELL)
      else:
        os.kill(os.getpid(), signal.SIGSTOP)
    return ''

  def raw_input (self, *args):
    line = super(EditableBufferInteractiveConsole, self).raw_input(*args)
    if line == EDIT_CMD:
      line = self._process_edit_cmd()
    elif line.startswith(SH_EXEC):
      line = self._process_sh_cmd(line.strip(SH_EXEC))
    elif line.endswith(DOC_CMD):
      line = 'help(%s)' % line[:-len(DOC_CMD)]
    elif line.startswith(SOURCE_CMD):
      line = self._source_file(line[len(SOURCE_CMD):].strip())
    return line

  def write (self, data, wrapper=_red):
    sys.stderr.write(wrapper(data))

# - create our pimped out console
__c = EditableBufferInteractiveConsole()

# - turn on the completer
# you could change this line to bind another key instead of tab.
readline.parse_and_bind('tab: complete')
readline.set_completer(IrlCompleter(namespace=__c.locals).complete)

# - fire it up !
__c.interact(banner='')

# Exit the Python shell on exiting the InteractiveConsole
sys.exit()
