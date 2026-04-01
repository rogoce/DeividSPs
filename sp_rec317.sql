DROP procedure sp_rec317;
create procedure sp_rec317()
returning	date as fecha,
            varchar(50) as nombre,
            varchar(20) as tipo_pago,
			varchar(100) as reclamante,
			char(5) as bloque,
			char(5) as asignacion,
			dec(16,2) as monto; 

define _fecha			    date;
define _nombre      		varchar(50);
define _tipo_pago			varchar(20);
define _reclamante			varchar(100);
define _cod_entrada			char(5);
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
	   AND case atcdocde.completado
	  when 1 then 'SI'
	  when 0 then 'NO'
	   end  =  'NO'
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
end procedure 