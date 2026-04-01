-- Auxiliar de Devolucion de Primas en Suspenso
-- Creado    : 19/10/2020 - Autor: Demetrio Hurtado Almanza 

drop procedure sp_sac193;

create procedure sp_sac193(a_periodo char(7)) 
returning char(100),
          dec(16,2);

define _nombre			char(100);
define _monto			dec(16,2);

define _doc_remesa		char(20);
define _cod_auxiliar	char(5);

set isolation to dirty read;

create temp table tmp_devolucion(
nombre		char(100),
monto		dec(16,2)
) with no log;

-- Cobros

let _cod_auxiliar = "0127";
let _doc_remesa   = sp_sis15('CPDEVSUS');

foreach
 select desc_remesa,
        monto
   into _nombre,
        _monto
   from cobredet
  where cod_compania = "001"
    and actualizado  = 1
    and tipo_mov     = "M"
	and periodo      >= a_periodo
    and doc_remesa   = _doc_remesa
    and cod_auxiliar = _cod_auxiliar

	insert into tmp_devolucion(nombre, monto)
	values (_nombre, _monto);

end foreach

-- Cheques

foreach
 select a_nombre_de,
        monto
   into _nombre,
        _monto
   from chqchmae
  where cod_compania  = "001"
    and pagado        = 1
	and anulado       = 0
	and origen_cheque = "S"
	and periodo      >= a_periodo

	insert into tmp_devolucion(nombre, monto)
	values (_nombre, _monto * -1);

end foreach

foreach
 select nombre,
        sum(monto)
   into _nombre,
        _monto
   from tmp_devolucion
  group by 1
  order by 1

	if _monto <> 0 then

		return _nombre,
		       _monto
			   with resume;

	end if

end foreach

drop table tmp_devolucion;

end procedure
