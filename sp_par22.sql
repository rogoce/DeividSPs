drop procedure sp_par22;
create procedure sp_par22()
returning char(10),
	      char(100),
		  integer,
		  dec(16,2),
		  dec(16,2),
		  char(3),
		  char(50);

define _cod_ajustador	char(3);
define _cod_cliente		char(10);
define _cantidad		integer;
define _monto			dec(16,2);
define _variacion		dec(16,2);
define _nombre_ajus		char(50);
define _nombre_taller	char(100);

set isolation to dirty read;

foreach
select r.ajust_interno, 
	   t.cod_cliente, 
	   count(*), 
	   sum(monto), 
	   sum(variacion)
  into _cod_ajustador,
       _cod_cliente,
	   _cantidad,
	   _monto,
	   _variacion
  from rectrmae t, recrcmae r
 where t.no_reclamo = r.no_reclamo
   and t.cod_tipopago = '002'
   and t.periodo >= '2001-01'
   and t.periodo <= '2001-06'
 group by 1, 2
having count(*) >= 10
 order by 1, 3 desc

	select nombre
	  into _nombre_ajus
	  from recajust
	 where cod_ajustador = _cod_ajustador;

	select nombre
	  into _nombre_taller
	  from cliclien
	 where cod_cliente = _cod_cliente;

	return _cod_cliente,
	       _nombre_taller,
		   _cantidad,
		   _monto,
		   _variacion,
		   _cod_ajustador,
		   _nombre_ajus
		   with resume;

end foreach

end procedure