-- Procedure que retorna los datos de los dependientes para la consulta de reclamos de saluda

-- Creado    : 28/07/2005 - Autor: Demetrio Hurtado Almanza 

-- SIS v.2.0 - DEIVID, S.A.

--drop procedure sp_rec108bk;

create procedure "informix".sp_rec108bk(a_no_poliza char(10), a_no_unidad char(5), a_cod_cliente char(10))
returning char(100),
          date,
		  date,
		  smallint,
		  date;
          
define _fecha			  date;
define _nombre			  char(100);
define _fecha2  		  date;
define _fecha3			  date;
define _activo	          smallint;
define _estatus_poliza    smallint;
define _fecha_cancelacion date;

select date_added,
       activo,
	   no_activo_desde
  into _fecha,
       _activo,
	   _fecha3
  from emidepen
 where no_poliza   = a_no_poliza
   and no_unidad   = a_no_unidad
   and cod_cliente = a_cod_cliente; 

select nombre
  into _nombre
  from cliclien
 where cod_cliente = a_cod_cliente;

select vigencia_final,
	   estatus_poliza,
	   fecha_cancelacion
  into _fecha2,
	   _estatus_poliza,
	   _fecha_cancelacion
  from emipomae
 where no_poliza = a_no_poliza;

if _activo = 0 then
	let _fecha2 = _fecha3;
end if

return _nombre,
       _fecha,
	   _fecha2,
	   _estatus_poliza,
	   _fecha_cancelacion;

end procedure