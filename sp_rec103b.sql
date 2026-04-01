-- Verificacion de los montos de los deducibles

-- Creado    : 20/04/2005 - Autor: Demetrio Hurtado Almanza 

drop procedure sp_rec103;

create procedure sp_rec103()
returning char(20),
	      char(4),
		  char(10),
		  dec(16,2),
		  dec(16,2),
		  char(5),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  char(50);

define _no_reclamo		char(10);
define _no_documento	char(20);
define _fecha_siniestro	date;
define _fecha_factura	date;
define _fecha_deducible	date;
define _ano				char(4);
define _deducible		dec(16,2);
define _deducible2		dec(16,2);
define _deducible_loc	dec(16,2);
define _deducible_ext	dec(16,2);
define _cod_reclamante	char(10);
define _cod_tipo		char(3);
define _cod_cobertura	char(5);
define _cod_producto	char(5);
define _no_unidad		char(5);
define _no_poliza		char(10);
define _exterior		smallint;
define _cantidad		smallint;

define _deduc_loc_lim	dec(16,2);
define _deduc_ext_lim	dec(16,2);

create temp table tmp_deducible(
no_documento	char(20),
ano             char(4),
cod_cliente     char(10),
no_unidad		char(5),
deducible		dec(16,2),
deducible2		dec(16,2),
deduc_loc_lim	dec(16,2),
deduc_ext_lim	dec(16,2)
) with no log;

foreach
 select	t.no_reclamo,
		c.a_deducible,
		c.cod_tipo,
		c.cod_cobertura,
		t.fecha_factura
   into	_no_reclamo,
        _deducible,
		_cod_tipo,
		_cod_cobertura,
		_fecha_factura
   from	rectrmae t, rectrcob c
  where t.no_tranrec  = c.no_tranrec
    and c.a_deducible <> 0.00
	and t.actualizado = 1

	select no_documento,
	       fecha_siniestro,
		   cod_reclamante,
		   no_poliza,
		   no_unidad
	  into _no_documento,
	       _fecha_siniestro,
		   _cod_reclamante,
		   _no_poliza,
		   _no_unidad
	  from recrcmae
	 where no_reclamo = _no_reclamo;

{
	if _no_documento <> "1804-01487-01" then
--	if _no_documento <> "1804-0148720-01" then
		continue foreach;
	end if

--}

	select cod_producto
	  into _cod_producto
	  from emipouni
	 where no_poliza = _no_poliza
	   and no_unidad = _no_unidad;

	if _cod_tipo is null then
		
		select exterior,
			   deducible_local,
			   deducible_fuera	
		  into _exterior,
			   _deduc_loc_lim,
			   _deduc_ext_lim
		  from prdcobpd
		 where cod_producto  = _cod_producto
		   and cod_cobertura = _cod_cobertura;

	else

		select exterior
		  into _exterior
		  from prdticob
		 where cod_tipo = _cod_tipo;

		select deducible_local,
			   deducible_fuera	
		  into _deduc_loc_lim,
			   _deduc_ext_lim
		  from prdcobsa
		 where cod_producto  = _cod_producto
		   and cod_cobertura = _cod_cobertura
		   and cod_tipo      = _cod_tipo;

	end if

	if _fecha_factura is null then
		let _ano = year(_fecha_siniestro);
	else
		let _ano = year(_fecha_factura);
	end if

	let _deducible_loc = 0.00;
	let _deducible_ext = 0.00;

	if _exterior = 1 then
		let _deducible_ext = _deducible;
	else
		let _deducible_loc = _deducible;
	end if

	insert into tmp_deducible
	values (_no_documento, _ano, _cod_reclamante, _no_unidad, _deducible_loc, _deducible_ext, _deduc_loc_lim, _deduc_ext_lim);

end foreach

foreach
 select no_documento,
		ano,
		cod_cliente,
		no_unidad,
		sum(deducible + deducible2),
		sum(deducible),
		sum(deducible2)
   into _no_documento,
		_ano,
		_cod_reclamante,
		_no_unidad,
		_deducible,
		_deducible_loc,
		_deducible_ext
   from tmp_deducible
  group by 1, 2, 3, 4
  order by 1, 2, 3, 4

	let _deduc_loc_lim = 0.00;
	let _deduc_ext_lim = 0.00;

	 select max(deduc_loc_lim),
			max(deduc_ext_lim)
	   into _deduc_loc_lim,
			_deduc_ext_lim
	   from tmp_deducible
	  where no_documento = _no_documento
		and ano          = _ano
		and cod_cliente	 = _cod_reclamante;

{
	foreach
	 select deduc_loc_lim,
			deduc_ext_lim
	   into _deduc_loc_lim,
			_deduc_ext_lim
	   from tmp_deducible
	  where no_documento = _no_documento
		and ano          = _ano
		and cod_cliente	 = _cod_reclamante
		exit foreach;		 
	end foreach
}

	select (monto_deducible + monto_deducible2)
	  into _deducible2
	  from recacuan
	 where no_documento = _no_documento
	   and ano			= _ano
	   and cod_cliente  = _cod_reclamante;
	
	if _deducible2 is null then
		let _deducible2 = 0.00;
	end if

	let _no_poliza = sp_sis21(_no_documento);

	select cod_producto
	  into _cod_producto
	  from emipouni
	 where no_poliza = _no_poliza
	   and no_unidad = _no_unidad;

	if _deducible <> _deducible2 then

--{
		select count(*)
		  into _cantidad
		  from recacuan
		 where no_documento = _no_documento
		   and ano			= _ano
		   and cod_cliente  = _cod_reclamante;

		if _cantidad = 0 then

			insert into recacuan( 
			no_documento,
			ano,
			cod_cliente,
			monto_deducible,
			monto_coaseguro,
			no_unidad,
			monto_deducible2
			)
			values(
			_no_documento,
			_ano,
			_cod_reclamante,
			0.00,
			0.00,
			_no_unidad,
			0.00
			);

		end if

		update recacuan
		   set monto_deducible  = _deducible_loc,
			   monto_deducible2 = _deducible_ext
		 where no_documento     = _no_documento
		   and ano			    = _ano
		   and cod_cliente      = _cod_reclamante;
--}

		return _no_documento,
		       _ano,
			   _cod_reclamante,
			   _deducible,
			   _deducible2,
			   _cod_producto,
			   _deducible_loc,
			   _deducible_ext,
			   _deduc_loc_lim,
			   _deduc_ext_lim,
			   "Deducibles Acumulados Incorrectos"
			   with resume;

	end if

{
	if _deducible_loc > _deduc_loc_lim then

		return _no_documento,
		       _ano,
			   _cod_reclamante,
			   _deducible,
			   _deducible2,
			   _cod_producto,
			   _deducible_loc,
			   _deducible_ext,
			   _deduc_loc_lim,
			   _deduc_ext_lim,
			   "Deducibles Local Incorrectos"
			   with resume;

	end if

	if _deducible_ext > _deduc_ext_lim then

		return _no_documento,
		       _ano,
			   _cod_reclamante,
			   _deducible,
			   _deducible2,
			   _cod_producto,
			   _deducible_loc,
			   _deducible_ext,
			   _deduc_loc_lim,
			   _deduc_ext_lim,
			   "Deducibles Exterior Incorrectos"
			   with resume;

	end if
}

end foreach

drop table tmp_deducible;

end procedure
