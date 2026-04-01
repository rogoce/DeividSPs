-- Procedure que selecciona los Asegurados o los Reclamantes
-- que han sufrido reclamos para una Poliza dada para la
-- Hoja de Audito de Salud
--
-- Creado    : 03/12/2001 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 03/12/2001 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - d_recl_sp_rec55_crit - DEIVID, S.A.

drop procedure sp_sis32;

create procedure sp_sis32(a_no_documento char(20), a_tipo char(1))
returning char(20),
          char(100);

define _codigo		char(20);
define _nombre		char(100);
define _no_unidad	char(5);
define _cod_icd		char(10);
define _no_poliza   char(10);

set isolation to dirty read;

--drop table tmp_cliente;

create temp table tmp_cliente(
codigo	char(20),
nombre	char(100)
) with no log;

if a_tipo = "1" then -- Asegurados
	
   foreach
	select no_unidad, no_poliza
	  into _no_unidad, _no_poliza 
	  from recrcmae
	 where no_documento = a_no_documento
	   and actualizado  = 1
	 group by no_unidad, no_poliza

	{	select u.cod_cliente
		  into _codigo
		  from endeduni u, endedmae p
		 where u.no_poliza    = p.no_poliza
		   and u.no_endoso    = p.no_endoso
		   and p.no_documento = a_no_documento
		   and u.no_unidad    = _no_unidad
		   and p.actualizado  = 1
		 group by u.cod_cliente	}

	   foreach	
         select cod_asegurado
		   into _codigo
		   from emipouni
 		  where no_poliza = _no_poliza 
 		    and no_unidad = _no_unidad

			select nombre
			  into _nombre
			  from cliclien
			 where cod_cliente = _codigo;
			
			insert into tmp_cliente
			values (_codigo, _nombre);

		end foreach

	end foreach

elif a_tipo = "2" then -- Reclamantes

   foreach
	select cod_reclamante
	  into _codigo
	  from recrcmae
	 where no_documento = a_no_documento
	   and actualizado  = 1
	 group by cod_reclamante

	select nombre
	  into _nombre
	  from cliclien
	 where cod_cliente = _codigo;

		insert into tmp_cliente
		values (_codigo, _nombre);

	end foreach

elif a_tipo = "3" then -- Reclamos

   foreach
	select numrecla,
	       cod_icd
	  into _codigo,
	       _cod_icd
	  from recrcmae
	 where no_documento = a_no_documento
	   and actualizado  = 1
	 order by numrecla[6,7] desc, numrecla[4,5] desc, numrecla[9,13] desc

	select nombre
	  into _nombre
	  from recicd
	 where cod_icd = _cod_icd;

		insert into tmp_cliente
		values (_codigo, _nombre);

	end foreach

end if


if a_tipo = "3" then -- Reclamos

	foreach
	 select codigo,
	        nombre
	   into _codigo,
	        _nombre	
	   from tmp_cliente
	  order by  codigo[6,7] desc, codigo[4,5] desc, codigo[9,13] desc

		return _codigo,
		       _nombre
			   with resume;

	end foreach

else

	foreach
	 select codigo,
	        nombre
	   into _codigo,
	        _nombre	
	   from tmp_cliente
	  group by nombre, codigo
	  order by nombre, codigo 

		return _codigo,
		       _nombre
			   with resume;

	end foreach

end if

drop table tmp_cliente;

end procedure
