-- Creado    : 11/03/2008 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 11/03/2008 - Autor: Demetrio Hurtado Almanza

--DROP PROCEDURE sp_che108f;
CREATE PROCEDURE sp_che108f(a_compania CHAR(3), a_cod_agente CHAR(255) default '*', a_periodo char(7), a_periodo2 char(7)) 
RETURNING CHAR(20),	    -- no_documento 
		  CHAR(50),	    -- nombre_agente
		  DEC(16,2),    -- monto
		  VARCHAR(100),	-- nombre_cliente
		  CHAR(7);

DEFINE _tipo          	 CHAR(1);
DEFINE v_cod_agente   	 CHAR(5);  
DEFINE v_no_poliza    	 CHAR(10); 
DEFINE v_monto        	 DEC(16,2);
DEFINE v_no_recibo    	 CHAR(10); 
DEFINE v_fecha        	 DATE;     
DEFINE v_prima        	 DEC(16,2);
DEFINE v_porc_comis   	 DEC(5,2); 
DEFINE v_comision     	 DEC(16,2);
DEFINE v_nombre_clte  	 CHAR(100);
DEFINE v_no_documento 	 CHAR(20);
DEFINE v_nombre_agt   	 CHAR(50);
DEFINE v_nombre_cia   	 CHAR(50);
DEFINE _fecha_comis   	 DATE;
define _moro_045      	 DEC(16,2); 
define _moro_4690	  	 DEC(16,2);
define _porc_045	  	 DEC(5,2);
define _porc_4690	  	 DEC(5,2);
define _porc_partic   	 DEC(5,2);
define _045           	 DEC(16,2);
define _4690		  	 DEC(16,2);
define _91			  	 DEC(16,2);
define _pol_corr	  	 DEC(16,2);
define _pol_0045	  	 DEC(16,2);
define _pol_4690	  	 DEC(16,2);
define _comision2	  	 DEC(16,2);
define _comision1	  	 DEC(16,2);
define _estatus_licencia CHAR(1);
define _no_poliza     	 CHAR(10);
define _cod_cliente   	 CHAR(10);
define _bandera	      	 Smallint;
define _periodo          char(7);

--SET DEBUG FILE TO "\\sp_che83.trc";
--TRACE ON;

-- Nombre de la Compania
SET ISOLATION TO DIRTY READ;

LET  v_nombre_cia = sp_sis01(a_compania); 

SET ISOLATION TO DIRTY READ;

let	_pol_corr     = 0;
let	_pol_0045     = 0;
let	_pol_4690     = 0;
let _comision1    = 0;
let _comision2    = 0;
let _bandera      = 0;
let v_no_documento = "";
let	v_nombre_agt   = "";
let	v_monto        = "";
let	v_nombre_clte  = "";
let _periodo       = "";

IF a_cod_agente = "*" THEN -- Solo un agente
else
	LET _tipo = sp_sis04(a_cod_agente);  -- Separa los Valores del String
	IF _tipo <> "E" THEN    -- Solo Incluir un Agente
		FOREACH
		 SELECT	cod_agente,
		 		no_documento,
				prima_cobrada,
				periodo
		   INTO	v_cod_agente,
		   		v_no_documento,
				v_monto,
				_periodo
		   FROM	chqbonoc
		  WHERE cod_agente IN (SELECT codigo FROM tmp_codigos)   -- matches a_cod_agente 
			and periodo    >= a_periodo
			and periodo    <= a_periodo2

			let _no_poliza = sp_sis21(v_no_documento);

			select cod_contratante
			  into _cod_cliente
			  from emipomae
			 where no_poliza = _no_poliza;

			select nombre
			  into v_nombre_clte
			  from cliclien
			 where cod_cliente = _cod_cliente;
			
			SELECT nombre
			  INTO v_nombre_agt
			  FROM agtagent
			 WHERE cod_agente = v_cod_agente;

			RETURN v_no_documento, 
				   v_nombre_agt,	
				   v_monto,	
				   v_nombre_clte	
				   WITH RESUME;	
			
		END FOREACH
		LET _bandera  = 1;
		DROP TABLE tmp_codigos;
	END IF
END IF

if _bandera = 0 then 
	RETURN  v_no_documento,
			v_nombre_agt,
			v_monto,
			v_nombre_clte,
			_periodo
			WITH RESUME;
end if

END PROCEDURE;	 