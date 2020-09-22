----------------------------------------------------------------
---- INFN Sezione di Roma Tre
---- Project Name : RMU
---- File         : TOP.vhd
---- Author       : Stefano Basti
---- Description  : Top Level RMU System
---- Modification History
---- 09/02/2019 First Issue
---- 16/04/2019 Changed to Fixed Latency Scheme
---- 25/04/2019 Added Latency Tester
---- 05/05/2019 Release
----------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
Library UNISIM;
use UNISIM.vcomponents.all;

ENTITY TOP IS
    PORT ( 
	clk_in_p:IN STD_LOGIC;		--system clock +
	clk_in_n:IN STD_LOGIC;		--system clock -
	clk_ref_p:IN STD_LOGIC;		--system clock +
	clk_ref_n:IN STD_LOGIC;		--system clock -
	--link A1 STATUS
	MOD_DEFA1:IN STD_LOGIC_VECTOR (1 DOWNTO 0);
	MOD_ABS_A1:IN STD_LOGIC;
	TX_FAULT_A1:IN STD_LOGIC;
	--link B1 STATUS
	MOD_DEFB1:IN STD_LOGIC_VECTOR (1 DOWNTO 0);
	MOD_ABS_B1:IN STD_LOGIC;
	TX_FAULT_B1:IN STD_LOGIC;
	--link C1 STATUS
	MOD_DEFC1:IN STD_LOGIC_VECTOR (1 DOWNTO 0);
	MOD_ABS_C1:IN STD_LOGIC;
	TX_FAULT_C1:IN STD_LOGIC; 
	--link D1 STATUS
	MOD_DEFD1:IN STD_LOGIC_VECTOR (1 DOWNTO 0);
	MOD_ABS_D1:IN STD_LOGIC;
	TX_FAULT_D1:IN STD_LOGIC;
	--link A2 STATUS
	MOD_DEFA2:IN STD_LOGIC_VECTOR (1 DOWNTO 0);
	MOD_ABS_A2:IN STD_LOGIC;
	TX_FAULT_A2:IN STD_LOGIC;
	--link B2 STATUS
	MOD_DEFB2:IN STD_LOGIC_VECTOR (1 DOWNTO 0);
	MOD_ABS_B2:IN STD_LOGIC;
	TX_FAULT_B2:IN STD_LOGIC;
	--link C2 STATUS
	MOD_DEFC2:IN STD_LOGIC_VECTOR (1 DOWNTO 0);
	MOD_ABS_C2:IN STD_LOGIC;
	TX_FAULT_C2:IN STD_LOGIC; 
	--link D2 STATUS
	MOD_DEFD2:IN STD_LOGIC_VECTOR (1 DOWNTO 0);
	MOD_ABS_D2:IN STD_LOGIC;
	TX_FAULT_D2:IN STD_LOGIC;
	--I2C Signal
	sda:INOUT STD_LOGIC;
	scl:IN  STD_LOGIC;
	--Board Led
	led:OUT STD_LOGIC_VECTOR (3 DOWNTO 0); 
	
	--GTX Refclk@125MHz
	CLK0_GTREFCLKN: in   std_logic;
    CLK0_GTREFCLKP: in   std_logic;
    CLK1_GTREFCLKN: in   std_logic;
    CLK1_GTREFCLKP: in   std_logic;
    --Link A1 Signal
    gt0_gtxrxp_in: in   std_logic;
    gt0_gtxrxn_in: in   std_logic;
    gt0_gtxtxp_out: out   std_logic;
    gt0_gtxtxn_out: out   std_logic;
	--Link B1 Signal
	gt1_gtxrxp_in: in   std_logic;
    gt1_gtxrxn_in: in   std_logic;
    gt1_gtxtxp_out: out   std_logic;
    gt1_gtxtxn_out: out   std_logic;
	--Link C1 Signal
	gt2_gtxrxp_in: in   std_logic;
    gt2_gtxrxn_in: in   std_logic;
    gt2_gtxtxp_out: out   std_logic;
    gt2_gtxtxn_out: out   std_logic;
	--Link D1 Signal
	gt3_gtxrxp_in: in   std_logic;
    gt3_gtxrxn_in: in   std_logic;
    gt3_gtxtxp_out: out   std_logic;
    gt3_gtxtxn_out: out   std_logic;
	--Link A2 Signal
	gt4_gtxrxp_in: in   std_logic;
    gt4_gtxrxn_in: in   std_logic;
    gt4_gtxtxp_out: out   std_logic;
    gt4_gtxtxn_out: out   std_logic;
	--Link B2 Signal
	gt5_gtxrxp_in: in   std_logic;
    gt5_gtxrxn_in: in   std_logic;
    gt5_gtxtxp_out: out   std_logic;
    gt5_gtxtxn_out: out   std_logic;
	--Link C2 Signal
	gt6_gtxrxp_in: in   std_logic;
    gt6_gtxrxn_in: in   std_logic;
    gt6_gtxtxp_out: out   std_logic;
    gt6_gtxtxn_out: out   std_logic;
    --Link D2 Signal
    gt7_gtxrxp_in: in   std_logic;
    gt7_gtxrxn_in: in   std_logic;
    gt7_gtxtxp_out: out   std_logic;
    gt7_gtxtxn_out: out   std_logic
    );
	
	
END ENTITY TOP ;

ARCHITECTURE top_level OF TOP IS
--Connection Signal
signal clk:STD_LOGIC;
signal reset_n:STD_LOGIC;
signal locked:STD_LOGIC;
signal SOFT_RESET:STD_LOGIC;

signal sda_in:STD_LOGIC;
signal sda_out:STD_LOGIC;

signal data0:STD_LOGIC_VECTOR (7 DOWNTO 0);
signal data1:STD_LOGIC_VECTOR (7 DOWNTO 0);
signal data2:STD_LOGIC_VECTOR (7 DOWNTO 0);
signal data3:STD_LOGIC_VECTOR (7 DOWNTO 0);
signal data4:STD_LOGIC_VECTOR (7 DOWNTO 0);
signal data5:STD_LOGIC_VECTOR (7 DOWNTO 0);
signal data6:STD_LOGIC_VECTOR (7 DOWNTO 0);
signal link0_mean:STD_LOGIC_VECTOR (15 DOWNTO 0):=(OTHERS => '0');
signal link1_mean:STD_LOGIC_VECTOR (15 DOWNTO 0):=(OTHERS => '0');
signal link2_mean:STD_LOGIC_VECTOR (15 DOWNTO 0):=(OTHERS => '0');
signal link3_mean:STD_LOGIC_VECTOR (15 DOWNTO 0):=(OTHERS => '0');
signal link4_mean:STD_LOGIC_VECTOR (15 DOWNTO 0):=(OTHERS => '0');
signal link5_mean:STD_LOGIC_VECTOR (15 DOWNTO 0):=(OTHERS => '0');
signal link6_mean:STD_LOGIC_VECTOR (15 DOWNTO 0):=(OTHERS => '0');
signal link7_mean:STD_LOGIC_VECTOR (63 DOWNTO 0):=(OTHERS => '0');
signal gtx_clk0_in:STD_LOGIC;
signal gtx_data0_in:STD_LOGIC_VECTOR (15 DOWNTO 0):=(OTHERS => '0');
signal gtx_clk1_in:STD_LOGIC;
signal gtx_data1_in:STD_LOGIC_VECTOR (15 DOWNTO 0):=(OTHERS => '0');
signal gtx_clk2_in:STD_LOGIC;
signal gtx_data2_in:STD_LOGIC_VECTOR (15 DOWNTO 0):=(OTHERS => '0');
signal gtx_clk3_in:STD_LOGIC;
signal gtx_data3_in:STD_LOGIC_VECTOR (15 DOWNTO 0):=(OTHERS => '0');
signal gtx_clk4_in:STD_LOGIC;
signal gtx_data4_in:STD_LOGIC_VECTOR (15 DOWNTO 0):=(OTHERS => '0');
signal gtx_clk5_in:STD_LOGIC;
signal gtx_data5_in:STD_LOGIC_VECTOR (15 DOWNTO 0):=(OTHERS => '0');
signal gtx_clk6_in:STD_LOGIC;
signal gtx_data6_in:STD_LOGIC_VECTOR (15 DOWNTO 0):=(OTHERS => '0');
signal gtx_clk0_out:STD_LOGIC;
signal gtx_data0_out:STD_LOGIC_VECTOR (15 DOWNTO 0):=(OTHERS => '0');
signal gtx_clk1_out:STD_LOGIC;
signal gtx_data1_out:STD_LOGIC_VECTOR (15 DOWNTO 0):=(OTHERS => '0');
signal gtx_clk2_out:STD_LOGIC;
signal gtx_data2_out:STD_LOGIC_VECTOR (15 DOWNTO 0):=(OTHERS => '0');
signal gtx_clk3_out:STD_LOGIC;
signal gtx_data3_out:STD_LOGIC_VECTOR (15 DOWNTO 0):=(OTHERS => '0');
signal gtx_clk4_out:STD_LOGIC;
signal gtx_data4_out:STD_LOGIC_VECTOR (15 DOWNTO 0):=(OTHERS => '0');
signal gtx_clk5_out:STD_LOGIC;
signal gtx_data5_out:STD_LOGIC_VECTOR (15 DOWNTO 0):=(OTHERS => '0');
signal gtx_clk6_out:STD_LOGIC;
signal gtx_data6_out:STD_LOGIC_VECTOR (15 DOWNTO 0):=(OTHERS => '0');
signal gtx_clk7_in:STD_LOGIC;
signal gtx_data7_in:STD_LOGIC_VECTOR (63 DOWNTO 0):=(OTHERS => '0');
signal gtx_clk7_out:STD_LOGIC;
signal gtx_data7_out:STD_LOGIC_VECTOR (63 DOWNTO 0):=(OTHERS => '0');
signal stop_avg:STD_LOGIC;	  
signal count0:STD_LOGIC_VECTOR(15 downto 0):=(OTHERS => '0');
signal count1:STD_LOGIC_VECTOR(15 downto 0):=(OTHERS => '0');
signal count2:STD_LOGIC_VECTOR(15 downto 0):=(OTHERS => '0');
signal count3:STD_LOGIC_VECTOR(15 downto 0):=(OTHERS => '0');
signal count4:STD_LOGIC_VECTOR(15 downto 0):=(OTHERS => '0');
signal count5:STD_LOGIC_VECTOR(15 downto 0):=(OTHERS => '0');
signal count6:STD_LOGIC_VECTOR(15 downto 0):=(OTHERS => '0');
signal count7:STD_LOGIC_VECTOR(15 downto 0):=(OTHERS => '0');
signal charisk: std_logic_vector(7 downto 0);
signal gt0_txcharisk_in: std_logic_vector(1 downto 0);
signal gt1_txcharisk_in: std_logic_vector(1 downto 0);
signal gt2_txcharisk_in: std_logic_vector(1 downto 0);
signal gt3_txcharisk_in: std_logic_vector(1 downto 0);
signal gt4_txcharisk_in: std_logic_vector(1 downto 0);
signal gt5_txcharisk_in: std_logic_vector(1 downto 0);
signal gt6_txcharisk_in: std_logic_vector(1 downto 0);
signal gt0_rxcharisk_out: std_logic_vector(1 downto 0);
signal gt1_rxcharisk_out: std_logic_vector(1 downto 0);
signal gt2_rxcharisk_out: std_logic_vector(1 downto 0);
signal gt3_rxcharisk_out: std_logic_vector(1 downto 0);
signal gt4_rxcharisk_out: std_logic_vector(1 downto 0);
signal gt5_rxcharisk_out: std_logic_vector(1 downto 0);
signal gt6_rxcharisk_out: std_logic_vector(1 downto 0);
signal gt7_rxcharisk_out: std_logic_vector(7 downto 0);
signal gt0_rxbyteisaligned_out: std_logic;
signal gt1_rxbyteisaligned_out: std_logic;
signal gt2_rxbyteisaligned_out: std_logic;
signal gt3_rxbyteisaligned_out: std_logic;
signal gt4_rxbyteisaligned_out: std_logic;
signal gt5_rxbyteisaligned_out: std_logic;
signal gt6_rxbyteisaligned_out: std_logic;
signal gt7_rxbyteisaligned_out: std_logic;

signal gt0_gtrefclk0_in: std_logic;
signal gt0_rxusrclk_in : std_logic;
signal gt0_rxusrclk2_in: std_logic;
signal gt0_rxoutclk_out: std_logic;
signal gt0_txoutclk_out: std_logic;
signal gt0_txusrclk_in : std_logic;
signal gt0_txusrclk2_in: std_logic;

signal gt1_gtrefclk0_in: std_logic;
signal gt1_rxusrclk_in : std_logic;
signal gt1_rxusrclk2_in: std_logic;
signal gt1_rxoutclk_out: std_logic;
signal gt1_txusrclk_in : std_logic;
signal gt1_txusrclk2_in: std_logic;

signal gt2_gtrefclk0_in: std_logic;
signal gt2_rxusrclk_in : std_logic;
signal gt2_rxusrclk2_in: std_logic;
signal gt2_rxoutclk_out: std_logic;
signal gt2_txusrclk_in : std_logic;
signal gt2_txusrclk2_in: std_logic;

signal gt3_gtrefclk0_in: std_logic;
signal gt3_rxusrclk_in : std_logic;
signal gt3_rxusrclk2_in: std_logic;
signal gt3_rxoutclk_out: std_logic;
signal gt3_txusrclk_in : std_logic;
signal gt3_txusrclk2_in: std_logic;

signal gt4_gtrefclk0_in: std_logic;
signal gt4_rxusrclk_in : std_logic;
signal gt4_rxusrclk2_in: std_logic;
signal gt4_rxoutclk_out: std_logic;
signal gt4_txusrclk_in : std_logic;
signal gt4_txusrclk2_in: std_logic;

signal gt5_gtrefclk0_in: std_logic;
signal gt5_rxusrclk_in : std_logic;
signal gt5_rxusrclk2_in: std_logic;
signal gt5_rxoutclk_out: std_logic;
signal gt5_txusrclk_in : std_logic;
signal gt5_txusrclk2_in: std_logic;

signal gt6_gtrefclk0_in: std_logic;
signal gt6_rxusrclk_in : std_logic;
signal gt6_rxusrclk2_in: std_logic;
signal gt6_rxoutclk_out: std_logic;
signal gt6_txusrclk_in : std_logic;
signal gt6_txusrclk2_in: std_logic;

signal gt7_gtrefclk0_in: std_logic;
signal gt7_rxusrclk_in : std_logic;
signal gt7_rxusrclk2_in: std_logic;
signal gt7_rxusrclk : std_logic;
signal gt7_rxusrclk2: std_logic;
signal gt7_rxoutclk_out: std_logic;
signal gt7_txusrclk_in : std_logic;
signal gt7_txusrclk2_in: std_logic;
signal gt7_txusrclk : std_logic;
signal gt7_txusrclk2: std_logic;
signal gt7_txoutclk_out: std_logic;

signal gt_gtrefclk:std_logic;
signal gt_txusrclk_i:std_logic;
signal gt_rxusrclk_i:std_logic;

signal txoutclk_mmcm0_reset:std_logic;
signal txoutclk_mmcm0_locked:std_logic;
signal rxoutclk_mmcm0_reset:std_logic;
signal rxoutclk_mmcm0_locked:std_logic;

signal gt7_txoutclk_out_i:std_logic;
signal gt7_rxoutclk_out_i:std_logic;

signal gt7_txresetdone,gt7_rxresetdone,gt7_rxslide_in : std_logic;

signal packer_mean:STD_LOGIC_VECTOR (63 DOWNTO 0):=(OTHERS => '0');

signal sys_status:STD_LOGIC_VECTOR (7 DOWNTO 0);

signal sendtest:std_logic;
signal recvtest:std_logic;
signal test:std_logic;
signal counttst:STD_LOGIC_VECTOR (7 DOWNTO 0);
signal probe0, probe9 : std_logic_vector(7 downto 0);
signal clk_ref_u,clk_ref,gt_gtrefclk1,gt0_gtrefclk1_in : std_logic;
BEGIN

-- ref clk buffer
    refbuf: IBUFDS
    generic map(
    DIFF_TERM => false
    )
    port map(
    I => clk_ref_p,
    IB => clk_ref_n,
    O => clk_ref_u
    );
    -- refclkbufg:  BUFG
    -- port map(
    -- I => clk_ref_u,
    -- O => clk_ref
    -- );
--Sys CLK Generation
	 clk_wiz_0_inst :entity work.clk_wiz_0
	  port map (
		clk_out1      => clk,
		locked        => locked,
		clk_in1_p     => clk_in_p,
		clk_in1_n     => clk_in_n
		);
		
--REFCLK Generation
	
	--IBUFDS_GTE2
     ibufds_instq0_clk0 :IBUFDS_GTE2  
       port map
      (
         O               =>     gt_gtrefclk,
         ODIV2           =>    open,
         CEB             =>     '0',
         I               =>     CLK0_GTREFCLKN,
         IB              =>     CLK0_GTREFCLKP
      );
      
      ibufds_instq1_clk0 :IBUFDS_GTE2  
       port map
      (
         O               =>     gt_gtrefclk1,
         ODIV2           =>    open,
         CEB             =>     '0',
         I               =>     CLK1_GTREFCLKN,
         IB              =>     CLK1_GTREFCLKP
      );
      
      gt0_gtrefclk0_in <= gt_gtrefclk1;
      gt1_gtrefclk0_in <= gt_gtrefclk1;
      gt2_gtrefclk0_in <= gt_gtrefclk1;
      gt3_gtrefclk0_in <= gt_gtrefclk1;
      gt4_gtrefclk0_in <= gt_gtrefclk1;
      gt5_gtrefclk0_in <= gt_gtrefclk1;
	  gt6_gtrefclk0_in <= gt_gtrefclk1;
	  gt7_gtrefclk0_in <= gt_gtrefclk1;
      gt0_gtrefclk1_in <= '0';
	  
	  
--USERCLK Generation
--For latency Fixing and Phase Synchronization all GTX clock are generated by link0 RX clock recovered	  
	txoutclk_bufg0_i : BUFG
		port map
		(
			I                               =>      gt0_txoutclk_out,
			O                               =>      gt_txusrclk_i
		);


    rxoutclk_bufg1_i : BUFG
		port map
		(
			I                               =>      gt0_rxoutclk_out,
			O                               =>      gt_rxusrclk_i
		);
	
	gt0_rxusrclk_in <= gt_rxusrclk_i;
	gt0_rxusrclk2_in <= gt_rxusrclk_i;
	gt1_rxusrclk_in <= gt_rxusrclk_i;
	gt1_rxusrclk2_in <= gt_rxusrclk_i;
	gt2_rxusrclk_in <= gt_rxusrclk_i;
	gt2_rxusrclk2_in <= gt_rxusrclk_i;
	gt3_rxusrclk_in <= gt_rxusrclk_i;
	gt3_rxusrclk2_in <= gt_rxusrclk_i;
	gt4_rxusrclk_in <= gt_rxusrclk_i;
	gt4_rxusrclk2_in <= gt_rxusrclk_i;
	gt5_rxusrclk_in <= gt_rxusrclk_i;
	gt5_rxusrclk2_in <= gt_rxusrclk_i;
	gt6_rxusrclk_in <= gt_rxusrclk_i;
	gt6_rxusrclk2_in <= gt_rxusrclk_i;
	
	gtx_clk0_out <= gt_rxusrclk_i;
	gtx_clk1_out <= gt_rxusrclk_i;
	gtx_clk2_out <= gt_rxusrclk_i;
	gtx_clk3_out <= gt_rxusrclk_i;
	gtx_clk4_out <= gt_rxusrclk_i;
	gtx_clk5_out <= gt_rxusrclk_i;
	gtx_clk6_out <= gt_rxusrclk_i;
	
	gt0_Txusrclk_in  <= gt_txusrclk_i;
	gt0_Txusrclk2_in <= gt_txusrclk_i;
	gt1_Txusrclk_in  <= gt_txusrclk_i;
	gt1_Txusrclk2_in <= gt_txusrclk_i;
	gt2_Txusrclk_in  <= gt_txusrclk_i;
	gt2_Txusrclk2_in <= gt_txusrclk_i;
	gt3_Txusrclk_in  <= gt_txusrclk_i;
	gt3_Txusrclk2_in <= gt_txusrclk_i;
	gt4_Txusrclk_in  <= gt_txusrclk_i;
	gt4_Txusrclk2_in <= gt_txusrclk_i;
	gt5_Txusrclk_in  <= gt_txusrclk_i;
	gt5_Txusrclk2_in <= gt_txusrclk_i;
	gt6_Txusrclk_in  <= gt_txusrclk_i;
	gt6_Txusrclk2_in <= gt_txusrclk_i;
	
	gtx_clk0_in <= gt_rxusrclk_i;
	gtx_clk1_in <= gt_rxusrclk_i;
	gtx_clk2_in <= gt_rxusrclk_i;
	gtx_clk3_in <= gt_rxusrclk_i;
	gtx_clk4_in <= gt_rxusrclk_i;
	gtx_clk5_in <= gt_rxusrclk_i;
	gtx_clk6_in <= gt_rxusrclk_i;
	
	toutclk_bufg2_i : BUFG
            port map
            (
                I                               =>      gt7_txoutclk_out,
                O                               =>      gt7_txoutclk_out_i
            );
	--
	-- Instantiate a MMCM module to divide the reference clock. Uses internal feedback
    -- for improved jitter performance, and to avoid consuming an additional BUFG
	txoutclk_mmcm_inst : entity work.clk_wiz_2
		port map ( 
		-- Clock out ports  
		clk_out1 => gt7_txusrclk2,
		clk_out2 => gt7_txusrclk,
		-- Status and control signals                
		reset => txoutclk_mmcm0_reset,
		locked => txoutclk_mmcm0_locked,
		-- Clock in ports
		clk_in1 => gt7_txoutclk_out_i
		);
		
         
	gt7_txusrclk_in <= gt7_txusrclk;
	gt7_txusrclk2_in <= gt7_txusrclk2;
	gtx_clk7_in <= gt7_txusrclk2;
	
	routclk_bufg2_i : BUFG
            port map
            (
                I                               =>      gt7_rxoutclk_out,
                O                               =>      gt7_rxoutclk_out_i
            );
	--
	-- Instantiate a MMCM module to divide the reference clock. Uses internal feedback
    -- for improved jitter performance, and to avoid consuming an additional BUFG
	rxoutclk_mmcm_inst : entity work.clk_wiz_1
		port map ( 
		-- Clock out ports  
		clk_out1 => gt7_rxusrclk2,
		clk_out2 => gt7_rxusrclk,
		-- Status and control signals                
		reset => rxoutclk_mmcm0_reset,
		locked => rxoutclk_mmcm0_locked,
		-- Clock in ports
		clk_in1 => gt7_rxoutclk_out_i
		);
		
	gt7_rxusrclk_in <= gt7_rxusrclk;
	gt7_rxusrclk2_in <= gt7_rxusrclk2;
	gtx_clk7_out <= gt7_rxusrclk2;
		
--System Interconnection
    
	 I2C_Slave_inst : entity work.I2C_Slave
	 generic map (
		device_address=>"0010110",
		device_id=>X"BA",
		last_addr=>X"FF"
		)
      port map (
		clk		=> clk,
		reset_n => reset_n,
		MOD_DEFA1     => MOD_DEFA1,
		MOD_ABS_A1    => MOD_ABS_A1,
		TX_FAULT_A1   => TX_FAULT_A1,
		MOD_DEFB1     => MOD_DEFB1,
		MOD_ABS_B1    => MOD_ABS_B1,
		TX_FAULT_B1   => TX_FAULT_B1,
		MOD_DEFC1     => MOD_DEFC1,
		MOD_ABS_C1    => MOD_ABS_C1,
		TX_FAULT_C1   => TX_FAULT_C1 ,
		MOD_DEFD1     => MOD_DEFD1,
		MOD_ABS_D1    => MOD_ABS_D1,
		TX_FAULT_D1   => TX_FAULT_D1,
		MOD_DEFA2     => MOD_DEFA2,
		MOD_ABS_A2    => MOD_ABS_A2,
		TX_FAULT_A2   => TX_FAULT_A2,
		MOD_DEFB2     => MOD_DEFB2,
		MOD_ABS_B2    => MOD_ABS_B2,
		TX_FAULT_B2   => TX_FAULT_B2,
		MOD_DEFC2     => MOD_DEFC2,
		MOD_ABS_C2    => MOD_ABS_C2,
		TX_FAULT_C2   => TX_FAULT_C2 ,
		MOD_DEFD2     => MOD_DEFD2,
		MOD_ABS_D2    => MOD_ABS_D2,
		TX_FAULT_D2   => TX_FAULT_D2,
		link0_mean    => link0_mean,
		link1_mean    => link1_mean,
		link2_mean    => link2_mean,
		link3_mean    => link3_mean,
		link4_mean    => link4_mean,
		link5_mean    => link5_mean,
		link6_mean    => link6_mean,
		link7_mean    => link7_mean,
		packer_mean	  => packer_mean,
		count0		  => count0,
		count1		  => count1,
		count2		  => count2,
		count3		  => count3,
		count4		  => count4,
		count5		  => count5,
		count6		  => count6,
		count7		  => count7,
		data0		  => data0,
		data1		  => data1,
		data2		  => data2,
		data3		  => data3,
		data4		  => data4,
		data5		  => data5,
		data6		  => data6,
		stop_avg	  => stop_avg,
		sendtest	  => sendtest,
		recvtest	  => recvtest,
		test		  => test,
		counttst	  => counttst,
		txrate		  => open,
		rxrate		  => open,
		rst_rate	  => open, 
		sys_status	 => sys_status,
		led => led,
		sda_in     => sda_in,
		sda_out     => sda_out,
		--out_en     => out_en,
		scl     => scl
		);
	--System status generation	
	sys_status<= gt7_rxbyteisaligned_out & gt6_rxbyteisaligned_out & gt5_rxbyteisaligned_out & gt4_rxbyteisaligned_out & gt3_rxbyteisaligned_out & gt2_rxbyteisaligned_out & gt1_rxbyteisaligned_out & gt0_rxbyteisaligned_out;
	
	avg0 : entity work.GTX_Avg
	generic map (
		DataWidth=>16,
		SelFunc=>'0'
	)
      port map (
        clk=>clk,
		reset_n => reset_n,
		gtx_clk => gtx_clk0_in,
		gtx_data_in => gtx_data0_out,
		test => '0',
		recvtest => open,
		stop_avg=>stop_avg,
		link_mean => link0_mean
		);
	avg1 : entity work.GTX_Avg
	generic map (
		DataWidth=>16,
		SelFunc=>'0'
	)
      port map (
        clk=>clk,
		reset_n => reset_n,
		gtx_clk => gtx_clk1_in,
		gtx_data_in => gtx_data1_out,
		test => '0',
		recvtest => open,
		stop_avg=>stop_avg,
		link_mean => link1_mean
		);
	avg2 : entity work.GTX_Avg
	generic map (
		DataWidth=>16,
		SelFunc=>'0'
	)
      port map (
        clk=>clk,
		reset_n => reset_n,
		gtx_clk => gtx_clk2_in,
		gtx_data_in => gtx_data2_out,
		test => '0',
		recvtest => open,
		stop_avg=>stop_avg,
		link_mean => link2_mean
		);
	avg3 : entity work.GTX_Avg
	generic map (
		DataWidth=>16,
		SelFunc=>'0'
	)
      port map (
        clk=>clk,
		reset_n => reset_n,
		gtx_clk => gtx_clk3_in,
		gtx_data_in => gtx_data3_out,
		test => '0',
		recvtest => open,
		stop_avg=>stop_avg,
		link_mean => link3_mean
		);
	avg4 : entity work.GTX_Avg
	generic map (
		DataWidth=>16,
		SelFunc=>'0'
	)
      port map (
        clk=>clk,
		reset_n => reset_n,
		gtx_clk => gtx_clk4_in,
		gtx_data_in => gtx_data4_out,
		test => '0',
		recvtest => open,
		stop_avg=>stop_avg,
		link_mean => link4_mean
		);
	avg5 : entity work.GTX_Avg
	generic map (
		DataWidth=>16,
		SelFunc=>'0'
	)
      port map (
        clk=>clk,
		reset_n => reset_n,
		gtx_clk => gtx_clk5_in,
		gtx_data_in => gtx_data5_out,
		test => '0',
		recvtest => open,
		stop_avg=>stop_avg,
		link_mean => link5_mean
		);
	avg6 : entity work.GTX_Avg
	generic map (
		DataWidth=>16,
		SelFunc=>'0'
	)
      port map (
        clk=>clk,
		reset_n => reset_n,
		gtx_clk => gtx_clk6_in,
		gtx_data_in => gtx_data6_out,
		test => '0',
		recvtest => open,
		stop_avg=>stop_avg,
		link_mean => link6_mean
		);
	avg7 : entity work.GTX_Avg
	generic map (
		DataWidth=>64,
		SelFunc=>'0'
	)
      port map (
        clk=>clk,
		reset_n => reset_n,
		gtx_clk => gtx_clk7_out,
		gtx_data_in => gtx_data7_out,
		test => test,
		recvtest => recvtest,
		stop_avg=>stop_avg,
		link_mean => link7_mean
		);
	avgpacker : entity work.GTX_Avg
	generic map (
		DataWidth=>64,
		SelFunc=>'0'
	)
      port map (
        clk=>clk,
		reset_n => reset_n,
		gtx_clk => gtx_clk7_in,
		gtx_data_in => gtx_data7_in,
		test => '0',
		recvtest => open,
		stop_avg=>stop_avg,
		link_mean => packer_mean
		);
	
	TTIM_Emulator_inst0 : entity work.TTIM_Emulator
      port map (
		reset_n => reset_n,
		txusrclk2 => gtx_clk0_in,
		txdata => open,--gtx_data0_in,
		txcharisk => gt0_txcharisk_in,
		sendtest => sendtest,
		test => test,
		count=>count0,
		data => gtx_data7_out(15 downto 8)
		);
    -- process(gtx_clk0_in)
    -- begin
        -- if rising_edge(gtx_clk0_in) then
            -- gtx_data0_in <= gtx_data0_out;
            -- gt0_txcharisk_in <= gt0_rxcharisk_out;
        -- end if;
    -- end process;
	TTIM_Emulator_inst1 : entity work.TTIM_Emulator
      port map (
		reset_n => reset_n,
		txusrclk2 => gtx_clk1_in,
		txdata => open,--gtx_data1_in,
		txcharisk => gt1_txcharisk_in,
		sendtest => open,
		test => '0',
		count=>count1,
		data => gtx_data7_out(23 downto 16)
		);
    -- process(gtx_clk0_in)
    -- begin
        -- if rising_edge(gtx_clk0_in) then
            -- gtx_data1_in <= gtx_data1_out;
            -- gt1_txcharisk_in <= gt1_rxcharisk_out;
        -- end if;
    -- end process;
	TTIM_Emulator_inst2 : entity work.TTIM_Emulator
      port map (
		reset_n => reset_n,
		txusrclk2 => gtx_clk2_in,
		txdata => open,--gtx_data2_in,
		txcharisk => gt2_txcharisk_in,
		sendtest => open,
		test => '0',
		count=>count2,
		data => gtx_data7_out(31 downto 24)
		);
    -- process(gtx_clk0_in)
    -- begin
        -- if rising_edge(gtx_clk0_in) then
            -- gtx_data2_in <= gtx_data2_out;
            -- gt2_txcharisk_in <= gt2_rxcharisk_out;
        -- end if;
    -- end process;
	TTIM_Emulator_inst3 : entity work.TTIM_Emulator
      port map (
		reset_n => reset_n,
		txusrclk2 => gtx_clk3_in,
		txdata => open,--gtx_data3_in,
		txcharisk => gt3_txcharisk_in,
		sendtest => open,
		test => '0',
		count=>count3,
		data => gtx_data7_out(39 downto 32)
		);
    -- process(gtx_clk0_in)
    -- begin
        -- if rising_edge(gtx_clk0_in) then
            -- gtx_data3_in <= gtx_data3_out;
            -- gt3_txcharisk_in <= gt3_rxcharisk_out;
        -- end if;
    -- end process;
	TTIM_Emulator_inst4 : entity work.TTIM_Emulator
      port map (
		reset_n => reset_n,
		txusrclk2 => gtx_clk4_in,
		txdata => open,--gtx_data4_in,
		txcharisk => gt4_txcharisk_in,
		sendtest => open,
		test => '0',
		count=>count4,
		data => gtx_data7_out(47 downto 40)
		);
    -- process(gtx_clk0_in)
    -- begin
        -- if rising_edge(gtx_clk0_in) then
            -- gtx_data4_in <= gtx_data4_out;
            -- gt4_txcharisk_in <= gt4_rxcharisk_out;
        -- end if;
    -- end process;
	TTIM_Emulator_inst5 : entity work.TTIM_Emulator
      port map (
		reset_n => reset_n,
		txusrclk2 => gtx_clk5_in,
		txdata => open,--gtx_data5_in,
		txcharisk => gt5_txcharisk_in,
		sendtest => open,
		test => '0',
		count=>count5,
		data => gtx_data7_out(55 downto 48)
		);
    -- process(gtx_clk0_in)
    -- begin
        -- if rising_edge(gtx_clk0_in) then
            -- gtx_data5_in <= gtx_data5_out;
            -- gt5_txcharisk_in <= gt5_rxcharisk_out;
        -- end if;
    -- end process;
	TTIM_Emulator_inst6 : entity work.TTIM_Emulator
      port map (
		reset_n => reset_n,
		txusrclk2 => gtx_clk6_in,
		txdata => open,--gtx_data6_in,
		txcharisk => gt6_txcharisk_in,
		sendtest => open,
		test => '0',
		count=>count6,
		data => gtx_data7_out(63 downto 56)
		);
	-- process(gtx_clk0_in)
    -- begin
        -- if rising_edge(gtx_clk0_in) then
            -- gtx_data6_in <= gtx_data6_out;
            -- gt6_txcharisk_in <= gt6_rxcharisk_out;
        -- end if;
    -- end process;
	Latency_Counter_inst : entity work.Latency_Counter
      port map (
		reset_n => reset_n,
		clk => clk,
		txclk => gtx_clk0_in,
		sendtest => sendtest,
		recvtest => recvtest,
		test => test,
		count => counttst
		);
		
 
		
	RMU_Packer_inst : entity work.RMU_Packer
	port map(
		reset_n => reset_n,
		gtx_clk => gtx_clk7_in,
		
		TTIM0_data => gtx_data0_out,
		TTIM1_data => gtx_data1_out,
		TTIM2_data => gtx_data2_out,
		TTIM3_data => gtx_data3_out,
		TTIM4_data => gtx_data4_out,
		TTIM5_data => gtx_data5_out,
		TTIM6_data => gtx_data6_out,
		TTIM0_clk => gtx_clk0_out,
		TTIM1_clk => gtx_clk1_out,
		TTIM2_clk => gtx_clk2_out,
		TTIM3_clk => gtx_clk3_out,
		TTIM4_clk => gtx_clk4_out,
		TTIM5_clk => gtx_clk5_out,
		TTIM6_clk => gtx_clk6_out,
		TTIM0_charisk => gt0_rxcharisk_out,
		TTIM1_charisk => gt1_rxcharisk_out,
		TTIM2_charisk => gt2_rxcharisk_out,
		TTIM3_charisk => gt3_rxcharisk_out,
		TTIM4_charisk => gt4_rxcharisk_out,
		TTIM5_charisk => gt5_rxcharisk_out,
		TTIM6_charisk => gt6_rxcharisk_out,
		TTIM0_allign => gt0_rxbyteisaligned_out,
		TTIM1_allign => gt1_rxbyteisaligned_out,
		TTIM2_allign => gt2_rxbyteisaligned_out,
		TTIM3_allign => gt3_rxbyteisaligned_out,
		TTIM4_allign => gt4_rxbyteisaligned_out,
		TTIM5_allign => gt5_rxbyteisaligned_out,
		TTIM6_allign => gt6_rxbyteisaligned_out,
        
        TTIM_txclk => gt0_Txusrclk2_in,
        TTIM0_txdata => gtx_data0_in,
        TTIM1_txdata => gtx_data1_in,
        TTIM2_txdata => gtx_data2_in,
        TTIM3_txdata => gtx_data3_in,
        TTIM4_txdata => gtx_data4_in,
        TTIM5_txdata => gtx_data5_in,
        TTIM6_txdata => gtx_data6_in,
        data_in => gtx_data7_out,
        CTU_align => gt7_rxbyteisaligned_out,
		
		count=>count7,
		
		charisk=> charisk,
		data_out => gtx_data7_in
		);
    -- process(gtx_clk7_in)
    -- begin
        -- if rising_edge(gtx_clk7_in) then
            -- charisk <= gt7_rxcharisk_out;
            -- gtx_data7_in <= gtx_data7_out;
        -- end if;
    -- end process;
--Low Speed Link0-6		
 gtwizard_0_inst : entity work.gtwizard_0
port map
(
    SYSCLK_IN => clk,
    
    SOFT_RESET_TX_IN => SOFT_RESET,
    SOFT_RESET_RX_IN => SOFT_RESET,
    DONT_RESET_ON_DATA_ERROR_IN => '0',
	
     GT0_TX_FSM_RESET_DONE_OUT => open,
     GT0_RX_FSM_RESET_DONE_OUT => open,
     GT0_DATA_VALID_IN => '1',
     GT1_TX_FSM_RESET_DONE_OUT => open,
     GT1_RX_FSM_RESET_DONE_OUT => open,
     GT1_DATA_VALID_IN => '1',
     GT2_TX_FSM_RESET_DONE_OUT => open,
     GT2_RX_FSM_RESET_DONE_OUT => open,
     GT2_DATA_VALID_IN => '1',
     GT3_TX_FSM_RESET_DONE_OUT => open,
     GT3_RX_FSM_RESET_DONE_OUT => open,
     GT3_DATA_VALID_IN => '1',
     GT4_TX_FSM_RESET_DONE_OUT => open,
     GT4_RX_FSM_RESET_DONE_OUT => open,
     GT4_DATA_VALID_IN => '1',
     GT5_TX_FSM_RESET_DONE_OUT => open,
     GT5_RX_FSM_RESET_DONE_OUT => open,
     GT5_DATA_VALID_IN => '1',
     GT6_TX_FSM_RESET_DONE_OUT => open,
     GT6_RX_FSM_RESET_DONE_OUT => open,
     GT6_DATA_VALID_IN => '1',

    --_________________________________________________________________________
    --GT0  (X0Y0)
    --____________________________CHANNEL PORTS________________________________
        gt0_cpllfbclklost_out           =>      open,
        gt0_cplllock_out                =>      open,
        gt0_cplllockdetclk_in           =>      clk,
        gt0_cpllreset_in                =>      '0',
        --gtgrefclk_i                =>      '0',
        gt0_gtrefclk0_in                =>      gt0_gtrefclk0_in,
        gt0_gtrefclk1_in                =>      gt0_gtrefclk1_in,
        gt0_drpaddr_in                  =>      "000000000",
        gt0_drpclk_in                   =>      '0',
        gt0_drpdi_in                    =>      "0000000000000000",
        gt0_drpdo_out                   =>      open,
        gt0_drpen_in                    =>      '0',
        gt0_drprdy_out                  =>      open,
        gt0_drpwe_in                    =>      '0',
        gt0_dmonitorout_out             =>      open,
        gt0_eyescanreset_in             =>      '0',
        gt0_rxuserrdy_in                =>      '1',
        gt0_eyescandataerror_out        =>      open,
        gt0_eyescantrigger_in           =>      '0',
        gt0_rxusrclk_in                 =>      gt0_rxusrclk_in,
        gt0_rxusrclk2_in                =>      gt0_rxusrclk2_in,
        gt0_rxdata_out                  =>      gtx_data0_out,
        gt0_rxdisperr_out               =>      open,
        gt0_rxnotintable_out            =>      open,
        gt0_gtxrxp_in                   =>      gt0_gtxrxp_in,
        gt0_gtxrxn_in                   =>      gt0_gtxrxn_in,
        gt0_rxphmonitor_out             =>      open,
        gt0_rxphslipmonitor_out         =>      open,
        gt0_rxbyteisaligned_out         =>      gt0_rxbyteisaligned_out,
        gt0_rxcommadet_out              =>      open,
        gt0_rxdfelpmreset_in            =>      '0',
        gt0_rxmonitorout_out            =>      open,
        gt0_rxoutclk_out                =>      gt0_rxoutclk_out,
        gt0_rxmonitorsel_in             =>      "00",
        gt0_rxoutclkfabric_out          =>      open,
        gt0_gtrxreset_in                =>      '0',
        gt0_rxpmareset_in               =>      '0',
        gt0_rxcharisk_out               =>      gt0_rxcharisk_out,
        gt0_rxresetdone_out             =>      open,
        gt0_gttxreset_in                =>      '0',
        gt0_txuserrdy_in                =>      '1',
        gt0_txusrclk_in                 =>      gt0_txusrclk_in,
        gt0_txusrclk2_in                =>      gt0_txusrclk2_in,
        gt0_txdata_in                   =>      gtx_data0_in,
        gt0_gtxtxn_out                  =>      gt0_gtxtxn_out,
        gt0_gtxtxp_out                  =>      gt0_gtxtxp_out,
		gt0_txoutclk_out                =>      gt0_txoutclk_out,
        gt0_txoutclkfabric_out          =>      open,
        gt0_txoutclkpcs_out             =>      open,
        gt0_txcharisk_in                =>      gt0_txcharisk_in,
        gt0_txresetdone_out             =>      open,
    --GT1  (X0Y1)
    --____________________________CHANNEL PORTS________________________________
		gt1_cpllfbclklost_out           =>      open,
        gt1_cplllock_out                =>      open,
        gt1_cplllockdetclk_in           =>      clk,
        gt1_cpllreset_in                =>      '0',
        gt1_gtrefclk0_in                =>      gt1_gtrefclk0_in,
        gt1_gtrefclk1_in                =>      gt0_gtrefclk1_in,
        gt1_drpaddr_in                  =>      "000000000",
        gt1_drpclk_in                   =>      '0',
        gt1_drpdi_in                    =>      "0000000000000000",
        gt1_drpdo_out                   =>      open,
        gt1_drpen_in                    =>      '0',
        gt1_drprdy_out                  =>      open,
        gt1_drpwe_in                    =>      '0',
        gt1_dmonitorout_out             =>      open,
        gt1_eyescanreset_in             =>      '0',
        gt1_rxuserrdy_in                =>      '1',
        gt1_eyescandataerror_out        =>      open,
        gt1_eyescantrigger_in           =>      '0',
        gt1_rxusrclk_in                 =>      gt1_rxusrclk_in,
        gt1_rxusrclk2_in                =>      gt1_rxusrclk2_in,
        gt1_rxdata_out                  =>      gtx_data1_out,
        gt1_rxdisperr_out               =>      open,
        gt1_rxnotintable_out            =>      open,
        gt1_gtxrxp_in                   =>      gt1_gtxrxp_in,
        gt1_gtxrxn_in                   =>      gt1_gtxrxn_in,
        gt1_rxphmonitor_out             =>      open,
        gt1_rxphslipmonitor_out         =>      open,
        gt1_rxbyteisaligned_out         =>      gt1_rxbyteisaligned_out,
        gt1_rxcommadet_out              =>      open,
        gt1_rxdfelpmreset_in            =>      '0',
        gt1_rxmonitorout_out            =>      open,
        gt1_rxoutclk_out                =>      gt1_rxoutclk_out,
        gt1_rxmonitorsel_in             =>      "00",
        gt1_rxoutclkfabric_out          =>      open,
        gt1_gtrxreset_in                =>      '0',
        gt1_rxpmareset_in               =>      '0',
        gt1_rxcharisk_out               =>      gt1_rxcharisk_out,
        gt1_rxresetdone_out             =>      open,
        gt1_gttxreset_in                =>      '0',
        gt1_txuserrdy_in                =>      '1',
        gt1_txusrclk_in                 =>      gt1_txusrclk_in,
        gt1_txusrclk2_in                =>      gt1_txusrclk2_in,
        gt1_txdata_in                   =>      gtx_data1_in,
        gt1_gtxtxn_out                  =>      gt1_gtxtxn_out,
        gt1_gtxtxp_out                  =>      gt1_gtxtxp_out,
		gt1_txoutclk_out                =>      open,
        gt1_txoutclkfabric_out          =>      open,
        gt1_txoutclkpcs_out             =>      open,
        gt1_txcharisk_in                =>      gt1_txcharisk_in,

    --GT2  (X0Y2)
    --____________________________CHANNEL PORTS________________________________
        gt2_cpllfbclklost_out           =>      open,
        gt2_cplllock_out                =>      open,
        gt2_cplllockdetclk_in           =>      clk,
        gt2_cpllreset_in                =>      '0',
        gt2_gtrefclk0_in                =>      gt2_gtrefclk0_in,
        gt2_gtrefclk1_in                =>      gt0_gtrefclk1_in,
        gt2_drpaddr_in                  =>      "000000000",
        gt2_drpclk_in                   =>      '0',
        gt2_drpdi_in                    =>      "0000000000000000",
        gt2_drpdo_out                   =>      open,
        gt2_drpen_in                    =>      '0',
        gt2_drprdy_out                  =>      open,
        gt2_drpwe_in                    =>      '0',
        gt2_dmonitorout_out             =>      open,
        gt2_eyescanreset_in             =>      '0',
        gt2_rxuserrdy_in                =>      '1',
        gt2_eyescandataerror_out        =>      open,
        gt2_eyescantrigger_in           =>      '0',
        gt2_rxusrclk_in                 =>      gt2_rxusrclk_in,
        gt2_rxusrclk2_in                =>      gt2_rxusrclk2_in,
        gt2_rxdata_out                  =>      gtx_data2_out,
        gt2_rxdisperr_out               =>      open,
        gt2_rxnotintable_out            =>      open,
        gt2_gtxrxp_in                   =>      gt2_gtxrxp_in,
        gt2_gtxrxn_in                   =>      gt2_gtxrxn_in,
        gt2_rxphmonitor_out             =>      open,
        gt2_rxphslipmonitor_out         =>      open,
        gt2_rxbyteisaligned_out         =>      gt2_rxbyteisaligned_out,
        gt2_rxcommadet_out              =>      open,
        gt2_rxdfelpmreset_in            =>      '0',
        gt2_rxmonitorout_out            =>      open,
        gt2_rxoutclk_out                =>      gt2_rxoutclk_out,
        gt2_rxmonitorsel_in             =>      "00",
        gt2_rxoutclkfabric_out          =>      open,
        gt2_gtrxreset_in                =>      '0',
        gt2_rxpmareset_in               =>      '0',
        gt2_rxcharisk_out               =>      gt2_rxcharisk_out,
        gt2_rxresetdone_out             =>      open,
        gt2_gttxreset_in                =>      '0',
        gt2_txuserrdy_in                =>      '1',
        gt2_txusrclk_in                 =>      gt2_txusrclk_in,
        gt2_txusrclk2_in                =>      gt2_txusrclk2_in,
        gt2_txdata_in                   =>      gtx_data2_in,
        gt2_gtxtxn_out                  =>      gt2_gtxtxn_out,
        gt2_gtxtxp_out                  =>      gt2_gtxtxp_out,
		gt2_txoutclk_out                =>      open,
        gt2_txoutclkfabric_out          =>      open,
        gt2_txoutclkpcs_out             =>      open,
        gt2_txcharisk_in                =>      gt2_txcharisk_in,

    --GT3  (X0Y3)
    --____________________________CHANNEL PORTS________________________________
        gt3_cpllfbclklost_out           =>      open,
        gt3_cplllock_out                =>      open,
        gt3_cplllockdetclk_in           =>      clk,
        gt3_cpllreset_in                =>      '0',
        gt3_gtrefclk0_in                =>      gt3_gtrefclk0_in,
        gt3_gtrefclk1_in                =>      gt0_gtrefclk1_in,
        gt3_drpaddr_in                  =>      "000000000",
        gt3_drpclk_in                   =>      '0',
        gt3_drpdi_in                    =>      "0000000000000000",
        gt3_drpdo_out                   =>      open,
        gt3_drpen_in                    =>      '0',
        gt3_drprdy_out                  =>      open,
        gt3_drpwe_in                    =>      '0',
        gt3_dmonitorout_out             =>      open,
        gt3_eyescanreset_in             =>      '0',
        gt3_rxuserrdy_in                =>      '1',
        gt3_eyescandataerror_out        =>      open,
        gt3_eyescantrigger_in           =>      '0',
        gt3_rxusrclk_in                 =>      gt3_rxusrclk_in,
        gt3_rxusrclk2_in                =>      gt3_rxusrclk2_in,
        gt3_rxdata_out                  =>      gtx_data3_out,
        gt3_rxdisperr_out               =>      open,
        gt3_rxnotintable_out            =>      open,
        gt3_gtxrxp_in                   =>      gt3_gtxrxp_in,
        gt3_gtxrxn_in                   =>      gt3_gtxrxn_in,
        gt3_rxphmonitor_out             =>      open,
        gt3_rxphslipmonitor_out         =>      open,
        gt3_rxbyteisaligned_out         =>      gt3_rxbyteisaligned_out,
        gt3_rxcommadet_out              =>      open,
        gt3_rxdfelpmreset_in            =>      '0',
        gt3_rxmonitorout_out            =>      open,
        gt3_rxoutclk_out                =>      gt3_rxoutclk_out,
        gt3_rxmonitorsel_in             =>      "00",
        gt3_rxoutclkfabric_out          =>      open,
        gt3_gtrxreset_in                =>      '0',
        gt3_rxpmareset_in               =>      '0',
        gt3_rxcharisk_out               =>      gt3_rxcharisk_out,
        gt3_rxresetdone_out             =>      open,
        gt3_gttxreset_in                =>      '0',
        gt3_txuserrdy_in                =>      '1',
        gt3_txusrclk_in                 =>      gt3_txusrclk_in,
        gt3_txusrclk2_in                =>      gt3_txusrclk2_in,
        gt3_txdata_in                   =>      gtx_data3_in,
        gt3_gtxtxn_out                  =>      gt3_gtxtxn_out,
        gt3_gtxtxp_out                  =>      gt3_gtxtxp_out,
		gt3_txoutclk_out                =>      open,
        gt3_txoutclkfabric_out          =>      open,
        gt3_txoutclkpcs_out             =>      open,
        gt3_txcharisk_in                =>      gt3_txcharisk_in,

    --GT4  (X0Y4)
    --____________________________CHANNEL PORTS________________________________
        gt4_cpllfbclklost_out           =>      open,
        gt4_cplllock_out                =>      open,
        gt4_cplllockdetclk_in           =>      clk,
        gt4_cpllreset_in                =>      '0',
        gt4_gtrefclk0_in                =>      gt4_gtrefclk0_in,
        gt4_gtrefclk1_in                =>      gt0_gtrefclk1_in,
        gt4_drpaddr_in                  =>      "000000000",
        gt4_drpclk_in                   =>      '0',
        gt4_drpdi_in                    =>      "0000000000000000",
        gt4_drpdo_out                   =>      open,
        gt4_drpen_in                    =>      '0',
        gt4_drprdy_out                  =>      open,
        gt4_drpwe_in                    =>      '0',
        gt4_dmonitorout_out             =>      open,
        gt4_eyescanreset_in             =>      '0',
        gt4_rxuserrdy_in                =>      '1',
        gt4_eyescandataerror_out        =>      open,
        gt4_eyescantrigger_in           =>      '0',
        gt4_rxusrclk_in                 =>      gt4_rxusrclk_in,
        gt4_rxusrclk2_in                =>      gt4_rxusrclk2_in,
        gt4_rxdata_out                  =>      gtx_data4_out,
        gt4_rxdisperr_out               =>      open,
        gt4_rxnotintable_out            =>      open,
        gt4_gtxrxp_in                   =>      gt4_gtxrxp_in,
        gt4_gtxrxn_in                   =>      gt4_gtxrxn_in,
        gt4_rxphmonitor_out             =>      open,
        gt4_rxphslipmonitor_out         =>      open,
        gt4_rxbyteisaligned_out         =>      gt4_rxbyteisaligned_out,
        gt4_rxcommadet_out              =>      open,
        gt4_rxdfelpmreset_in            =>      '0',
        gt4_rxmonitorout_out            =>      open,
        gt4_rxoutclk_out                =>      gt4_rxoutclk_out,
        gt4_rxmonitorsel_in             =>      "00",
        gt4_rxoutclkfabric_out          =>      open,
        gt4_gtrxreset_in                =>      '0',
        gt4_rxpmareset_in               =>      '0',
        gt4_rxcharisk_out               =>      gt4_rxcharisk_out,
        gt4_rxresetdone_out             =>      open,
        gt4_gttxreset_in                =>      '0',
        gt4_txuserrdy_in                =>      '1',
        gt4_txusrclk_in                 =>      gt4_txusrclk_in,
        gt4_txusrclk2_in                =>      gt4_txusrclk2_in,
        gt4_txdata_in                   =>      gtx_data4_in,
        gt4_gtxtxn_out                  =>      gt4_gtxtxn_out,
        gt4_gtxtxp_out                  =>      gt4_gtxtxp_out,
		gt4_txoutclk_out                =>      open,
        gt4_txoutclkfabric_out          =>      open,
        gt4_txoutclkpcs_out             =>      open,
        gt4_txcharisk_in                =>      gt4_txcharisk_in,
    --GT5  (X0Y5)
    --____________________________CHANNEL PORTS________________________________
        gt5_cpllfbclklost_out           =>      open,
        gt5_cplllock_out                =>      open,
        gt5_cplllockdetclk_in           =>      clk,
        gt5_cpllreset_in                =>      '0',
        gt5_gtrefclk0_in                =>      gt5_gtrefclk0_in,
        gt5_gtrefclk1_in                =>      gt0_gtrefclk1_in,
        gt5_drpaddr_in                  =>      "000000000",
        gt5_drpclk_in                   =>      '0',
        gt5_drpdi_in                    =>      "0000000000000000",
        gt5_drpdo_out                   =>      open,
        gt5_drpen_in                    =>      '0',
        gt5_drprdy_out                  =>      open,
        gt5_drpwe_in                    =>      '0',
        gt5_dmonitorout_out             =>      open,
        gt5_eyescanreset_in             =>      '0',
        gt5_rxuserrdy_in                =>      '1',
        gt5_eyescandataerror_out        =>      open,
        gt5_eyescantrigger_in           =>      '0',
        gt5_rxusrclk_in                 =>      gt5_rxusrclk_in,
        gt5_rxusrclk2_in                =>      gt5_rxusrclk2_in,
        gt5_rxdata_out                  =>      gtx_data5_out,
        gt5_rxdisperr_out               =>      open,
        gt5_rxnotintable_out            =>      open,
        gt5_gtxrxp_in                   =>      gt5_gtxrxp_in,
        gt5_gtxrxn_in                   =>      gt5_gtxrxn_in,
        gt5_rxphmonitor_out             =>      open,
        gt5_rxphslipmonitor_out         =>      open,
        gt5_rxbyteisaligned_out         =>      gt5_rxbyteisaligned_out,
        gt5_rxcommadet_out              =>      open,
        gt5_rxdfelpmreset_in            =>      '0',
        gt5_rxmonitorout_out            =>      open,
        gt5_rxoutclk_out                =>      gt5_rxoutclk_out,
        gt5_rxmonitorsel_in             =>      "00",
        gt5_rxoutclkfabric_out          =>      open,
        gt5_gtrxreset_in                =>      '0',
        gt5_rxpmareset_in               =>      '0',
        gt5_rxcharisk_out               =>      gt5_rxcharisk_out,
        gt5_rxresetdone_out             =>      open,
        gt5_gttxreset_in                =>      '0',
        gt5_txuserrdy_in                =>      '1',
        gt5_txusrclk_in                 =>      gt5_txusrclk_in,
        gt5_txusrclk2_in                =>      gt5_txusrclk2_in,
        gt5_txdata_in                   =>      gtx_data5_in,
        gt5_gtxtxn_out                  =>      gt5_gtxtxn_out,
        gt5_gtxtxp_out                  =>      gt5_gtxtxp_out,
		gt5_txoutclk_out                =>      open,
        gt5_txoutclkfabric_out          =>      open,
        gt5_txoutclkpcs_out             =>      open,
        gt5_txcharisk_in                =>      gt5_txcharisk_in,
    --GT6  (X0Y6)
    --____________________________CHANNEL PORTS________________________________
        gt6_cpllfbclklost_out           =>      open,
        gt6_cplllock_out                =>      open,
        gt6_cplllockdetclk_in           =>      clk,
        gt6_cpllreset_in                =>      '0',
        gt6_gtrefclk0_in                =>      gt6_gtrefclk0_in,
        gt6_gtrefclk1_in                =>      gt0_gtrefclk1_in,
        gt6_drpaddr_in                  =>      "000000000",
        gt6_drpclk_in                   =>      '0',
        gt6_drpdi_in                    =>      "0000000000000000",
        gt6_drpdo_out                   =>      open,
        gt6_drpen_in                    =>      '0',
        gt6_drprdy_out                  =>      open,
        gt6_drpwe_in                    =>      '0',
        gt6_dmonitorout_out             =>      open,
        gt6_eyescanreset_in             =>      '0',
        gt6_rxuserrdy_in                =>      '1',
        gt6_eyescandataerror_out        =>      open,
        gt6_eyescantrigger_in           =>      '0',
        gt6_rxusrclk_in                 =>      gt6_rxusrclk_in,
        gt6_rxusrclk2_in                =>      gt6_rxusrclk2_in,
        gt6_rxdata_out                  =>      gtx_data6_out,
        gt6_rxdisperr_out               =>      open,
        gt6_rxnotintable_out            =>      open,
        gt6_gtxrxp_in                   =>      gt6_gtxrxp_in,
        gt6_gtxrxn_in                   =>      gt6_gtxrxn_in,
        gt6_rxphmonitor_out             =>      open,
        gt6_rxphslipmonitor_out         =>      open,
        gt6_rxbyteisaligned_out         =>      gt6_rxbyteisaligned_out,
        gt6_rxcommadet_out              =>      open,
        gt6_rxdfelpmreset_in            =>      '0',
        gt6_rxmonitorout_out            =>      open,
        gt6_rxoutclk_out                =>      gt6_rxoutclk_out,
        gt6_rxmonitorsel_in             =>      "00",
        gt6_rxoutclkfabric_out          =>      open,
        gt6_gtrxreset_in                =>      '0',
        gt6_rxpmareset_in               =>      '0',
        gt6_rxcharisk_out               =>      gt6_rxcharisk_out,
        gt6_rxresetdone_out             =>      open,
        gt6_gttxreset_in                =>      '0',
        gt6_txuserrdy_in                =>      '1',
        gt6_txusrclk_in                 =>      gt6_txusrclk_in,
        gt6_txusrclk2_in                =>      gt6_txusrclk2_in,
        gt6_txdata_in                   =>      gtx_data6_in,
        gt6_gtxtxn_out                  =>      gt6_gtxtxn_out,
        gt6_gtxtxp_out                  =>      gt6_gtxtxp_out,
		gt6_txoutclk_out                =>      open,
        gt6_txoutclkfabric_out          =>      open,
        gt6_txoutclkpcs_out             =>      open,
        gt6_txcharisk_in                =>      gt6_txcharisk_in,
        --____________________________COMMON PORTS________________________________
             GT0_QPLLOUTCLK_IN  => '0',
             GT0_QPLLOUTREFCLK_IN => '0',
            --____________________________COMMON PORTS________________________________
             GT1_QPLLOUTCLK_IN  => '0',
             GT1_QPLLOUTREFCLK_IN => '0'
);		
--High Speed Link7		
gtwizard_1_inst : entity work.gtwizard_1
      port map (
        SYSCLK_IN => clk,	
		SOFT_RESET_TX_IN	=> SOFT_RESET,
        SOFT_RESET_RX_IN	=> SOFT_RESET,
        DONT_RESET_ON_DATA_ERROR_IN	=> '0',
        GT0_TX_FSM_RESET_DONE_OUT	=> gt7_txresetdone,
        GT0_RX_FSM_RESET_DONE_OUT	=> gt7_rxresetdone,
        GT0_DATA_VALID_IN	=> '1',
        GT0_TX_MMCM_LOCK_IN => txoutclk_mmcm0_locked,
        GT0_TX_MMCM_RESET_OUT => txoutclk_mmcm0_reset,
        GT0_RX_MMCM_LOCK_IN => rxoutclk_mmcm0_locked,
        GT0_RX_MMCM_RESET_OUT => rxoutclk_mmcm0_reset,
        gt0_gtrefclk0_in => gt7_gtrefclk0_in,
        gt0_gtrefclk1_in => '0',
        gt0_cplllockdetclk_in => clk,
        gt0_cpllreset_in	=> '0',
        gt0_drpaddr_in	=> "000000000",
        gt0_drpclk_in=>'0',
        gt0_drpdi_in	=> "0000000000000000",
        gt0_drpen_in	=> '0',
        gt0_drpwe_in	=> '0',
        gt0_eyescanreset_in	=> '0',
        gt0_rxuserrdy_in	=> '1',
        gt0_eyescantrigger_in	=> '0',
        gt0_rxusrclk_in => gt7_rxusrclk_in,
        gt0_rxusrclk2_in => gt7_rxusrclk2_in,
        gt0_rxdata_out	=> gtx_data7_out,
        gt0_rxslide_in => gt7_rxslide_in,
        gt0_gtxrxp_in	=> gt7_gtxrxp_in,
        gt0_gtxrxn_in	=> gt7_gtxrxn_in,
        gt0_rxdfelpmreset_in	=> '0',
        gt0_rxmonitorsel_in	=> "00",
		gt0_rxoutclk_out => gt7_rxoutclk_out,
        gt0_gtrxreset_in	=> '0',
        gt0_rxpmareset_in	=> '0',
        gt0_rxcharisk_out	=> gt7_rxcharisk_out,
        gt0_gttxreset_in	=> '0',
        gt0_txuserrdy_in	=> '1',
        gt0_txusrclk_in => gt7_txusrclk_in,
        gt0_txusrclk2_in => gt7_txusrclk2_in,
        gt0_txdata_in	=> gtx_data7_in,
        gt0_gtxtxn_out	=> gt7_gtxtxn_out,
        gt0_gtxtxp_out	=> gt7_gtxtxp_out,
		gt0_txoutclk_out => gt7_txoutclk_out,
        gt0_txcharisk_in	=> charisk,
        GT0_QPLLOUTCLK_IN	=> '0',
        GT0_QPLLOUTREFCLK_IN	=> '0',
		gt0_rxbyteisaligned_out	=> open
		);
		
	Inst_rx_align:entity work.rx_alignment
        generic map(
        NUMBER_TO_ALIGN => 10,
        LOSS_ALIGN => 20,
        DATA_WIDTH => 64
        )
        port map(
        clk_i => gt7_rxusrclk2_in,
        reset_i => not gt7_rxresetdone,
        slide_o => gt7_rxslide_in,
        rx_data_i => gtx_data7_out,
        aligned_o => gt7_rxbyteisaligned_out,
        re_align_i => '0',
        debug_fsm => open
        );
	-- sda open-drain buffer	
	sda_in <= sda;
	sda <= '0' when sda_out='0' else 'Z';
	-- GTX reset
	SOFT_RESET <= (not reset_n);
	--System under RESET if System clock not stable
	reset_n <= locked;
Inst_ila :entity work.ila_0
PORT MAP (
	clk => gt_txusrclk_i,
	probe0 => probe0, 
	probe1 => gtx_data0_out, 
	probe2 => gtx_data1_out, 
	probe3 => gtx_data2_out, 
	probe4 => gtx_data3_out, 
	probe5 => gtx_data4_out, 
	probe6 => gtx_data5_out, 
	probe7 => gtx_data6_out, 
	probe8 => gtx_data7_out,
	probe9 => probe9,
    probe10 => gtx_data0_in,
    probe11 => gtx_data7_in
);
probe0 <= gt7_rxbyteisaligned_out & gt6_rxbyteisaligned_out & gt5_rxbyteisaligned_out & gt4_rxbyteisaligned_out & gt3_rxbyteisaligned_out
        & gt2_rxbyteisaligned_out & gt1_rxbyteisaligned_out & gt0_rxbyteisaligned_out;
probe9 <= gt7_rxcharisk_out(0) & gt6_rxcharisk_out(0) & gt5_rxcharisk_out(0) & gt4_rxcharisk_out(0) & gt3_rxcharisk_out(0) & gt2_rxcharisk_out(0) & gt1_rxcharisk_out(0) & gt0_rxcharisk_out(0);
END ARCHITECTURE top_level;		