import json
import io
import util

# read or dump a config file
# not yet tested
# do we want to hardcode key names?

class SmurfConfig:
    ## initialize, read, or dump a config file

    def __init__(self, filename=None):
        self.filename = filename
        # self.config = [] # do I need to initialize this? I don't think so
        if self.filename is not None:
            self.read(update=True)

    def read(self, update=False):
        ## read file and update the configuration ##
        if update:
            with open(self.filename) as config_file:
                loaded_config = json.load(config_file)
            
            # put in some logic here to make sure parameters in experiment file match the parameters we're looking for
            self.config = loaded_config

    def write(self, outputfile):
        ## dump current config to outputfile ##
        with io.open(outputfile, 'w', encoding='utf8') as out_file:
            str_ = json.dumps(self.config, indent = 4, separators = (',', ': '))
            out_file.write(to_unicode(str_))

