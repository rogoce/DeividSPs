-- Carta de Cambio de Tarifa 2006-2007 

-- Creado: 07/08/2006 - Autor: Demetrio Hurtado Almanza 

-- SIS v.2.0 - d_prod_sp_pro170_dw1 - DEIVID, S.A.
-- SIS v.2.0 - d_prod_sp_pro76_crit - DEIVID, S.A.

drop procedure sp_pro175;
create procedure sp_pro175(a_fecha_desde date, a_fecha_hasta date) 
returning char(100),
		  char(20),
		  varchar(20),
		  varchar(100),
		  varchar(100),
		  char(10),
		  char(10),
		  char(100),
		  varchar(50),
		  varchar(60),
		  varchar(60),
		  char(3),
		  smallint;

define _no_poliza		char(10);
define _cod_cliente		char(10);
define _cod_producto	char(5);
define _no_documento  	char(20);
define _nombre_cliente	varchar(100);
define _forma_pago		char(100);
define _nombre_perpago	char(50);
define _tipo_forma		smallint;
define _cod_formapag	char(3);
define _cod_perpago		char(3);
define _nombre_agente	varchar(50);
define _meses			smallint;
define _fecha_carta		date;
define _direccion		varchar(100);
define _dir_alternativo varchar(100);
define _telefono1		char(10);
define _telefono2		char(10);
define _prima           dec(16,2);

define _cod_subramo     char(3);

define _fecha_aniv		date;

define _letra_fecha_aniv  varchar(60);
define _letra_fecha_carta varchar(60);
define _prima_string    varchar(20);
define _por_edad        smallint;

set isolation to dirty read;

let _fecha_carta   = current;

--set debug file to "sp_pro170.trc";
--trace on;

foreach
 SELECT no_documento,
		nombre_cliente,
		fecha_aniv,
		direccion,
		telefono1,
		telefono2,
		nombre_agente,
		dir_alternativo,
		por_edad,
		cod_subramo,
		cod_producto,
		prima
   INTO _no_documento,
		_nombre_cliente,
		_fecha_aniv,
		_direccion,
		_telefono1,
		_telefono2,
		_nombre_agente,
		_dir_alternativo,
		_por_edad,
		_cod_subramo,
		_cod_producto,
		_prima
   FROM emicartasal
  WHERE fecha_aniv >= a_fecha_desde
    and fecha_aniv <= a_fecha_hasta

  FOREACH
	 SELECT no_poliza,
			cod_formapag,
			cod_perpago
	   INTO _no_poliza,
			_cod_formapag,
			_cod_perpago
	   FROM emipomae
	  WHERE no_documento          = _no_documento
	    AND actualizado           = 1                     -- Actualizado
	  ORDER BY no_poliza desc
  END FOREACH	   

	-- Forma de Pago

	let _forma_pago = "";

	select tipo_forma
	  into _tipo_forma
	  from cobforpa
	 where cod_formapag = _cod_formapag;

	if _tipo_forma = 2 then
		let _forma_pago = "TARJETA DE CREDITO";
	elif _tipo_forma = 3 then 
		let _forma_pago = "DESCUENTO SALARIAL";
	elif _tipo_forma = 4 then 
		let _forma_pago = "DESCUENTO BANCARIO";
	else
		let _forma_pago = "VOLUNTARIO";
	end if

	select nombre,
	       meses
	  into _nombre_perpago,
	       _meses
	  from cobperpa
	 where cod_perpago = _cod_perpago;

	let _forma_pago = trim(_forma_pago) || " - " || trim(_nombre_perpago);


	let _letra_fecha_aniv = sp_sis20(_fecha_aniv);
	let _letra_fecha_carta = sp_sis20(_fecha_carta);
	let _prima_string =	_prima;


	return trim(_nombre_cliente),
		   _no_documento,
		   _prima_string,
		   trim(_direccion),		
		   trim(_dir_alternativo),
		   _telefono1,		
		   _telefono2,		
		   trim(_forma_pago),
		   trim(_nombre_agente),
		   trim(_letra_fecha_carta),
		   trim(_letra_fecha_aniv),
		   _cod_subramo,
		   _por_edad
		   with resume;


end foreach

end procedure