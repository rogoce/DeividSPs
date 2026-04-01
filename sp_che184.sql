-- Genera Cheque ACH -- Verificador antes de generar los ach
-- Creado    : 14/09/2018 - Autor: Amado Perez
-- SIS v.2.0 - DEIVID, S.A.	
-- execute procedure sp_che177('2',0)

DROP PROCEDURE sp_che184;
CREATE PROCEDURE sp_che184(a_origen char(1)) 
RETURNING  char(10),
           char(10),							
		   char(10);			

DEFINE 	_a_nombre_de		char(100);
DEFINE 	_e_mail 			char(50);
DEFINE 	_cedula			    char(30);
DEFINE 	_cod_cuenta		    char(18);
DEFINE 	_no_requis		    char(10);
DEFINE  _no_requis_tr       char(10);
DEFINE 	_periodo			char(7);
DEFINE 	_cod_agente		    char(5);
DEFINE  _numrecla           char(2);
DEFINE 	_tipo_cuenta		char(1);
DEFINE 	_monto_cta		    dec(16,2);
DEFINE 	_monto			    dec(16,2);
DEFINE 	_cnt				smallint;
DEFINE 	_ver				smallint;
DEFINE 	_ruta_numero		integer;
DEFINE 	_pagado			    integer;
DEFINE 	_no_cheque		    integer;
DEFINE 	_fecha_impresion	date;
DEFINE  _transaccion        char(10);
DEFINE  _origen_orig        char(1);
DEFINE  _cant               smallint;


SET ISOLATION TO DIRTY READ;
--  set debug file to "sp_che117.trc";	
--  trace on;

LET _pagado = 0;

LET _origen_orig = a_origen;

if a_origen = "Z" or a_origen = "S" then
	let a_origen = "3";
end if

FOREACH
	SELECT chqchmae.no_requis,
		   chqchmae.a_nombre_de
	  INTO _no_requis,
		   _a_nombre_de
	  FROM chqchmae
	 WHERE ((chqchmae.origen_cheque = a_origen)
	   AND (chqchmae.cod_banco = '001')
	   AND (chqchmae.cod_chequera <> '006')
	   AND (chqchmae.tipo_requis = 'A')
	   AND (chqchmae.pagado = 0)
	   AND (chqchmae.autorizado = 1 )
	   AND (chqchmae.en_firma = 2)
	   AND (chqchmae.pre_autorizado = 1) 
	   AND (chqchmae.aut_imp_tec = 1))
	 ORDER BY 1

	LET _no_requis_tr = null;
	
	let _cant = 0;
	
		-- Buscando pago a subrogaciones
	let _cant = sp_rec315(_no_requis);	
	
	if _origen_orig = "S" then
		if _cant = 0 then
			continue foreach;
		end if
	end if

	
	FOREACH
		SELECT transaccion
		  INTO _transaccion
		  FROM chqchrec
		 WHERE no_requis = _no_requis
		 
		select pagado,
			   no_requis
		  into _pagado,
			   _no_requis_tr
		  from rectrmae
		 where transaccion = _transaccion;
		 
        if _pagado = 1 then		   
			EXIT FOREACH;
		end if
	END FOREACH

   if _pagado = 1 then
		RETURN	_no_requis,
		        _transaccion,
				_no_requis_tr;		     
		EXIT FOREACH;	
   end if	
END FOREACH;
if  _pagado = 0 then
	RETURN	null,
	        null,
			null;		     
end if
DROP TABLE tmp_cta;
END PROCEDURE	  