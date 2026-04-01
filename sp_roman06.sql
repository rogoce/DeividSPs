--*******************************************************************************************************
-- Procedimiento que genera Info. para verifi. de la prima neta cobrada devengada de rentabilidad 2023***
--*******************************************************************************************************
-- Creado    : 06/02/2024 - Autor: Armando Moreno M.

DROP PROCEDURE sp_roman06;
CREATE PROCEDURE sp_roman06(a_compania CHAR(3),a_sucursal CHAR(3),a_periodo char(7), a_periodo2 char(7))
RETURNING char(20)      as poliza,
          char(3)       as cod_ramo,
          char(50)      as nombre_ramo,
		  char(3)       as cod_subramo,
		  char(50)      as nombre_subramo,
		  decimal(16,2) as prima_neta,
		  decimal(16,2) as monto_cobrado;
		  
DEFINE _no_poliza       CHAR(10);
DEFINE _no_documento    CHAR(20); 
DEFINE _cod_ramo        CHAR(3);  
DEFINE _nombre_ramo     CHAR(50);  
DEFINE _cod_subramo     CHAR(3);  
define _nombre_subramo	char(50);
define _prima_neta,_monto      dec(16,2);

--SET DEBUG FILE TO "sp_pro868a.trc";
--TRACE ON;

SET ISOLATION TO DIRTY READ;

let _prima_neta = 0.00;
let _monto      = 0.00;

foreach
	select no_documento
	  into _no_documento
	  from rentabilidad1
	 where periodo = '2023-12'

	select sum(prima_neta),sum(monto)
	  into _prima_neta,_monto
	  from cobredet
	 where periodo     >= a_periodo
	   and periodo     <= a_periodo2
	   and actualizado = 1
	   and tipo_mov    in ("P", "N")
	   and doc_remesa = _no_documento;
	   
	if _prima_neta is null then
		continue foreach;
	end if
	let _no_poliza = sp_sis21(_no_documento);   

	select cod_ramo,
		   cod_subramo
	  into _cod_ramo,
		   _cod_subramo
	  from emipomae
	 where no_poliza = _no_poliza;
		 
	select nombre
	  into _nombre_ramo
	  from prdramo
	 where cod_ramo = _cod_ramo;
	 
	select nombre
	  into _nombre_subramo
	  from prdsubra
	 where cod_ramo    = _cod_ramo
	   and cod_subramo = _cod_subramo;
	   
	Return _no_documento, _cod_ramo, _nombre_ramo, _cod_subramo, _nombre_subramo, _prima_neta, _monto  with resume;
				 
end foreach

END PROCEDURE;