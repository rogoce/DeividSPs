-- Carta de Cambio de Tarifa 2006-2007 

-- Creado: 07/08/2006 - Autor: Demetrio Hurtado Almanza 

-- SIS v.2.0 - d_prod_sp_pro170_dw1 - DEIVID, S.A.
-- SIS v.2.0 - d_prod_sp_pro76_crit - DEIVID, S.A.

drop procedure sp_pro170;
create procedure sp_pro170(a_compania char(3), a_sucursal char(3), a_fecha date, a_periodo char(7)) 
returning date,
		  char(100),
		  char(20),
		  varchar(100),
		  dec(16,2),
		  date,
		  varchar(50),
		  char(5),
		  smallint,
		  char(100),
		  char(10),
		  char(10),
		  char(10),
		  char(2),
		  char(2),
		  char(4),
		  varchar(60),
		  varchar(60),
		  char(3),
		  varchar(50),
		  varchar(20),
		  date,
		  date,
		  varchar(50),
		  char(10),
		  dec(16,2),
		  char(2),
		  smallint;

define _cantidad		smallint;
define _cant2			smallint;
define _no_poliza		char(10);
define _cod_cliente		char(10);
define _cod_producto	char(5);
define _prima_total		dec(16,2);
define _fecha_nac	  	date;
define _edad		  	smallint;
define _prima_plan	  	dec(16,2);
define _prima_vida	  	dec(16,2);
define _vigencia_inic 	dec(16,2);
define _vigencia_final	dec(16,2);
define _no_documento  	char(20);
define _producto_nuevo	char(5);
define _nombre_cliente	varchar(100);
define _anos			smallint;
define _forma_pago		char(100);
define _nombre_perpago	char(50);
define _tipo_forma		smallint;
define _cod_formapag	char(3);
define _cod_perpago		char(3);
define _cod_agente		char(5);
define _nombre_agente	varchar(50);
define _prima_nueva	  	dec(16,2);
define _meses			smallint;
define _cod_pagador		char(10);
define _porc_impuesto	dec(16,2);
define _fecha_carta		date;
define _fecha_chequeo	date;
define _dir1 			char(50);
define _dir2		 	char(50);
define _tel_pag1		char(10);
define _tel_pag2		char(10);
define _cel_pag			char(10);
define _dir				char(100);
define _cod_subramo     char(3);
define _desc_subramo    varchar(50);
define _vig_inic_uni 	date;
define _vig_final_uni	date;
define _cod_vendedor    char(3);
define _vendedor_nombre varchar(50);

define _fecha_aniv		date;
define _porc_descuento  dec(5,2);
define _porc_recargo    dec(5,2);
define _descuento       dec(16,2);
define _recargo         dec(16,2);
define _prima_certif    dec(16,2);
define _no_unidad		char(5);

define _fecha_dia		char(2);
define _fecha_mes		char(2);
define _fecha_ano		char(4);
define _letra_fecha_aniv char(60);
define _letra_fecha_carta char(60);
define _prima_string    varchar(20);
define _control         char(2);
define _cant_depend		smallint;
define _tipo_suscrip	smallint;
define _por_edad        smallint;
define _edad_desde_o	smallint;
define _edad_hasta_o	smallint;
define _edad_desde_n	smallint;
define _edad_hasta_n	smallint;
define _cod_producto_o  char(5);
define _prima_asegurado dec(16,2);
DEFINE _impuesto   DEC(16,2);
define _direccion_cob   varchar(100);

set isolation to dirty read;

let _fecha_carta   = a_fecha;
let _fecha_chequeo = sp_sis36(a_periodo);

--set debug file to "sp_pro170.trc";
--trace on;

foreach
 SELECT no_poliza,
		vigencia_inic,
		vigencia_final,
		no_documento,
		cod_formapag,
		cod_perpago,
		cod_pagador,
		cod_subramo
   INTO _no_poliza,
		_vigencia_inic,
		_vigencia_final,
		_no_documento,
		_cod_formapag,
		_cod_perpago,
		_cod_pagador,
		_cod_subramo
   FROM emipomae
  WHERE cod_ramo              = "018"	              -- Salud
    AND estatus_poliza        = 1                     -- Vigentes
    AND actualizado           = 1                     -- Actualizado
	and cod_tipoprod          in ("001", "005")
	and cod_subramo           in ("007", "008")       -- Panama y Panama Plus
    and vigencia_final        <= _fecha_chequeo
	and month(vigencia_inic)  = month(_fecha_chequeo) -- Que Cumplan Aniversario en el Mes
	   
	select count(*)
	  into _cantidad
	  from prdsalno
	 where no_documento = _no_documento;

	if _cantidad >= 1 then
		continue foreach;
	end if

	select count(*)
	  into _cantidad
	  from emipouni
	 where no_poliza = _no_poliza;

	if _cantidad > 1 then
		continue foreach;
	end if

	let _fecha_aniv = mdy(month(_fecha_chequeo), day(_vigencia_inic), year(_fecha_chequeo));

    select nombre
	  into _desc_subramo
	  from prdsubra
	 where cod_ramo = '018'
	   and cod_subramo = _cod_subramo;

	foreach
	 select cod_asegurado,
	        cod_producto,
			prima_asegurado,
			no_unidad,
			vigencia_inic,
			vigencia_final,
			prima_asegurado
	   into _cod_cliente,
	        _cod_producto_o,
			_prima_total,
			_no_unidad,
			_vig_inic_uni,
			_vig_final_uni,
			_prima_asegurado
	   from emipouni
	  where no_poliza = _no_poliza
	    
		let _cod_producto = _cod_producto_o;

		let _cod_producto = sp_pro30d(_no_poliza, _cod_producto);

		select fecha_aniversario
		  into _fecha_nac
		  from cliclien
		 where cod_cliente = _cod_cliente;
		 
		let _edad = sp_sis78(_fecha_nac, _fecha_aniv);
		let _anos = (_fecha_aniv - _vigencia_inic) / 365;

		if _edad is null then
			insert into prdsalex
			VALUES(_no_documento, a_periodo, "EDAD DEL CLIENTE EN BLANCO");
			continue foreach;
		end if

		if _anos = 0 then
			insert into prdsalex
			VALUES(_no_documento, a_periodo, "POLIZA AUN NO CUMPLE ANIVERSARIO");
			continue foreach;
		end if

		let _prima_plan   = 0;
		let _prima_vida   = 0;

		select prima,
	           prima_vida,
			   edad_desde,
			   edad_hasta
		  into _prima_plan,
	           _prima_vida,
			   _edad_desde_n,
			   _edad_hasta_n
		  from prdtaeda
		 where cod_producto = _cod_producto
		   and edad_desde   <= _edad
		   and edad_hasta   >= _edad;

        -- Verificando si cambio por siniestralidad es a la vez por edad
		let _por_edad = 0;

        select count(*)
		  into _cant2
		  from prdtaeda
		 where cod_producto = _cod_producto_o
		   and prima = _prima_asegurado;
		   
		If _cant2 = 1 Then    

	        select edad_desde,
			       edad_hasta
			  into _edad_desde_o,
			       _edad_hasta_o
			  from prdtaeda
			 where cod_producto = _cod_producto_o
			   and prima = _prima_asegurado;
			   
			if _edad_desde_o <> _edad_desde_n Then
				let _por_edad = 1;
			end if

	        if _edad_hasta_o <> _edad_hasta_n Then
				let _por_edad = 1;
        	end if  
		end if

		if _prima_plan is null then
			insert into prdsalex
			VALUES(_no_documento, a_periodo, "NO SE ENCONTRO PRIMA PARA EDAD");
			continue foreach;
		end if
		
		if _prima_total >= (_prima_plan + _prima_vida) then
			insert into prdsalex
			VALUES(_no_documento, a_periodo, "PRIMA A COBRAR ES MENOR");
			continue foreach;
		end if

		LET _dir = "";

		select nombre,
			   telefono1,
			   telefono2,
			   celular,
			   direccion_1,
			   direccion_2,
			   direccion_cob
		  into _nombre_cliente,
			   _tel_pag1,
			   _tel_pag2,
			   _cel_pag,
			   _dir1,
			   _dir2,
			   _direccion_cob
		  from cliclien
		 where cod_cliente = _cod_cliente;
		 
		let _dir1 = trim(_dir1);
		let _dir2 = trim(_dir2);

		if _dir1 is null then
			let _dir1 = "";
		end if

		if _dir2 is null then
			let _dir2 = "";
		end if

		if _direccion_cob is null  or trim(_direccion_cob) = "" Then
			let _dir  = _dir1 || _dir2;
		else
		    let _dir  = trim(_direccion_cob);
		end if

		foreach
		 select cod_agente
		   into _cod_agente
		   from emipoagt
		  where no_poliza = _no_poliza
			exit foreach;
		end foreach
		
		select nombre,
		       cod_vendedor
		  into _nombre_agente,
		       _cod_vendedor
		  from agtagent
		 where cod_agente = _cod_agente;

		--let _nombre_agente = "c.c.: " || trim(_nombre_agente);
				
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

		-- Prima Nueva
		
		SELECT SUM(porc_descuento)
		  INTO _porc_descuento
		  FROM emiunide
		 WHERE no_poliza = _no_poliza
		   AND no_unidad = _no_unidad;

		SELECT SUM(porc_recargo)
		  INTO _porc_recargo
		  FROM emiunire
		 WHERE no_poliza = _no_poliza
		   AND no_unidad = _no_unidad;

		IF _porc_descuento IS NULL THEN
			LET _porc_descuento = 0;
		END IF

		IF _porc_recargo IS NULL THEN
			LET _porc_recargo = 0;
		END IF

		let _prima_certif = _prima_plan + _prima_vida;
		LET _descuento    = _prima_certif  / 100 * _porc_descuento;
		LET _recargo      = (_prima_certif - _descuento) / 100 * _porc_recargo;
		LET _prima_nueva  = _prima_certif  - _descuento + _recargo;

{		LET _descuento      = _prima_certif / 100 * _porc_descuento;
		LET _recargo        = (_prima_certif - _descuento) / 100 * _porc_recargo;
		LET _prima_neta     = _prima_certif - _descuento + _recargo;
		LET _impuesto_uni   = (_prima_neta - _prima_vida_uni) / 100 * _factor_imp_tot;
		LET _prima_brut_uni = _prima_neta + _impuesto_uni;
 }
		select sum(factor_impuesto)
		  into _porc_impuesto
		  from emipolim p, prdimpue i
		 where p.cod_impuesto = i.cod_impuesto
		   and p.no_poliza    = _no_poliza;

        If _porc_impuesto Is Null Then
			let _porc_impuesto = 0;
		End If

  --		let _porc_impuesto = 1 + _porc_impuesto/100;

		if _meses = 0 then
			let _meses = 1;
		end if

--		let _prima_nueva  = _prima_plan  * _meses;
		let _prima_nueva  = _prima_nueva * _meses;
		let _impuesto  = (_prima_nueva - _prima_vida) * _porc_impuesto / 100;	--el impuesto no incluye la prima de vida
		let _prima_nueva = _prima_nueva + _impuesto;

		let _fecha_dia    = day(_fecha_aniv);
		let _fecha_mes	  =	month(_fecha_aniv);
		let _fecha_ano	  =	year(_fecha_aniv);
		let _letra_fecha_aniv = sp_sis20(_fecha_aniv);
		let _letra_fecha_carta = sp_sis20(_fecha_carta);
		let _prima_string =	_prima_nueva;

        select nombre
		  into _vendedor_nombre
		  from agtvende
		 where cod_vendedor = _cod_vendedor;

		-- Verificando el producto
		let _control = "";

		select tipo_suscripcion
		  into _tipo_suscrip
		  from prdprod
		 where cod_producto = _cod_producto;

		select count(*)
		  into _cant_depend
		  from emidepen
		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad
		   and activo = 1;

        if _cant_depend is null Then
			let _cant_depend = 0;
		end if
        
		if _tipo_suscrip = 1 and _cant_depend > 0 then -- Asegurado Solo
			let _control = "*";
  	    elif _tipo_suscrip = 2 and (_cant_depend > 1 or _cant_depend < 1) then -- Asegurado + 1 
			let _control = "*";
		elif _tipo_suscrip = 3 and _cant_depend < 2 then -- Asegurado + 2
			let _control = "*";
		end if

        if _dir is null or _dir = "" Then
			let _control = trim(_control) || "%";
		end if

		return _fecha_carta,
			   trim(_nombre_cliente),
			   _no_documento,
			   _forma_pago,
			   _prima_nueva,
			   _fecha_aniv,
			   trim(_nombre_agente),
			   _cod_producto,
			   _edad,
			   _dir,
			   _tel_pag1,
			   _tel_pag2,
			   _cel_pag,
			   _fecha_dia,
			   _fecha_mes,
			   _fecha_ano,
			   trim(_letra_fecha_carta),
			   trim(_letra_fecha_aniv),
			   _cod_subramo,
			   trim(_desc_subramo),
			   trim(_prima_string),
			   _vig_inic_uni, 
			   _vig_final_uni,
			   _vendedor_nombre,
			   _cod_pagador,
			   _prima_total,
			   _control,
			   _por_edad
			   with resume;

	end foreach

end foreach

end procedure