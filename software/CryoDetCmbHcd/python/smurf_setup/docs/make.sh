sphinx-apidoc -f -o ./ ../../smurf_setup/
make html
rsync -avz --progress _build/html/genindex.html _build/html/index.html _build/html/_modules _build/html/modules.html _build/html/objects.inv _build/html/py-modindex.html _build/html/search.html _build/html/searchindex.js _build/html/smurf_setup.config.html _build/html/smurf_setup.html _build/html/smurf_setup.util.html _build/html/_sources _build/html/_static swh76@rice.stanford.edu:/home/swh76/afs-home/WWW/smurf_setup_docs/
