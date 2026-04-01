--- Renovacion Automatica. Proceso de excepciones
--- Creado 02/03/2009 por Armando Moreno

drop procedure sp_pro329;

create procedure "informix".sp_pro329(a_no_poliza char(10))
returning char(8);

define _gerarquia     smallint;
define _centro_costo  char(3);
define _cod_sucursal  char(3);
define _jera,_renglon smallint;
define _tipo_ramo     char(1);
define _usuario       char(8);

select cod_sucursal
  into _cod_sucursal
  from emipomae
 where no_poliza = a_no_poliza;

select centro_costo
  into _centro_costo
  from insagen
 where codigo_agencia  = _cod_sucursal
   and codigo_compania = '001';

foreach
	select renglon
	  into _renglon
	  from emideren
	 where no_poliza = a_no_poliza
	   and renglon   <> 11	--cobros

	foreach
		select tipo_ramo
		  into _tipo_ramo
		  from emiredis
		 where renglon = _renglon

		foreach
			select gerarquia,
				   usuario
			  into _jera,
			       _usuario
			  from emiredis
			 where cod_sucursal = _centro_costo
			   and tipo_ramo    = _tipo_ramo
			 order by gerarquia desc

			if _jera <> 0 then
				return _usuario;
			end if
		end foreach

	end foreach

end foreach

if _usuario is null then

	select usuario_fideliza
 	  into _usuario
	  from emirepar;

end if

return _usuario;

end procedure;
