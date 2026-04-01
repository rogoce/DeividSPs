-- Genera Cheque ACH
-- Creado    : 27/09/2010 - Autor: Amado Perez
-- SIS v.2.0 - DEIVID, S.A.	
-- execute procedure sp_che117('2',0)

DROP PROCEDURE sp_che120;
CREATE PROCEDURE sp_che120(a_origen char(1), a_pagado  smallint) 
RETURNING  char(5),					--cod_agente		
		   decimal(16,2),			--monto			
		   char(30),				--cedula			
		   char(1),					--tipo_cuenta		
		   char(18),				--cod_cuenta		
		   integer,					--ruta_numero		
		   char(10),				--no_requis		
		   integer,					--pagado			
		   integer,					--no_cheque		
		   char(7),					--periodo			
		   date,					--fecha_impresion
		   char(50),				--e_mail 			
		   char(100);				--a_nombre_de		

DEFINE 	_cod_agente		    char(5);
DEFINE 	_monto			    decimal(16,2);
DEFINE 	_cedula			    char(30);
DEFINE 	_tipo_cuenta		char(1);
DEFINE 	_cod_cuenta		    char(18);
DEFINE 	_ruta_numero		integer;
DEFINE 	_no_requis		    char(10);
DEFINE 	_pagado			    integer;
DEFINE 	_no_cheque		    integer;
DEFINE 	_periodo			char(7);
DEFINE 	_fecha_impresion	date;
DEFINE 	_e_mail 			char(50);
DEFINE 	_a_nombre_de		char(100);
DEFINE 	_cnt				smallint;
DEFINE 	_ver				smallint;
DEFINE 	_monto_cta		    decimal(16,2);


SET ISOLATION TO DIRTY READ;
--  set debug file to "sp_che117.trc";	
--  trace on;


FOREACH
  SELECT chqchmae.cod_cliente,
         chqchmae.monto,
         cliclien.cedula,
         cliclien.tipo_cuenta,
         cliclien.cod_cuenta,
         chqbanco.ruta_numero,
         chqchmae.no_requis,
         chqchmae.pagado,
         chqchmae.no_cheque,
         chqchmae.periodo,
         chqchmae.fecha_impresion,
         cliclien.e_mail,
         chqchmae.a_nombre_de
	INTO _cod_agente,
		 _monto,
		 _cedula,
		 _tipo_cuenta,
		 _cod_cuenta,
		 _ruta_numero,
		 _no_requis,
		 _pagado,
		 _no_cheque,
		 _periodo,
		 _fecha_impresion,
		 _e_mail,
		 _a_nombre_de
    FROM chqchmae, cliclien, chqbanco
   WHERE ( cliclien.cod_cliente = chqchmae.cod_cliente ) and
         ( chqbanco.cod_banco = cliclien.cod_banco ) and
         ( ( chqchmae.origen_cheque = a_origen ) AND
         ( chqchmae.tipo_requis = 'A' ) AND
         ( chqchmae.pagado = a_pagado ) AND
         ( chqchmae.autorizado = 1 ) )
   order by	5,2 Desc


		  RETURN  _cod_agente,
		  		  _monto,
		  		  _cedula,
		  		  _tipo_cuenta,
		  		  _cod_cuenta,
		  		  _ruta_numero,
		  		  _no_requis,
		  		  _pagado,
		  		  _no_cheque,
		  		  _periodo,
		  		  _fecha_impresion,
		  		  _e_mail,
		  		  _a_nombre_de
  		    	  WITH RESUME;
		      
END FOREACH;



END PROCEDURE	  