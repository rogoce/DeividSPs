-- Hoja de Auditoria para Reclamos de Salud (Detalle de Gastos No Cubiertos)

-- Creado    : 20/04/2004 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - d_recl_sp_rec83_dw1 - DEIVID, S.A.

drop procedure sp_che62;

create procedure sp_che62(a_compania char(3),a_no_tranrec char(10), a_numrecla char(20)) 
returning char(100),
          date,
		  dec(16,2),
		  char(3),
		  char(50);

define _no_reclamo		char(10);
define _cod_cpt			char(10);
define _no_tranrec		char(10);
define _transaccion     char(10);
define _fecha_factura	date;
define _gastos_no_cub	dec(16,2);
define _cod_no_cubierto	char(3);
define _nombre_cpt		char(100);
define _nombre_no_cub	char(50);
define _fecha_actual    date;
define _ano_actual      char(4);
define _cod_asignacion  char(10);
define _cod_tipotran    char(3);
define _cnt             smallint;
define _ano_ant         char(4);

let _fecha_actual = today;
let _ano_actual   = year(_fecha_actual);
let _ano_ant      = year(_fecha_actual) - 1;

foreach
	select transaccion
	  into _transaccion
	  from chqchrec
	 where no_requis = a_no_tranrec
	   and numrecla  = a_numrecla

foreach
 select cod_cpt,
		no_tranrec,
		fecha_factura,
		cod_asignacion,
		cod_tipotran
   into	_cod_cpt,
		_no_tranrec,
		_fecha_factura,
		_cod_asignacion,
		_cod_tipotran
   from rectrmae
  where numrecla     = a_numrecla
    and actualizado  = 1
	and transaccion  = _transaccion
	and year(fecha_factura) in(_ano_actual,_ano_ant)

	if _cod_tipotran not in("004","013") then
		continue foreach;
	else
		if _cod_tipotran = "013" then
			select count(*)
			  into _cnt
			  from rectrmae
			 where cod_asignacion = _cod_asignacion
			   and actualizado  = 1
			   --and cod_tipotran = "004"
			   and year(fecha_factura) in(_ano_actual,_ano_ant);
			 if _cnt > 0 then
			 else
				continue foreach;
			 end if
		end if
	end if

	foreach
	 select	monto_no_cubierto,
			cod_no_cubierto
	   into	_gastos_no_cub,
			_cod_no_cubierto
	   from rectrcob
	  where no_tranrec = _no_tranrec

		if _cod_no_cubierto is null then
			continue foreach;
		end if

		select nombre
		  into _nombre_cpt
		  from reccpt
		 where cod_cpt = _cod_cpt;

		select nombre
		  into _nombre_no_cub
		  from recnocub
		 where cod_no_cubierto = _cod_no_cubierto;

		return _nombre_cpt,
			   _fecha_factura,
			   _gastos_no_cub,
			   _cod_no_cubierto,
			   _nombre_no_cub
			   with resume;

	end foreach

end foreach
end foreach

end procedure