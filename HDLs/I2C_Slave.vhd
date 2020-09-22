----------------------------------------------------------------
---- INFN Sezione di Roma Tre
---- Project Name : RMU
---- File         : GTX_Avg.vhd
---- Author       : Stefano Basti
---- Description  : I2C Slave Interface for RMU Project
---- Modification History
---- 25/01/2019 First Issue
---- 24/04/2019 Improved code and ported for RMU project 
---- 25/04/2019 Added Latency Tester Interface
---- 12/05/2019 Generic Value Added
---- 13/05/2019 Release
----------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.all; 
USE IEEE.STD_LOGIC_ARITH.ALL;

ENTITY I2C_Slave IS
GENERIC(
		device_address:STD_LOGIC_VECTOR (6 DOWNTO 0):="0010110"; --I2C Device Address
		device_id:STD_LOGIC_VECTOR (7 DOWNTO 0):=X"BA"; --Device ID Read from register 0x0
		last_addr:STD_LOGIC_VECTOR (7 DOWNTO 0):=X"FF" --Bank Register Size
	);
PORT(
		clk:IN STD_LOGIC;		--system clock
		reset_n:IN STD_LOGIC;
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
		--Link Average or SnapShot
		link0_mean:IN STD_LOGIC_VECTOR (15 DOWNTO 0); 
		link1_mean:IN STD_LOGIC_VECTOR (15 DOWNTO 0); 
		link2_mean:IN STD_LOGIC_VECTOR (15 DOWNTO 0); 
		link3_mean:IN STD_LOGIC_VECTOR (15 DOWNTO 0); 
		link4_mean:IN STD_LOGIC_VECTOR (15 DOWNTO 0); 
		link5_mean:IN STD_LOGIC_VECTOR (15 DOWNTO 0); 
		link6_mean:IN STD_LOGIC_VECTOR (15 DOWNTO 0); 
		link7_mean:IN STD_LOGIC_VECTOR (63 DOWNTO 0);
		packer_mean:IN STD_LOGIC_VECTOR (63 DOWNTO 0);
		--Comma Insertion Counter Value
		count0:OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
		count1:OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
		count2:OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
		count3:OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
		count4:OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
		count5:OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
		count6:OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
		count7:OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
		--Data for TTIM Emulator
		data0:OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		data1:OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		data2:OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		data3:OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		data4:OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		data5:OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		data6:OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		--Stop Signal for Average Calculator
		stop_avg:OUT STD_LOGIC;
		--Latency Tester Signal
		test:OUT STD_LOGIC;
		recvtest:IN STD_LOGIC;
		sendtest:IN STD_LOGIC;
		counttst:IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		--Rate Changer Signal (not used)
		txrate:OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
		rxrate:OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
		rst_rate:OUT STD_LOGIC;
		--System Status Signal
		sys_status:IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		--Board Led Signal
		led:OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
		--I2C Open Drain Signal
		scl:IN STD_LOGIC;		--I2C clk
		sda_in:IN STD_LOGIC;		--I2C data
		sda_out:OUT STD_LOGIC		--I2C data 
		--out_en:OUT STD_LOGIC	--SDA Output En --Removed S.B. 24/04/2019
		);
		
END ENTITY I2C_Slave;

ARCHITECTURE slave Of I2C_Slave IS
--Reset sync signal
signal Q1:STD_LOGIC;
signal Q0:STD_LOGIC;
signal ireset_n:STD_LOGIC;
--scl sda sync signal
signal scl_cset:STD_LOGIC;
signal sscl:STD_LOGIC;
signal s2scl:STD_LOGIC;
signal ssscl:STD_LOGIC;
signal sda_cset:STD_LOGIC;
signal ssda_in:STD_LOGIC;
signal s2sda_in:STD_LOGIC;
signal sssda_in:STD_LOGIC;
signal sda_rise:STD_LOGIC;
signal sda_fall:STD_LOGIC;
signal sda_rising_done:STD_LOGIC;
--FSM I2C cntrl signal
signal end_cycle:STD_LOGIC;
signal start:STD_LOGIC;	
signal rstart:STD_LOGIC;
signal stop:STD_LOGIC;
signal s_data:STD_LOGIC_VECTOR (7 DOWNTO 0);
--signal c_data:STD_LOGIC_VECTOR (1024 DOWNTO 0);  --Removed S.B. 24/04/2019
type fsm_state is (IDLE,GET_DEVICE,GET_ADDRESS,GET_DATA,PUT_DATA,ACK,NACK,CHECK_NACK);
signal state:fsm_state;
signal pstate:fsm_state;  
signal i:integer;
signal rise:std_logic;

--Register 
Type mem_8 Is Array (0 to CONV_INTEGER(last_addr)) Of STD_LOGIC_VECTOR (7 DOWNTO 0);
signal reg_mem:mem_8; 
-- Device ID -- 0x0
-- Link A1 sts -- 0x1
-- Link B1 sts -- 0x2
-- Link C1 sts -- 0x3
-- Link D1 sts -- 0x4
-- Link A2 sts -- 0x5
-- Link B2 sts -- 0x6
-- Link C2 sts -- 0x7
-- Link D2 sts -- 0x8
-- link0_mean -- 0x9 0xA
-- link1_mean -- 0xB 0xC
-- link2_mean -- 0xD 0xE
-- link3_mean -- 0xF 0x10
-- link4_mean -- 0x11 0x12
-- link5_mean -- 0x13 0x14
-- link6_mean -- 0x15 0x16
-- link7_mean -- 0x17 0x18 0x19 0x1A 0x1B 0x1C 0x1D 0x1E
-- packer_mean -- 0x1F 0x20 0x21 0x22 0x23 0x24 0x25 0x26
-- count0 -- 0x27 0x28 
-- count1 -- 0x29 0x2A 
-- count2 -- 0x2B 0x2C 
-- count3 -- 0x2D 0x2E 
-- count4 -- 0x2F 0x30 
-- count5 -- 0x31 0x32 
-- count6 -- 0x33 0x34 
-- count7 -- 0x35 0x36
-- data0 -- 0x37
-- data1 -- 0x38
-- data2 -- 0x39
-- data3 -- 0x3A
-- data4 -- 0x3B
-- data5 -- 0x3C
-- data6 -- 0x3D
-- sys_status -- 0x3E
-- test -- 0x3F
-- countst  -- 0x40
-- led -- 0x41
-- txrate -- 0x42
-- rxrate -- 0x43
-- spare -- 0x44 0xFF
--Addressing
signal WRn:STD_LOGIC;
signal RDn:STD_LOGIC;
signal reg_address:STD_LOGIC_VECTOR (7 DOWNTO 0);
signal write_data:STD_LOGIC_VECTOR (7 DOWNTO 0);
signal read_data:STD_LOGIC_VECTOR (7 DOWNTO 0);
--test signal
signal irecvtest:STD_LOGIC;
signal srecvtest:STD_LOGIC;
signal isendtest:STD_LOGIC;
signal ssendtest:STD_LOGIC;

BEGIN
	--Double stage sync for Metastability
	reset_sync: PROCESS (clk,reset_n)
	BEGIN
		if (reset_n='0')then
			Q0<='0';
			Q1<='0';
			ireset_n<='0';
		elsif(rising_edge(clk))then
			Q0<='1';
			Q1<=Q0;
			ireset_n<=Q1;
		end if;
	END PROCESS reset_sync;
	--Double stage sync for Metastability
	testsignal_sync: PROCESS (clk,reset_n)
	BEGIN
		if (reset_n='0')then
			irecvtest<='0';
			srecvtest<='0';
			isendtest<='0';
			ssendtest<='0';
		elsif(rising_edge(clk))then
			irecvtest<=recvtest;
			srecvtest<=irecvtest;
			isendtest<=sendtest;
			ssendtest<=isendtest;
		end if;
	END PROCESS testsignal_sync;
	--scl double stage sync for Metastability and De-bouncer
	sync_scl: PROCESS (clk, ireset_n) 
	variable i: integer range 0 to 255;
	BEGIN
		if (ireset_n='0')then
		sscl<='1';
		ssscl<='1';
		s2scl<= '1';
		i:=10;
		elsif (rising_edge(clk))then
			sscl<=scl;
			s2scl<=sscl;
			if(scl_cset='1') then
				i:=10;
			end if;
			if(i>0) then
				i:= i-1;
			else
				ssscl<=s2scl;
			end if;
		end if;
	END PROCESS sync_scl;
	scl_cset<= sscl xor s2scl;
	--sda in double stage sync for Metastability and De-bouncer
	sync_sda: PROCESS (clk, ireset_n) 
	variable i: integer range 0 to 255;
	BEGIN
		if (ireset_n='0')then
		ssda_in<='1';
		sssda_in<='1';
		s2sda_in<='1';
		i:= 10;
		elsif (rising_edge(clk))then
			ssda_in<=sda_in;
			s2sda_in<=ssda_in;
			if(sda_cset='1') then
				i:=10;
			end if;
			if(i>0) then
				i:= i-1;
			else
				sssda_in<=s2sda_in;
			end if;
		end if;
	END PROCESS sync_sda;
	sda_cset<= ssda_in xor s2sda_in;
	--rising and falling enable signal generator
	sda_edge_en_gen:PROCESS (clk, ireset_n)
	BEGIN
		if(ireset_n='0')then
			sda_rise<='0';
			sda_fall<='0';
			sda_rising_done<='0';
		elsif (rising_edge(clk))then
			if(sssda_in='1' and sda_rising_done='0')then --Capture Rising
				sda_rise<='1';
				sda_rising_done<='1';
			elsif(sssda_in='0' and sda_rising_done='1')then --Capture Falling
				sda_fall<='1'; 
				sda_rising_done<='0';
			else
				sda_rise<='0';
				sda_fall<='0';
			end if;
		end if;
	END PROCESS sda_edge_en_gen;
	--Check Start and Stop condition
	start_stop_check:PROCESS (clk,ireset_n)
	BEGIN
		if(ireset_n='0')then
			start<='0';
			stop<='0';
		elsif(rising_edge(clk))then
			if((ssscl='1') and (sda_fall='1'))then  --START Condition
				start<='1';
			elsif (ssscl='1' and sda_rise='1')then  --STOP Condition
				stop<='1';
			elsif (end_cycle ='1')then
				start<='0';
				stop<='0';
			end if;
		end if;
	END PROCESS start_stop_check;
	--Reg Addressing
	reg_addressing:PROCESS (clk,ireset_n)
	BEGIN
		if(ireset_n='0')then
			read_data<=(OTHERS => '0');
			reg_mem <= (OTHERS => (OTHERS => '0'));
			reg_mem(39) <= X"FF";
            reg_mem(40) <= X"FF";
            reg_mem(41) <= X"FF";
            reg_mem(42) <= X"FF";
            reg_mem(43) <= X"FF";
            reg_mem(44) <= X"FF";
            reg_mem(45) <= X"FF";
            reg_mem(46) <= X"FF";
            reg_mem(47) <= X"FF";
            reg_mem(48) <= X"FF";
            reg_mem(49) <= X"FF";
            reg_mem(50) <= X"FF";
            reg_mem(51) <= X"FF";
            reg_mem(52) <= X"FF";
            reg_mem(53) <= X"FF";
            reg_mem(54) <= X"FF";
		elsif rising_edge(clk) then
				if RDn = '0' then
					read_data<=	reg_mem(CONV_INTEGER(reg_address(7 DOWNTO 0)));
				elsif WRn = '0' then
					reg_mem(CONV_INTEGER(reg_address(7 DOWNTO 0)))<=write_data;
				else  --Read Only Register
					reg_mem(0)<=device_id;
					reg_mem(1)<=('0' & '0' & '0' & '0' & MOD_DEFA1 & MOD_ABS_A1 & TX_FAULT_A1);
					reg_mem(2)<=('0' & '0' & '0' & '0' & MOD_DEFB1 & MOD_ABS_B1 & TX_FAULT_B1);
					reg_mem(3)<=('0' & '0' & '0' & '0' & MOD_DEFC1 & MOD_ABS_C1 & TX_FAULT_C1);
					reg_mem(4)<=('0' & '0' & '0' & '0' & MOD_DEFD1 & MOD_ABS_D1 & TX_FAULT_D1);
					reg_mem(5)<=('0' & '0' & '0' & '0' & MOD_DEFA2 & MOD_ABS_A2 & TX_FAULT_A2);
					reg_mem(6)<=('0' & '0' & '0' & '0' & MOD_DEFB2 & MOD_ABS_B2 & TX_FAULT_B2);
					reg_mem(7)<=('0' & '0' & '0' & '0' & MOD_DEFC2 & MOD_ABS_C2 & TX_FAULT_C2);
					reg_mem(8)<=('0' & '0' & '0' & '0' & MOD_DEFD2 & MOD_ABS_D2 & TX_FAULT_D2);
					reg_mem(9)<=link0_mean(7 downto 0);
					reg_mem(10)<=link0_mean(15 downto 8);
					reg_mem(11)<=link1_mean(7 downto 0);
					reg_mem(12)<=link1_mean(15 downto 8);
					reg_mem(13)<=link2_mean(7 downto 0);
					reg_mem(14)<=link2_mean(15 downto 8);
					reg_mem(15)<=link3_mean(7 downto 0);
					reg_mem(16)<=link3_mean(15 downto 8);
					reg_mem(17)<=link4_mean(7 downto 0);
					reg_mem(18)<=link4_mean(15 downto 8);
					reg_mem(19)<=link5_mean(7 downto 0);
					reg_mem(20)<=link5_mean(15 downto 8);
					reg_mem(21)<=link6_mean(7 downto 0);
					reg_mem(22)<=link6_mean(15 downto 8);
					reg_mem(23)<=link7_mean(7 downto 0);
					reg_mem(24)<=link7_mean(15 downto 8);
					reg_mem(25)<=link7_mean(23 downto 16);
					reg_mem(26)<=link7_mean(31 downto 24);
					reg_mem(27)<=link7_mean(39 downto 32);
					reg_mem(28)<=link7_mean(47 downto 40);
					reg_mem(29)<=link7_mean(55 downto 48);
					reg_mem(30)<=link7_mean(63 downto 56);
					reg_mem(31)<=packer_mean(7 downto 0);
					reg_mem(32)<=packer_mean(15 downto 8);
					reg_mem(33)<=packer_mean(23 downto 16);
					reg_mem(34)<=packer_mean(31 downto 24);
					reg_mem(35)<=packer_mean(39 downto 32);
					reg_mem(36)<=packer_mean(47 downto 40);
					reg_mem(37)<=packer_mean(55 downto 48);
					reg_mem(38)<=packer_mean(63 downto 56);
					reg_mem(62)<=sys_status;
					reg_mem(63)(7 downto 1)<= "00000" & sendtest & recvtest;
					reg_mem(64)<=counttst;
				end if;
		end if;
	END PROCESS reg_addressing;
	--Writeable register
	count0(7 downto 0) <=  reg_mem(39);
	count0(15 downto 8) <= reg_mem(40);
	count1(7 downto 0)  <= reg_mem(41);
	count1(15 downto 8) <= reg_mem(42);
	count2(7 downto 0)  <= reg_mem(43);
	count2(15 downto 8) <= reg_mem(44);
	count3(7 downto 0)  <= reg_mem(45);
	count3(15 downto 8) <= reg_mem(46);
	count4(7 downto 0)  <= reg_mem(47);
	count4(15 downto 8) <= reg_mem(48);
	count5(7 downto 0)  <= reg_mem(49);
	count5(15 downto 8) <= reg_mem(50);
	count6(7 downto 0)  <= reg_mem(51);
	count6(15 downto 8) <= reg_mem(52);
	count7(7 downto 0)  <= reg_mem(53);
	count7(15 downto 8) <= reg_mem(54);
	data0 <= reg_mem(55);
	data1 <= reg_mem(56);
	data2 <= reg_mem(57);
	data3 <= reg_mem(58);
	data4 <= reg_mem(59);
	data5 <= reg_mem(60);
	data6 <= reg_mem(61);
	test <= reg_mem(63)(0);
	led <= reg_mem(65)(3 downto 0);	
	txrate <= reg_mem(66)(2 downto 0);
	rxrate <= reg_mem(67)(2 downto 0);
	
	--Reset gtx after change rate
	rst_gtx_rate:PROCESS (clk, ireset_n)
	variable j:integer range 0 to 255;
	BEGIN
		if(ireset_n='0')then
			rst_rate<='0';
			j:=0;
		elsif rising_edge(clk) then
			if(WRn='0' and reg_address=X"4B")then
				j:=1;
			elsif j>0 then
				j:= j+1;
				if(j=50) then
					rst_rate<='1';
				elsif (j=15) then
					rst_rate<='0';
					j:=0;
				end if;
			end if;
		end if;
	end process rst_gtx_rate;	
	
	--FSM of I2C cntrl 
	fsm_i2c:PROCESS (clk,ireset_n)
	variable c:integer range 0 to 2048;	
	variable m:integer range 0 to 2048;
	BEGIN
		if(ireset_n='0')then
			state<=IDLE;
			s_data<=(others=>'0');
			--c_data<=(others=>'0');
			reg_address<=(others=>'0'); 
			write_data<=(others=>'0');
			RDn<='1';
			WRn<='1';
			i<=0;
			c:=0;
			m:=0;
			rise<='0';
			end_cycle<='1';
			rstart<='0';
			stop_avg<='0';
			--out_en<= '0';
			sda_out<='1';
		elsif(rising_edge(clk))then
			case(state)is
				WHEN IDLE =>  --State IDLE, Wait Start condition
					s_data<=(others=>'0');
					--c_data<=(others=>'0'); --Removed S.B. 24/04/2019
					i<=7;
					c:=0;
					m:=0;
					RDn<='1';
					WRn<='1';
					rstart<='0';
					end_cycle<='0';
					rise<='0';
					--out_en<= '0'; --Removed S.B. 24/04/2019
					stop_avg<='0';
					sda_out<='1';					
					if(start='1' and ssscl='0' and end_cycle<='0')then --Start received, Get Device address
						pstate<=state;
						state<= GET_DEVICE;
						end_cycle<='1';
					end if;
					if(stop='1')then
						end_cycle<='1';
					end if;
					
				WHEN GET_DEVICE =>	 --State GET_DEVICE, Get Device address 
					if stop='1'then --Abort
						state<=IDLE;
						end_cycle<='1';
					end if;
					if start='1'then --repeat state
						i<=7;
						c:=0;
						m:=0;
						state<=GET_DEVICE;
					end if;
					if(ssscl='0' and rise='0')then --When SCL low Count half period duration
						if(c<2047)then
							c:=c+1;
						end if;
					elsif(ssscl='1' and rstart='0')then
						--c_data(c)<= sssda_in; --Removed S.B. 24/04/2019
						if(m=c/2)then --Sample half of half period where the data is stable whit SCL High
							s_data(i)<=sssda_in;
							c:=0;
						else
							m:=m+1;
						end if;
						rise<='1';
					elsif(ssscl='0' and rise='1')then --Bit Sampled, decrement bit Counter
						--c:= c/2; --Removed S.B. 24/04/2019
						--s_data(i)<=c_data(c); --Removed S.B. 24/04/2019
						i<= i-1;
						rise<='0';
						if(i = 0) then --If 8 bit sampled check device address and go to ACK
							if(s_data(7 DOWNTO 1) = device_address) then --OK ACK
								i<=7;
								m:=m/2;
								pstate<=state;
								state<=ACK;
							else  --Abort
								i<=0;
								end_cycle<='1';
								state<=IDLE;
							end if;
						else
							m:=0;
						end if;
						if rstart = '1' then --Repeated Start handler
							rstart<='0';
							i<=7;
						end if;
						c:= 0;
					end if;
					
	 
				WHEN GET_ADDRESS =>	  --State GET_ADDRESS, Get Register Address 
					if stop='1'then --Abort
						state<=IDLE;
						end_cycle<='0';
					end if;
					if start='1'then --Start received, abort and go to Get Device address
						i<=7;
						c:=0;
						m:=0;
						rstart<='1';
						state<=GET_DEVICE;
					end if;
					if(ssscl='0' and rise='0')then --When SCL low Count half period duration
						if(c<2047)then
							c:=c+1;
						end if;
					elsif(ssscl='1')then
						--c_data(c)<= sssda_in; --Removed S.B. 24/04/2019
						--if(c<1023)then --Removed S.B. 24/04/2019
						--	c:=c+1; --Removed S.B. 24/04/2019
						--end if; --Removed S.B. 24/04/2019
						if(m=c/2)then --Sample half of half period where the data is stable whit SCL High
							s_data(i)<=sssda_in;
							c:=0;
						else
							m:=m+1;
						end if;
						rise<='1';
					elsif(ssscl='0' and rise='1')then --Bit Sampled, decrement bit Counter
						--c:= c/2; --Removed S.B. 24/04/2019
						--s_data(i)<=c_data(c); --Removed S.B. 24/04/2019
						i<= i-1;
						rise<='0';
						if(i = 0) then --If 8 bit sampled check address in range and go to ACK
							m:=m/2;
							pstate<=state;
							if(s_data(7 DOWNTO 0) > last_addr) then -- Address too high, go to NACK (last address to be defined, now is 0xFF, all address is ok)
								i<=0;
								state<=NACK;
							else --OK, ACK
								i<=0;
								state<=ACK;
							end if;
						else
							m:=0;
						end if;
						c:= 0;
					end if;
				
				WHEN GET_DATA =>  --State GET_DATA, Get Data from Master
					if stop='1'then --Abort
						state<=IDLE;
						end_cycle<='1';
					end if;
					if start='1'then  --Start received, abort and go to Get Device address
						i<=7;
						c:=0;
						m:=0;
						rstart<='1';
						state<=GET_DEVICE;
					end if;
					if(ssscl='0' and rise='0')then --When SCL low Count half period duration
						if(c<2047)then
							c:=c+1;
						end if;
					elsif(ssscl='1')then 
						WRn<='1';
						--c_data(c)<= sssda_in; --Removed S.B. 24/04/2019
						--if(c<1023)then --Removed S.B. 24/04/2019
						--	c:=c+1; --Removed S.B. 24/04/2019
						--end if; --Removed S.B. 24/04/2019
						if(m=c/2)then --Sample half of half period where the data is stable whit SCL High
							s_data(i)<=sssda_in;
							c:=0;
						else
							m:=m+1;
						end if;
						rise<='1';
					elsif(ssscl='0' and rise='1')then --Bit Sampled, decrement bit Counter
						--c:= c/2; --Removed S.B. 24/04/2019
						--s_data(i)<=c_data(c); --Removed S.B. 24/04/2019
						i<= i-1;
						rise<='0';
						if(i = 0) then --If 8 bit sampled go to ACK
							m:=m/2;
							pstate<=state;
							i<=0;
							state<=ACK;
						else
							m:=0;
						end if;
						c:= 0;
					end if;
				
				WHEN PUT_DATA => --State PUT_DATA, put Data to Master
					RDn<='1';
					if stop='1'then --Abort
						state<=IDLE;
						end_cycle<='1';
					end if;
					if start='1'then --Start received, abort and go to Get Device address
						i<=7;
						c:=0;
						m:=0;
						state<=GET_DEVICE;
					end if;
					if(ssscl='0')then --When SCL low and the half of half period reached put the bit of data
						if(c=m)then 
							sda_out<= read_data(i);	
						end if;
						if(c<1023)then
							c:=c+1;
						end if;
					end if;
					if(ssscl='1')then --Keep the bit stable for the SCL high period
						if(c<1023)then --When SCL High Count half period duration
							c:=c+1;
						end if;
						if rise='0' then
							rise<='1';
							c:=0;
						end if;
					elsif(ssscl='0' and rise='1')then --Bit sent, decrement bit Counter
						m:= c/2;
						i<= i-1;
						rise<='0';
						if(i = 0) then --If 8 bit sent go to Check the master ACK
							--out_en<='0'; --Removed S.B. 24/04/2019
							sda_out<='1'; --Disable SDA Output
							pstate<=state;
							i<=0;
							state<=CHECK_NACK;
						end if;
						c:=0;
					end if;
				
				WHEN ACK => --State ACK, Send ACK to Master and decide the next operation
					if stop='1'then --Abort
						state<=IDLE;
						end_cycle<='1';
					end if;
					if start='1'then  --Start received, abort and go to Get Device address
						i<=7;
						c:=0;
						state<=GET_DEVICE;
					end if;
					if(rise='0')then
						if (pstate = GET_DATA and c=0)then --If previous state GET_DATA, put the 8bit into the register
							write_data<=s_data;
							WRn<='0';
						else
							WRn<='1';
						end if;
						if(c=m)then --When SCL low and the half of half period reached put the line SDA low
							--out_en<='1'; --Removed S.B. 24/04/2019
							sda_out<='0';
						end if;
						c:=c+1;
						RDn<='1';
					end if;
					if(ssscl='1')then --Keep the SDA line stable low for the SCL high period
						rise<='1';
					elsif(ssscl='0' and rise='1')then --ACK sent, decide the next state
						sda_out<= '1';
						--out_en<='0'; --Removed S.B. 24/04/2019
						write_data<=(OTHERS => '0');
						c:=0;
						if( pstate = GET_DEVICE)then --If previous state GET_DEVICE, check W/R bit
							if(s_data(0) = '0')then --W/R bit low, Write operation, go to GET_ADDRESS
							    i<=7;
								m:=0;
								rise<='0';
								pstate<=state;
								state<=GET_ADDRESS;
							else --W/R bit High, Read operation, go to PUT_DATA
								rise<='0';
							    i<=7;
								pstate<=state;
								RDn<='0';
								if((reg_address > X"09") and (reg_address < X"4A")) then --If Link-mean register Stop the Average calculator
									stop_avg<='1';
								else
									stop_avg<='0';
								end if;
								state<=PUT_DATA;
								--out_en<='1'; --Removed S.B. 24/04/2019
							end if;
						elsif(pstate = GET_ADDRESS)then --If previous state GET_ADDRESS, write address to register bus and go to GET_DATA
							rise<='0';
							i<=7;
							m:=0;
							reg_address <= s_data;
							pstate<=state;
							state<=GET_DATA;
						elsif(pstate = GET_DATA)then --If previous state GET_DATA, increment address to register bus and repeat GET_DATA
							if(stop='1')then --Abort
								pstate<=state;
							    rise<='0';
								end_cycle<='1';
								state<=IDLE;
							elsif scl='1' then
								rise<='0';
								i<=7;
								m:=0;
								pstate<=state;
								if(reg_address < last_addr)then
									reg_address<= reg_address+1;
								end if;
								state<=GET_DATA;
							end if;
						end if;
					end if;
					
				WHEN NACK => --State NACK, Send NACK to Master and go to IDLE
					if stop='1'then --Abort
						state<=IDLE;
						end_cycle<='1';
					end if;
					if start='1'then --Start received, abort and go to Get Device address
						i<=7;
						c:=0;
						state<=GET_DEVICE;
					end if;
					if(rise='0')then 
						if(c=m)then --When SCL low and the half of half period reached put the line SDA High
							--out_en<='1'; --Removed S.B. 24/04/2019
							sda_out<='1';
							c:=0;
						else
							c:=c+1;
						end if;
						WRn<='1';
						RDn<='1';
					end if;
					if(ssscl='1')then --Keep the SDA line stable High for the SCL high period
						rise<='1';
					elsif(scl='0'and rise='1')then --NACK sent to Master, go to IDLE
						c:=0;  
						--out_en<='0'; --Removed S.B. 24/04/2019
						sda_out<= '1';
						rise<='0';
						i<=7;
						m:=0;
						state<=pstate;
					end if;
				
				WHEN CHECK_NACK => --State CHECK_NACK, Check Master ACK or NACK for REad Operation
					 if stop='1'then --Abort
						state<=IDLE;
						end_cycle<='1';
					end if;
					if start='1'then --Start received, abort and go to Get Device address
						i<=7;
						c:=0;
						state<=GET_DEVICE;
					end if;
					if(ssscl='1')then
						--c_data(c)<= sssda_in; --Removed S.B. 24/04/2019
						--if(c<1023)then --Removed S.B. 24/04/2019
						--	c:=c+1; --Removed S.B. 24/04/2019
						--end if; --Removed S.B. 24/04/2019
						if(c=m)then --Sample half of half period where the data is stable whit SCL High
							s_data(i)<=sssda_in;
						else
							c:=c+1;
						end if;
						rise<='1';
					elsif(ssscl='0' and rise='1')then  --Bit Sampled, Check if is NACK or ACK
						--c:= c/2; --Removed S.B. 24/04/2019
						rise<='0';
						if(s_data(i) = '1') then --NACK, Master end Read, go to IDLE
							i<=7;
							c:=0;
							pstate<=state;
							RDn<='1';
							state<=IDLE;
						else --ACK, Master want another byte
							i<=7;
							pstate<=state;
							if(reg_address < last_addr)then --If Address not too high, increment it
								reg_address<= reg_address+1;
							end if;
							RDn<='0';
							if((reg_address > X"09") and (reg_address < X"4A")) then --If Link-mean register Stop the Average calculator 
								stop_avg<='1';
							else
								stop_avg<='0';
							end if;
							c:=0;
							state<=PUT_DATA;
							--out_en<='1'; --Removed S.B. 24/04/2019
						end if;
					end if;
				
				WHEN OTHERS => --Exception Handler
					state<=IDLE;
			end case;
		end if;
	END PROCESS fsm_i2c;

END ARCHITECTURE slave;
