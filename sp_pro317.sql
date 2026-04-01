--- Renovacion Automatica. Proceso de excepciones
--- Creado 02/03/2009 por Armando Moreno

drop procedure sp_pro317;

create procedure "informix".sp_pro317()
returning integer;

define _reg integer;

ON EXCEPTION IN(-206)

	create temp table tmp_reaut(
	usuario		char(8),
	no_poliza	char(10),
	renglon     smallint,
	tipo_ramo   char(1),
	gerarquia   smallint default 0
	);

    CREATE INDEX i_tmp_reaut1 ON tmp_reaut(no_poliza);
END EXCEPTION

select count(*)
  into _reg
  from tmp_reaut;

return 0;
end procedure;
