LIBRARY IEEE               ;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL   ;
-----------------------------------
LIBRARY PLL_40MHz          ;
USE PLL_40MHz.ALL          ;
USE WORK.basic_package.ALL ;
USE WORK.VGA_package.ALL   ;
-----------------------------------------------------
ENTITY battle_engine IS
	PORT
	(
		CLK             : IN  UINT01;
		RST             : IN  UINT01;
		UP_SIG          : IN  UINT01; --BOTON ABAJO
		DOWN_SIG        : IN  UINT01; --BOTON ARRIBA
		SELECT_SIG      : IN  UINT01; --BOTON DE SELECCION
		STATE_CONTROL   : OUT UINT01; --SIRVE PARA SABER SI ESTAN JUGANDO O SI ESTAN SELECIONANDO
		TURN_DEFINITION : OUT UINT01; --SIRVE PARA SABER QUE INTERFAZ CAMBIAR, SI LA DE P0 O P1
		PK0_SELECTOR    : OUT UINT04;
		PK1_SELECTOR    : OUT UINT04;
		PK0_ENA         : OUT UINT01;
		PK1_ENA         : OUT UINT01;
		P0_READY_SIG    : OUT UINT01; --FEEDBACK VISUAL
		P1_READY_SIG    : OUT UINT01  --FEEDBACK VISUAL
	);
END ENTITY battle_engine;
-----------------------------------------------------
ARCHITECTURE functional OF battle_engine IS

TYPE STATE_TYPE IS
(
	ST_SEL_P0 ,
	ST_WAIT_P0,
	ST_SEL_P1 ,
	ST_WAIT_P1,
	ST_BATTLE
);

SIGNAL CURRENT_ST      : STATE_TYPE        ;
SIGNAL TURN_CONTROLLER : UINT01     := '0' ;
SIGNAL P0_READY        : UINT01     := '0' ;
SIGNAL P1_READY        : UINT01     := '0' ;
SIGNAL SELECTED_PK0    : UINT04            ;
SIGNAL SELECTED_PK1    : UINT04            ;
SIGNAL CURSOR_POS0     : UINT04            ;
SIGNAL CURSOR_POS1     : UINT04            ;
SIGNAL NEXT_VAL0       : UINT04            ;
SIGNAL NEXT_VAL1       : UINT04            ;
SIGNAL CURSOR_PK0      : UINT04     := X"0"; 
SIGNAL CURSOR_PK1      : UINT04     := X"0";
SIGNAL UD_INPUT        : UINT02            ;
SIGNAL U_SIG           : UINT01            ;
SIGNAL D_SIG           : UINT01            ;
SIGNAL REG_U_SIG       : UINT01            ;
SIGNAL REG_D_SIG       : UINT01            ;
SIGNAL UD0_SIG         : UINT04            ;
SIGNAL UD1_SIG         : UINT04            ;
BEGIN
	
	TURN_DEFINITION <= TURN_CONTROLLER;
	P0_READY_SIG    <= P0_READY;
	P1_READY_SIG    <= P1_READY;
	--UD INPUT LOGIC WAWAWAWAWAWAWAWAWAWAWAWAWAAWWAWA
	PROCESS (CLK, RST)
	BEGIN
		IF (RST = '1') THEN 
			REG_U_SIG <= '0';
			REG_D_SIG <= '0';
		ELSE
			IF RISING_EDGE(CLK) THEN
				REG_U_SIG <= UP_SIG  ;
				REG_D_SIG <= DOWN_SIG;
			END IF;
		END IF;
	END PROCESS;
	U_SIG <= UP_SIG   AND (NOT REG_U_SIG);
	D_SIG <= DOWN_SIG AND (NOT REG_D_SIG);
	
	UD_INPUT <= U_SIG & D_SIG;
	
	WITH UD_INPUT SELECT
		UD0_SIG <= X"1" WHEN "10"  ,
		           X"F" WHEN "01"  ,
		           X"0" WHEN OTHERS;
	
	WITH UD_INPUT SELECT
		UD1_SIG <= X"1" WHEN "10"  ,
		           X"F" WHEN "01"  ,
		           X"0" WHEN OTHERS;
	
	PK0_CURSOR_SUM : ENTITY WORK.bitn_fullAdder
	GENERIC MAP
	(
		B_LENGTH => 4
	)
	PORT MAP
	(
		A    => CURSOR_PK0 ,
		B    => UD0_SIG    ,
		Cin  => '0'        ,
		Cout => OPEN       ,
		S    => CURSOR_POS0
	);
	
	PK1_CURSOR_SUM : ENTITY WORK.bitn_fullAdder
	GENERIC MAP
	(
		B_LENGTH => 4
	)
	PORT MAP
	(
		A    => CURSOR_PK1,
		B    => UD1_SIG    ,
		Cin  => '0'        ,
		Cout => OPEN       ,
		S    => CURSOR_POS1
	);
	
	NEXT_VAL0 <= X"0" WHEN (UNSIGNED(CURSOR_POS0) > 9) ELSE CURSOR_POS0;
	NEXT_VAL1 <= X"0" WHEN (UNSIGNED(CURSOR_POS1) > 9) ELSE CURSOR_POS1;
	
	PROCESS(CLK, RST)
	BEGIN
		IF(RST = '1') THEN
			CURSOR_PK0 <= X"0";
			CURSOR_PK1 <= X"0";
		ELSE
			IF RISING_EDGE(CLK) THEN
				IF (TURN_CONTROLLER = '0') THEN
					CURSOR_PK0 <= NEXT_VAL0;
				ELSE
					CURSOR_PK1 <= NEXT_VAL1;
				END IF;
			END IF;
		END IF;
	END PROCESS;
	
	WITH P0_READY SELECT
		PK0_SELECTOR <= SELECTED_PK0 WHEN '1',
		                CURSOR_PK0   WHEN OTHERS;
	WITH P1_READY SELECT
		PK1_SELECTOR <= SELECTED_PK1 WHEN '1',
		                CURSOR_PK1   WHEN OTHERS;
	




	
	PROCESS(CLK, RST)
	BEGIN
		IF (RST = '1') THEN
			CURRENT_ST      <= ST_SEL_P0;
			STATE_CONTROL   <= '0'      ;
			TURN_CONTROLLER <= '0'      ;
			P0_READY        <= '0'      ;
			P1_READY        <= '0'      ;
		ELSIF RISING_EDGE(CLK) THEN
			CASE CURRENT_ST IS
				
				WHEN ST_SEL_P0 =>
					STATE_CONTROL   <= '0';
					PK0_ENA         <= '1';
					PK1_ENA         <= '0';
					TURN_CONTROLLER <= '0';
					IF (SELECT_SIG = '1') THEN
						CURRENT_ST <= ST_WAIT_P0;
					END IF;
				WHEN ST_WAIT_P0 =>
					IF (SELECT_SIG = '0') THEN
						P0_READY        <= '1'       ;
						CURRENT_ST      <= ST_SEL_P1 ;
						SELECTED_PK0    <= CURSOR_PK0;
					END IF;
				WHEN ST_SEL_P1 =>
					PK0_ENA         <= '0';
					PK1_ENA         <= '1';
					TURN_CONTROLLER <= '1';
					IF (SELECT_SIG = '1') THEN
						CURRENT_ST <= ST_WAIT_P1;
					END IF;
				WHEN ST_WAIT_P1 =>
					IF (SELECT_SIG = '0') THEN
						P1_READY     <= '1'       ;
						CURRENT_ST   <= ST_BATTLE ;
						SELECTED_PK1 <= CURSOR_PK1;
					END IF;
				WHEN ST_BATTLE =>
					PK0_ENA <= '1';
					PK1_ENA <= '1';
					STATE_CONTROL <= '1';
				WHEN OTHERS =>
					CURRENT_ST <= ST_SEL_P0;
				
			END CASE;
		END IF;
	END PROCESS;

END ARCHITECTURE functional;















