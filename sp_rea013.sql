-- Cargar la tabla de comprobantes de reaseguro

-- Creado    : 08/02/2010 - Autor: Demetrio Hurtado Almanza 

-- SIS v.2.0 -- -- DEIVID, S.A.

drop procedure sp_rea013;

create procedure "informix".sp_rea013()
returning	char(20),
			char(10),
			char(10),
			char(5),
			date,
			char(7),
			char(50),
			datetime hour to second;

define _descripcion		char(50);
define _error_desc		char(50);
define _transaccion		char(10);
define _no_poliza		char(10);
define _no_remesa		char(10);
define _no_tranrec		char(10);
define _periodo			char(7);
define _periodo_fis		char(7);
define _no_endoso		char(5);
define _anofiscal		char(4);
define _cod_endomov		char(3);
define _cod_tipotran	char(3);
define _mesfiscal		char(2);
define _tipo_mov		char(1);
define _error			integer;
define _cantidad		smallint;
define _renglon			smallint;
define _mes_int			smallint;
define _fecha			date;
define _hora			datetime hour to second;

select par_mesfiscal,
       par_anofiscal
  into _mesfiscal,
       _anofiscal
  from cglparam;

let _mes_int = _mesfiscal;

if _mes_int < 10 then
	let _mesfiscal = "0" || _mes_int;
else
	let _mesfiscal = _mes_int;
end if
 
let _periodo_fis = _anofiscal || "-" || _mesfiscal;
 
set isolation to dirty read;

foreach
	select no_remesa,
		   date_posteo,
		   periodo,
		   hora_creacion
	  into _no_remesa,
		   _fecha,
		   _periodo,
		   _hora
	  from cobremae
	 where periodo    >= _periodo_fis
	   and actualizado = 1

	foreach
		select renglon,
			   no_recibo,
			   tipo_mov
		  into _renglon,
			   _transaccion,
			   _tipo_mov
		  from cobredet
		 where no_remesa = _no_remesa
		   and tipo_mov in ("P", "N")

		select count(*)
		  into _cantidad
		  from sac999:reacomp
		 where no_remesa = _no_remesa
		   and renglon   = _renglon;

		if _cantidad = 0 then 

			if _tipo_mov = "P" then
				let _descripcion = "PAGO DE PRIMA";
			else
				let _descripcion = "NOTA DE CREDITO";
			end if

			return "Cobros",
			       _transaccion,
			       _no_remesa,
			       _renglon,
			       _fecha,
			       _periodo,
				   _descripcion,
				   _hora
				   with resume;

		end if
	end foreach
end foreach

foreach
	select no_poliza,
		   no_endoso,
		   no_factura,
		   fecha_emision,
		   periodo,
		   cod_endomov,
		   wf_fecha_aprob
	  into _no_poliza,
		   _no_endoso,
		   _transaccion,
		   _fecha,
		   _periodo,
		   _cod_endomov,
		   _hora
	  from endedmae
	 where periodo    >= _periodo_fis
	   and actualizado = 1

	select count(*)
	  into _cantidad
	  from sac999:reacomp
	 where no_poliza = _no_poliza
	   and no_endoso = _no_endoso;

	if _cantidad = 0 then 

		select nombre
		  into _descripcion
		  from endtimov
		 where cod_endomov = _cod_endomov;

		return "Produccion",
		       _transaccion,
		       _no_poliza,
		       _no_endoso,
		       _fecha,
		       _periodo,
			   _descripcion,
			   _hora
			   with resume;
	end if 
end foreach

foreach
	select no_tranrec,
		   transaccion,
		   fecha,
		   periodo,
		   cod_tipotran,
		   wf_apr_j_fh
	  into _no_tranrec,
		   _transaccion,
		   _fecha,
		   _periodo,
		   _cod_tipotran,
		   _hora
	  from rectrmae
	 where periodo    >= _periodo_fis
	   and actualizado = 1

	select count(*)
	  into _cantidad
	  from sac999:reacomp
	 where no_tranrec = _no_tranrec;

	if _cantidad = 0 then 

		select nombre
		  into _descripcion
		  from rectitra
		 where cod_tipotran = _cod_tipotran;

		return "Reclamos",
		       _transaccion,
		       _no_tranrec,
		       "",
		       _fecha,
		       _periodo,
			   _descripcion,
			   _hora
			   with resume;

	end if
end foreach

return "Completado",
       "",
       "",
       "",
       null,
       null,
	   "",
	   null
	   with resume;

end procedure;