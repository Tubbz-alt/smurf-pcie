import os
import time
import subprocess
from smurf_setup.config import SmurfConfig


def make_dir(directory):
    """check if a directory exists; if not, make it

       Args:
        directory (str): path of directory to create
    """

    if not os.path.exists(directory):
        os.makedirs(directory)


class SmurfTune:
    """generic class based on the MCE tuningData class
    """

    def __init__(self, name=None, cfg_file=None, data_dir=None, debug=False):

        # define data dir
        if data_dir is None:
            #maybe use the config file directory?
            if cfg_file is not None:
                data_dir = os.path.dirname(cfg_file)
                self.data_dir = data_dir

            else:
                print("please supply a data directory!")
                pass # unless there's a good generic to stick in here

            
        self.date = time.strftime("%Y%m%d")
        self.debug = debug

        # name
        self.the_time = time.time()
        if name is None:
            name = '%10i' % (self.the_time)
        self.name = name

        self.base_dir = os.path.abspath(data_dir)

        # create output and plot directories
        self.output_dir = os.path.join(self.base_dir, 'outputs', name)
        self.plot_dir = os.path.join(self.base_dir,'plots', name)

        # name the logfile and create flags for it
        self.log_file = os.path.join(self.data_dir, name + '.log')
        self.openlog_failed = False # is this necessary?
        self.log = None

        # the experiment file whee
        if cfg_file is None:
            cfg_file = os.path.join(self.base_dir, 'experiment.cfg')
            self.cfg_file = cfg_file

        #try:
        self.config = SmurfConfig(cfg_file)
        #except:
            #self.config = config.get_generic_config # need to implement this

    def make_dirs(self):
        """make the paths for the output and plot directories for this tuning run
        """
        make_dir(self.output_dir)
        make_dir(self.plot_dir)

    def get_cfg_param(self, key):
        """get config parameter

           Args:
            key (str): configuration key to get
        """
        return self.config.get(key)

    def set_cfg_param(self, key, value):
        """set config parameter. note: this will not change the actual config file

           Args:
            key (str): configuration key to set
            value (any): val to assign to the key
        """
        return self.config.update(key, value) 

    def run(self, args, no_log=False):
        """run functions with current smurfTune object, logging outputs

           Args:
            args (any): arguments to run (fed to subprocess.call)
            no_log (bool): whether or not to log outputs
        """
        if (no_log):
            log = None
        else:
            if (not self.openlog_failed and self.log is None):
                try:
                    self.log = open(self.log_file, "w+")
                    self.log.write("SMuRF tuning run started " + 
                            time.asctime(time.gmtime(self.the_time)) + " UTC\n")
                    self.log.write("Dir:   " + self.base_dir + "\n")
                    self.log.write("Name:   " + self.name + "\n")
                except IOError:
                    print("Unable to create logfile \"{0}\" (errno: {1}; {2})".\
                            format(self.log_file, errno, strerror))
                    print("Logging disabled!")
                    self.openlog_failed = True

            log = self.log

        if (log):
            log.write("\nExecuting")
            log.writelines([" " + str(x) for x in args] + ["\n"])
            log.flush()

        if (self.debug):
            print("Executing:   " + str(args))

        s = subprocess.call([str(x) for x in args], stdout = log, stderr = log)

        if (log):
            log.write("Exit Status:   " + str(s) + "\n")
            log.flush()

        return s


    def filename(self, suffix=None, nickname=None, ctime=None, absolute=False):
        """create timestamped filenames in the output folder of this tuning run
           
           Args:
            nickname (str): user-readable name to append to the filename
            ctime (posix time?): current time, to track files
            absolute (bool): whether to return absolute path (or just filename)
        """

        if ctime is None:
            ctime = time.time()

        time_stamp = str(int(ctime))
        strname = time_stamp
        if nickname is not None:
            strname = strname + '_' + nickname

        strname = strname + suffix

        if (absolute):
            s = os.path.join(self.output_dir, strname)
        else:
            s = os.path.join(self.name, strname)

        return s, strname

    def write_to_log(self, message, flush=False):
        """Write a message to the logfile

           Args:
            message (str): message to write to the logfile
            flush (bool): whether to flush immediately
        """
        if (self.log_file):
            self.log_file.write(message)
            if (flush):
                self.log.flush()

