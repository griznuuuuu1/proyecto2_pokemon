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
		PK0_HIT_SIG     : OUT UINT01;
		PK1_HIT_SIG     : OUT UINT01;
		PK0_ENA         : OUT UINT01;
		PK1_ENA         : OUT UINT01;
		P0_READY_SIG    : OUT UINT01; --FEEDBACK VISUAL
		P1_READY_SIG    : OUT UINT01; --FEEDBACK VISUAL
		P0_HP_OUT       : OUT UINT08;
		P1_HP_OUT       : OUT UINT08
	);
END ENTITY battle_engine;
-----------------------------------------------------
ARCHITECTURE functional OF battle_engine IS

TYPE STATE_TYPE IS
(
	ST_SEL_P0   ,
	ST_WAIT_P0  ,
	ST_SEL_P1   ,
	ST_WAIT_P1  ,
	ST_TURN_P0  ,
	ST_BATTLE   ,
	ST_WAIT_T_P0,
	ST_TURN_P1  ,
	ST_WAIT_T_P1,
	ST_GAME_OVER
);

SIGNAL CURRENT_ST       : STATE_TYPE    ;
SIGNAL TURN_CONTROLLER  : UINT01 := '0' ;
SIGNAL P0_READY         : UINT01 := '0' ;
SIGNAL P1_READY         : UINT01 := '0' ;
SIGNAL SELECTED_PK0     : UINT04        ;
SIGNAL SELECTED_PK1     : UINT04        ;
SIGNAL CURSOR_POS0      : UINT04        ;
SIGNAL CURSOR_POS1      : UINT04        ;
SIGNAL NEXT_VAL0        : UINT04        ;
SIGNAL NEXT_VAL1        : UINT04        ;
SIGNAL CURSOR_PK0       : UINT04 := X"0"; 
SIGNAL CURSOR_PK1       : UINT04 := X"0";
SIGNAL UD_INPUT         : UINT02        ;
SIGNAL U_SIG            : UINT01        ; --SEÑAL DE FLANCO DE SUBIDA PARA UP_SIG
SIGNAL D_SIG            : UINT01        ; --SEÑAL DE FLANCO DE SUBIDA PARA DOWN_SIG
SIGNAL S_SIG            : UINT01        ; --SEÑAL DE FLANCO DE SUBIDA PARA SELECT_SIG
SIGNAL REG_U_SIG        : UINT01        ; --REGISTRO ANTERIOR PARA UP_SIG
SIGNAL REG_D_SIG        : UINT01        ; --REGISTRO ANTERIOR PARA DOWN_SIG
SIGNAL REG_S_SIG        : UINT01        ; --REGISTRO ANTERIOR PARA SELECT_SIG
SIGNAL UD0_SIG          : UINT04        ;
SIGNAL UD1_SIG          : UINT04        ;
SIGNAL RANDOM_NUMBER    : UINT04        ; --VARIABLES DEL JUEGO ↓↓↓
SIGNAL PLAYER_RAND_NUM  : UINT04 := X"6";
SIGNAL MISS_ATK         : UINT01        ;
SIGNAL CRIT_FLAG        : UINT01        ;
SIGNAL P0_STATS         : PK_STAT       ;
SIGNAL P1_STATS         : PK_STAT       ;
SIGNAL P0_INITIAL_STATS : PK_STAT       ;
SIGNAL P1_INITIAL_STATS : PK_STAT       ;
SIGNAL CURSOR0_STATS    : PK_STAT       ;
SIGNAL CURSOR1_STATS    : PK_STAT       ;
SIGNAL P0_ATT_MOD       : UINT05        ;
SIGNAL P1_ATT_MOD       : UINT05        ;
SIGNAL DAMAGE_FINAL     : INTEGER RANGE 0 TO 63;
--RECUERDA QUE LA DEFINICION DE LAS ESTADISTICAS DE CADA POKEMON ESTA EN BASICK_PACKAGE.VHD !!!!!!!!!!!
--TYP => "000", "001", "010", "011", "100"
--         ↓      ↓      ↓      ↓      ↓
--        PLT    ELEC   AGUA   TERR   FGO
--
--PLT  > TERR, AGUA
--ELEC > PLT , AGUA
--AGUA > FGO , TERR
--TERR > ELEC, FGO
--FGO  > ELEC, PLT

BEGIN
	
	P0_HP_OUT       <= P0_STATS.HP    ;
	P1_HP_OUT       <= P1_STATS.HP    ;
	TURN_DEFINITION <= TURN_CONTROLLER;
	P0_READY_SIG    <= P0_READY       ;
	P1_READY_SIG    <= P1_READY       ;
	--UD INPUT LOGIC WAWAWAWAWAWAWAWAWAWAWAWAWAAWWAWA
	
	--DETECTOR DE FLANCOS DE SUBIDA PARA UP, DOWN Y SELECT_SIG
	PROCESS (CLK, RST)
	BEGIN
		IF (RST = '1') THEN 
			REG_U_SIG <= '0';
			REG_D_SIG <= '0';
			REG_S_SIG <= '0';
		ELSE
			IF RISING_EDGE(CLK) THEN
				REG_U_SIG <= UP_SIG    ;
				REG_D_SIG <= DOWN_SIG  ;
				REG_S_SIG <= SELECT_SIG;
			END IF;
		END IF;
	END PROCESS;
	U_SIG          <= UP_SIG     AND (NOT REG_U_SIG);
	D_SIG          <= DOWN_SIG   AND (NOT REG_D_SIG);
	S_SIG          <= SELECT_SIG AND (NOT REG_S_SIG);

	--LOGICA COMBINACIONAL PARA SUBIR O BAJAR EL CURSOR
	--DEPENDIENDO DE LA POSICION ANTERIOR Y LAS SEÑALES DE ENTRADA
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
	--CURSOR CICLICO PARA EVITAR SELECCIONAR POKEMONES QUE NO EXISTEN (10 AL 15)
	NEXT_VAL0 <= X"0" WHEN (UNSIGNED(CURSOR_POS0) > 9) ELSE CURSOR_POS0;
	NEXT_VAL1 <= X"0" WHEN (UNSIGNED(CURSOR_POS1) > 9) ELSE CURSOR_POS1;
	--EL CURSOR ES CILCICO DE UN SOLO SENTIDO YA QUE SI SE SUMA X"F" A X"0" SE
	--SOBREPASA DEL VALOR MAXIMO Y LO RETORNA A 0
	
	--PROCESS PARA GUARDAR LA POSICION DEL CURSOR DEPENDIENDO DE LA SUMA O "RESTA"
	--CALCULADA CON LOS FLANCOS DE LOS BOTONES. TAMBIEN CAMBIA SEGUN EL TURNO.
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
	
	--LOGICA COMBINACIONAL PARA FIJAR EL POKEMON Y ESTADISTICAS 
	--DESPUES DE HABER SELECCIONADO EL POKEMON PARA LA BATALLA
	WITH P0_READY SELECT
		PK0_SELECTOR <= SELECTED_PK0  WHEN '1',
		                CURSOR_PK0    WHEN OTHERS;
	
	WITH P1_READY SELECT
		PK1_SELECTOR <= SELECTED_PK1  WHEN '1',
		                CURSOR_PK1    WHEN OTHERS;
	
	WITH SELECTED_PK0 SELECT
		P0_INITIAL_STATS <= LEAF_STAT WHEN X"0"  ,
		                    ZERA_STAT WHEN X"1"  ,
		                    VAPO_STAT WHEN X"2"  ,
		                    SAND_STAT WHEN X"3"  ,
		                    ODDI_STAT WHEN X"4"  ,
		                    LAPR_STAT WHEN X"5"  ,
		                    JOLT_STAT WHEN X"6"  ,
		                    GARC_STAT WHEN X"7"  ,
		                    FLAR_STAT WHEN X"8"  ,
		                    CHAR_STAT WHEN X"9"  ,
		                    NOPK_STAT WHEN OTHERS;
	
	WITH SELECTED_PK1 SELECT
		P1_INITIAL_STATS <= LEAF_STAT WHEN X"0"  ,
		                    ZERA_STAT WHEN X"1"  ,
		                    VAPO_STAT WHEN X"2"  ,
		                    SAND_STAT WHEN X"3"  ,
		                    ODDI_STAT WHEN X"4"  ,
		                    LAPR_STAT WHEN X"5"  ,
		                    JOLT_STAT WHEN X"6"  ,
		                    GARC_STAT WHEN X"7"  ,
		                    FLAR_STAT WHEN X"8"  ,
		                    CHAR_STAT WHEN X"9"  ,
		                    NOPK_STAT WHEN OTHERS;

-- PROCESO COMBINACIONAL PARA CALCULAR EL DAÑO FINAL
	PROCESS(CURRENT_ST, P0_STATS, P1_STATS, CRIT_FLAG)
	VARIABLE BASE_ATK   : INTEGER;
	VARIABLE DEF_DEF    : INTEGER;
	VARIABLE ATK_TYP    : UINT03;
	VARIABLE DEF_TYP    : UINT03;
	VARIABLE DAMAGE_TMP : INTEGER;
	-- Constantes de tipos de tu dibujo
	CONSTANT TYP_PLT  : UINT03 := "000";
	CONSTANT TYP_ELEC : UINT03 := "001";
	CONSTANT TYP_AGUA : UINT03 := "010";
	CONSTANT TYP_TERR : UINT03 := "011";
	CONSTANT TYP_FGO  : UINT03 := "100";
	BEGIN
        -- 1. Identificar quién ataca y quién defiende según el turno de la FSM
        IF (CURRENT_ST = ST_TURN_P0 OR CURRENT_ST = ST_WAIT_T_P0) THEN
            BASE_ATK := Slv2Int(P0_STATS.ATT);
            DEF_DEF  := Slv2Int(P1_STATS.DEF);
            ATK_TYP  := P0_STATS.TYP;
            DEF_TYP  := P1_STATS.TYP;
        ELSE
            BASE_ATK := Slv2Int(P1_STATS.ATT);
            DEF_DEF  := Slv2Int(P0_STATS.DEF);
            ATK_TYP  := P1_STATS.TYP;
            DEF_TYP  := P0_STATS.TYP;
        END IF;

        -- 2. Aplicar el bono de +5 si hay ventaja de tipo (Tus 10 flechas)
        DAMAGE_TMP := BASE_ATK; -- Empezamos con el ataque base

        CASE ATK_TYP IS
            WHEN TYP_FGO =>
                IF (DEF_TYP = TYP_ELEC OR DEF_TYP = TYP_PLT) THEN DAMAGE_TMP := BASE_ATK + 5; END IF;
            WHEN TYP_ELEC =>
                IF (DEF_TYP = TYP_AGUA OR DEF_TYP = TYP_PLT) THEN DAMAGE_TMP := BASE_ATK + 5; END IF;
            WHEN TYP_AGUA =>
                IF (DEF_TYP = TYP_FGO OR DEF_TYP = TYP_TERR) THEN DAMAGE_TMP := BASE_ATK + 5; END IF;
            WHEN TYP_TERR =>
                IF (DEF_TYP = TYP_FGO OR DEF_TYP = TYP_ELEC) THEN DAMAGE_TMP := BASE_ATK + 5; END IF;
            WHEN TYP_PLT =>
                IF (DEF_TYP = TYP_AGUA OR DEF_TYP = TYP_TERR) THEN DAMAGE_TMP := BASE_ATK + 5; END IF;
            WHEN OTHERS =>
                DAMAGE_TMP := BASE_ATK;
        END CASE;

        -- 3. Si además es CRÍTICO, se multiplica todo ese daño por 2
        IF (CRIT_FLAG = '1') THEN
            DAMAGE_TMP := DAMAGE_TMP * 2;
        END IF;

        -- 4. Restarle la defensa del oponente (Daño Final = Ataque calculado - Defensa)
        -- Protegemos que el daño no sea negativo (si la defensa es mayor al ataque)
        IF (DAMAGE_TMP > DEF_DEF) THEN
            DAMAGE_FINAL <= DAMAGE_TMP - DEF_DEF;
        ELSE
            DAMAGE_FINAL <= 1; -- Daño mínimo de 1 para que los golpes siempre hagan algo
        END IF;

    END PROCESS;

	--CONTADOR PAAR NUMEROS ALEATORIOS
	RANDOM_COUNTER : ENTITY WORK.contador_uni
	GENERIC MAP
	(
		N => 4
	)
	PORT MAP
	(
		clk      => CLK          ,
		rst      => RST          ,
		ena      => '1'          ,
		syn_clr  => '0'          ,
		ini      => X"0"         ,
		up       => '1'          ,
		max      => X"F"         ,
		max_tick => OPEN         ,
		counter  => RANDOM_NUMBER
	);
	
	--PROCESS PARA GUARDAR LA INFORMACOIN DEL NUMERO ALEATORIO
	PROCESS(CLK, RST)
	BEGIN
		IF (RST = '1') THEN
			PLAYER_RAND_NUM <= X"6";
		ELSIF RISING_EDGE(CLK) THEN
			IF
			(
				S_SIG = '1' AND
				(
					CURRENT_ST = ST_TURN_P0 OR
					CURRENT_ST = ST_TURN_P1
				)
			)
			THEN
				PLAYER_RAND_NUM <= RANDOM_NUMBER;
			END IF;
		END IF;
	END PROCESS;
	--PROCESS PARA SABER SI EL GOLVE ES EFECTIVO Y SI HACE CRITICO O NO
	PROCESS(PLAYER_RAND_NUM)
	BEGIN
		IF PLAYER_RAND_NUM > Int2Slv(5, 4) THEN
			MISS_ATK <= '0';
			--IF PLAYER_RAND_NUM > Int2Slv(12, 4) THEN
			--END IF;
		ELSE
			MISS_ATK <= '1';
		END IF;
	END PROCESS;


	PROCESS(CLK, RST)
	BEGIN
		IF (RST = '1') THEN
			CURRENT_ST      <= ST_SEL_P0;
			STATE_CONTROL   <= '0'      ;
			TURN_CONTROLLER <= '0'      ;
			P0_READY        <= '0'      ;
			P1_READY        <= '0'      ;
			P0_STATS        <= NOPK_STAT;
			P1_STATS        <= NOPK_STAT;
		ELSIF RISING_EDGE(CLK) THEN
			CASE CURRENT_ST IS
				
				WHEN ST_SEL_P0 =>
					STATE_CONTROL   <= '0';
					PK0_ENA         <= '1';
					PK1_ENA         <= '0';
					TURN_CONTROLLER <= '0';
					PK0_HIT_SIG     <= '1';
					PK1_HIT_SIG     <= '1'; 
					IF (SELECT_SIG = '1') THEN
						CURRENT_ST <= ST_WAIT_P0;
					END IF;
				
				WHEN ST_WAIT_P0 =>
					IF (SELECT_SIG = '0') THEN
						P0_READY        <= '1'       ;
						CURRENT_ST      <= ST_SEL_P1 ;
						SELECTED_PK0    <= CURSOR_PK0;
						P0_STATS        <= P0_INITIAL_STATS;
					END IF;
				
				WHEN ST_SEL_P1 =>
					PK0_ENA         <= '0';
					PK1_ENA         <= '1';
					TURN_CONTROLLER <= '1';
					PK0_HIT_SIG     <= '1';
					PK1_HIT_SIG     <= '1';  ---------P1_HIT_SIG
					IF (S_SIG = '1') THEN
						CURRENT_ST <= ST_WAIT_P1;
					END IF;
				
				WHEN ST_WAIT_P1 =>
					IF (SELECT_SIG = '0') THEN
						P1_READY     <= '1'       ;
						CURRENT_ST   <= ST_BATTLE ;
						SELECTED_PK1 <= CURSOR_PK1;
						P1_STATS     <= P1_INITIAL_STATS;
					END IF;
				
				WHEN ST_BATTLE =>
					PK0_ENA       <= '1';
					PK1_ENA       <= '1';
					STATE_CONTROL <= '1';
					IF (S_SIG = '1') THEN
						CURRENT_ST    <= ST_TURN_P0;
					END IF;
				
				WHEN ST_TURN_P0 =>
					TURN_CONTROLLER <= '0';
					P0_READY        <= '1';
					P1_READY        <= '0';
					PK0_HIT_SIG     <= '1';
					PK1_HIT_SIG     <= '1';
					IF (S_SIG = '1') THEN
						IF(MISS_ATK = '0') THEN
							PK1_HIT_SIG <= '0'; --ANIMACION DE GOLPE
							P1_STATS.HP <= Int2Slv(Slv2Int(P1_STATS.HP) - DAMAGE_FINAL,8);
						ELSE
							PK1_HIT_SIG <= '1'; --GOLPE FALLO
						END IF;
						CURRENT_ST  <= ST_WAIT_T_P0;
					END IF;
				
				WHEN ST_WAIT_T_P0 =>
					PK0_HIT_SIG <= '1';
					IF (S_SIG = '1') THEN
						PK1_HIT_SIG <= '0';
						CURRENT_ST  <= ST_TURN_P1;
					END IF;
				
				WHEN ST_TURN_P1 =>
					TURN_CONTROLLER <= '1';
					P0_READY        <= '0';
					P1_READY        <= '1';
					PK0_HIT_SIG     <= '0';
					PK1_HIT_SIG     <= '1';
					IF (S_SIG = '1') THEN
						IF (MISS_ATK = '0') THEN
							PK0_HIT_SIG <= '0';
							P0_STATS.HP <= Int2Slv(Slv2Int(P0_STATS.HP) - DAMAGE_FINAL,8);
						ELSE
							PK0_HIT_SIG <= '1';
						END IF;
						CURRENT_ST <= ST_WAIT_T_P1;
					END IF;
				
				WHEN ST_WAIT_T_P1 =>
					PK1_HIT_SIG <= '1';
					IF (S_SIG = '1') THEN
						PK0_HIT_SIG <= '1';
						CURRENT_ST <= ST_TURN_P0;
					END IF;
				
				WHEN OTHERS =>
					CURRENT_ST <= ST_SEL_P0;
				
			END CASE;
		END IF;
	END PROCESS;

END ARCHITECTURE functional;















