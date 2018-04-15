import io
import sys
import epics
import numpy

"""functions to wrap gets and puts
   either EPICS or ROGUE goes underneath these
   for now I have used epics from pyepics
"""

def ca_get(pv):
    """Gets the value of a process variable
    
       Args: 
        pv (str): name of the process variable to read
    """
    value = epics.caget(pv)
    return value

def ca_put(pv, val, wait=False, timeout=60):
    """Puts a value into a process variable

       Args:
        pv (str): name of the process variable to edit
        val (any): value to put in
        wait (bool): optional, tells the function to wait until the processing completes
        timeout (int): time (in seconds) the function will wait

       returns 1 on success; negative number if timeout exceeded
    """
    success = epics.caput(pv, val, wait, timeout)
    return success

def ca_info(pv, print_out=True):
    """ prints (or returns as string) an informational paragraph about the PV, including Control Settings

       Args:
        pv (str): name of the process variable
        print_out (bool): whether to write results to standard output
    """
    epics.cainfo(pv, print_out)
    return

def ca_monitor(pv, writer=None, callback=None):
    """sets a monitor on a PV, which will cause something to be done each time the value changes
        by default PV name, time, value will be printed to stdout each time the value changes

       Args:
        pv (str): name of the PV
        writer (None or callable function that takes a string argument): where to write results to stdoutput
        callback (None or callable function): user-supplied function to receive result
    """
    epics.camonitor(pv, writer, callback)
    return

def ca_clearmonitor(pv):
    """clears a monitor on a PV
       Args:
        pv (str): ;name of pv that has monitor set with ca_monitor
    """


class ProcessVariable:
    """Creates a process variable object that can be manipulated
       Maybe redundant; pyEpics already comes with this
    """

    def __init__(self, address, callback=None, form='time',verbose=False,auto_monitor=None, count=None, connection_callback=None, 
            connection_timeout=None, access_callback=None):
        """Creates a process variable pointing to a register?

           Args:
            address (str): firmware address of the PV?
            callback (callable, tuple, list, or None): user-defined callback function on changes to PV value or state
            form (str, one of ('native', 'ctrl', or 'time')): which epics data type to use
            verbose (bool): whether to print out debugging messages
            auto_monitor (None, True, False, or bitmask): whether to automatically monitor the PV for changes
            count (int): number of data elements to return by default
            connection_callback (callable or None): user-defined function called on changes to PV connection status
            connection_timeout (float or None): time (seconds) to wait for connection
            access_callback (callable or None): user-defined function called on changes to access rights
        """
        self = epics.PV(address, callback, form, verbose, auto_mintor, count, connection_callback, connection_timeout,
                access_callback)

        pass

    def get(self, count=None, as_string=False, as_numpy=True, timeout=None, use_monitor=True):
        """Gets the value of the process variable object

           Args:
            count (int or None): maximum number of array elements to return
            as_string (bool): whether to return string representation of value
            as_numpy (bool): whether to try to return a numpy array if numpy is available
            timeout (float or None): max time to wait for data before returning None
            use_monitor (bool): controls whether the most recent value from the automatic monitoring will be used. 
                usually this is good enough to be up-to-date, but might not be depending on network traffic
        """
        val = self.get(count, as_string, as_numpy, timeout, use_monitor)
        return val

    def put(self, val):
        """Puts a value into the process variable object

           Args:
            val (any): value to put in
        """
        success = self.put(val)
        return success

    def info(self):
        """Gets informational paragraph bout the PV, including Control Settings
        """
        return self.info
