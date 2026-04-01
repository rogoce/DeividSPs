-- Generacion de Registros Contables de un Cheque Anulado

-- Creado    : 08/02/2010 - Autor: Demetrio Hurtado Almanza 

-- SIS v.2.0 -- -- DEIVID, S.A.

drop procedure sp_che109;

create procedure "informix".sp_che109(a_no_requis char(10))
returning integer,
		  char(100);

define _renglon_old	smallint;
define _renglon_new	smallint;
define _null		char(1);

let _null = null;

select max(renglon)
  into _renglon_new
  from chqchcta
 where no_requis = a_no_requis;

foreach
 select renglon
   into _renglon_old
   from chqchcta
  where no_requis = a_no_requis
    and tipo      = 1
  order by renglon
    
	let _renglon_new = _renglon_new + 1;
	
    insert into chqchcta(
    no_requis,
    renglon,
    cuenta,
    debito,
    credito,
    cod_auxiliar,
    tipo,
    fecha,
    centro_costo,
    sac_notrx,
	periodo,
	no_poliza,
	tipo_requis
	)
	select 
    no_requis,
    _renglon_new,
    cuenta,
    credito,
    debito,
    cod_auxiliar,
    2,
    _null,
    centro_costo,
    _null,
	_null,
	no_poliza,
	tipo_requis
	from chqchcta
   where no_requis = a_no_requis
     and renglon   = _renglon_old;
	     
	insert into chqctaux(
	no_requis, 
	renglon, 
	cuenta, 
	cod_auxiliar, 
	debito, 
	credito, 
	tipo, 
	fecha, 
	centro_costo
	)
	select 
	no_requis, 
	_renglon_new, 
	cuenta, 
	cod_auxiliar, 
	credito, 
	debito, 
	2, 
	_null, 
	centro_costo
	from chqctaux
   where no_requis = a_no_requis
     and renglon   = _renglon_old;

end foreach

return 0, "Actualizacion Exitosa";


end procedure 