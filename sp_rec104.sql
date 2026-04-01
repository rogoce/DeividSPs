-- Verificacion de los montos de los deducibles

-- Creado    : 20/04/2005 - Autor: Demetrio Hurtado Almanza 

drop procedure sp_rec104;

create procedure sp_rec104()
returning smallint;

define _no_documento	char(20);
define _cod_reclamante	char(10);
define _no_reclamo		char(10);
define _no_poliza		char(10);
define _cod_cobertura	char(5);
define _cod_producto	char(5);
define _no_unidad		char(5);
define _ano				char(4);
define _cod_tipo		char(3);
define _deducible_loc	dec(16,2);
define _deduc_loc_lim	dec(16,2);
define _deduc_ext_lim	dec(16,2);
define _deducible_ext	dec(16,2);
define _deducible2		dec(16,2);
define _deducible		dec(16,2);
define _ano_cal_int		integer;
define _exterior		smallint;
define _tipo_acum_deduc	smallint;
define _fecha_siniestro	date;
define _vigencia_inic	date;

SET ISOLATION TO DIRTY READ;

create temp table tmp_deducible(
no_documento	char(20),
ano             char(4),
cod_cliente     char(10),
deducible		dec(16,2),
deducible2		dec(16,2),
deduc_loc_lim	dec(16,2),
deduc_ext_lim	dec(16,2)
) with no log;

foreach
	select t.no_reclamo,
		   c.a_deducible,
		   c.cod_tipo,
		   c.cod_cobertura
	  into _no_reclamo,
		   _deducible,
		   _cod_tipo,
		   _cod_cobertura
	  from rectrmae t, rectrcob c
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
	
	let _tipo_acum_deduc = 1;
	
	select tipo_acum_deduc
	  into _tipo_acum_deduc
	  from prdprod
	 where cod_producto = _cod_producto;

	let _ano = year(_fecha_siniestro);
	
	if _tipo_acum_deduc = 2 then
		select vigencia_inic
		  into _vigencia_inic
		  from emipomae
		 where no_poliza = _no_poliza;

		if month(_vigencia_inic) > month(_fecha_siniestro) then			
			let _ano_cal_int = _ano;
			let _ano_cal_int = _ano_cal_int - 1;
			let _ano = _ano_cal_int;
		end if
	end if
	
	let _deducible_loc = 0.00;
	let _deducible_ext = 0.00;

	if _exterior = 1 then
		let _deducible_ext = _deducible;
	else
		let _deducible_loc = _deducible;
	end if

	insert into tmp_deducible
	values (_no_documento, _ano, _cod_reclamante, _deducible_loc, _deducible_ext, _deduc_loc_lim, _deduc_ext_lim);
end foreach

foreach
	select no_documento,
		   ano,
		   cod_cliente,
		   sum(deducible + deducible2),
		   sum(deducible),
		   sum(deducible2)
	  into _no_documento,
		   _ano,
		   _cod_reclamante,
		   _deducible,
		   _deducible_loc,
		   _deducible_ext
	  from tmp_deducible
	 group by 1, 2, 3
	 order by 1, 2, 3

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

	select (monto_deducible + monto_deducible2),
	       no_unidad
	  into _deducible2,
	       _no_unidad
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
		drop table tmp_deducible;
		return 1;
	end if

	if _deducible_loc > _deduc_loc_lim then
		drop table tmp_deducible;
		return 1;
	end if

	if _deducible_ext > _deduc_ext_lim then
		drop table tmp_deducible;
		return 1;
	end if

end foreach

drop table tmp_deducible;

return 0;
end procedure
