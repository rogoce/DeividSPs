-- Procedure que genera la informacion solicitada por Maruquel
-- para el actuario de Multinacional

drop procedure sp_rec155;

create procedure sp_rec155(a_ano smallint)
returning char(10),
          char(10),
		  smallint,
		  char(50),
		  dec(16,2),
		  dec(16,2),
		  char(20),
		  char(50),
		  char(1),
		  date,
		  date,
		  date,
		  dec(16,2),
		  char(20),
		  char(50),
		  date,
		  char(20),
		  char(10),
		  char(50),
		  char(10),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  date,
		  char(50);
		  	
define _no_reclamo		char(10);
define _fecha_siniestro	date;
define _fecha_documento	date;
define _fecha_reclamo	date;
define _transaccion		char(10);
define _numrecla		char(20);
define _cod_cliente		char(10);
define _monto			dec(16,2);
define _cod_espe		char(3);
define _nombre_espe		char(50);
define _monto_med		dec(16,2);
define _monto_hos		dec(16,2);
define _no_tranrec		char(10);
define _pagado			smallint;
define _monto_pen		dec(16,2);
define _monto_pag		dec(16,2);
define _no_poliza		char(10);
define _no_unidad		char(5);
define _cod_asegurado	char(10);
define _cod_reclamante	char(10);
define _cod_parentesco	char(3);
define _nombre_paren	char(50);
define _suma_asegurada	dec(16,2);
define _prima			dec(16,2);
define _cod_producto	char(5);
define _nombre_prod		char(50);
define _deducible		dec(16,2);
define _no_documento	char(20);
define _sucursal_origen	char(3);
define _centro_costo	char(3);
define _fecha_emision	date;
define _vigencia_inic	date;
define _vigencia_final	date;
define _nombre_sucur	char(50);
define _fecha_naci		date;
define _sexo			char(1);
define _cantidad_uni	smallint;
define _tipo_poliza		char(20);
define _edad			smallint;
define _cod_proveedor	char(10);
define _nombre_prov		char(50);
define _fecha_factura	date;

foreach
 select no_reclamo,
        transaccion,
        cod_cliente,
        monto,
        no_tranrec,
        pagado,
		cod_proveedor,
		fecha_factura
   into _no_reclamo,
        _transaccion,
		_cod_cliente,
		_monto,
		_no_tranrec,
		_pagado,
		_cod_proveedor,
		_fecha_factura
   from rectrmae
  where periodo[1,4]  = a_ano
--    and periodo       = a_ano || "-04"
    and actualizado   = 1
	and numrecla[1,2] = "18"
	and cod_tipotran  = "004"
	and monto         <> 0.00

	-- Datos del Siniestro

	let _nombre_espe = "";

	foreach
	 select cod_especialidad
	   into _cod_espe
	   from cliespe
	  where cod_cliente = _cod_cliente

		select nombre
		  into _nombre_espe
		  from cliespme
		 where cod_espmedica = _cod_espe;

		exit foreach;

	end foreach

	let _monto_pen = 0.00;
	let _monto_pag = 0.00;

	if _pagado = 1 then
		let _monto_pag = _monto;
	else
		let _monto_pen = _monto;
	end if
			
	select sum(monto)
	  into _monto_med
	  from rectrcob c, prdticob t
	 where c.cod_tipo   = t.cod_tipo
	   and c.no_tranrec = _no_tranrec
	   and t.tipo       = "M"; 	

	if _monto_med is null then
		let _monto_med = 0.00;
	end if	

	select sum(monto)
	  into _monto_hos
	  from rectrcob c, prdticob t
	 where c.cod_tipo   = t.cod_tipo
	   and c.no_tranrec = _no_tranrec
	   and t.tipo       = "H";
	
	if _monto_hos is null then
		let _monto_hos = 0.00;
	end if	

	if _monto_hos <> 0.00 then

		select nombre
		  into _nombre_prov
		  from cliclien
		 where cod_cliente = _cod_proveedor;

	else

		let _nombre_prov   = null;
		let _fecha_factura = null;

	end if

	select fecha_documento,
	       fecha_siniestro,
		   fecha_reclamo,
	       no_poliza,
		   no_unidad,
		   cod_reclamante,
		   numrecla
	  into _fecha_documento,
	       _fecha_siniestro,
		   _fecha_reclamo,
	       _no_poliza,
		   _no_unidad,
		   _cod_reclamante,
		   _numrecla
	  from recrcmae
	 where no_reclamo = _no_reclamo;

	-- Datos de la Poliza		

	select cod_asegurado,
	       suma_asegurada,
		   cod_producto,
		   prima
	  into _cod_asegurado,
	       _suma_asegurada,
		   _cod_producto,
		   _prima
	  from emipouni
	 where no_poliza = _no_poliza
	   and no_unidad = _no_unidad;

	if _cod_asegurado is null then

	   foreach
		select cod_cliente,
		       suma_asegurada,
			   cod_producto,
			   prima
		  into _cod_asegurado,
		       _suma_asegurada,
			   _cod_producto,
			   _prima
		  from endeduni
		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad
		 order by no_endoso
			exit foreach;
		end foreach

	end if

	let _nombre_paren = "";

	if _cod_asegurado = _cod_reclamante then
			
		let _nombre_paren = "TITULAR";

	else

		select cod_parentesco
		  into _cod_parentesco
		  from emidepen
		 where no_poliza   = _no_poliza
		   and no_unidad   = _no_unidad
		   and cod_cliente = _cod_reclamante;

		select nombre
		  into _nombre_paren
		  from emiparen
		 where cod_parentesco = _cod_parentesco;

	end if
			
	select deducible_local,
	       nombre
	  into _deducible,
	       _nombre_prod
	  from prdprod
	 where cod_producto = _cod_producto;

	select no_documento,
	       sucursal_origen,
		   fecha_suscripcion,
		   vigencia_inic,
		   vigencia_final
	  into _no_documento,
	       _sucursal_origen,
		   _fecha_emision,
		   _vigencia_inic,
		   _vigencia_final
	  from emipomae
	 where no_poliza = _no_poliza;

	select centro_costo
	  into _centro_costo
	  from insagen
	 where codigo_agencia = _sucursal_origen;

	select descripcion
	  into _nombre_sucur
	  from insagen
	 where codigo_agencia = _centro_costo;

	select fecha_aniversario,
	       sexo
	  into _fecha_naci,
	       _sexo
	  from cliclien
	 where cod_cliente = _cod_reclamante;

	let _edad = sp_sis78(_fecha_naci, _fecha_documento);

	if _edad < 0 or
	   _edad is null then
		let _fecha_documento = _fecha_reclamo;
		let _edad = sp_sis78(_fecha_naci, _fecha_documento);
	end if

	select count(*)
	  into _cantidad_uni
	  from emipouni
	 where no_poliza = _no_poliza;

	if _cantidad_uni > 1 then
		let _tipo_poliza = "COLECTIVA";
	else
		let _tipo_poliza = "INDIVIDUAL";
	end if		
	
	return _cod_asegurado,
	       _cod_reclamante,
		   _edad,
		   _nombre_paren,
		   _suma_asegurada,
		   _deducible,
		   _no_documento,
		   _nombre_sucur,
		   _sexo,
		   _fecha_emision,
		   _vigencia_inic,
		   _vigencia_final,
		   _prima,
		   _tipo_poliza,
		   _nombre_prod,
		   _fecha_documento,
		   _numrecla,
		   _transaccion,
		   _nombre_espe,
		   "",
		   _monto_pen,
		   _monto_pag,
		   _monto_med,
		   _monto_hos,
		   _monto_pen + _monto_pag,
		   _fecha_factura,
		   _nombre_prov
		   with resume;
	
end foreach

end procedure