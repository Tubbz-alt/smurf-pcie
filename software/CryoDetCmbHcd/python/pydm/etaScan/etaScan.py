import epics
import numpy as np
import pyqtgraph as pg
from os import path
from pydm import Display
from pydm.widgets import PyDMPushButton
from pydm.PyQt import QtGui, QtCore

class ETAScanDisplay(Display):
    update_plot_signal = QtCore.pyqtSignal()
    
    def __init__(self, parent=None, args=None, macros=None):
        super(ETAScanDisplay, self).__init__(parent=parent, args=args, macros=macros)
        
        # Get the root from macros...
        self.pv_root = macros.get('root', 'mitch_epics:AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[0]:CryoChannels:')

        # Channel string formatter
        channel_str = 'ca://'+self.pv_root+'{}'

        # Set the channel at the widgets...
        self.ui.txt_amplitude.channel = channel_str.format('etaScanAmplitude')
        self.ui.txt_amplitude.precisionFromPV = False
        self.ui.txt_amplitude.precision = 3
        self.ui.txt_channel.channel = channel_str.format('etaScanChannel')
        
        self.ui.txt_dwell.channel = channel_str.format('etaScanDwell')
        self.ui.txt_dwell.precisionFromPV = False
        self.ui.txt_dwell.precision = 3
        
        self.ui.txt_delf.channel = channel_str.format('etaScanDelF')
        self.ui.txt_delf.precisionFromPV = False
        self.ui.txt_delf.precision = 3

        # Create the PV object in which we will set the array for frequencies...
        self.freqs_pv = channel_str.format('etaScanFreqs')[5:]
        
        # Create the PV object for the real and imaginary data
        # [5:] to remote the ca:// prefix.
        self.data_real_pv = channel_str.format('etaScanResultsReal')[5:]
        self.data_imag_pv = channel_str.format('etaScanResultsImag')[5:]

        # Set the channel at the launch button...
        self.ui.btn_launch.clicked.connect(self.btn_launch_clicked)

        self.run_pv = channel_str.format('runEtaScan')[5:]
        self.inprogress_pv = channel_str.format('etaScanInProgress')[5:]      
        
        epics.PV(self.inprogress_pv, callback=self.update_status_label)
        epics.PV(self.freqs_pv, callback=self.update_freqs)
        epics.PV(self.data_real_pv, callback=self.update_real)
        epics.PV(self.data_imag_pv, callback=self.update_imag)

        # Set title and other configuration at the plots...
        self.plot1 = pg.PlotWidget()
        self.plot1.setLabels(
            title='Amplitude Response for Band',
            left='Response (arbs)',
            bottom='Frequency (MHz)')
        self.plot1.showGrid(x=True, y=True)
        layout = QtGui.QHBoxLayout(self.ui.frm_plot1)
        self.ui.frm_plot1.layout().addWidget(self.plot1)

        self.plot2 = pg.PlotWidget()
        self.plot2.setLabels(
            title='Phase Response for Band',
            left='Phase (rad)',
            bottom='Frequency (MHz)')
        self.plot2.showGrid(x=True, y=True)
        layout = QtGui.QHBoxLayout(self.ui.frm_plot2)
        self.ui.frm_plot2.layout().addWidget(self.plot2)

        self.plot3 = pg.PlotWidget()
        self.plot3.setLabels(
            title='Complex Response for Band',
            left='',
            bottom='')
        self.plot3.showGrid(x=True, y=True)
        layout = QtGui.QHBoxLayout(self.ui.frm_plot3)
        self.ui.frm_plot3.layout().addWidget(self.plot3)

        self.plot4 = pg.PlotWidget()
        self.plot4.setLabels(
            title='Complex Response for Band (Rotated)',
            left='',
            bottom='')        
        self.plot4.showGrid(x=True, y=True)
        layout = QtGui.QHBoxLayout(self.ui.frm_plot4)
        self.ui.frm_plot4.layout().addWidget(self.plot4)
        self.update_plot_signal.connect(self.assemble_plots)

    def ui_filename(self):
        return 'etaScan.ui'

    def ui_filepath(self):
        return path.join(path.dirname(path.realpath(__file__)), self.ui_filename())

    def update_freqs(self, value, *args, **kwargs):
        self.freqs = value

    def update_real(self, value, *args, **kwargs):
        self.real = value
        
    def update_imag(self, value, *args, **kwargs):
        self.imag = value
        self.update_plot_signal.emit()      

    def update_status_label(self, value, *args, **kwargs):
        status_fmt = '<b>Status: </b> {}'

        st = 'Idle' if value == 0 else 'Running'
        self.ui.lbl_status.setText(status_fmt.format(st))

    def btn_launch_clicked(self):
        ok, message = self.sanity_check()
        if not ok:
            self.show_error(message)
            return

        start = float(self.ui.txt_freqstart.text())
        stop = float(self.ui.txt_freqstop.text())
        step = float(self.ui.txt_freqstep.text())
        epics.caput(self.freqs_pv, np.arange(start, stop, step), wait=True)
        epics.caput(self.run_pv, 1)

    def sanity_check(self):
        error_msg = ''
        try:
            start = float(self.ui.txt_freqstart.text())
            stop = float(self.ui.txt_freqstop.text())
            step = float(self.ui.txt_freqstep.text())
        except ValueError:
            error_msg = 'Start, Stop and Step Size must be valid numbers.'
            return False, error_msg
            
        if stop < start:
            error_msg = 'Stop must be greater than start.'
            return False, error_msg
        
        if step == 0.0:
            error_msg = 'Step must be greater than zero.'
            return False, error_msg
            
        return True, ''
        
    def show_error(self, error_msg):
        msg = QtGui.QMessageBox()
        msg.setIcon(QtGui.QMessageBox.Critical)
        msg.setText("Invalid Scan Parameters")
        msg.setInformativeText(error_msg)
        msg.setWindowTitle("etaScan Error")
        msg.exec_()

    @QtCore.pyqtSlot()
    def assemble_plots(self):
        freqs = self.freqs
        I = self.real
        Q = self.imag
        
        if not isinstance(self.real, np.ndarray):
            return
            
        if not isinstance(self.imag, np.ndarray):
            return
        
        try:
            delF = float(self.ui.txt_delf.text())
        except ValueError:
            delF = 0.05

        resp     = I + 1j*Q
        aresp    = np.abs(resp)
        minIdx   = np.where(aresp == min(aresp))[0]
        F0       = freqs[minIdx]
        left     = np.where(freqs > (F0-delF))[0][0]
        right    = np.where(freqs > (F0+delF))[0][0]
        
        white = pg.mkColor((255, 255, 255))
        red = pg.mkColor((255, 0, 0))
        green = pg.mkColor((0, 255, 0))
        plot_kwargs = {'symbol': 'o', 'symbolSize': 2, 'symbolPen': pg.mkPen(color=white), 'symbolBrush': pg.mkBrush(color=white)}
        plot_central_kwargs = {'symbol': 'star', 'symbolSize': 10, 'symbolPen': pg.mkPen(color=red), 'symbolBrush': pg.mkBrush(color=red)}
        plot_lr_kwargs = {'symbol': 'x', 'symbolSize': 10, 'symbolPen': pg.mkPen(color=green), 'symbolBrush': pg.mkBrush(color=green)}

        self.plot1.plot(freqs, np.abs(resp), clear=True, pen=None, **plot_kwargs)
        self.plot1.plot(freqs[minIdx], np.abs(resp[minIdx]), pen=None, **plot_central_kwargs)

        self.plot2.plot(freqs, np.unwrap(np.angle(resp)), clear=True, pen=None, **plot_kwargs)
        self.plot2.plot(freqs[minIdx], np.angle(resp[minIdx]), pen=None, **plot_central_kwargs)
        self.plot2.plot([freqs[left]], [np.angle(resp[left])], **plot_lr_kwargs)
        self.plot2.plot([freqs[right]], [np.angle(resp[right])], **plot_lr_kwargs)

        spot = resp[minIdx]
        self.plot3.plot(resp.real, resp.imag, clear=True, pen=None, **plot_kwargs)
        self.plot3.plot(spot.real, spot.imag, pen=None, **plot_central_kwargs)


        spot = resp[left]
        self.plot3.plot([spot.real], [spot.imag], **plot_lr_kwargs)
        spot = resp[right]
        self.plot3.plot([spot.real], [spot.imag], **plot_lr_kwargs)


        eta = (freqs[right]-freqs[left])/(resp[right]-resp[left])
        etaMag = abs(eta) # Magnitude in MHz per unit response
        etaPhase = np.angle(eta)
        etaPhase = np.angle(eta, deg=True)
        etaScaled = etaMag/19.2

        data = resp*eta

        self.plot4.plot(data.real, data.imag, clear=True, pen=None, **plot_kwargs)

        spot = eta*resp[minIdx]
        self.plot4.plot(spot.real, spot.imag, pen=None, **plot_central_kwargs)
        spot = eta*resp[left]
        self.plot4.plot([spot.real], [spot.imag], **plot_lr_kwargs)
        spot = eta*resp[right]
        self.plot4.plot([spot.real], [spot.imag], **plot_lr_kwargs)

        self.plot1.update()
        self.plot2.update()
        self.plot3.update()
        self.plot4.update()

