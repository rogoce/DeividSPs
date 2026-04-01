-- Pool General

-- Creado    : 15/05/2009 - Autor: Armando Moreno.

--DROP PROCEDURE sp_pro325a;

CREATE PROCEDURE "informix".sp_pro325a(a_tipo_ramo char(1))
returning varchar(50),	 --_n_corredor,
		  char(10),		 --_no_poliza,
		  char(8),		 --_user_added,   
		  char(3),       --_cod_no_renov,   
		  char(20),		 --_no_documento,   
		  smallint,		 --_renovar,   
		  smallint,		 --_no_renovar,   
		  date,			 --_fecha_selec,   
		  date,			 --_vigencia_inic,   
		  date,			 --_vigencia_final,   
		  dec(16,2),	 --_saldo,   
		  smallint,		 --_cant_reclamos,   
		  char(10),		 --_no_factura,   
		  decimal(16,2), --_incurrido,   
		  decimal(16,2), --_pagos,   
		  decimal(5,2),	 --_porc_depreciacion,
		  char(5),	   	 --_cod_agente,
		  varchar(100),  --_n_cliente,
		  decimal(16,2), --_prima_bruta,
		  decimal(16,2), --_diezporc,
		  char(10),		 --_cod_contratante  
		  integer;

define _no_poliza	    char(10);
define a_usuario        char(8);	 
define _cod_contratante char(10);	 
define _prima_bruta	    dec(16,2);	 
define _user_added   	char(8);
define _cod_no_renov   	char(3);
define _no_documento	char(20);
define _renovar   		smallint;
define _no_renovar		smallint;
define _fecha_selec		date;
define _vigencia_inic	date;
define _vigencia_final	date;
define _saldo			dec(16,2);
define _cant_reclamos	smallint;
define _no_factura		char(10);
define _incurrido		dec(16,2);
define _pagos   		dec(16,2);
define _porc_depreciacion  dec(5,2);
define _cod_agente  	char(5);
define _saldo_porc      integer;
define _n_cliente       varchar(100);
define _n_corredor      varchar(50);
define _diezporc      	dec(16,2);
define _fecha_hoy       date;
define _dias            integer;

let _fecha_hoy = current;

SET ISOLATION TO DIRTY READ;

foreach

	select distinct(usuario)
	  into a_usuario
	  from emiredis
	 where cod_sucursal = '001'
	   and tipo_ramo    = a_tipo_ramo

	foreach
	  SELECT no_poliza,   
	         user_added,   
	         cod_no_renov,   
	         no_documento,   
	         renovar,   
	         no_renovar,   
	         fecha_selec,   
	         vigencia_inic,   
	         vigencia_final,   
	         saldo,   
	         cant_reclamos,   
	         no_factura,   
	         incurrido,   
	         pagos,   
	         porc_depreciacion,   
	         cod_agente  
		INTO _no_poliza,
			 _user_added,   
			 _cod_no_renov,   
			 _no_documento,   
			 _renovar,   
			 _no_renovar,   
			 _fecha_selec,   
			 _vigencia_inic,   
			 _vigencia_final,   
			 _saldo,   
			 _cant_reclamos,   
			 _no_factura,   
			 _incurrido,   
			 _pagos,   
			 _porc_depreciacion,
			 _cod_agente  
	    FROM emirepo  
	   WHERE user_added = a_usuario

	  SELECT cod_contratante,
	         prima_bruta
		INTO _cod_contratante,
		     _prima_bruta
		FROM emipomae
	   WHERE no_poliza = _no_poliza;

	  select saldo_porc
	    into _saldo_porc
	    from emirepar;
	    	
	  if _saldo_porc is null then
		let _saldo_porc = 10;
	  end if

	  let _diezporc = 0;
	  let _diezporc = _prima_bruta * (_saldo_porc/100);

	  SELECT nombre
	    INTO _n_cliente
	    FROM cliclien
	   WHERE cod_cliente = _cod_contratante;

	  SELECT nombre
	    INTO _n_corredor
	    FROM agtagent
	   WHERE cod_agente = _cod_agente;

		let _dias = _fecha_hoy - _fecha_selec;

	   return _n_corredor,
	   		  _no_poliza,
	   		  _user_added,   
	   		  _cod_no_renov,   
			  _no_documento,   
			  _renovar,   
			  _no_renovar,   
			  _fecha_selec,   
			  _vigencia_inic,   
			  _vigencia_final,   
			  _saldo,   
			  _cant_reclamos,   
			  _no_factura,   
			  _incurrido,   
			  _pagos,   
			  _porc_depreciacion,
			  _cod_agente,
			  _n_cliente,
			  _prima_bruta,
			  _diezporc,
			  _cod_contratante,
			  _dias
			  with resume;
	end foreach
end foreach

END PROCEDURE
