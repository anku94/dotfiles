# copy to ~/.ipython/profile_default/startup/00-autoreload.py

get_ipython().run_line_magic('load_ext', 'autoreload')
get_ipython().run_line_magic('autoreload', '2')
# get_ipython().run_line_magic('matplotlib', 'osx') # - uncomment for MacOS
