import io
import sys

"""functions to wrap gets and puts
   either EPICS or ROGUE goes underneath these
"""

def ca_get(pv):
    """Gets the value of a process variable
    
       Args: 
        pv (str): name of the process variable to read
    """
    pass

def ca_put(pv, val):
    """Puts a value into a process variable

       Args:
        pv (str): name of the process variable to edit
        val (any): value to put in
    """

    pass


class ProcessVariable:
    """Creates a process variable object that can be manipulated
       Maybe redundant; pyEpics already comes with this
    """

    def __init__(self, address, name=None):
        """Creates a process variable pointing to a register?

           Args:
            address (str): firmware address of the PV?
            name (str): shorthand name? currently defaults to none
        """
        pass

    def get(self):
        """Gets the value of the process variable object
        """
        val = ca_get(self)
        return val

    def put(self, val):
        """Puts a value into the process variable object

           Args:
            val (any): value to put in
        """

        ca_put(self, val)
        return
