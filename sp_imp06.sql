-- Procedimiento para el resumen de Coberturas para Flota
--
-- Creado    : 05/01/2000 - Autor: Edgar E. Cano G.
-- Modificado: 05/01/2000 - Autor: Edgar E. Cano G.
--
-- copia del sp_pro44a para la impresion Autor: Federico Coronado 18/12/2012
-- Adaptado para que el sistema lea desde las tablas de emision
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_imp06;

create procedure "informix".sp_imp06(a_poliza char(10), a_endoso char(5))
returning	smallint,			 -- _orden
			char(50),			 -- _nom_cobertura
			dec(16,2);			 -- _prima

define _cod_cobertura    char(5);
define _orden	         int;
define _nom_cobertura    char(50);
define _prima		     dec(16,2);
define _count_cobertura  smallint;

begin

set isolation to dirty read;

-- set debug file to "sp_pro44.trc";
-- trace on;

if a_poliza = '1227015' then
	select x.cod_cobertura,
	   sum(x.prima) prima
	  from endedcob x, endedmae e
	 where x.no_poliza = e.no_poliza
	   and x.no_endoso = e.no_endoso
	   and e.no_poliza = a_poliza
	   and no_unidad in (select no_unidad from endeduni where no_poliza = a_poliza and no_endoso = '00000')
	   and no_unidad in (select no_unidad from emipouni where no_poliza = a_poliza)
	   and e.actualizado = 1
	 group by x.cod_cobertura
	 into temp tmp1;

else
	if a_poliza = '1703305' then  --SD#3683 jaquelin poliza especial
		select x.cod_cobertura,
		   sum(x.prima) prima
		  from endedcob x, endedmae e
		 where x.no_poliza = e.no_poliza
		   and x.no_endoso = e.no_endoso
		   and e.no_poliza = a_poliza
		   and no_unidad in (select no_unidad from endeduni where no_poliza = a_poliza )
		   and e.actualizado = 1
		 group by x.cod_cobertura
		 into temp tmp1;

	else
		select x.cod_cobertura,
			   sum(x.prima) prima
		  from emipocob x
		 where x.no_poliza = a_poliza
		 group by x.cod_cobertura
		  into temp tmp1;
	end if
end if

foreach
    select cod_cobertura,
		   prima
	  into _cod_cobertura,
		   _prima
      from tmp1

	select min(x.orden)
	  into _orden
	  from tmp1 z, endedcob x
	 where z.cod_cobertura = x.cod_cobertura
	   and x.cod_cobertura = _cod_cobertura
       and x.no_poliza = a_poliza
       and x.no_endoso = a_endoso;

    select nombre
	  into _nom_cobertura
	  from prdcober
	 where cod_cobertura = _cod_cobertura;

	SELECT count(*)
      into _count_cobertura
	  FROM prdcober, emipocob
	 WHERE prdcober.cod_cobertura = emipocob.cod_cobertura
	   and no_poliza 	 = a_poliza
	   and emipocob.cod_cobertura = _cod_cobertura
	   and (nombre like '%LESIONES CORPORALES%' or nombre like '%A LA PROPIEDAD AJENA%');

	if _count_cobertura > 0 then
		let _nom_cobertura = "*"||_nom_cobertura;
	end if


	return _orden,
		   _nom_cobertura,
		   _prima
		   with resume;
end foreach

drop table tmp1;

end
end procedure