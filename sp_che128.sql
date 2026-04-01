-- Genera Cheque ACH
-- Creado    : 08/06/2010 - Autor: Henry Girón
-- SIS v.2.0 - DEIVID, S.A.	
-- execute procedure sp_che123('2',0)

DROP PROCEDURE sp_che128;
CREATE PROCEDURE sp_che128() 
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
		   char(100),				--a_nombre_de		
		   smallint,				--cnt			
		   smallint,				--ver			
		   decimal(16,2),			--monto_cta	
		   smallint,				--Salud
		   char(20),
		   char(20),
		   integer;

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
DEFINE  _numrecla           char(2);
DEFINE  _de_salud           smallint;
DEFINE 	_firma1 			char(20);
DEFINE 	_firma2 			char(20);
DEFINE  _dias               integer;



SET ISOLATION TO DIRTY READ;
--  set debug file to "sp_che117.trc";	
--  trace on;

CREATE TEMP TABLE tmp_cta(
	cod_cuenta	char(18)	
	) WITH NO LOG;


FOREACH
  SELECT chqchmae.cod_cliente,
         chqchmae.monto,
		 chqchmae.firma1,
		 chqchmae.firma2,
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
		 _firma1,
		 _firma2,
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
         ( ( chqchmae.origen_cheque = '3' ) AND
		 ( chqchmae.cod_banco = '001' ) AND
         ( chqchmae.cod_chequera = '006' ) AND
         ( chqchmae.tipo_requis = 'A' ) AND
         ( chqchmae.pagado = 0 ) AND
         ( chqchmae.autorizado = 1 ) AND
         (chqchmae.en_firma = 2) AND
		 (chqchmae.pre_autorizado = 1) AND
		 ( chqchmae.aut_imp_tec = 1))
   order by	5,2 Desc

	let _dias = sp_par392(_no_requis);

   FOREACH
	SELECT numrecla
	  INTO _numrecla
	  FROM chqchrec
	 WHERE no_requis = _no_requis
	 EXIT FOREACH;
   END FOREACH

   IF _numrecla = '18' THEN
		let _de_salud = 1;
   ELSE
		let _de_salud = 0;
   END IF

		 let _cnt = 0;
		 let _ver = 0;
		 let _monto_cta = 0;

		 select count(*)
		   into	_cnt
		   from tmp_cta
		  where cod_cuenta = _cod_cuenta;

--		  let _cnt = 1; 

		  if _cnt = 0 then

			  SELECT sum(chqchmae.monto)
			    INTO _monto_cta
			    FROM chqchmae, cliclien, chqbanco
			   WHERE ( cliclien.cod_cliente = chqchmae.cod_cliente ) and
			         ( chqbanco.cod_banco = cliclien.cod_banco ) and
			         ( ( chqchmae.origen_cheque = '3' ) AND
					 ( chqchmae.cod_banco = '001' ) AND
					 ( chqchmae.cod_chequera = '006' ) AND
			         ( chqchmae.tipo_requis = 'A' ) AND
			         ( chqchmae.pagado = 0 ) AND
            --         ( chqchmae.no_cheque = 2588) AND
			         ( chqchmae.autorizado = 1 )  AND
                     ( chqchmae.en_firma = 2) AND
					 ( chqchmae.pre_autorizado = 1) AND
					 ( chqchmae.aut_imp_tec = 1)) AND
			         ( cliclien.cod_cuenta = _cod_cuenta )	;

				INSERT INTO tmp_cta( cod_cuenta )
				VALUES ( _cod_cuenta );

				let _ver = 1;
		  end if
      
		  if _ver = 1 then
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
			  		  _a_nombre_de,
					  _cnt,
					  _ver,
					  _monto_cta,
					  _de_salud,
					  _firma1,
					  _firma2,
					  _dias
	  		    	  WITH RESUME;
		  end if
		      
END FOREACH;

DROP TABLE tmp_cta;


END PROCEDURE	  