--************************************************************************************************************************************
-- Procedimiento que genera Info. del detalle de facturas en vigencia 2023 de las polizas del bono de rentabilidad 2023***************
--************************************************************************************************************************************
-- Creado    : 06/02/2024 - Autor: Armando Moreno M.

DROP PROCEDURE sp_roman07;
CREATE PROCEDURE sp_roman07()
RETURNING char(20)      as poliza,
          date          as vig_ini_end,
		  date          as vig_fin_end,
		  date          as vig_ini_pol,
		  date          as vig_fin_pol,
		  char(3)       as cod_ramo,
          char(50)      as nombre_ramo,
		  char(3)       as cod_subramo,
		  char(50)      as nombre_subramo,
		  decimal(16,2) as prima_neta,
		  decimal(16,2) as prima_suscrita,
		  decimal(16,2) as prima_bruta,
		  char(10)      as no_factura;
		  
	  
DEFINE _no_poliza,_no_factura  CHAR(10);
DEFINE _no_documento    CHAR(20); 
DEFINE _cod_ramo        CHAR(3);  
DEFINE _nombre_ramo     CHAR(50);  
DEFINE _cod_subramo     CHAR(3);  
define _nombre_subramo	char(50);
define _prima_neta      dec(16,2);
define _prima_sus,_prima_bruta dec(16,2);
define _vig_inic_end,_vig_fin_end date;
define _vig_inic_pol,_vig_final_pol date;

--SET DEBUG FILE TO "sp_pro868a.trc";
--TRACE ON;

SET ISOLATION TO DIRTY READ;

let _prima_neta  = 0.00;
let _prima_sus   = 0.00;
let _prima_bruta = 0.00;

foreach
	select no_documento
	  into _no_documento
	  from rentabilidad1
	 where periodo = '2023-12'

	foreach
		select vigencia_inic,
		       vigencia_final,
			   vigencia_inic_pol,
			   vigencia_final_pol,
			   no_poliza,
			   prima_neta,
			   prima_suscrita,
			   prima_bruta,
			   no_factura
		  into _vig_inic_end,
               _vig_fin_end,
               _vig_inic_pol,
               _vig_final_pol,
               _no_poliza,
               _prima_neta,
			   _prima_sus,
			   _prima_bruta,
			   _no_factura
		  from endedmae
         where actualizado = 1
		   and no_documento = _no_documento
           and (vigencia_inic < '01/01/2023'
		   and vigencia_final  >= '01/01/2023'  -- esto es para lo que se emitió antes de 2023
            or vigencia_inic <= '31/12/2023'
		   and vigencia_final >= '31/12/2023'  --esto es para lo que se vence despues de 2023
            or vigencia_inic >= '01/01/2023'
		   and vigencia_final <= '31/12/2023')  --todo lo que nace y vence en 2023

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
			   
	   
		Return _no_documento, _vig_inic_end,_vig_fin_end,_vig_inic_pol,_vig_final_pol,_cod_ramo, _nombre_ramo, _cod_subramo, _nombre_subramo, 
		       _prima_neta, _prima_sus,_prima_bruta,_no_factura  with resume;
	end foreach
end foreach
END PROCEDURE;