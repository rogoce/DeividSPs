-- verificar % para descuento buena exp
--
-- creado    : 20/03/2014 - Autor: Roman Gordon
-- modificado: 28/07/2014 - Autor: Amado Perez M -- Se agrega validacion para los descuentos por cobertura
-- sis v.2.0

drop procedure sp_sis194;
create procedure "informix".sp_sis194(a_no_poliza char(10), a_no_unidad char(5),a_porc_desc dec(5,2))
returning	integer,
			char(100),
			dec(5,2);

define _no_motor        char(30);
define _no_documento	char(21);
define _no_poliza		char(10);
define _vig_ini	     	char(10);
define _vig_fin			char(10);
define _cod_cobertura	char(5);
define _cod_cober_rec	char(5);
define _nueva_renov		char(1);
define _uso_auto		char(1);
define _descuento_max	dec(5,2);
define _suma_asegurada  dec(16,2);
define _suma_aseg_max   dec(16,2);
define _porc_deduc		dec(16,2);
define _cnt_duc			smallint;
define _cnt				smallint;
define _fecha_envio		date;
define _tipo_auto       smallint;
define _cod_producto    char(5);

begin

set isolation to dirty read;

--set debug file to "sp_sis194.trc"; 
--trace on;

select uso_auto
  into _uso_auto
  from emiauto
 where no_poliza = a_no_poliza
   and no_unidad = a_no_unidad;

if _uso_auto = 'C' then
	return 0, 'El Porcentaje de Descuento es Permitido.',0.00;
end if

select no_documento,
       nueva_renov,
	   to_char(vigencia_inic,"%m/%d/%Y"),
	   to_char(vigencia_final,"%m/%d/%Y")
  into _no_documento,
       _nueva_renov,
	   _vig_ini,
	   _vig_fin
  from emipomae
 where no_poliza = a_no_poliza;

if _nueva_renov = 'R' then

	let _no_poliza = sp_sis21(_no_documento);

	let _fecha_envio = null;

	foreach

		select fecha_envio
		  into _fecha_envio
		  from emirenduc
		 where no_documento  = _no_documento
		   and vigencia_inic = _vig_ini

		exit foreach;
	end foreach

	select count(*)
	  into _cnt_duc
	  from emirenduc
	 where no_documento = _no_documento;
	
	if _cnt_duc is null then
		let _cnt_duc = 0;
	end if
	
	if _cnt_duc > 0 then
		--Puesto en comentario por instrucción de Analisa 23/04/2014
		{select count(*)
		  into _cnt
		  from recrcmae
		 where no_poliza      = _no_poliza
		   and actualizado       = 1
		   and estatus_audiencia not in (1,7)
		   and fecha_siniestro < _fecha_envio;}
		let _cnt = 0;
	else
		select count(*)
		  into _cnt
		  from recrcmae
		 where no_poliza         = _no_poliza
		   and actualizado       = 1
		   and estatus_audiencia not in (1,7);
	end if

	if _cnt is null then
		let _cnt = 0;
	end if
elif _nueva_renov = 'N' then
	let _cnt = 1;
end if

if _cnt > 0 then

	let _suma_asegurada = 0.00;

	select suma_asegurada
	  into _suma_asegurada
	  from emipouni
	 where no_poliza = a_no_poliza
	   and no_unidad = a_no_unidad;

	foreach
		select cod_cobertura
		  into _cod_cobertura
		  from emipocob
		 where no_poliza = a_no_poliza
		   and no_unidad = a_no_unidad

		call sp_sis193(a_no_poliza, a_no_unidad,_cod_cobertura) returning _cod_cober_rec, _porc_deduc, _descuento_max, _suma_aseg_max;
		
		if _suma_asegurada <= _suma_aseg_max then
			if a_porc_desc > _descuento_max then
				return 1,'Esta Póliza no puede recibir un descuento mayor a: ' || cast(_descuento_max as char(5)) || ' . Verifique',_descuento_max;
			end if
		end if
	end foreach
end if

-- Busqueda por tipo de auto 1: Sedan, 2: Suv, 3:Pickup

let _tipo_auto = sp_proe75(a_no_poliza, a_no_unidad);

if _tipo_auto in (1,2,3) and _nueva_renov = 'N' then
	select cod_producto
	  into _cod_producto
	  from emipouni
	 where no_poliza = a_no_poliza
	   and no_unidad = a_no_unidad;

	select count(*)
	  into _cnt
	  from prdcobpd p, emipocob e
	 where p.cod_cobertura = e.cod_cobertura
	   and p.cod_producto  = _cod_producto
	   and p.tipo_descuento in (1,2)
	   and e.no_poliza = a_no_poliza
	   and e.no_unidad = a_no_unidad;

	if _cnt > 0 then
		return 1, 'Este Descuento No Aplica, UNIDAD:' || a_no_unidad, 0.00;
	end if    

end if

return 0, 'El Porcentaje de Descuento es Permitido.',0.00;
end
end procedure 