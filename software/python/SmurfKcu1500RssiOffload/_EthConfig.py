#!/usr/bin/env python
##############################################################################
## This file is part of 'camera-link-gen1'.
## It is subject to the license terms in the LICENSE.txt file found in the 
## top-level directory of this distribution and at: 
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
## No part of 'camera-link-gen1', including this file, 
## may be copied, modified, propagated, or distributed except according to 
## the terms contained in the LICENSE.txt file.
##############################################################################

import pyrogue as pr
from surf.ethernet import udp

class EthConfig(pr.Device):
    def __init__(   self,       
            name        = "EthConfig",
            description = "Container for EthConfig",
            rssiPerLink = 6,
            **kwargs):
        super().__init__(name=name, description=description, **kwargs)
        
        self.add(pr.RemoteVariable(   
            name         = "LocalMacRaw",
            description  = "Local MAC Address",
            offset       = 0x00,
            bitSize      = 48,
            base         = pr.UInt,
            mode         = "RW",
            hidden       = True,     
        ))      
        
        self.add(pr.LinkVariable(
            name         = "LocalMac", 
            description  = "Local MAC (human readable & little-Endian configuration)",
            mode         = 'RW', 
            linkedGet    = udp.getMacValue,
            linkedSet    = udp.setMacValue,
            dependencies = [self.variables["LocalMacRaw"]],
        ))          
        
        self.add(pr.RemoteVariable(   
            name         = "LocalIpRaw",
            description  = "Local IP Address",
            offset       = 0x08,
            bitSize      = 32,
            base         = pr.UInt,
            mode         = "RW",
            hidden       = True,     
        ))  

        self.add(pr.LinkVariable(
            name         = "LocalIp", 
            description  = "Local Ip Address (human readable string)",
            mode         = 'RW', 
            linkedGet    = udp.getIpValue,
            linkedSet    = udp.setIpValue,
            dependencies = [self.variables["LocalIpRaw"]],
        ))          
        
        self.add(pr.RemoteVariable(   
            name         = "BypRssi",
            description  = "Bypass RSSI for FSBL",
            offset       = 0x0C,
            bitSize      = rssiPerLink,
            base         = pr.UInt,
            mode         = "RW",
        ))  
        
        self.add(pr.RemoteVariable(   
            name         = "PhyReady",
            description  = "ETH Phy Ready",
            offset       =  0x10,
            bitSize      =  1,
            base         = pr.UInt,
            mode         = "RO",
            pollInterval = 1,
        ))        
        
        self.add(pr.RemoteVariable(   
            name         = "NUM_LINKS_C",
            description  = "Defined in AppPkg.vhd",
            offset       =  0x80,
            mode         = "RO",
        ))
        
        self.add(pr.RemoteVariable(   
            name         = "RSSI_PER_LINK_C",
            description  = "Defined in AppPkg.vhd",
            offset       =  0x84,
            mode         = "RO",
        ))
        
        self.add(pr.RemoteVariable(   
            name         = "RSSI_STREAMS_C",
            description  = "Defined in AppPkg.vhd",
            offset       =  0x88,
            mode         = "RO",
        ))
        
        self.add(pr.RemoteVariable(   
            name         = "AXIS_PER_LINK_C",
            description  = "Defined in AppPkg.vhd",
            offset       =  0x8C,
            mode         = "RO",
        ))
        
        self.add(pr.RemoteVariable(   
            name         = "NUM_AXIS_C",
            description  = "Defined in AppPkg.vhd",
            offset       =  0x90,
            mode         = "RO",
        ))    

        self.add(pr.RemoteVariable(   
            name         = "NUM_RSSI_C",
            description  = "Defined in AppPkg.vhd",
            offset       =  0x94,
            mode         = "RO",
        ))            
        