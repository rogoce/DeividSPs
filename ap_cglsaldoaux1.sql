-- Genera Cheque ACH -- Verificador antes de generar los ach
-- Creado    : 14/09/2018 - Autor: Amado Perez
-- SIS v.2.0 - DEIVID, S.A.	
-- execute procedure sp_che177('2',0)

DROP PROCEDURE ap_cglsaldoaux1;
CREATE PROCEDURE ap_cglsaldoaux1() 
RETURNING  integer;			

define _sld1_tipo   char(2);
define _sld1_cuenta char(12);
define _sld1_tercero char(5);
define _sld1_ano     char(4);
define _sld1_periodo smallint;
define _sld1_saldo   dec(15,2);


SET ISOLATION TO DIRTY READ;
--  set debug file to "sp_che117.trc";	
--  trace on;

	 foreach
		 select sld1_tipo, 
				sld1_cuenta, 
				sld1_tercero, 
				sld1_ano, 
				sld1_periodo,
				sld1_saldo
		   into _sld1_tipo, 
				_sld1_cuenta, 
				_sld1_tercero, 
				_sld1_ano, 
				_sld1_periodo,
				_sld1_saldo	 	
		   from tmp_cglaux1 
		  where seleccionado = 0
		   
		update cglsaldoaux1
           set sld1_saldo =	_sld1_saldo
         where sld1_tipo = _sld1_tipo
           and sld1_cuenta = _sld1_cuenta
           and sld1_tercero = _sld1_tercero
           and sld1_ano = _sld1_ano
           and sld1_periodo = _sld1_periodo;
		   		   
		update tmp_cglaux1
           set seleccionado = 1
         where sld1_tipo = _sld1_tipo
           and sld1_cuenta = _sld1_cuenta
           and sld1_tercero = _sld1_tercero
           and sld1_ano = _sld1_ano
           and sld1_periodo = _sld1_periodo;
		   
		  
		return  1  
				with resume;		
	end foreach			
 

END PROCEDURE	  