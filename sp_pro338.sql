-- Procedure que determina cuales facturas han cambiado
-- desde que se crearon

-- Creado    : 31/07/2002 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 31/07/2002 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_pro338;

create procedure sp_pro338(a_no_poliza char(10), a_no_endoso char(5), a_no_unidad char(5))
returning smallint,
          char(50);

define _prima_suscrita	dec(16,2);
define _suma_asegurada	dec(16,2);

define _no_cambio		smallint;
define _cod_cober_reas	char(3);
define _orden			smallint;
define _cod_contrato	char(5);
define _porc_partic		dec(16,5);

select prima_suscrita,
       suma_asegurada
  into _prima_suscrita,
	   _suma_asegurada
  from endeduni
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso
   and no_unidad = a_no_unidad;

select max(no_cambio)
  into _no_cambio
  from emireaco
 where no_poliza = a_no_poliza
   and no_unidad = a_no_unidad;

foreach
 select cod_cober_reas,
		orden,
		cod_contrato,
		porc_partic_prima
   into _cod_cober_reas, 
        _orden,
		_cod_contrato,
		_porc_partic
   from emireaco
 where no_poliza = a_no_poliza
   and no_unidad = a_no_unidad
   and no_cambio = _no_cambio

	insert into emifacon
	values (a_no_poliza, 
	        a_no_endoso, 
	        a_no_unidad, 
	        _cod_cober_reas, 
	        _orden, 
	        _cod_contrato, 
	        null, 
	        _porc_partic, 
	        _porc_partic, 
	        _suma_asegurada * _porc_partic / 100,
	        _prima_suscrita * _porc_partic / 100,
			0,
			0
	        );

end foreach

return 0, "Actualizacion Exitosa";

end procedure
