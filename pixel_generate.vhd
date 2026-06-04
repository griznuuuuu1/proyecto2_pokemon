LIBRARY IEEE               ;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL   ;
------------------------------------
USE WORK.basic_package.ALL ;
USE WORK.VGA_package.ALL   ;
-----------------------------------------------------
ENTITY pixel_generate IS
	PORT
	(
		CLK           : IN  UINT01  ;
		SPRITE0_POS_X : IN  UINT11  ;                --POSICION DE ESCANEO DEL PK0
		SPRITE0_POS_Y : IN  UINT11  ;                --POSICION DE ESCANEO DEL PK0
		SPRITE1_POS_X : IN  UINT11  ;                --POSICION DE ESCANEO DEL PK1
		SPRITE1_POS_Y : IN  UINT11  ;                --POSICION DE ESCANEO DEL PK1
		POS_X         : IN  UINT11  ;                --POSICION DE ESCANEO DE PANTALLA
		POS_Y         : IN  UINT11  ;                --POSICION DE ESCANEO DE PANTALLA
		STATE_CONTR   : IN  UINT01  ;
		TURN_DEF      : IN  UINT01  ;
		PK0_SELECTOR  : IN  UINT04  ;
		PK1_SELECTOR  : IN  UINT04  ;
		POKEMON0_ENA  : IN  UINT01  ;
		POKEMON1_ENA  : IN  UINT01  ;
		VIDEO_ON      : IN  UINT01  ;
		P0_HP         : IN  UINT08  ;
		P1_HP         : IN  UINT08  ;
		R             : OUT UINT08  ;
		G             : OUT UINT08  ;
		B             : OUT UINT08  
	);
END ENTITY pixel_generate;
-----------------------------------------------------
ARCHITECTURE main OF pixel_generate IS
CONSTANT MENU_P0_X                : INTEGER := 40 ;
CONSTANT MENU_P0_Y                : INTEGER := 100;
CONSTANT MENU_P1_X                : INTEGER := 480;
CONSTANT MENU_P1_Y                : INTEGER := 100;

SIGNAL MENU_X0, MENU_Y0           : INTEGER;
SIGNAL MENU_X1, MENU_Y1           : INTEGER;
SIGNAL MENU_X0_REG, MENU_Y0_REG   : INTEGER;
SIGNAL MENU_X1_REG, MENU_Y1_REG   : INTEGER;
SIGNAL MENU_X0_REG2, MENU_Y0_REG2 : INTEGER;
SIGNAL MENU_X1_REG2, MENU_Y1_REG2 : INTEGER;

SIGNAL INT_POS_X                  : INTEGER;
SIGNAL INT_POS_Y                  : INTEGER;
SIGNAL X_REG    , Y_REG           : INTEGER;

SIGNAL LOCAL_X_PK0     , LOCAL_Y_PK0      : INTEGER;
SIGNAL LOCAL_X_PK1     , LOCAL_Y_PK1      : INTEGER;
SIGNAL LOCAL_X_REG_PK0 , LOCAL_Y_REG_PK0  : INTEGER;
SIGNAL LOCAL_X_REG_PK1 , LOCAL_Y_REG_PK1  : INTEGER;
SIGNAL LOCAL_X_REG2_PK0, LOCAL_Y_REG2_PK0 : INTEGER;
SIGNAL LOCAL_X_REG2_PK1, LOCAL_Y_REG2_PK1 : INTEGER;
SIGNAL LOCAL_X_REG3_PK0, LOCAL_Y_REG3_PK0 : INTEGER;
SIGNAL LOCAL_X_REG3_PK1, LOCAL_Y_REG3_PK1 : INTEGER;

SIGNAL ADDR_INT_PK0, ADDR_INT_PK1         : INTEGER RANGE 0 TO 4095 := 0 ;
SIGNAL PIXEL_PK0, PIXEL_PK1, PIXEL_BG     : UINT16                       ;

SIGNAL ADDR_INT_MENU                      : INTEGER RANGE 0 TO 32767 := 0;
SIGNAL ADDR_SLV_MENU                      : UINT15                       ;
SIGNAL PIXEL_MENU                         : UINT16                       ;

SIGNAL BG_X : INTEGER RANGE 0 TO 159              ;
SIGNAL BG_Y : INTEGER RANGE 0 TO 119              ;
SIGNAL ADDR_INT_BG : INTEGER RANGE 0 TO 19199 := 0;
SIGNAL ADDR_SLV_BG : UINT15                       ;

SIGNAL S_POS_X  : INTEGER           ;
SIGNAL S_POS_Y  : INTEGER           ;
SIGNAL PK1_X    : INTEGER           ;  --DEJA ESTOS 2 COMO SEÑALES PARA MAS ADELANTE
SIGNAL PK1_Y    : INTEGER           ;  --PARA MANIPULAR SU POSICION EN EL MOVE_CONT

SIGNAL PK0_VISIBLE, PK1_VISIBLE : UINT01     ;
SIGNAL MENU0_VISIBLE, MENU1_VISIBLE       : UINT01;
SIGNAL CURSOR0_ON, CURSOR1_ON             : UINT01;

SIGNAL BAR0_VISIBLE : UINT01 := '0';
SIGNAL BAR1_VISIBLE : UINT01 := '0';
SIGNAL P0_HP_INT    : INTEGER      ;
SIGNAL P1_HP_INT    : INTEGER      ;

SIGNAL TRIANGLE_X_BASE : INTEGER;
SIGNAL TRIANGLE_Y_BASE : INTEGER;
SIGNAL LOCAL_X_TRI     : INTEGER;
SIGNAL LOCAL_Y_TRI     : INTEGER;
SIGNAL TRIANGLE_ON     : UINT01;

SIGNAL STATE_CONTR_INT_N : INTEGER;

BEGIN --/////////////////////////////////////////////////////////////////////////////
	
	P0_HP_INT <= Slv2Int(P0_HP);
	P1_HP_INT <= Slv2Int(P1_HP);
	STATE_CONTR_INT_N <= 1 WHEN (STATE_CONTR = '0') ELSE 0;
	
	S_POS_X        <= Slv2Int(SPRITE0_POS_X); --POS DE PK0
	S_POS_Y        <= Slv2Int(SPRITE0_POS_Y); --POS DE PK0
	PK1_X          <= Slv2Int(SPRITE1_POS_X); --POS DE PK1
	PK1_Y          <= Slv2Int(SPRITE1_POS_Y); --POS DE PK1
	INT_POS_X      <= Slv2Int(POS_X)              ;
	INT_POS_Y      <= Slv2Int(POS_Y)              ;
	ADDR_SLV_BG    <= Int2Slv(ADDR_INT_BG, 15)    ;
	ADDR_SLV_MENU  <= Int2Slv(ADDR_INT_MENU, 15)  ;

	PK_SEL : ENTITY WORK.pokemon_sel
	PORT MAP
	(
		CLK       => CLK         ,
		PK0_SEL   => PK0_SELECTOR,
		PK1_SEL   => PK1_SELECTOR,
		ADDR_PK0  => ADDR_INT_PK0,
		ADDR_PK1  => ADDR_INT_PK1,
		PIXEL_PK0 => PIXEL_PK0   ,
		PIXEL_PK1 => PIXEL_PK1
	);
	
	BACKGROUND_SP : ENTITY WORK.BACKGROUND_ROM
	PORT MAP
	(
		address => ADDR_SLV_BG,
		clock   => CLK        ,
		q       => PIXEL_BG
	);
	
	TILES_ROM : ENTITY WORK.NAMES_ROM
	PORT MAP
	(
		address => ADDR_SLV_MENU,
		clock   => CLK          ,
		q       => PIXEL_MENU
	);
	
	PROCESS(CLK) --process para el pipeline (desface de 1 ciclo de reloj)
	VARIABLE X_VEC     : UINT11;
	VARIABLE Y_VEC     : UINT11;
	VARIABLE X_SCALED  : UNSIGNED(10 DOWNTO 0);
	VARIABLE Y_SCALED  : UNSIGNED(10 DOWNTO 0);
	VARIABLE ADDR_CALC : UNSIGNED(21 DOWNTO 0);
	BEGIN
		IF RISING_EDGE(CLK) THEN
			--capa1
			X_REG        <= INT_POS_X           ;
			Y_REG        <= INT_POS_Y           ;
			
			--capa2
			LOCAL_X_PK0      <= X_REG - S_POS_X; --POS DE LEAFEON
			LOCAL_Y_PK0      <= Y_REG - S_POS_Y; --POS DE LEAFEON
			LOCAL_X_PK1      <= X_REG - PK1_X ;
			LOCAL_Y_PK1      <= Y_REG - PK1_Y ;
			MENU_X0          <= X_REG - MENU_P0_X;
			MENU_Y0          <= Y_REG - MENU_P0_Y;
			MENU_X1          <= X_REG - MENU_P1_X;
			MENU_Y1          <= Y_REG - MENU_P1_Y;
			BG_X             <= X_REG / 5; 
			BG_Y             <= Y_REG / 5;
			LOCAL_X_TRI <= X_REG - TRIANGLE_X_BASE;
			LOCAL_Y_TRI <= Y_REG - TRIANGLE_Y_BASE;
			
			--capa3
			LOCAL_X_REG_PK0  <= LOCAL_X_PK0   ;
			LOCAL_Y_REG_PK0  <= LOCAL_Y_PK0   ;
			LOCAL_X_REG_PK1  <= LOCAL_X_PK1   ;
			LOCAL_Y_REG_PK1  <= LOCAL_Y_PK1   ;
			MENU_X0_REG      <= MENU_X0;
			MENU_Y0_REG      <= MENU_Y0;
			MENU_X1_REG      <= MENU_X1;
			MENU_Y1_REG      <= MENU_Y1;
			
			IF  (BG_X >=   0) AND
			    (BG_X <  160) AND
			    (BG_Y >=   0) AND
			    (BG_Y <  120) THEN
				ADDR_INT_BG <= BG_Y * 160 + BG_X;
			ELSE
				ADDR_INT_BG <= 0;
			END IF;
			
			--capa4
			IF  (LOCAL_X_REG_PK0 >=   0) AND
			    (LOCAL_X_REG_PK0 <  128) AND  --IF DE LEAF
			    (LOCAL_Y_REG_PK0 >=   0) AND
			    (LOCAL_Y_REG_PK0 <  128) THEN
				
				ADDR_INT_PK0 <= (LOCAL_Y_REG_PK0 / 2) * 64 + (LOCAL_X_REG_PK0 / 2);
			END IF;
			IF  (LOCAL_X_REG_PK1 >=   0) AND
			    (LOCAL_X_REG_PK1 <  128) AND  --IF DE ZERA
			    (LOCAL_Y_REG_PK1 >=   0) AND
			    (LOCAL_Y_REG_PK1 <  128) THEN
				
				ADDR_INT_PK1 <= (LOCAL_Y_REG_PK1 / 2) * 64 + (LOCAL_X_REG_PK1 / 2);
			END IF;
			
			IF (MENU_X0_REG >= 0) AND (MENU_X0_REG < 512) AND 
			   (MENU_Y0_REG >= 0) AND (MENU_Y0_REG < 704) THEN
				
				X_VEC := STD_LOGIC_VECTOR(TO_UNSIGNED(MENU_X0_REG, 11));
				Y_VEC := STD_LOGIC_VECTOR(TO_UNSIGNED(MENU_Y0_REG, 11));
				
				X_SCALED := UNSIGNED("00" & X_VEC(10 DOWNTO 2));
				Y_SCALED := UNSIGNED("00" & Y_VEC(10 DOWNTO 2));
				
				ADDR_CALC     := (Y_SCALED * 128) + X_SCALED;
				ADDR_INT_MENU <= TO_INTEGER(ADDR_CALC);
				
			ELSIF (MENU_X1_REG >= 0) AND (MENU_X1_REG < 512) AND 
			      (MENU_Y1_REG >= 0) AND (MENU_Y1_REG < 704) THEN
				
				X_VEC := STD_LOGIC_VECTOR(TO_UNSIGNED(MENU_X1_REG, 11));
				Y_VEC := STD_LOGIC_VECTOR(TO_UNSIGNED(MENU_Y1_REG, 11));
				
				X_SCALED := UNSIGNED("00" & X_VEC(10 DOWNTO 2));
				Y_SCALED := UNSIGNED("00" & Y_VEC(10 DOWNTO 2));
				
				ADDR_CALC     := (Y_SCALED * 128) + X_SCALED;
				ADDR_INT_MENU <= TO_INTEGER(ADDR_CALC);
			ELSE
				ADDR_INT_MENU <= 0;
			END IF;
			
			
			--pinche capa6 DDDDDDDDDDDDDDD'>
			LOCAL_X_REG2_PK0 <= LOCAL_X_REG_PK0;
			LOCAL_Y_REG2_PK0 <= LOCAL_Y_REG_PK0;
			LOCAL_X_REG2_PK1 <= LOCAL_X_REG_PK1;
			LOCAL_Y_REG2_PK1 <= LOCAL_Y_REG_PK1;
			
			MENU_X0_REG2     <= MENU_X0_REG;
			MENU_Y0_REG2     <= MENU_Y0_REG;
			MENU_X1_REG2     <= MENU_X1_REG;
			MENU_Y1_REG2     <= MENU_Y1_REG;
			
			--capa7
			
		END IF;
	END PROCESS;
	
	CURSOR0_ON <= '1' WHEN (MENU_Y0_REG2 >= (Slv2Int(PK0_SELECTOR) * 64) AND 
	                        MENU_Y0_REG2 <  (Slv2Int(PK0_SELECTOR) * 64) + 64) ELSE '0';
	
	CURSOR1_ON <= '1' WHEN (MENU_Y1_REG2 >= (Slv2Int(PK1_SELECTOR) * 64) AND 
	                        MENU_Y1_REG2 <  (Slv2Int(PK1_SELECTOR) * 64) + 64) ELSE '0';
	
	MENU0_VISIBLE <= '1' WHEN (MENU_X0_REG2 >= 0 AND MENU_X0_REG2 < 512  AND 
	                           MENU_Y0_REG2 >= 0 AND MENU_Y0_REG2 < 704  AND
	                           (STATE_CONTR_INT_N = 1)) ELSE '0';
	
	MENU1_VISIBLE <= '1' WHEN (MENU_X1_REG2 >= 0 AND MENU_X1_REG2 < 512  AND 
	                           MENU_Y1_REG2 >= 0 AND MENU_Y1_REG2 < 704  AND
	                           (STATE_CONTR_INT_N = 1)) ELSE '0';
	
	
	PK0_VISIBLE <= '1' WHEN (LOCAL_X_REG2_PK0 >= 0 AND LOCAL_X_REG2_PK0 < 128 AND
	                         LOCAL_Y_REG2_PK0 >= 0 AND LOCAL_Y_REG2_PK0 < 128 AND
	                         PIXEL_PK0 /= X"FFFF" AND POKEMON0_ENA = '1') ELSE '0';
	
	PK1_VISIBLE <= '1' WHEN (LOCAL_X_REG2_PK1 >= 0 AND LOCAL_X_REG2_PK1 < 128 AND
	                         LOCAL_Y_REG2_PK1 >= 0 AND LOCAL_Y_REG2_PK1 < 128 AND
	                         PIXEL_PK1 /= X"FFFF" AND POKEMON1_ENA = '1') ELSE '0';
	
	BAR0_VISIBLE <= '1' WHEN (X_REG >= 40 AND X_REG <(40 + P0_HP_INT) AND
	                          Y_REG >= 40 AND Y_REG < 52 AND POKEMON0_ENA = '1')
	                    ELSE '0';
	BAR1_VISIBLE <= '1' WHEN (X_REG >= 480 AND X_REG < (480 + P1_HP_INT) AND
	                          Y_REG >= 40  AND Y_REG < 52 AND POKEMON1_ENA = '1')
	                    ELSE '0';
	TRIANGLE_ON <= '1' WHEN (LOCAL_Y_TRI >= 0 AND LOCAL_Y_TRI < 16 AND
	                         LOCAL_X_TRI >= (-15 + LOCAL_Y_TRI)    AND 
	                         LOCAL_X_TRI <= (15 - LOCAL_Y_TRI)     AND
	                         VIDEO_ON = '1') ELSE '0';

	TRIANGLE_X_BASE <= (S_POS_X + 48) WHEN (STATE_CONTR = '0' AND TURN_DEF = '0') ELSE
	                   (PK1_X + 48)   WHEN (STATE_CONTR = '0' AND TURN_DEF = '1') ELSE
	                   (S_POS_X + 48) WHEN (STATE_CONTR = '1' AND TURN_DEF = '0') ELSE
	                   (PK1_X + 48);
	
	TRIANGLE_Y_BASE <= (S_POS_Y - 46) WHEN (STATE_CONTR = '0' AND TURN_DEF = '0') ELSE
	                   (PK1_Y - 46) WHEN (STATE_CONTR = '0' AND TURN_DEF = '1') ELSE
	                   (S_POS_Y - 46) WHEN (STATE_CONTR = '1' AND TURN_DEF = '0') ELSE
	                   (PK1_Y - 46);



PROCESS(CLK)
	BEGIN
		IF(RISING_EDGE(CLK)) THEN                            --RGB565!!!
			R        <= X"00";
			G        <= X"00";
			B        <= X"00";
			IF (VIDEO_ON = '1') THEN
				R <= PIXEL_BG(15 DOWNTO 11) & "000";
				G <= PIXEL_BG(10 DOWNTO  5) &  "00";
				B <= PIXEL_BG( 4 DOWNTO  0) & "000";
				IF (TRIANGLE_ON = '1') THEN
					R <= X"FF";
					G <= X"D7";
					B <= X"00";
				END IF;
				IF (POKEMON0_ENA = '0' AND MENU0_VISIBLE = '1' AND
				    PIXEL_MENU /= X"FFFF" AND PIXEL_MENU /= X"0000") THEN
					IF (CURSOR0_ON = '1') THEN
						R <= X"20"; 
						G <= X"20";
						B <= X"FF";
					ELSE
						R <= PIXEL_MENU(15 DOWNTO 11) & "000";
						G <= PIXEL_MENU(10 DOWNTO  5) &  "00";
						B <= PIXEL_MENU( 4 DOWNTO  0) & "000";
					END IF;
				ELSIF (POKEMON1_ENA = '0' AND MENU1_VISIBLE = '1' AND
				       PIXEL_MENU /= X"FFFF" AND PIXEL_MENU /= X"0000") THEN
					IF (CURSOR1_ON = '1') THEN
						R <= X"20"; 
						G <= X"20";
						B <= X"FF";
					ELSE
						R <= PIXEL_MENU(15 DOWNTO 11) & "000";
						G <= PIXEL_MENU(10 DOWNTO  5) &  "00";
						B <= PIXEL_MENU( 4 DOWNTO  0) & "000";
					END IF;
				END IF;

				IF (BAR0_VISIBLE = '1') THEN
					IF (P0_HP_INT > 35) THEN
						R <= X"20";
						G <= X"FF";
						B <= X"20";
					ELSE
						R <= X"FF";
						G <= X"20";
						B <= X"20";
					END IF;
				ELSIF (BAR1_VISIBLE = '1') THEN
					IF (P1_HP_INT > 35 ) THEN
						R <= X"20";
						G <= X"FF";
						B <= X"20";
					ELSE
						R <= X"FF";
						G <= X"20";
						B <= X"20";
					END IF;
				END IF;

				IF (PK0_VISIBLE = '1') THEN
					R <= PIXEL_PK0(15 DOWNTO 11) & "000";
					G <= PIXEL_PK0(10 DOWNTO  5) &  "00";
					B <= PIXEL_PK0( 4 DOWNTO  0) & "000";
				ELSIF (PK1_VISIBLE = '1') THEN
					R <= PIXEL_PK1(15 DOWNTO 11) & "000";
					G <= PIXEL_PK1(10 DOWNTO  5) &  "00";
					B <= PIXEL_PK1( 4 DOWNTO  0) & "000";
				END IF;
			END IF;
		END IF;
	END PROCESS;
END ARCHITECTURE main;

