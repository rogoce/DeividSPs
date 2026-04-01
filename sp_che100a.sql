-- Reporte de los Bonificacion de Rentabilidad  - TOTALES X RAMO

-- Creado    : 16/02/2009 - Autor: Henry Giron
-- Modificado: 16/02/2009 - Autor: Henry Giron


DROP PROCEDURE sp_che100a;

CREATE PROCEDURE sp_che100a(a_compania CHAR(3), a_cod_agente CHAR(5) default '*', a_periodo char(7), a_requis smallint) 
  RETURNING CHAR(20),	-- Poliza	  
			CHAR(100),	-- Asegurado  
			DEC(16,2),	-- Monto	  
			DEC(16,2),	-- Prima	  
			DEC(16,2),	-- Comision	   
			CHAR(50),  
			CHAR(50),  			   
			DEC(16,2),  			   
			DEC(16,2), 	   
			DEC(16,2),  	   
			DEC(16,2), 	   
			DEC(16,2), 	   
			DEC(16,2), 	   
			DEC(16,2), 	   
			DEC(16,2), 	   
			DEC(16,2),
			DEC(16,2),
			DEC(16,2),
			CHAR(3),
			DEC(16,2),
			CHAR(50),
			CHAR(3),
			CHAR(50),
			DEC(16,2),
			DEC(16,2),
			DEC(16,2);


DEFINE _tipo          CHAR(1);
DEFINE v_cod_agente   CHAR(5);  
DEFINE v_no_poliza    CHAR(10); 
DEFINE v_monto        DEC(16,2);
DEFINE v_no_recibo    CHAR(10); 
DEFINE v_fecha        DATE;     
DEFINE v_prima        DEC(16,2);
DEFINE v_porc_comis   DEC(16,2); 
DEFINE v_porc_cre	  DEC(16,2); 
DEFINE v_porc_sin	  DEC(16,2); 
DEFINE v_comision     DEC(16,2);
DEFINE v_nombre_clte  CHAR(100);
DEFINE v_no_documento CHAR(20);
DEFINE v_nombre_agt   CHAR(50);
DEFINE v_nombre_cia   CHAR(50);
DEFINE _fecha_comis   DATE;
define _porc_persis   DEC(16,2);
define _porcentaje    DEC(16,2);
define _estatus_licencia char(1);
define _cod_ramo	  char(3);
define _prima_ap      DEC(16,2);
define _nombre_ramo   CHAR(50);

define  _cod_ramo1    char(3);
define  _nombre_ramo1 CHAR(50);
define  _prima_ap1    DEC(16,2);
define  _prima_neta1  DEC(16,2);
define  _comision1    DEC(16,2);
define  _sini_g       DEC(16,2);
define  _sini         DEC(16,2);   

define _incremento_psp  dec(16,2);
define _crecimiento     dec(16,2);
define _siniestralidad  dec(16,2);
define s_requis         char(1);

--SET DEBUG FILE TO "che100.trc";
--TRACE ON;

-- Nombre de la Compania
SET ISOLATION TO DIRTY READ;

LET  v_nombre_cia = sp_sis01(a_compania); 
if a_requis = 0 then
	let s_requis = "*";
end if
if a_requis = 1 then
	let s_requis = "A";
end if
if a_requis = 2 then
	let s_requis = "C";
end if

SET ISOLATION TO DIRTY READ;

FOREACH
  SELECT cod_agente,
		 nombre,
  		 sum(prima_ap),
		 sum(prima_neta),
		 sum(comision),
    	 sum(sini)
    into v_cod_agente,
		 v_nombre_agt,
		 _prima_ap1,
		 _prima_neta1,
		 _comision1,
		 _sini_g
    FROM chqrenta5
   WHERE cod_agente  matches a_cod_agente
	 and periodo     = a_periodo   
group by cod_agente,nombre

        let _incremento_psp       = 0;
		let _crecimiento          = 0;
		let _siniestralidad       = 0; 			
	
		--************************************************
		--   Calculos para incremeto de PSP 2008 vs 2007
		--************************************************
		let _incremento_psp  = _prima_neta1 - _prima_ap1 ;				
	
		--************************************************
		--   Calculos % de crecimiento de PSP
		--************************************************
		if _prima_ap1 <> 0 then
			let _crecimiento = ((_prima_neta1 - _prima_ap1) / _prima_ap1) * 100;
		end if
	
		if _crecimiento = 0 then
			let _crecimiento = 100;
		end if
		
		--************************************************
		--    Calculos % de siniestralidad 2008	
		--************************************************
		let _siniestralidad = 0;
		if _prima_neta1 <> 0 then
			let _siniestralidad = (_sini_g / _prima_neta1) * 100;
 		end if							


	
	RETURN  '',
			'',
			_siniestralidad,
			_crecimiento,
			_sini_g,
			v_nombre_agt,
			v_nombre_cia,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
            0,
            0,
			'',
		    0,
		    '',
			'',
			'',
			_prima_ap1,
			_prima_neta1,
			_comision1
			WITH RESUME;
	
END FOREACH
END PROCEDURE;