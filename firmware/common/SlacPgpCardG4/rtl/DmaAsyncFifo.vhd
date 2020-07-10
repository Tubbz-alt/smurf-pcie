-------------------------------------------------------------------------------
-- File       : DmaAsyncFifo.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- This file is part of 'axi-pcie-core'.
-- It is subject to the license terms in the LICENSE.txt file found in the
-- top-level directory of this distribution and at:
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
-- No part of 'axi-pcie-core', including this file,
-- may be copied, modified, propagated, or distributed except according to
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library surf;
use surf.StdRtlPkg.all;
use surf.AxiStreamPkg.all;
use surf.EthMacPkg.all;

use work.AppPkg.all;

entity DmaAsyncFifo is
   generic (
      TPD_G : time := 1 ns);
   port (
      -- DMA Interface (dmaClk domain)
      dmaClk          : in  sl;
      dmaRst          : in  sl;
      dmaBuffGrpPause : in  slv(7 downto 0);
      dmaObMaster     : in  AxiStreamMasterType;
      dmaObSlave      : out AxiStreamSlaveType;
      dmaIbMaster     : out AxiStreamMasterType;
      dmaIbSlave      : in  AxiStreamSlaveType;
      -- UDP/RSSI Interface (axilClk domain)
      axilClk         : in  sl;
      axilRst         : in  sl;
      udpIbMaster     : out AxiStreamMasterType;
      udpIbSlave      : in  AxiStreamSlaveType;
      udpObMaster     : in  AxiStreamMasterType;
      udpObSlave      : out AxiStreamSlaveType;
      rssiIbMaster    : out AxiStreamMasterType;
      rssiIbSlave     : in  AxiStreamSlaveType;
      rssiObMaster    : in  AxiStreamMasterType;
      rssiObSlave     : out AxiStreamSlaveType);
end DmaAsyncFifo;

architecture mapping of DmaAsyncFifo is

   constant TDEST_ROUTES_C : Slv8Array(1 downto 0) := (
      0 => x"C1",
      1 => "--------");

   constant TID_ROUTES_C : Slv8Array(1 downto 0) := (
      0 => x"01",
      1 => x"00");

   signal dmaIbMasters : AxiStreamMasterArray(1 downto 0);
   signal dmaIbSlaves  : AxiStreamSlaveArray(1 downto 0);

   signal dmaObMasters : AxiStreamMasterArray(1 downto 0);
   signal dmaObSlaves  : AxiStreamSlaveArray(1 downto 0);

   signal axilReset : sl;
   signal dmaReset  : sl;

begin

   -----------------------------------------------------------------
   --                   Pipelined Resets
   -----------------------------------------------------------------

   U_axilRst : entity surf.RstPipeline
      generic map (
         TPD_G => TPD_G)
      port map (
         clk    => axilClk,
         rstIn  => axilRst,
         rstOut => axilReset);

   U_dmaRst : entity surf.RstPipeline
      generic map (
         TPD_G => TPD_G)
      port map (
         clk    => dmaClk,
         rstIn  => dmaRst,
         rstOut => dmaReset);

   -----------------------------------------------------------------
   --             DMA Path: APP->DMA
   -----------------------------------------------------------------

   U_IB_DMA_1 : entity surf.AxiStreamFifoV2
      generic map (
         -- General Configurations
         TPD_G               => TPD_G,
         -- INT_PIPE_STAGES_G   => 1,
         -- PIPE_STAGES_G       => 1,
         -- FIFO configurations
         MEMORY_TYPE_G       => "distributed",
         GEN_SYNC_FIFO_G     => false,
         FIFO_ADDR_WIDTH_G   => 4,
         -- AXI Stream Port Configurations
         SLAVE_AXI_CONFIG_G  => APP_AXIS_CONFIG_C,
         MASTER_AXI_CONFIG_G => APP_AXIS_CONFIG_C)
      port map (
         -- Slave Port
         sAxisClk    => axilClk,
         sAxisRst    => axilReset,
         sAxisMaster => rssiObMaster,
         sAxisSlave  => rssiObSlave,
         -- Master Port
         mAxisClk    => dmaClk,
         mAxisRst    => dmaReset,
         mAxisMaster => dmaIbMasters(1),
         mAxisSlave  => dmaIbSlaves(1));

   U_IB_DMA_0 : entity surf.AxiStreamFifoV2
      generic map (
         -- General Configurations
         TPD_G               => TPD_G,
         -- INT_PIPE_STAGES_G   => 1,
         -- PIPE_STAGES_G       => 1,
         -- FIFO configurations
         MEMORY_TYPE_G       => "distributed",
         GEN_SYNC_FIFO_G     => false,
         FIFO_ADDR_WIDTH_G   => 4,
         -- AXI Stream Port Configurations
         SLAVE_AXI_CONFIG_G  => EMAC_AXIS_CONFIG_C,
         MASTER_AXI_CONFIG_G => APP_AXIS_CONFIG_C)
      port map (
         -- Slave Port
         sAxisClk    => axilClk,
         sAxisRst    => axilReset,
         sAxisMaster => udpObMaster,
         sAxisSlave  => udpObSlave,
         -- Master Port
         mAxisClk    => dmaClk,
         mAxisRst    => dmaReset,
         mAxisMaster => dmaIbMasters(0),
         mAxisSlave  => dmaIbSlaves(0));

   U_AxiStreamMux : entity surf.AxiStreamMux
      generic map (
         TPD_G                => TPD_G,
         -- PIPE_STAGES_G        => 1,
         NUM_SLAVES_G         => 2,
         MODE_G               => "ROUTED",
         TDEST_ROUTES_G       => TDEST_ROUTES_C,
         TID_MODE_G           => "ROUTED",
         TID_ROUTES_G         => TID_ROUTES_C,
         ILEAVE_EN_G          => true,
         ILEAVE_ON_NOTVALID_G => true,
         ILEAVE_REARB_G       => 128)
      port map (
         -- Clock and reset
         axisClk      => dmaClk,
         axisRst      => dmaReset,
         -- Slaves
         disableSel   => dmaBuffGrpPause(1 downto 0),
         sAxisMasters => dmaIbMasters,
         sAxisSlaves  => dmaIbSlaves,
         -- Master
         mAxisMaster  => dmaIbMaster,
         mAxisSlave   => dmaIbSlave);

   -----------------------------------------------------------------
   --             DMA Path: DMA->APP
   -----------------------------------------------------------------

   U_DeMux : entity surf.AxiStreamDeMux
      generic map (
         TPD_G          => TPD_G,
         -- PIPE_STAGES_G => 1,
         NUM_MASTERS_G  => 2,
         MODE_G         => "ROUTED",
         TDEST_ROUTES_G => TDEST_ROUTES_C)
      port map (
         -- Clock and reset
         axisClk      => dmaClk,
         axisRst      => dmaReset,
         -- Slave
         sAxisMaster  => dmaObMaster,
         sAxisSlave   => dmaObSlave,
         -- Masters
         mAxisMasters => dmaObMasters,
         mAxisSlaves  => dmaObSlaves);

   U_OB_DMA_1 : entity surf.AxiStreamFifoV2
      generic map (
         -- General Configurations
         TPD_G               => TPD_G,
         -- INT_PIPE_STAGES_G   => 1,
         -- PIPE_STAGES_G       => 1,
         -- FIFO configurations
         MEMORY_TYPE_G       => "block",
         GEN_SYNC_FIFO_G     => false,
         FIFO_ADDR_WIDTH_G   => 9,
         -- AXI Stream Port Configurations
         SLAVE_AXI_CONFIG_G  => APP_AXIS_CONFIG_C,
         MASTER_AXI_CONFIG_G => APP_AXIS_CONFIG_C)
      port map (
         -- Slave Port
         sAxisClk    => dmaClk,
         sAxisRst    => dmaReset,
         sAxisMaster => dmaObMasters(1),
         sAxisSlave  => dmaObSlaves(1),
         -- Master Port
         mAxisClk    => axilClk,
         mAxisRst    => axilReset,
         mAxisMaster => rssiIbMaster,
         mAxisSlave  => rssiIbSlave);

   U_OB_DMA_0 : entity surf.AxiStreamFifoV2
      generic map (
         -- General Configurations
         TPD_G               => TPD_G,
         -- INT_PIPE_STAGES_G   => 1,
         -- PIPE_STAGES_G       => 1,
         -- FIFO configurations
         MEMORY_TYPE_G       => "block",
         GEN_SYNC_FIFO_G     => false,
         FIFO_ADDR_WIDTH_G   => 9,
         -- AXI Stream Port Configurations
         SLAVE_AXI_CONFIG_G  => APP_AXIS_CONFIG_C,
         MASTER_AXI_CONFIG_G => EMAC_AXIS_CONFIG_C)
      port map (
         -- Slave Port
         sAxisClk    => dmaClk,
         sAxisRst    => dmaReset,
         sAxisMaster => dmaObMasters(0),
         sAxisSlave  => dmaObSlaves(0),
         -- Master Port
         mAxisClk    => axilClk,
         mAxisRst    => axilReset,
         mAxisMaster => udpIbMaster,
         mAxisSlave  => udpIbSlave);

end mapping;
