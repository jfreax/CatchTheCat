from __future__ import with_statement
from fabric.api import *

env.hosts = ['jdsoft.de']
src_dir = '/home/jens/VCS/evoface'
public_dir = '/var/www/static/evoface'


# Local #
def commit(a=False):
    local("git commit" + (" -a" if a else ""))


def push():
    local("git push")

    
def make(watch=False):
    local("coffee " + ("-w " if watch else "") +"-o public/js -j all -c $(find src/ -iname *.coffee)")
    
    if not watch:
      doc()


def doc():
  local("docco $(find src/ -iname *.coffee)")


# Remote #
def deploy(a=False):
    if a:
        commit(True)
    push()
    
    with cd(src_dir):
        run("git reset --hard")
        run("git clean -f -d")
        run("git pull")
        run("fab make")
        run("cp -r " + src_dir + "/public/* " + public_dir + "/")
        run("cp -r " + src_dir + "/docs " + public_dir + "/")

    
# Helper #
def server():
    make()
    with lcd('public/'):
        local("python -m SimpleHTTPServer")
