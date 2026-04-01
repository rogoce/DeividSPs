-- Procedure : Reporte de Asignaciones Pendientes de reclamos Salud para la póliza de la Cooperativa de Médicos
-- 
-- Creado    : 09/10/2021 - Autor: Amado Perez M.
--

drop procedure sp_web75;
create procedure sp_web75(as_no_documento char(20))
returning	date as fecha,
            varchar(50) as nombre,
            varchar(20) as tipo_pago,
			varchar(100) as reclamante,
			char(6) as bloque,
			char(5) as asignacion,
			dec(16,2) as monto; 

define _fecha			    date;
define _nombre      		varchar(50);
define _tipo_pago			varchar(20);
define _reclamante			varchar(100);
define _cod_entrada			char(6);
define _cod_asignacion		char(5);
define _monto			    dec(16,2);

set isolation to dirty read;

FOREACH 
	SELECT date(atcdocma.fecha) as fecha,
	       atcdocma.nombre,
	       case atcdocde.cod_tipopago
	       when '001' then 'PAGO A PROVEEDOR'
	       when '003' then 'PAGO A ASEGURADO'
	       end as Tipo_Pago,
	       dbo_cliclien2.nombre as reclamante,
	       atcdocma.cod_entrada,
	       atcdocde.cod_asignacion,
	       sum(atcdocde.monto) as monto
	  INTO _fecha, 
	       _nombre,
		   _tipo_pago,
		   _reclamante,
		   _cod_entrada,
		   _cod_asignacion,
		   _monto
	  FROM atcdocma, atcdocde, cliclien  dbo_cliclien2, emipomae
	 WHERE atcdocma.cod_entrada=atcdocde.cod_entrada
	   AND atcdocde.cod_reclamante=dbo_cliclien2.cod_cliente
	   AND atcdocde.no_documento=emipomae.no_documento
	   AND emipomae.no_documento = as_no_documento
	   AND  case atcdocde.completado
	  when 1 then 'SI'
	  when 0 then 'NO'
	   end  =  'NO'
	   and escaneado = 1
	   and (cod_ajustador is null or cod_ajustador = '')
	GROUP BY
	  atcdocma.fecha,
	  atcdocma.nombre,
	  atcdocde.cod_tipopago,
	  dbo_cliclien2.nombre,
	  atcdocma.cod_entrada,
	  atcdocde.cod_asignacion
	order by fecha
	 
	return 	_fecha,
	        _nombre,
			_tipo_pago,
			_reclamante,
			_cod_entrada,
			_cod_asignacion,
			_monto WITH RESUME;
END FOREACH

--- No escaneados
let _fecha				= "";
let _nombre				= "";
let _tipo_pago			= "";
let _reclamante			= "";
let _cod_entrada		= "";
let _cod_asignacion		= "";
let _monto				= "";

/*
FOREACH 
	SELECT date(atcdocma.fecha) as fecha,
	       cod_entrada,  
		   nombre
	  INTO _fecha,
		   _cod_entrada,	  
	       _nombre
	  FROM atcdocma
	 where procesado = 0 
	   and completado = 0 
  order by fecha
	 
	return 	_fecha,
	        _nombre,
			_tipo_pago,
			_reclamante,
			_cod_entrada,
			_cod_asignacion,
			_monto WITH RESUME;
END FOREACH
*/
end procedure;