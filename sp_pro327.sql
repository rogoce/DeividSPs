--- Renovacion Automatica. Proceso de excepciones
--- Creado 02/03/2009 por Armando Moreno

drop procedure sp_pro327;

create procedure "informix".sp_pro327(a_centro_costo char(3), a_tipo_ramo char(1), a_renglon smallint, a_usuario char(8))
returning smallint;


define _gerarquia smallint;

select gerarquia
  into _gerarquia
  from emiredis
 where cod_sucursal = a_centro_costo
   and tipo_ramo    = a_tipo_ramo
   and usuario      = a_usuario
   and renglon      = a_renglon;

return _gerarquia;

end procedure;
