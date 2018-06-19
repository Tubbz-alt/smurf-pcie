root=getSMuRFenv('SMURF_EPICS_ROOT');
lcaPut([root, ':AMCc:streamDataWriter:open'], 'False');
