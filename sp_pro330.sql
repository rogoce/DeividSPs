--- Renovacion Automatica. Proceso de excepciones
--- Creado 02/03/2009 por Armando Moreno

drop procedure sp_pro330;

create procedure "informix".sp_pro330(a_no_poliza char(10))
returning smallint;

define _gerarquia     smallint;
define _centro_costo  char(3);
define _cod_sucursal  char(3);
define _jera		  smallint;
define _tipo_ramo     char(1);
define _usuario       char(8);
define _renglon       smallint;
define _activo        smallint;

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

	select activo,
	       renglon
	  into _activo,
	  	   _renglon
	  from emideren
	 where no_poliza = a_no_poliza
	 order by activo

	if _activo = 0 then

		foreach

			select usuario
			  into _usuario
			  from emiredis
			 where cod_sucursal = _centro_costo
			   and renglon      = _renglon

			exit foreach;

		end foreach

	else

		foreach

			select activo,
			       renglon
			  into _activo,
			  	   _renglon
			  from emideren
			 where no_poliza = a_no_poliza

		    foreach
		   	
				select usuario,
				       gerarquia
				  into _usuario,
				       _gerarquia
				  from emiredis
				 where cod_sucursal = _centro_costo
				   and renglon      = _renglon
				 order by gerarquia desc

				exit foreach;

			end foreach

			exit foreach;

		end foreach

	end if

	update emirepo
	   set user_added = _usuario
	 where no_poliza  = a_no_poliza;

	exit foreach;

end foreach

return 0;

end procedure;
