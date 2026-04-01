--DROP procedure sp_pro4960amm;
CREATE procedure sp_pro4960amm(a_cia CHAR(03),a_agencia CHAR(3),a_periodo CHAR(7), a_periodo2 CHAR(7), a_origen CHAR(3) DEFAULT '%')
RETURNING  date;

--------------------------------------------
---  APADEA
---  INFORMACION ESTADISTICA MENSUAL 
---  Armando Moreno M. 21/02/2002
---  Modificado: Amado Perez M. 12/03/2013 -- Se agrega el ramo 022 de equipo pesado a Ramos Tecnicos
---  Ref. Power Builder - d_sp_pro03b
-- execute procedure sp_pro4960('001','001','2016-06', '2016-06', '%')
--------------------------------------------
	define _no_poliza           CHAR(10);	
	define _fecha2     	        DATE;
	define _mes2,_ano2          SMALLINT;
	define _cod_ramo            CHAR(3);	
	define _no_documento        CHAR(20);
	define _total_pri_sus		DECIMAL(16,2);		
	define _suma_asegurada		DECIMAL(16,2);		
	define _orden               CHAR(3);	
	define _tipo_persona        CHAR(1);
    define _cod_contratante,_cod_cliente     CHAR(10);		
	define _descripcion         CHAR(100);	
	define _pn_cant_cli	        INTEGER;
	define _pn_cant_pol	        INTEGER;
	define _pj_cant_cli	        INTEGER;
	define _pj_cant_pol	        INTEGER;		
	define _prima_anual	        DECIMAL(16,2);
	define _prima_devuelta	    DECIMAL(16,2);		
	define _prima_cedida,_monto DECIMAL(16,2);
	define _cod_subramo         CHAR(3);	
	define _tiene_acreedor      SMALLINT;		
	define _cnt_polizas         INTEGER;
	define _cnt_contratante     INTEGER;	
    define _cod_subra_015       CHAR(3);	
    define _codigo              CHAR(3);	
	define _nombre              CHAR(100);	
    define _filtros             CHAR(255);	
	define _descr_cia	        CHAR(45);	
	define _renglon             SMALLINT;	
	define _linea               CHAR(8); 
	define _fronting            smallint;
	
--SET DEBUG FILE TO "sp_pro4960.trc"; 
--trace on;

		
SET ISOLATION TO DIRTY READ;
LET _cod_ramo        = NULL;
LET _descr_cia       = NULL;
LET _descr_cia = sp_sis01(a_cia);
LET _suma_asegurada = 0.00;
LET _prima_devuelta = 0.00;
LET _total_pri_sus = 0.00;
LET _prima_cedida = 0.00;
LET _cnt_contratante = 0;
LET _tiene_acreedor = 0;
LET _cnt_polizas = 0;
let _monto  = 0;
let _fronting = 0;

LET _ano2 = a_periodo2[1,4];
LET _mes2 = a_periodo2[6,7];

IF _mes2 = 12 THEN
   LET _mes2 = 1;
   LET _ano2 = _ano2 + 1;
ELSE
   LET _mes2 = _mes2 + 1;
END IF
LET _fecha2 = MDY(_mes2,1,_ano2);
LET _fecha2 = _fecha2 - 1;

return _fecha2; 

END PROCEDURE;